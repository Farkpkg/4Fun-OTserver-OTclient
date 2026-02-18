# Architecture Overview

## Camadas principais

## 1) Client Runtime (`otclient`)

- Entrypoint em `otclient/src/main.cpp`.
- Executa `init.lua`, descobre e auto-carrega módulos (`g_modules`).
- Renderização e UI via framework próprio + OTUI.
- Comunicação de jogo via `ProtocolGame`.

## 2) Game/Network Server (`crystalserver`)

- Entrypoint em `crystalserver/src/main.cpp`.
- Orquestração de boot em `CrystalServer::run()`.
- Carrega config, banco, XMLs, scripts Lua, mapa e protocolos.
- Runtime autoritativo de game state e persistência.

## 3) Contrato Client ⇄ Server

- Pacotes binários de protocolo Tibia/OTC.
- Extended opcode habilitado por feature e trafegado como opcode dedicado.
- Eventos Lua no server recebem extended opcode e podem responder ao cliente.

## 4) Persistência

- Abstração DB em `crystalserver/src/database/`.
- Operações de login/save em camadas `io/*` + entidades de jogo.
- Modelo relacional em `crystalserver/schema.sql`.
