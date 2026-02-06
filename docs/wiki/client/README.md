[Wiki](../README.md) > Cliente

# Cliente (OTClient)

## Visão geral
O OTClient é o cliente gráfico responsável por renderização, UI, entrada do usuário e comunicação com o servidor. Ele possui um framework C++ e uma camada de módulos e scripts Lua para UI e funcionalidades.

## Papel no projeto
- Renderiza o mundo, criaturas e UI.
- Envia ações e recebe atualizações do servidor.
- Carrega módulos e scripts que estendem a interface e o gameplay do cliente.

## Localização no repositório
- Código principal: `otclient/src/`
- Módulos: `otclient/modules/`
- Assets/UI: `otclient/data/`
- Mods: `otclient/mods/`
- Configuração: `otclient/config.ini`, `otclient/otclientrc.lua`, `otclient/init.lua`

## Estrutura interna (alto nível)
- `otclient/src/client/` — núcleo do cliente e entidades do jogo no cliente.
- `otclient/src/framework/` — engine (core, graphics, input, net, sound, ui, luaengine).
- `otclient/src/protobuf/` — mensagens protobuf (quando usado).
- `otclient/modules/` — módulos de UI e gameplay (ex.: `game_*`, `client_*`).
- `otclient/data/` — estilos, imagens, fontes, sons, things.

## Fluxo de execução (alto nível)
1. **Inicialização**: entrada em `otclient/src/main.cpp` (ou `androidmain.cpp` no Android).
2. **Framework**: inicializa subsistemas do framework (`otclient/src/framework/`).
3. **Scripts**: carrega `otclient/init.lua` e módulos em `otclient/modules/`.
4. **Conexão**: protocolo em `otclient/src/client/protocolgame*.cpp` comunica com o servidor.

## Integrações
- **Servidor**: protocolos de rede em `otclient/src/client/protocolgame*.cpp`.
- **UI/OTUI**: layouts e estilos em `otclient/data/styles/` e módulos em `otclient/modules/`.
- **Assets**: sprites, fontes e sons em `otclient/data/`.
