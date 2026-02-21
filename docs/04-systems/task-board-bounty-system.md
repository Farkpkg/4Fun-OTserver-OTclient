# Task Board / Bounty Tasks System

## Objetivo
O **Task Board** implementa um sistema completo de progressão com:
- **Bounty Tasks diárias** (3 slots com reroll, tier e recompensas).
- **Weekly Tasks** (kill/delivery + progressão semanal).
- **Preferred / Unwanted list** para influenciar sorteio.
- **Talisman** com upgrades por Bounty Points.
- **Shop** com compra por Hunting Task Points.

---

## Arquitetura ponta a ponta

## 1) Cliente OTClient

### Módulo visual/lógico
- `otclient/modules/game_taskboard/taskboard.otmod` registra módulo e ciclo `init/terminate`.
- `otclient/modules/game_taskboard/taskboard.otui` define toda UI (abas Bounty, Weekly, Shop, Preferred, popup semanal).
- `otclient/modules/game_taskboard/taskboard.lua` controla:
  - estado local,
  - leitura de opcodes do servidor,
  - envio de ações do jogador ao servidor,
  - atualização dinâmica dos widgets.

### Fluxo de dados no cliente
1. Servidor envia opcode **OPEN (50)** → cliente abre janela.
2. Servidor envia payloads de:
   - **BOUNTY_DATA (51)**,
   - **WEEKLY_DATA (52)**,
   - **SHOP_DATA (53)**,
   - **PREFERRED (54)**,
   - **TALISMAN (55)**,
   - **CURRENCIES (56)**,
   - **RESULT (57)**.
3. Cliente renderiza os painéis e envia ações usando opcodes 60–72.

---

## 2) Servidor CrystalServer

### Núcleo do sistema
- `crystalserver/data/scripts/task_board/taskboard_manager.lua`
  - regra de negócio principal,
  - geração de tasks,
  - validação de ações,
  - recompensa e persistência.

### Configuração de gameplay
- `crystalserver/data/scripts/task_board/taskboard_config.lua`
  - dificuldades (beginner/adept/expert/master),
  - criaturas elegíveis,
  - recompensas,
  - custos de slots extras/talisman,
  - itens da weekly delivery e shop.

### Persistência
- `crystalserver/data/scripts/task_board/taskboard_db.lua`
  - camada SQL para load/save de moedas, tasks, talisman, preferred/unwanted e slots extras.

### Eventos e entrada
- `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua`
  - dispatcher dos opcodes 60–72 para `TaskBoard.*`.
- `crystalserver/data/scripts/task_board/taskboard_events.lua`
  - contabiliza kills em `TaskBoard.onCreatureKill`.
- `crystalserver/data-crystal/npc/task_board.lua`
  - NPC que abre a interface.
- `crystalserver/data/scripts/task_board/taskboard_weekly_reset.lua`
  - reset semanal (segunda-feira UTC 00:00).
- `crystalserver/data/scripts/talkactions/god/bountytask.lua`
  - comando administrativo `/bountytask`.

---

## 3) Banco de dados

Definições em `crystalserver/schema.sql`:
- `player_bounty_tasks`
- `player_weekly_tasks`
- `player_talisman`
- `player_task_preferred`
- `player_task_extra_slots`
- `player_task_currencies`

### Relações principais
- Todas vinculadas por `player_id -> players.id` com `ON DELETE CASCADE`.
- Chaves compostas por slot/tipo para evitar duplicidade por jogador.

---

## Protocolo (Extended Opcodes)

### Servidor → Cliente
- `50 OPEN`
- `51 BOUNTY_DATA`
- `52 WEEKLY_DATA`
- `53 SHOP_DATA`
- `54 PREFERRED`
- `55 TALISMAN`
- `56 CURRENCIES`
- `57 RESULT`

### Cliente → Servidor
- `60 SELECT`
- `61 REROLL`
- `62 CLAIM_DAILY`
- `63 PREF_SET`
- `64 PREF_CLEAR`
- `65 UNWANTED_CLEAR`
- `66 EXTRA_SLOT`
- `67 TALISMAN_UPGRADE`
- `68 SHOP_BUY`
- `69 WEEKLY_DIFFICULTY`
- `70 WEEKLY_DELIVER`
- `71 WEEKLY_UNLOCK_KILL`
- `72 WEEKLY_UNLOCK_DELIVER`

---

## Fluxos funcionais críticos

### A) Seleção e progresso de Bounty Task
1. Jogador seleciona slot (opcode 60).
2. Servidor valida e grava task ativa/estado.
3. Kills são capturadas por `taskboard_events.lua`.
4. `TaskBoard.onCreatureKill` incrementa progresso e finaliza quando necessário.
5. Servidor envia refresh de moedas/estado/result.

### B) Preferred / Unwanted
1. Cliente abre janela preferred (ping opcode 63 sem payload).
2. Servidor responde com `PREFERRED (54)` contendo listas e catálogo.
3. Cliente envia set/clear conforme interação.
4. Servidor salva em `player_task_preferred`.

### C) Weekly
1. Jogador define dificuldade semanal (opcode 69).
2. Servidor recalcula tarefas e recompensas semanais.
3. Entregas usam opcode 70.
4. Unlock permanente kill/delivery via 71/72.
5. Reset global semanal limpa `player_weekly_tasks` e recalcula estado.

### D) Shop e Talisman
- Compra (68) valida HTP e aplica recompensa.
- Upgrade talisman (67) valida BP e nível/custo.

---

## Dados cruzados (arquivos que interagem diretamente)

- Cliente UI/Lógica:
  - `otclient/modules/game_taskboard/taskboard.otui`
  - `otclient/modules/game_taskboard/taskboard.lua`
- Servidor Dispatcher:
  - `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua`
- Regra de negócio:
  - `crystalserver/data/scripts/task_board/taskboard_manager.lua`
  - `crystalserver/data/scripts/task_board/taskboard_config.lua`
- Persistência:
  - `crystalserver/data/scripts/task_board/taskboard_db.lua`
  - `crystalserver/schema.sql`
- Entradas externas:
  - `crystalserver/data-crystal/npc/task_board.lua`
  - `crystalserver/data/scripts/task_board/taskboard_events.lua`
  - `crystalserver/data/scripts/task_board/taskboard_weekly_reset.lua`
  - `crystalserver/data/scripts/talkactions/god/bountytask.lua`

---

## Correções aplicadas nesta revisão

1. **Padronização visual OTClient**
   - Substituição de `align: center` por `text-align: center` nos labels do Task Board.
   - Padronização dos widgets de criatura para `UICreature`.

2. **Sincronização dificuldade cliente-servidor**
   - Combo de dificuldade agora envia opcode 69 ao alterar opção.
   - Cliente passa a refletir a dificuldade recebida em `BOUNTY_DATA` no combobox.

3. **Compatibilidade de bitwise no cliente**
   - Removida dependência rígida de `bit32` para parse de `extraSlots`.
   - Implementado fallback com `bit` e modo aritmético quando necessário.

---

## Checklist de operação

- [ ] Módulo `game_taskboard` carregado no cliente.
- [ ] `#extended_opcode.lua` registrado e ativo no servidor.
- [ ] Scripts de `task_board/` carregados.
- [ ] Tabelas SQL do Task Board criadas no banco.
- [ ] NPC `Task Board` disponível no mapa (ou outro gatilho de abertura).
- [ ] Evento semanal global habilitado.

---

## Referências adicionais
- Documento legado: `docs/weekly_bounty_system.md`.
- README local do módulo: `otclient/modules/game_taskboard/README.md`.
