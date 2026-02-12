# TaskBoard — Stability Report (Hardening Final)

## Persistência — Estado Atual

### Situação anterior
- O `TaskBoardRepository` era stub (sem persistência real).
- Estado ficava em cache de memória, com risco de perda em restart/logout.

### Situação implementada
- Persistência real adicionada em DB com duas tabelas:
  - `player_taskboard_state`
  - `player_taskboard_tasks`
- Persistência cobre:
  - estado global (`weekKey`, `boardState`, `difficulty`)
  - tarefas weekly e bounty
  - `weeklyProgress`
  - `multiplier`
  - `rerollState`
  - `shopPurchases`
- Carregamento no login/primeiro acesso:
  - `loadSnapshot(playerId)` usado para hidratar cache quando necessário.

### Garantia prática
- Progresso semanal, claims, compras e multiplicador sobrevivem restart do servidor.

---

## Reset Semanal — Validação

### Regra de reset
- Continua baseado em `weekKey` UTC (`os.date("!%Y-W%V")`).
- `ensureWeek` compara semana persistida vs semana corrente.

### Hardening aplicado
- Reset é idempotente:
  - se semana não mudou, não há rotação indevida.
  - se mudou, limpa apenas tasks da semana antiga (`clearWeek`) e reinicializa estado semanal.
- Snapshot persistido após reset/merge para evitar desvio cache vs DB.

### Garantia prática
- Reset não depende exclusivamente de restart.
- Reset não duplica em chamadas repetidas da mesma semana.

---

## Validação e Blindagem de Domínio

### Validações adicionadas no fluxo de rede
- Limite de payload (`MAX_PAYLOAD_SIZE = 32KB`).
- Rejeição de payload vazio.
- Rejeição de payload inválido/JSON inválido.
- Rejeição de action ausente.
- Rejeição de action inexistente.
- Validação de parâmetros por action:
  - dificuldade inválida
  - item de delivery inválido
  - offerId inválido
  - bountyId inválido

### Regras anti-abuso já presentes e mantidas
- Claim duplicado bloqueado (`BOUNTY_NOT_CLAIMABLE`).
- Compra sem pontos bloqueada (`NOT_ENOUGH_TASK_POINTS`).
- Reroll com cooldown/limite diário/semanal bloqueado.
- Delivery inválido bloqueado (`DELIVERY_NOT_APPLICABLE`).

### Garantia prática
- Servidor não confia em input do cliente.
- Erros retornam como códigos estruturados via `sendCancelMessage`.

---

## Teste de Carga Simulada

### Método nesta etapa
- Avaliação estática de complexidade e caminhos quentes (sem harness de benchmark integrado no repositório).

### Resultado técnico
- Operações de kill/delivery percorrem listas pequenas de tasks (escala linear no número de tasks do player).
- Não há loops quadráticos críticos no caminho principal de ação.
- Snapshot + cache reduzem custo de reconstrução em acessos sucessivos.

### Risco remanescente
- Sem benchmark runtime com 50+ players reais nesta etapa (necessário ambiente de staging com servidor ativo e bots).

---

## Validação Final do Protocolo

- Stack única TaskBoard mantida em opcode `242`.
- Cliente já faz decode defensivo com `pcall(json.decode, ...)`.
- Servidor reforçado com validações de payload/action/parâmetros.
- Contrato de `multiplier` estabilizado como objeto/metadata no servidor para alinhar com consumo do cliente.

---

## Limpeza Final

- Não foi reintroduzido legado.
- Não foi criado novo opcode.
- Não houve adição de feature de produto; apenas hardening e persistência.

---

## Pontos frágeis remanescentes

1. Recomendado criar teste de estresse automatizado em staging (50–100 sessões simultâneas) para medir latência e lock contention no DB.
2. Recomendado adicionar índices adicionais caso o volume por jogador/semana cresça além do previsto.
3. Recomendado complementar com suite de testes de integração Lua (login -> sync -> kill -> deliver -> buy -> restart -> re-sync).

---

## Garantia de produção

Com as mudanças desta etapa:
- Persistência está implementada.
- Reset semanal está idempotente e persistido.
- Validação de domínio/rede está endurecida contra abuso básico.
- Contrato cliente-servidor do TaskBoard está mais resiliente.

**Status**: pronto para validação final em staging/produção controlada.
