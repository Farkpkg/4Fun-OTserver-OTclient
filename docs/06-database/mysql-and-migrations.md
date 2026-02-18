# MySQL e Migrações no CrystalServer

## Descrição
O servidor usa MySQL via camada C++ (`Database`) e migrações Lua versionadas em `data/migrations`.

## Localização no Projeto
- server/
  - `crystalserver/src/database/`
  - `crystalserver/data/migrations/`

## Arquivos Envolvidos
- `crystalserver/src/database/database.hpp`
- `crystalserver/src/database/database.cpp`
- `crystalserver/data/migrations/`
- `crystalserver/config.lua.dist`

## Fluxo de Execução
1. O servidor abre conexão MySQL com parâmetros de configuração (`MYSQL_HOST`, `MYSQL_USER`, etc.).
2. Query API principal: `executeQuery`, `storeQuery`, `retryQuery`.
3. Em runtime, `Database::createDatabaseBackup` pode gerar dump via `mysqldump` quando habilitado.
4. Migrações Lua incrementais ficam em `data/migrations/<versão>.lua`.

## Dependências
- Cliente MySQL (`mysql_real_connect`, `mysql_query`).
- Ferramenta externa `mysqldump` para backup automático.
- Configuração de banco no `config.lua`.

## Pontos de Extensão
- Adicionar nova migração criando próximo arquivo numérico em `data/migrations/`.
- Evoluir política de backup e retenção em `Database::createDatabaseBackup`.
- Incluir validações transacionais para migrações críticas.
