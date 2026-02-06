# Fluxos principais (alto nível)

## Fluxo de login
1. **Cliente** inicia e carrega módulos de entrada (ex.: `otclient/modules/client_entergame/`).
2. **Cliente** envia credenciais via protocolo (`otclient/src/client/protocolgame*.cpp`).
3. **Servidor** recebe no stack de rede/protocolo (`crystalserver/src/server/network/protocol/`) e valida conta em `crystalserver/src/account/`.

## Comunicação cliente ↔ servidor
- **Cliente** serializa mensagens no protocolo (`otclient/src/client/protocolgameparse.cpp` / `protocolgamesend.cpp`).
- **Servidor** trata mensagens na camada de protocolo (`crystalserver/src/server/network/protocol/`) e encaminha ao núcleo do jogo (`crystalserver/src/game/`).

## Game loop principal
- **Servidor**: fluxo central em `crystalserver/src/game/` com apoio de agendadores (`crystalserver/src/game/scheduling/`).
- **Cliente**: loop principal em `otclient/src/client/game.cpp` e camadas do framework (`otclient/src/framework/`).

## Onde scripts entram no fluxo
- **Servidor**: scripts Lua são carregados de `crystalserver/data/scripts/` e acionados por eventos em `crystalserver/data/events/` e registros XML.
- **Cliente**: módulos e scripts em `otclient/modules/` e `otclient/mods/` integram UI e comportamento.
