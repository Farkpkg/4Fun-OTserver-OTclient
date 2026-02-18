# Opcodes Client (Client → Server)

## Cyclopedia (auditado no código atual)

| Opcode | Enum (client) | Uso no sistema Cyclopedia | Payload real |
|---|---|---|---|
| `0x2A` | `ClientBestiaryTrackerStatus` | Ativar/desativar tracker de bestiary/bosstiary | `u16 raceId`, `u8 status` |
| `0xAD` | `ClientCyclopediaHouseAuction` | Ações da aba House | `u8 actionType` + payload condicional (town/bid/moveout/transfer/cancel/accept/reject) |
| `0xAE` | `ClientBosstiaryRequestInfo` | Abrir/atualizar Bosstiary | vazio |
| `0xAF` | `ClientBosstiaryRequestSlotInfo` | Abrir/atualizar Boss Slots | vazio |
| `0xB0` | `ClientBosstiaryRequestSlotAction` | Setar/remover boss em slot | `u8 action`, `u32 raceId` |
| `0xCD` | `ClientInspectionObject` | Detalhe de item da aba Items (`INSPECT_CYCLOPEDIA`) | `u8 inspectionType`, `u16 itemId`, `u8 itemCount` |
| `0xE1` | `ClientBestiaryRequest` | Carregar categorias/races de bestiary | vazio |
| `0xE2` | `ClientBestiaryRequestOverview` | Carregar overview por categoria/search | `u8 search`; se `1`: `u16 count` + `u16 raceId[]`; se `0`: `string category` |
| `0xE3` | `ClientBestiaryRequestSearch` | Carregar monstro específico | `u16 raceId` |
| `0xE4` | `ClientCyclopediaSendBuyCharmRune` | Compra/ação de charm rune | `u8 runeId`, `u8 action`, `u16 raceId` |
| `0xE5` | `ClientCyclopediaRequestCharacterInfo` | Requisição de blocos da aba Character | `u32 characterId`, `u8 infoType`; para deaths/pvpkills também `u16 entriesPerPage`, `u16 page` |

## Observações
- Não há uso de extended opcode para Cyclopedia no core auditado.
- A aba House depende do opcode `0xAD`, porém o parse de resposta no client C++ ainda possui TODO de integração final com Lua/UI.
