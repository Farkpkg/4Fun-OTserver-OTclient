# Extended Opcodes

## Transporte de protocolo

- Client envia usando `ClientExtendedOpcode`.
- Server recebe `0x32` e delega para callbacks de `CreatureEvent`.
- Server responde via `Player.sendExtendedOpcode`.

## IDs identificados no código atual

## Núcleo OTClient

- `ExtendedIds.Activate = 0`
- `ExtendedIds.Locale = 1`
- `ExtendedIds.Ping = 2`
- `ExtendedIds.Sound = 3`
- `ExtendedIds.Game = 4`
- `ExtendedIds.Particles = 5`
- `ExtendedIds.MapShader = 6`
- `ExtendedIds.NeedsUpdate = 7`

Fonte: `otclient/modules/gamelib/const.lua`.

## Implementações de script observadas

- Locale: `opcode 1` (`#extended_opcode.lua` no server).
- Game shop opcional: `opcode 201` (scripts `game_shop`).

## Estrutura de payload

- Transporte base: `uint8 opcode lógico + string buffer`.
- Contrato de conteúdo:
  - string simples (locale)
  - JSON (`{action, data}`) no shop.

## Regras de compatibilidade

- IDs devem ser globalmente únicos por servidor.
- Payload deve possuir validação server-side antes de aplicar efeitos em estado persistente.
