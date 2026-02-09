<!-- tags: - game-systems - hunting-tasks - prey priority: high -->

## LLM Summary
- **What**: Separação entre os dois sistemas de hunt tasks existentes no projeto.
- **Why**: Evita confusão entre fluxo Global-like (Task Hunting/Prey) e fluxo customizado (Hunting Task via extended opcode).
- **Where**: crystalserver/src + otclient/src/modules.
- **How**: Mapeia nomes, tabelas, protocolo e pontos de entrada de cada sistema.
- **Extends**: Novas features devem declarar explicitamente qual sistema alvo.
- **Risks**: Misturar handlers/opcodes/tabelas entre sistemas causa bugs de persistência e UI.

[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Hunting Tasks

# Hunting Tasks (separação de sistemas)

## Visão geral
Atualmente existem **dois sistemas diferentes** de “tasks de hunt”:

1. **Task Hunting Global-like (Prey ecosystem)**
2. **Hunting Task customizado (novo backend em `hunting_task/`)**

Eles coexistem e **não devem ser tratados como o mesmo fluxo**.

---

## 1) Task Hunting Global-like (Prey ecosystem)

### Servidor (CrystalServer)
- Entrada de ação no game loop: `Game::playerTaskHuntingAction(...)`.
- Parser/execução principal no I/O legado de prey: `g_ioprey().parseTaskHuntingAction(...)`.
- Persistência principal na tabela `player_taskhunt` (legado global-like).

Arquivos-chave:
- `crystalserver/src/game/game.cpp`
- `crystalserver/src/io/ioprey.*`
- `crystalserver/schema.sql` (tabela `player_taskhunt`)

### Client (OTClient)
- Fluxo via protocolo nativo do jogo (`ProtocolGame::parseTaskHuntingBasicData` e `parseTaskHuntingData`).
- UI principal no módulo `game_prey` (mesma família funcional do prey/task hunting global).

Arquivos-chave:
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/modules/game_prey/prey.lua`
- `otclient/modules/game_prey/prey.otui`

### Protocolo
- Usa opcodes/estruturas nativas do protocolo game para task hunting/prey.
- Não depende do canal custom de extended opcode do novo sistema.

---

## 2) Hunting Task customizado (novo)

### Servidor (CrystalServer)
- Backend dedicado em `crystalserver/src/creatures/players/hunting_task/`.
- Parse de ação roteado em `Game::parsePlayerExtendedOpcode(...)` quando opcode de ação do `HuntingTaskSystem` é recebido.
- Persistência própria em `player_hunting_tasks` com campos dedicados (ex.: `required_kills`, `stars`, `reward_points`, `bestiary_unlocked`, `reroll_time`).

Arquivos-chave:
- `crystalserver/src/creatures/players/hunting_task/hunting_task.*`
- `crystalserver/src/game/game.cpp` (rota por extended opcode)
- `crystalserver/src/io/functions/iologindata_save_player.cpp`
- `crystalserver/src/io/functions/iologindata_load_player.cpp`
- `crystalserver/schema.sql` (tabela `player_hunting_tasks`)

### Client (OTClient)
- O transporte esperado é por **extended opcode** (ação/evento) com payload textual.
- Esse fluxo **é distinto** do parser nativo `parseTaskHuntingData` do protocolo global-like.
- Qualquer módulo de UI para esse sistema deve registrar callbacks de extended opcode e manter contrato de payload compatível com o backend custom.

Arquivos de suporte no cliente:
- `otclient/src/client/protocolgameparse.cpp` (`parseExtendedOpcode`)
- `otclient/modules/gamelib/protocolgame.lua` (registro de handlers de extended opcode)

---

## Regras para evitar confusão futura
- Sempre nomear explicitamente no PR/issue qual sistema foi alterado:
  - **Global-like Task Hunting (Prey)** ou
  - **Hunting Task customizado**.
- Não reutilizar tabela do sistema A no código do sistema B.
- Não misturar parser nativo de task hunting com canais custom de extended opcode.
- Ao alterar protocolo, validar alinhamento client↔server conforme orientação da wiki de servidor/protocolo.

## Checklist de mudança (rápido)
- Banco: alterou `player_taskhunt` ou `player_hunting_tasks`?
- Rede: alterou parser nativo ou extended opcode?
- Client: alterou `game_prey` ou módulo custom?
- Persistência: `IOPrey` (legado) ou `IOLoginData*HuntingTaskClass` (novo)?
