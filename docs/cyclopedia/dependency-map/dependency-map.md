# Dependency Map — Cyclopedia

## Diagrama textual (solicitado)

**Servidor -> Protocol -> NetworkMessage -> Cyclopedia Data -> UI -> Renderer -> Player Interaction**

## Explicação por etapa

1. **Servidor**
   - Emite pacotes de bestiary, bosstiary, item detail, character info, houses.
   - Responde a requests do cliente (search, overview, slot action, tracker toggle).

2. **Protocol**
   - `ProtocolGame` recebe opcode e roteia para parser específico em `protocolgameparse.cpp`.
   - Requests são emitidos em `protocolgamesend.cpp`.

3. **NetworkMessage**
   - `InputMessage` faz `getU8/getU16/getU32/getString/getDouble...`.
   - Parser monta structs fortemente tipadas (ex.: `BestiaryMonsterData`).

4. **Cyclopedia Data**
   - `Game::process*` converte para callbacks Lua (`g_game.onParse...`).
   - `luavaluecasts_client.cpp` serializa structs C++ para tabelas Lua.
   - Lua guarda estado em `Cyclopedia.*` (listas, página atual, filtros, cache local).

5. **UI**
   - `game_cyclopedia.lua` e tabs atualizam widgets dinamicamente.
   - `g_ui.loadUI` carrega OTUI de cada submódulo.
   - busca/filtros/paginação alteram datasets exibidos.

6. **Renderer**
   - UI widgets desenham imagens e textos.
   - `UICreature` e `UIItem` renderizam looktypes e sprites via engine.
   - efeitos visuais dependem de sprites/dat/spr e style definitions.

7. **Player Interaction**
   - Usuário clica em tabs, busca, marca tracker, muda filtros, inspeciona item.
   - Novos requests são disparados ao servidor, fechando o ciclo.

## Dependências internas entre módulos
- `game_cyclopedia` depende de:
  - `game_mainpanel` (botões topo)
  - `game_interface` (painéis/miniwindows)
  - `corelib` (UI base, tooltip, teclado)
  - `gamelib` (dados auxiliares, spells)
  - C++ client core (`g_game`, `g_things`, protocol)

## Pontos de acoplamento forte
- Condições por versão (`clientVersion >= ...`) em parse e UI.
- IDs e enums compartilhados (categoria de item, tipos de info de personagem).
- Persistência local por personagem para tracker e preços custom.
