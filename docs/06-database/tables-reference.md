# Tables Reference

## Núcleo de conta e personagem

- `accounts`: credenciais, e-mail, premium, coins.
- `players`: atributos centrais do personagem (nível, posição, vocação, skills base, etc.).

## Inventário e armazenamento

- `player_items`
- `player_depotitems`
- `player_inboxitems`
- `player_stash`
- `player_storage`

## Progressão e especializações

- `player_spells`
- `player_outfits`
- `player_mounts`
- `player_wheeldata`
- `player_charms`
- `player_taskhunt`
- `player_prey`
- `player_bosstiary`

## Cyclopedia (persistência auditada)

- `player_charms`
  - Recursos e estado de charms (`charm_points`, `minor_charm_echoes`, bits de runes).
  - `charms` (blob) e `tracker_list` (blob) usados pelo ecossistema bestiary/cyclopedia.
- `player_deaths`
  - Fonte de `RecentDeaths` e `RecentPvPKills` da Cyclopedia Character.
- `player_hirelings`
  - Contagem usada no Summary da Cyclopedia (`loadSummaryData`).
- `kv_store`
  - Backend de KV para summary/titles/badges/cooldowns e outros escopos consumidos por Cyclopedia.
- `player_items` / `player_depotitems` / `player_inboxitems` / `player_stash`
  - Base do cálculo de `ItemSummary` enviado pela Cyclopedia Character.

## Economia

- `market_offers`
- `market_history`
- `store_history`
- `coins_transactions`

## Social e governança

- `guilds`, `guild_ranks`, `guild_membership`, `guild_invites`, `guild_wars`, `guildwar_kills`
- `account_viplist`, `account_vipgroups`, `account_vipgrouplist`
- `account_bans`, `account_ban_history`, `ip_bans`

## Mundo e suporte

- `houses`, `house_lists`, `towns`, `global_storage`, `tile_store`
- `players_online`, `account_sessions`, `kv_store`
