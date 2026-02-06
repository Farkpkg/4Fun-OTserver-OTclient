---
alwaysApply: true
---
# Guia de Network (Transport, Security, Messages)

## Escopo

Este guia cobre o transporte e seguranca de rede no framework: Connection/Protocol, criptografia e mensagens.

## Componentes

- `Connection`: socket TCP via ASIO, timers e filas.
- `Protocol`: checksum, XTEA, RSA, sequenciamento.
- `InputMessage`/`OutputMessage`: serializacao binaria.

## Segurança e headers

- RSA: usado no login; chave definida pelo cliente/servidor.
- XTEA: criptografia da sessao (chave por login).
- Checksum e sequenciamento ativados por feature flags.
- Header varia conforme versao e flags (checksum/sequence).

## Arquivos principais

- `src/framework/net/connection.*`
- `src/framework/net/protocol.*`
- `src/framework/net/inputmessage.*`
- `src/framework/net/outputmessage.*`

## Notas

- O protocolo de jogo e parse/send ficam em `src/client`.
- Lua hooks e callbacks ficam em `src/framework/luaengine/AGENTS.md` e `src/client/AGENTS.md`.
