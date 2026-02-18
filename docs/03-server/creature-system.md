# Creature System

## Estrutura

- Base comum: `src/creatures/creature.*`
- Players: `src/creatures/players/*`
- Monsters: `src/creatures/monsters/*`
- NPCs: `src/creatures/npcs/*`
- Combate/condições: `src/creatures/combat/*`

## Responsabilidades

- Movimento, vida/mana, velocidade, estados e ícones.
- Relações sociais (party/guild), progressão e atributos de player.
- Spawn e comportamento de monstros/NPCs.

## Integração com rede

- Serialização de estado por métodos `ProtocolGame::send*` (health, outfit, speed, type, skull, etc.).
- Ações recebidas de cliente roteadas para `g_game().player*`.

## Integração com Lua

- Funções de criatura expostas em `src/lua/functions/creatures/*`.
- Eventos de criatura em `src/lua/creature/creatureevent.*`.
