# Task Board — Auditoria Completa (Reconstrução de Contexto)

> Escopo desta etapa: **auditoria técnica apenas** (sem implementação funcional nova).

## 1) Reconstrução de contexto (docs existentes)

### 1.1 Inventário de documentação em `docs/`
Foi realizada varredura de todos os `.md` em `docs/` para reconstrução de contexto (incluindo `docs/wiki/*` e `docs/ai/*`).

Documentos diretamente relevantes para este tema:
- `docs/TaskBoard_Mapeamento_Inicial.md`
- `docs/taskboard.md`
- `docs/Weekly_Task_Board_Documentacao_Tecnica.md`
- `docs/BattlePass_Documentacao_Tecnica.md`

### 1.2 Confirmação de documentação derivada
- **COMPLETE_CUSTOM_CLIENT**: existe documentação derivada (ex.: `Weekly_Task_Board_Documentacao_Tecnica.md`, `BattlePass_Documentacao_Tecnica.md`).
- **Weekly Tasks**: existe documentação dedicada.
- **Bounty Tasks**: existe documentação dedicada/embutida em TaskBoard docs.
- **Battle Pass**: existe documentação dedicada.

### 1.3 Consistência com a conclusão anterior (“COMPLETE_CUSTOM_CLIENT não tem TaskBoard”)
A conclusão anterior permanece consistente com a auditoria textual:
- `TaskBoard_Mapeamento_Inicial.md` já declarava ausência de módulos explícitos `taskboard/weekly/bounty` no `COMPLETE_CUSTOM_CLIENT`.
- Nova busca textual no diretório também não encontrou ocorrências para `taskboard`, `game_taskboard`, `game_weeklytasks`, `bounty`.

---

## 2) Auditoria Cliente (`OTCLIENT/`)

## 2.1 Arquivos modificados recentemente (último commit)
- `otclient/modules/game_taskboard/protocol.lua`
- `otclient/modules/game_taskboard/state_store.lua`
- `otclient/modules/game_taskboard/taskboard_controller.lua`

## 2.2 Arquivos criados recentemente (impacto cliente indireto)
- Nenhum arquivo novo dentro de `otclient/modules/game_taskboard/` no último commit.

## 2.3 Diferenças estruturais introduzidas
### a) State Store
- O `state_store` deixou de ser minimalista e passou a armazenar:
  - `bounties`, `weeklyTasks`, `weeklyProgress`, `multiplier`, `rerollState`, `shopPurchases`, `shopOffers`.
- Foi introduzido `applySync(payload)` para hidratação completa via `sync`.
- `reduceDelta(delta)` passou a tratar eventos `weekRotated`, `taskUpdated`, `progressUpdated`, `multiplierUpdated`, `shopUpdated`.

### b) Controller
- O `taskboard_controller` saiu de render mockado para renderização por dados reais de estado.
- Fluxos conectados no cliente:
  - `selectDifficulty`
  - `reroll`
  - `deliver`
  - `buy`
  - `claimBounty`
  - `claimDaily`
- Renderização efetiva de:
  - cards de bounty
  - grid de weekly kill/delivery
  - shop cards
  - resumo de progresso/multiplicador

### c) Protocolo
- `protocol.lua` passou a usar parse resiliente com `pcall(json.decode, buffer)`.
- Continua no opcode `242`, com envelopes `sync/delta`.

## 2.4 Duplicação com `game_weeklytasks/`
- Existe duplicação funcional potencial:
  - `game_taskboard` contém aba Weekly + Shop + Bounty.
  - `game_weeklytasks` mantém implementação standalone de Weekly + Shop (opcodes 240/241).
- Isso gera coexistência de duas UIs para “weekly tasks” com regras e payloads diferentes.

## 2.5 Módulos órfãos / parcialmente órfãos
- `taskboard_viewmodel.lua` continua listado no `.otmod`, mas o controller atual não depende mais dele no fluxo principal.
- Risco: arquivo permanecer carregado sem função prática (dívida técnica, não quebra imediata).

---

## 3) Auditoria Servidor (`CRYSTALSERVER/`)

## 3.1 Arquivos alterados recentemente
- `crystalserver/data/modules/taskboard/constants.lua`
- `crystalserver/data/modules/taskboard/infrastructure/network.lua`
- `crystalserver/data/modules/taskboard/application/service.lua`
- `crystalserver/data/modules/taskboard/application/bounty_service.lua`
- `crystalserver/data/modules/taskboard/application/shop_service.lua`

## 3.2 Arquivo novo criado
- `crystalserver/data/scripts/globalevents/system/taskboard_bootstrap.lua`

## 3.3 Bootstrap automático
- Sim, foi criado bootstrap que faz `dofile(.../modules/taskboard/init.lua)` se `TaskBoard` ainda não existir.
- Isso garante carregamento do módulo sem alterar diretamente o core do módulo taskboard.

## 3.4 Alteração de fluxo ExtendedOpcode 242
- `constants.lua` adicionou ações:
  - `CLAIM_BOUNTY = "claimBounty"`
  - `CLAIM_DAILY = "claimDaily"`
- `network.lua` passou a rotear essas ações para o service.
- `service.lua` passou a expor wrappers `claimBounty` e `claimDaily`.

## 3.5 Conflitos com legado (`weekly_tasks.lua` antigo)
- O sistema antigo de weekly tasks permanece ativo no repositório (`data/scripts/lib/weekly_tasks.lua`, opcodes 240/241).
- O novo taskboard usa opcode 242.
- **Não há colisão direta de opcode** entre weekly legacy (240/241) e taskboard (242), porém há duplicação de domínio de negócio (weekly + shop) em duas stacks.

## 3.6 Lógica potencialmente não usada / redundante
- `TaskBoardRepository` segue com stubs (persistência incompleta), então parte da arquitetura “produção completa” ainda depende só de cache em memória.
- Há risco de funcionalidades paralelas (legacy weekly vs taskboard weekly) divergirem com o tempo.

---

## 4) Auditoria de Assets

## 4.1 Assets realmente referenciados por `game_taskboard`
Referências atuais do módulo:
- `/images/topbuttons/questlog`
- `/images/ui/panel_flat`

## 4.2 Existência em `OTCLIENT/data/images/`
- `otclient/data/images/topbuttons/questlog.png` ✅
- `otclient/data/images/ui/panel_flat.png` ✅

## 4.3 Necessidade de copiar assets do `COMPLETE_CUSTOM_CLIENT`
- Para o estado atual do módulo `game_taskboard`, **não** há referência direta a assets do `COMPLETE_CUSTOM_CLIENT`.
- Portanto, **não há asset faltando crítico** para este layout atual.

---

## 5) Auditoria de Protocolo

## 5.1 Opcode 242
- O `TaskBoard` já está definido em `TaskBoardConstants.OP_CODE_TASKBOARD = 242`.
- Não foi observado outro módulo de ExtendedOpcode usando `242` no mesmo fluxo de registro de taskboard.

## 5.2 Risco de colisão
- No projeto existem outros usos numéricos de `242` (protocol IDs/constantes de outros domínios), mas não equivalem automaticamente a ExtendedOpcode taskboard.
- No escopo de ExtendedOpcode auditado, o acoplamento do TaskBoard em `242` está consistente.

## 5.3 Compatibilidade JSON cliente-servidor
### Compatível (geral)
- Envelope `sync/delta` alinhado.
- Actions principais alinhadas (`open`, `selectDifficulty`, `reroll`, `deliver`, `buy`, `claimBounty`, `claimDaily`).

### Ponto crítico detectado
- `weekly_service.recalcProgress` grava `cache.multiplier = multiplierMeta.value` (número).
- O cliente (`state_store`) trata `multiplier` como mapa/objeto (`cloneMap`) e o controller lê `board.multiplier.value`.
- Isso cria risco de inconsistência entre payload de `sync` e consumo do cliente quando `multiplier` chega como número em vez de objeto.

---

## 6) Matriz de risco

## 6.1 Riscos de conflito
- **Médio**: coexistência `game_weeklytasks` (legacy UI) e `game_taskboard` (UI nova) com escopos sobrepostos.
- **Baixo**: colisão direta de opcode entre weekly legacy (240/241) e taskboard (242) não observada.

## 6.2 Riscos de duplicação
- **Alto**: duas implementações de weekly/shop em cliente e servidor (legacy + taskboard).

## 6.3 Riscos de regressão
- **Médio/Alto**: divergência de contrato do campo `multiplier` (number vs object).
- **Médio**: persistência ainda stubada em `TaskBoardRepository` (estado pode não sobreviver reinícios, dependendo do ambiente de execução real).

## 6.4 Pontos frágeis
- Contrato de payload parcialmente inconsistente (`multiplier`).
- Arquivo `taskboard_viewmodel.lua` potencialmente sem uso prático após refatoração do controller.
- Estratégia de convivência com legado weekly ainda não formalizada.

## 6.5 Pontos estáveis
- Wiring básico do opcode 242 client/server está montado.
- Fluxos de ações principais estão roteados de ponta a ponta.
- Assets atuais do módulo existem localmente no `otclient/data/images`.
- Bootstrap automático para carregar taskboard no servidor foi introduzido.

---

## 7) Conclusão executiva

1. **O que foi alterado:** controller/state/protocol no cliente e dispatcher/services/constantes no servidor, além de bootstrap e documentação inicial.
2. **O que já existia:** infraestrutura base de taskboard no servidor e módulo `game_taskboard` no cliente já estavam presentes, mas com partes mockadas/incompletas.
3. **O que foi criado do zero no último ciclo:** documento de mapeamento inicial e bootstrap de carregamento, além de novos handlers de claim diário/bounty.
4. **Se `COMPLETE_CUSTOM_CLIENT` realmente possui o sistema:** auditoria atual mantém conclusão de que não há módulo explícito `TaskBoard/Weekly/Bounty` com essas nomenclaturas naquele diretório.
5. **Inconsistências com docs anteriores:** existe desalinhamento potencial entre status “funcional v1” e riscos reais detectados (especialmente contrato de `multiplier` e convivência com legado).
6. **Assets faltando:** não foram detectados faltantes para os assets atualmente referenciados pelo `game_taskboard`.
7. **Segurança estrutural do sistema:** estrutura base está montada, porém **ainda com risco médio/alto** por duplicação de domínio (legacy + novo) e contrato de payload não totalmente estável.

