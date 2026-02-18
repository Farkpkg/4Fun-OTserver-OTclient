# Player System

## Núcleo

- Classe principal: `src/creatures/players/player.*`
- Subdomínios: vocations, storages, imbuements, wheel, achievements, grouping.

## Ciclo de sessão

1. Login carrega dados via camada IO.
2. Sessão online atualiza estado em memória no objeto `Player`.
3. Save/logout persiste blocos relacionais no banco.

## Integração com protocolo

- Recebe comandos do cliente via `ProtocolGame::parsePacketFromDispatcher`.
- Emite atualizações por múltiplos `send*` (skills, inventory, states, channels, trackers).

## Extensão

- Eventos Lua para onLogin/onLogout/onGainExperience/onMoveItem etc.
- Extended opcode por player via CreatureEvent dedicado.
