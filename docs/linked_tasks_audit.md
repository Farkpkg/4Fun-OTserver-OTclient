# Linked Tasks audit notes

## KV system / storage name usage

The following usage points of `player:getStorageValueByName` / `player:setStorageValueByName` were found and reviewed:

| Location | Usage | Classification | Notes |
| --- | --- | --- | --- |
| `crystalserver/data/scripts/talkactions/god/manage_storage.lua` | Admin command allowing storage manipulation by name. | **Legacy allowed** | Kept for GM tooling; not a player-facing flow. |
| `crystalserver/data-global/scripts/game_migrations/20241708485868_move_some_storages_to_kv.lua` | Reads storage by name and migrates to KV. | **Legacy for migration** | Purpose-built migration script; expected to use deprecated API. |
| `crystalserver/data-global/scripts/game_migrations/20241715984279_move_wheel_scrolls_from_storagename_to_kv.lua` | Reads storage by name and migrates to KV. | **Legacy for migration** | Purpose-built migration script; expected to use deprecated API. |

No usage of storage-by-name APIs was found in the Linked Tasks Lua scripts. The Linked Tasks system continues to use numeric storages to preserve current compatibility.

## Database

Linked Tasks relies on the `player_tasks` table created by migration `crystalserver/data/migrations/61.lua`.

## Runtime stability issues found

| Issue | Risk | Fix applied |
| --- | --- | --- |
| ExtendedOpcode handlers parsed payloads without guarding against empty/malformed buffers. | Client crash (`NetworkMessage::getByte`/`getString` errors) when payloads are missing or invalid. | Added defensive payload normalization and early aborts for empty/malformed payloads. |
| Kill progression relied on `onKill` CreatureEvent. | Deprecated API warning and future incompatibility with Canary/Crystal. | Migrated to `onDeath` with `killer`/`mostDamageKiller` resolution. |
| Linked Tasks talk-action used `MESSAGE_INFO_DESCR` (not defined in this server core). | Invalid message type warning in Canary/Crystal builds. | Replaced default/neutral messages with `MESSAGE_STATUS` to align with server-defined enums. |
| Payload sanitization not fully documented. | Client parser could break if delimiters leaked into payloads. | Documented payload delimiter rules and ensured sanitization is explicit. |

## Remaining risks / attention points

- Enum values are extracted from the current C++ core; re-validate `docs/enums.md` after updating Canary/Crystal sources.
