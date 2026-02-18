# Opcodes Server (Server → Client)

## Fontes canônicas

- Client enum de recepção: `otclient/src/client/protocolcodes.h` (`GameServerOpcodes`).
- Client parser: `otclient/src/client/protocolgameparse.cpp` (`parseMessage` switch).
- Server envio: `crystalserver/src/server/network/protocol/protocolgame.cpp` (`send*` methods).

## Cyclopedia (auditado)

| Opcode | Enum (client) | Origem server | Payload real resumido |
|---|---|---|---|
| `0x61` | `GameServerBosstiaryData` | `sendBosstiaryData()` | Lista de bosses/categoria/kills/tracker |
| `0x62` | `GameServerBosstiarySlots` | `parseSendBosstiarySlots()` (envio) | Pontos/bônus/slots/bosses desbloqueados |
| `0x73` | `GameServerBosstiaryInfo` | `parseSendBosstiary()` (envio) | Lista resumida de bosses |
| `0x76` | `GameServerCyclopediaItemDetail` | caminho de inspection cyclopedia | Header + item + pares de descrições |
| `0xB9` | `GameServerBestiaryRefreshTracker` | `refreshCyclopediaMonsterTracker()` | trackerType + entradas (race/kills/unlocks/status) |
| `0xBD` | `GameServerBosstiaryCooldownTimer` | `sendBosstiaryCooldownTimer()` | `u16 count` + (`u32 bossId`,`u64 cooldown`)[] |
| `0xC3` | `GameServerCyclopediaHouseAuctionMessage` | `sendHouseAuctionMessage()` | `u32 houseId`, `u8 type`, flags/index |
| `0xC6` | `GameServerCyclopediaHousesInfo` | `sendHousesInfo()` | metadados de casas da conta |
| `0xC7` | `GameServerCyclopediaHouseList` | `sendCyclopediaHouseList()` | lista de casas por estado com campos condicionais |
| `0xD5` | `GameServerBestiaryRaces` | `parseBestiarySendRaces()` (envio) | classe por raça + total/unlocked |
| `0xD6` | `GameServerBestiaryOverview` | `parseBestiarySendCreatures()` (envio) | lista de criaturas + progresso |
| `0xD7` | `GameServerBestiaryMonsterData` | `parseBestiarysendMonsterData()` (envio) | detalhe de monstro/loot/combat |
| `0xD8` | `GameServerBestiaryCharmsData` | `sendBestiaryCharms()` | charms, slots, unlocks, custo |
| `0xD9` | `GameServerBestiaryEntryChanged` | `sendBestiaryEntryChanged()` | `u16 raceId` |
| `0xDA` | `GameServerCyclopediaCharacterInfoData` | `sendCyclopediaCharacter*()` | bloco multiplexado por infoType |
| `0xE6` | `GameServerSendBosstiaryEntryChanged` | `sendBosstiaryEntryChanged()` | `u32 bossId` |

## Governança

Qualquer opcode novo deve atualizar simultaneamente:

1. Enum/parse no client.
2. Handler send/parse no server.
3. Documentação em `05-protocol/opcodes-client.md`, `05-protocol/opcodes-server.md` e `05-protocol/packet-structure.md`.
