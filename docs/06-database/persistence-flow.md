# Persistence Flow

## Fluxo de leitura (login)

1. Conta autenticada via protocolo/login.
2. Player selecionado.
3. Camada IO carrega dados relacionais essenciais do personagem.
4. Objeto `Player` entra no runtime do `g_game()`.

## Fluxo de escrita (save/logout)

1. Runtime sinaliza persistência por logout/save periódico/eventos.
2. Camadas IO convertem estado em operações SQL.
3. Tabelas satélite (items/storage/spells/outfits/etc.) são sincronizadas.
4. Sessão é encerrada e status online atualizado.

## Migrações

- Aplicadas no bootstrap por `DatabaseManager::updateDatabase()`.
- Garantem compatibilidade do schema com a versão do binário.
