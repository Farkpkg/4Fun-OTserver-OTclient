# Persistence Flow

## Fluxo de leitura (login)

1. Conta autenticada via protocolo/login.
2. Player selecionado.
3. Camada IO carrega dados relacionais essenciais do personagem.
4. Objeto `Player` entra no runtime do `g_game()`.
5. Para Cyclopedia no login:
   - `checkAndUpdateNewBadges()` e `checkAndUpdateNewTitles()` são executados.
   - `loadSummaryData()` inicializa summary (ex.: hirelings).

## Fluxo de escrita (save/logout)

1. Runtime sinaliza persistência por logout/save periódico/eventos.
2. Camadas IO convertem estado em operações SQL.
3. Tabelas satélite (items/storage/spells/outfits/etc.) são sincronizadas.
4. Sessão é encerrada e status online atualizado.

## Fluxo Cyclopedia sob demanda

1. Client solicita blocos Cyclopedia por opcode (Character/Bestiary/Bosstiary/House).
2. Server consulta fontes adequadas:
   - `player_deaths` para histórico de mortes e kills PvP.
   - estado de charms/tracker (`player_charms`) via IOBestiary.
   - KV (`kv_store`) para summary, badges, titles e cooldowns.
   - inventários/stash/depot para `ItemSummary`.
3. Server serializa resposta no protocolo e envia ao client.
4. Client parseia e atualiza UI.

## Migrações

- Aplicadas no bootstrap por `DatabaseManager::updateDatabase()`.
- Garantem compatibilidade do schema com a versão do binário.
- Para Cyclopedia/Bestiary há migrações específicas de `player_charms` (ex.: ajustes de FK, tipos e `tracker_list`).
