# Database Layer

## Camadas

- Driver/conexão: `src/database/database.*`
- Gestão de schema/migrations: `src/database/databasemanager.*`
- Execução assíncrona: `src/database/databasetasks.*`

## Artefatos de persistência

- Schema base: `crystalserver/schema.sql`
- Migrações incrementais: `crystalserver/data/migrations/*.lua`

## Regras observadas

- Server valida existência de schema no boot.
- Atualização de versão aplicada por `DatabaseManager::updateDatabase()`.
- Otimização opcional executada por flag de configuração.
