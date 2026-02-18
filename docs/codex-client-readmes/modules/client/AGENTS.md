---
alwaysApply: true
---
# Guia do Client (Lua UI base)

## Escopo

Este guia cobre os modulos `modules/client_*`: login, menus e UI base do cliente. Para protocolo e estado de jogo, veja `src/client/network.md` e `src/client/state.md`.

## Modulos principais

- `client_entergame`: login e selecao de personagem.
- `client_options`: opcoes e configuracao.
- `client_topmenu` / `client_bottommenu`: menus principais.
- `client_styles`: estilos OTUI base.
 - `client_locales`: carregamento de traducoes.

## Onde editar

- Login e selecao: `modules/client_entergame`.
- Opcoes: `modules/client_options`.
- Menus: `modules/client_topmenu` e `modules/client_bottommenu`.
- Estilos base: `modules/client_styles`.
 - Locales: `modules/client_locales` e `data/locales/AGENTS.md`.

## Referencias

- UI C++: `src/framework/ui/AGENTS.md`.
- Protocolos: `src/client/network.md`.
- Locales: `data/locales/AGENTS.md`.
