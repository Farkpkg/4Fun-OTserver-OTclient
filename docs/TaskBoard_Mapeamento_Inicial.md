# Task Board — Mapeamento Inicial

## Observação crítica da fonte oficial

Foi feita varredura no `COMPLETE_CUSTOM_CLIENT/` procurando por `taskboard`, `weekly`, `bounty`, `game_weeklytasks`, `game_taskboard` e variações.

**Resultado:** não foram localizados arquivos específicos desse sistema dentro de `COMPLETE_CUSTOM_CLIENT/`.

Com isso, o mapeamento funcional foi realizado a partir dos módulos existentes em `OTCLIENT/` e `CRYSTALSERVER/`, que já contêm a base do Task Board.

---

## Estrutura de pastas identificada

### Cliente (`OTCLIENT/`)

- `otclient/modules/game_taskboard/`
  - `game_taskboard.otmod`
  - `taskboard.lua`
  - `protocol.lua`
  - `taskboard_controller.lua`
  - `taskboard_viewmodel.lua`
  - `state_store.lua`
  - `taskboard.otui`
  - `components/`
    - `bounty_card.otui`
    - `weekly_slot.otui`
    - `shop_card.otui`
    - `progress_track.otui`
    - `talisman_panel.otui`

- Legado/paralelo:
  - `otclient/modules/game_weeklytasks/`

### Servidor (`CRYSTALSERVER/`)

- `crystalserver/data/modules/taskboard/`
  - `init.lua`
  - `constants.lua`
  - `domain/`
  - `application/`
  - `infrastructure/`

- Scripts semanais antigos (coexistentes):
  - `crystalserver/data/scripts/creaturescripts/player/weekly_tasks.lua`
  - `crystalserver/data/scripts/lib/weekly_tasks.lua`
  - `crystalserver/data/weeklytasks/*`

---

## Fluxo de abertura da UI

1. Jogador clica no botão **Task Board** (`game_taskboard/taskboard.lua`).
2. Cliente abre `taskboard.otui` e envia ação `open` via ExtendedOpcode.
3. Servidor recebe opcode no módulo taskboard e retorna payload `sync`.

---

## Fluxo de recebimento de dados

1. Cliente registra opcode em `game_taskboard/protocol.lua`.
2. Servidor envia mensagens com envelope:
   - `type = "sync"` + estado completo.
   - `type = "delta"` + alterações incrementais.
3. Controller aplica estado em memória e atualiza widgets por aba (Bounty/Weekly/Shop).

---

## Fluxo de claim/reward

### Bounty

- Progresso avança em kills (`onKill` no servidor).
- Task completa muda para estado claimable.
- Claim é disparado por ação dedicada (`claimBounty` / `claimDaily`) e refletido via `delta.taskUpdated`.

### Weekly

- Tasks de kill e delivery atualizam progresso.
- Ao completar task, servidor incrementa:
  - Task Points
  - Soul Seals
- Progresso e multiplicador são recalculados e enviados via delta.

### Shop

- Compra enviada por ação `buy`.
- Servidor valida pontos, desconta saldo e envia eventos `progressUpdated` e `shopUpdated`.

---

## ExtendedOpcodes e protocolo

- **Opcode principal Task Board:** `242`
- Payload em JSON.
- Ações mapeadas:
  - `open`
  - `selectDifficulty`
  - `reroll`
  - `deliver`
  - `buy`
  - `claimBounty`
  - `claimDaily`

---

## Dependências com outros módulos

### Cliente

- `client_styles`
- `client_topmenu`
- `gamelib/protocolgame` (ExtendedOpcode)

### Servidor

- Sistema de `CreatureEvent` (login/kill/extendedopcode)
- Biblioteca JSON disponível no ambiente
- Cache em memória (`TaskBoardCache`) e repositório (stub atual)

---

## Assets utilizados

- OTUI usa painéis padrão (`/images/ui/panel_flat`)
- Ícones de item via widget `Item` (IDs enviados/definidos no cliente)
- Botão de menu utiliza `/images/topbuttons/questlog`

