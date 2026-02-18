# Runtime e Eventos no CrystalServer

## Descrição
O CrystalServer usa núcleo C++ com camada Lua para regras de jogo. O carregamento de bibliotecas e sistemas Lua começa em `data/core.lua`, e eventos são conectados por metatables e wrappers de revscriptsys.

## Localização no Projeto
- server/
  - `crystalserver/src/`
  - `crystalserver/data/`

## Arquivos Envolvidos
- `crystalserver/data/core.lua`
- `crystalserver/data/libs/functions/load.lua`
- `crystalserver/data/libs/functions/revscriptsys.lua`
- `crystalserver/src/lua/creature/creatureevent.cpp`
- `crystalserver/src/game/game.cpp`

## Fluxo de Execução
1. `data/core.lua` carrega libs centrais, sistemas e tabelas.
2. `load.lua` inclui funções utilitárias e `revscriptsys.lua`.
3. `revscriptsys.lua` registra comportamento dinâmico (`__newindex`) para classes de evento.
4. Eventos Lua (ex.: `CreatureEvent`) recebem tipo automaticamente ao atribuir callbacks.
5. O C++ executa callbacks em runtime (ex.: `CreatureEvent::executeExtendedOpcode`).

## Dependências
- Binding Lua exposto pelo servidor (`rawgetmetatable`, classes `CreatureEvent`, `TalkAction`, etc.).
- Subsystem de game loop em `src/game`.

## Pontos de Extensão
- Criar scripts em `crystalserver/data/scripts/` para novos eventos.
- Adicionar novos callbacks suportados no binding C++/Lua.
- Expandir wrappers em `revscriptsys.lua` para novos tipos de evento.
