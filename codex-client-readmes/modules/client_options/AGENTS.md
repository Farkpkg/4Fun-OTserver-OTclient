---
alwaysApply: true
---
# Guia de Client Options (Configuracoes)

## Escopo

Este guia cobre opcoes do cliente em `modules/client_options`: UI de configuracao e persistencia via `g_settings`.

## Arquivos principais

- `modules/client_options/options.lua`
- `modules/client_options/options.otui`
- `modules/client_options/core.md`

## Pontos chave

- Categorias e subcategorias de opcoes.
- Widgets: checkbox, scrollbar, combobox.
- Persistencia com `g_settings.set/get`.
- API: `setOption()` e `getOption()`.
- Extensao: `createCategory()`, `addButton()`, `removeCategory()`.

## Relacionados

- `modules/corelib/settings.lua` (wrapper de `g_settings`).
- `src/framework/core/configmanager.h` (Config/Settings no C++).
- `src/framework/ui/AGENTS.md` (widgets e input).

## Onde editar

- Logica e callbacks: `options.lua`.
- Layout: `options.otui`.
- Textos: `data/locales/*.lua`.
- Fluxo detalhado: `modules/client_options/core.md`.
