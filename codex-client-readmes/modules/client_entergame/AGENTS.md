---
alwaysApply: true
---
# Guia de Login e Character Selection

## Escopo

Este guia cobre login, lista de personagens e entrada no jogo (modules/client_entergame). Para fluxo de protocolo, veja `src/client/network.md` e `modules/gamelib/AGENTS.md`.

## Modulos e arquivos

- `modules/client_entergame/entergame.lua` + `entergame.otui`
- `modules/client_entergame/characterlist.lua` + `characterlist.otui`

## Fluxo geral

- `entergame` faz autenticacao (HTTP ou binario).
- `characterlist` exibe personagens e chama `g_game.loginWorld()`.
- `ProtocolLogin` (Lua) parseia resposta e dispara callbacks.

## Pontos chave

- HTTP login para versoes novas; binario para legado.
- Sessao e MOTD gerenciados aqui.
- Auto-reconnect e waiting list ficam em `characterlist.lua`.

## Onde editar

- UI: `*.otui`
- Logica: `entergame.lua` e `characterlist.lua`
- Protocolo login: `modules/gamelib/protocollogin.lua`
- Config inicial: `init.lua`
