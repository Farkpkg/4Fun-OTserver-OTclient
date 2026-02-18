# Coding Standards

## Princípios

- Mudanças devem ser rastreáveis a arquivos reais.
- Toda alteração de protocolo exige atualização de documentação e validação cruzada.
- Evitar acoplamento circular entre módulos.
- Preferir extensões via pontos de hook existentes (callbacks, módulos, send/parse handlers).

## Server

- Regras de jogo no server (autoridade).
- Scripts Lua devem validar entradas externas (especialmente payloads).
- Mudanças de schema sempre acompanhadas de migração.

## Client

- `init()`/`terminate()` devem manter simetria de recursos.
- UI deve separar layout (`.otui`) de lógica (`.lua`) quando possível.
- Novos módulos devem declarar prioridade/dependências explícitas.

## Documentação

- Atualizar arquivo de sistema em `04-systems` para qualquer feature relevante.
- Manter listas de opcode e schema sincronizadas com implementação.
