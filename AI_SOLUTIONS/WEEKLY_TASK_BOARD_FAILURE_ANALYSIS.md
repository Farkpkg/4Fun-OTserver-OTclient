# WEEKLY TASK BOARD — FAILURE ANALYSIS

## ETAPA ZERO — CONTEXTO OPERACIONAL (OBRIGATÓRIO)

### Estado operacional atual do projeto
- O projeto está em **CURRENT_STATE**: controles realmente ativos são os executáveis no código/CI atual; o restante fica como manual/parcial/target state.
- Governança arquitetural automática dedicada **não está ativa** como gate bloqueante; os gates automáticos reais são build/lint/test existentes.
- `TARGET_STATE` é explícito como não ativo e não pode ser usado como bloqueio real.

### Invariantes ativos
- Invariantes de sistema existem e devem ser respeitadas (autoridade server-side, simetria de protocolo, persistência com trilha de evolução, etc.), mas com validação majoritariamente manual.

### Gates reais vs. manuais
- **Reais (automáticos):** pipelines de qualidade (build/lint/test) já existentes.
- **Manuais:** checklist de mudança, análise de impacto, revisão de invariantes e ADR/proposta quando aplicável.
- **Não-real/target:** AIS completo, simulação estrutural, score preditivo, dashboard automático, bloqueios automáticos de governança.

### Limites de atuação
- Não considerar componentes `TARGET_STATE` como enforcement real.
- Não expandir arquitetura nem criar subsistemas novos para corrigir o problema.

---

## Escopo investigado
Sistema **Weekly Task Board** no fluxo completo:

`UI (otclient) → Evento/opcode → Processamento (server Lua) → Persistência (MySQL/Lua DB layer) → Re-renderização (opcode server→client)`

Arquivos principais verificados:
- `otclient/modules/game_taskboard/taskboard.lua`
- `otclient/modules/game_taskboard/taskboard.otui`
- `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua`
- `crystalserver/data/scripts/task_board/taskboard_manager.lua`
- `crystalserver/data/scripts/task_board/taskboard_db.lua`
- `crystalserver/data/scripts/task_board/taskboard_events.lua`
- `docs/04-systems/task-board-bounty-system.md`

---

## 1) Cruzamento com governança e regras

### 1.1 SYSTEM_INVARIANTS
**Fato comprovado:**
- Contrato de opcodes está simétrico entre cliente e servidor para weekly (`69–72`) e payloads básicos.
- Estado de progressão semanal é processado no servidor (autoridade server-side), com cliente apenas enviando intenção.

**Observação de risco:**
- A dificuldade semanal usada no cálculo de recompensa não está persistida de forma robusta; depende de estado em memória (`selectedDifficulty`) que reinicia em relog. Isso gera inconsistência de regra/recompensa após reconexão.

### 1.2 UI_CANONICAL_RULES
**Fato comprovado:**
- A UI weekly é recriada dinamicamente (`destroyChildren + createWidget`) em `refreshWeekly()`.
- Painéis `killGrid` e `deliveryGrid` não possuem layout definido em `.otui`, nem layout programático no Lua.

**Impacto:**
- Os cards podem ser renderizados empilhados no mesmo ponto (efeito visual de “não funciona corretamente”).

### 1.3 CHANGE_IMPACT_PROTOCOL
**Fato comprovado:**
- A feature está implementada em múltiplas superfícies críticas (cliente UI/Lua, servidor Lua, persistência SQL).
- Não foi encontrada evidência no repositório de execução formal do gate manual (checklist/registro de impacto específico do Task Board).

### 1.4 OPERATIONAL_STATE_DECLARATION
**Fato comprovado:**
- O processo exige tratar governança estrutural desta feature como **manual/parcial**; não há enforcement automático dedicado para esse tipo de desvio de consistência.

---

## 2) Mapeamento do fluxo completo (UI → evento → processamento → persistência → re-render)

### A) Troca de dificuldade semanal
1. **UI:** Combo `comboDifficulty` dispara `sendOpcode(69)`.
2. **Evento:** server recebe opcode 69 em `#extended_opcode.lua`.
3. **Processamento:** `TaskBoard.selectWeeklyDifficulty()` atualiza `data.selectedDifficulty`, rerolla tasks e rebuild semanal.
4. **Persistência:** weekly tasks e bounty tasks são salvas, mas `selectedDifficulty` não tem coluna persistente dedicada.
5. **Re-render:** server envia `BOUNTY_DATA` + `WEEKLY_DATA`; client atualiza UI.

### B) Progresso de kill semanal
1. **UI:** jogador mata criatura no jogo (evento world).
2. **Evento:** `taskBoardKill.onDeath()` chama `TaskBoard.onCreatureKill()`.
3. **Processamento:** compara nome da criatura e incrementa `currentCount`; ao completar, aplica recompensa.
4. **Persistência:** `TaskBoardDB.saveWeeklyTask(... task_type=0 ...)`.
5. **Re-render:** server envia `WEEKLY_DATA`.

### C) Entrega semanal
1. **UI:** botão `Deliver` envia opcode 70 com índice.
2. **Evento:** server recebe e encaminha para `TaskBoard.weekly(..., "delivery", index)`.
3. **Processamento:** remove itens do jogador, marca task completa e recompensa.
4. **Persistência:** `TaskBoardDB.saveWeeklyTask(... task_type=1 ...)`.
5. **Re-render:** `sendWeeklyData()`.

---

## 3) Fato comprovado vs hipótese vs violação estrutural

### 3.1 Fatos comprovados no código
1. `selectedDifficulty` inicia em `0` no `ensureData()` e não é carregado de persistência dedicada.
2. Recompensa de kill semanal usa `selectedDifficulty` em memória para buscar `killTaskHuntingPoints`.
3. Após relog, weekly tasks persistidas podem continuar da dificuldade anterior, mas `selectedDifficulty` volta para `beginner`.
4. `killGrid` e `deliveryGrid` não têm layout definido no `.otui` e não recebem layout via Lua.

### 3.2 Hipóteses técnicas (derivadas)
1. Usuário percebe “weekly quebrado” por receber recompensa incompatível com dificuldade efetiva da semana após relog.
2. Usuário percebe “weekly quebrado” visualmente porque cards aparecem sobrepostos/sem organização adequada.

### 3.3 Violações estruturais
1. **Inconsistência estado em memória ↔ estado persistido** para dificuldade semanal (drift funcional pós-relog).
2. **Inconsistência UI ↔ lógica de dados** por ausência de layout de grade para renderização dinâmica.

---

## 4) Verificação de formalização e estado operacional da feature

- **Feature registrada formalmente?**
  - Sim, há documentação funcional (`docs/04-systems/task-board-bounty-system.md`) e presença em manifests de cliente/servidor.

- **Classificação operacional correta?**
  - Parcialmente: implementação real existe, porém o controle de consistência arquitetural da feature depende de processo manual (coerente com `OPERATIONAL_STATE_DECLARATION`).

- **Gate manual se exigido foi comprovado?**
  - Não foi encontrada evidência explícita no repositório (registro/checklist específico) comprovando execução formal do gate manual para a introdução/alteração desta feature.

---

## 5) Veredito técnico classificado

**Veredito principal:** **E) Problema de persistência**
- Causa raiz: dificuldade semanal usada na regra de recompensa depende de estado volátil (`selectedDifficulty`) sem persistência robusta.

**Vereditos secundários:**
- **F) Inconsistência UI ↔ lógica** (renderização weekly sem layout de grid).
- **D) Drift estrutural** (estado semanal persistido e estado operacional em memória podem divergir após reconexão).

Não há evidência forte de quebra de protocolo (portanto não classificado como falha primária de integração de opcode).

---

## 6) Correção mínima proposta (sem expandir arquitetura)

### 6.1 Correção de causa raiz (persistência)
Aplicar **uma** das opções mínimas:
1. **Sem migration (mais mínima):** ao carregar dados (`ensureData`), inferir `selectedDifficulty` a partir de `bountyTasks[1].difficulty` (ou maioria dos slots válidos) quando existir.
2. **Com persistência explícita (mais robusta, ainda mínima):** criar coluna/registro para `selected_difficulty` no estado do taskboard e salvar ao trocar dificuldade.

Recomendação: opção **1** como hotfix imediato (menor impacto), opção **2** como estabilização definitiva.

### 6.2 Correção de UI mínima
- Definir layout grid em `killGrid` e `deliveryGrid` (ex.: 3x2 com `cell-size` compatível com `weeklyKillCard`) para garantir re-render previsível.

---

## 7) Conclusão executiva
O “weekly task board” falha principalmente por **desalinhamento entre persistência e estado em memória da dificuldade semanal**, causando cálculo incorreto de recompensa em sessões subsequentes. Em paralelo, a UI semanal possui um defeito estrutural de layout que reforça a percepção de quebra funcional. A correção mínima deve atacar primeiro a persistência da dificuldade e, em seguida, ajustar o layout dos grids semanais.
