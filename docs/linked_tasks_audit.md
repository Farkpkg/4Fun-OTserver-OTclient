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
