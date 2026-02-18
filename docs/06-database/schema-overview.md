# Schema Overview

## Fonte de verdade

- `crystalserver/schema.sql`

## Estrutura macro

- Configuração/versão: `server_config`
- Identidade: `accounts`, `players`
- Social: guildas, vip, bans
- Economia: market, store, coins
- Estado do player: items/storage/spells/outfits/mounts/wheel/prey/taskhunt/bosstiary
- Mundo: houses, towns, global_storage, tile_store
- Sessão: `players_online`, `account_sessions`

## Versionamento

- `server_config.db_version` armazena versão aplicada.
- Migrações incrementais em `data/migrations/*.lua`.
