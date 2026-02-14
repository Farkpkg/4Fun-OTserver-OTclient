# ObjectPool

- **Tipo:** Pure Lua metatable
- **Categoria:** utils
- **Definição/registro:** otclient/modules/corelib/objectpool.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Tabela Lua prototipal (`Class.__index = Class`) e instâncias com `setmetatable`.

## API
- Métodos públicos: ver funções no arquivo fonte do módulo
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: ObjectPool
- Dependências: módulo Lua local

## Exemplos reais (extração direta)
- `otclient/modules/corelib/objectpool.lua:2`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
