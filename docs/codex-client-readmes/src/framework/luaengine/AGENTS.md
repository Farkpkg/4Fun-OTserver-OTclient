---
alwaysApply: true
---
# Guia de Lua Bindings (C++ ↔ Lua)

## Escopo

Este guia cobre a camada de bindings entre C++ e Lua: registro de singletons, classes e callbacks. Os bindings do framework ficam em `src/framework/luafunctions.cpp` e os bindings do jogo em `src/client/luafunctions.cpp`.

## Visao geral do binding

- `LuaInterface` (g_lua) registra classes, metodos e singletons.
- O registro ocorre em `registerLuaFunctions()` (framework e client).
- Dois caminhos principais: singletons globais (`g_*`) e classes instanciaveis.

## Padrao de registro (mini manual)

1. **Registrar singleton**:
   - `g_lua.registerSingletonClass("g_app");`
   - `g_lua.bindSingletonFunction("g_app", "exit", &Application::exit, &g_app);`
2. **Registrar classe**:
   - `g_lua.registerClass<UIWidget, LuaObject>();`
   - `g_lua.bindClassMemberFunction<UIWidget>("setVisible", &UIWidget::setVisible);`
3. **Factory/estatico** (quando precisar criar via Lua):
   - `g_lua.bindClassStaticFunction<UIWidget>("create", []{ return std::make_shared<UIWidget>(); });`
4. **Callbacks C++ → Lua**:
   - `g_lua.callGlobalField("g_game", "onLogin");`

## Checklist ao criar um novo bind

1. Declarar a funcao em `.h` e implementar em `.cpp`.
2. Registrar no `luafunctions.cpp` correto (framework ou client).
3. Adicionar documentacao no `meta.lua` para autocompletar/typing.
4. Validar parametros e manter nomes consistentes com o restante da API.

## Convenções e boas praticas

- Validar parametros antes de expor funcoes.
- Manter nomes Lua consistentes com a API existente (ex.: `setVisible`, `getRect`).
- Evitar expor metodos que permitam estados invalidos sem checagem.
- Preferir tipos simples (bool, number, string, table) e conversoes ja existentes.

## Tipos e conversoes

- Tipos basicos sao convertidos automaticamente.
- Estruturas comuns usam tabelas (`Position`, `Rect`, `Color`).
- `std::shared_ptr<T>` vira userdata e mantem lifetime.

## Onde procurar

- Framework: `src/framework/luafunctions.cpp`, `src/framework/luaengine/luainterface.h`.
- Client/game: `src/client/luafunctions.cpp`, `src/client/game.cpp`.
- UI: `src/framework/ui/uiwidget.cpp` (callbacks e hooks).
- Tipos e assinaturas Lua: `meta.lua` (manter atualizado com novos binds).

## Callbacks comuns (exemplos)

- `g_game.onLogin`, `g_game.onGameStart`, `g_game.onGameEnd`.
- `g_game.onTalk(name, level, mode, text, channelId, pos)`.
- `g_game.onWalk(direction)` e eventos de movimento.
- UI widgets chamam callbacks como `onClick`, `onStyleApply`.
