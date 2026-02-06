# Sistemas identificados (existentes no código)

## Servidor (CrystalServer)
- **Core do servidor**: inicialização e ciclo principal em `crystalserver/src/game/` e `crystalserver/src/server/`.
- **Rede e protocolos**: camadas em `crystalserver/src/server/network/` (connection/message/protocol).
- **Banco de dados**: camada em `crystalserver/src/database/` + `schema.sql`.
- **Contas e autenticação**: `crystalserver/src/account/`.
- **Criaturas e combate**: `crystalserver/src/creatures/` (combat, monsters, npcs, players).
- **Itens**: `crystalserver/src/items/` e definições em `crystalserver/data/items/`.
- **Mapas**: `crystalserver/src/map/`.
- **Scripts e eventos (Lua)**: `crystalserver/data/scripts/` e `crystalserver/data/events/`.
- **Magias, runas e armas**: `crystalserver/data/scripts/spells/`, `runes/`, `weapons/`.
- **Movimentos e ações**: `crystalserver/data/scripts/movements/` e `actions/`.
- **Configurações**: `crystalserver/config.lua.dist` e `crystalserver/data/XML/`.
- **Logs e métricas**: `crystalserver/data/logs/` e `crystalserver/metrics/`.
- **Segurança**: `crystalserver/src/security/`.
- **Protobuf**: `crystalserver/src/protobuf/`.

## Cliente (OTClient)
- **Core do cliente**: `otclient/src/client/`.
- **Framework**: `otclient/src/framework/` (core, graphics, input, net, platform, sound, ui, luaengine).
- **Protocolos de rede**: `otclient/src/client/protocolgame*.cpp` e `protocolcodes*`.
- **UI/OTUI**: `otclient/data/styles/` e arquivos `.otui`, além de `otclient/modules/`.
- **Módulos de jogo**: `otclient/modules/game_*` (inventário, battle, minimap, spells etc.).
- **Módulos base**: `otclient/modules/corelib/`, `modulelib/`, `gamelib/`.
- **Assets**: `otclient/data/` (imagens, fontes, sons, things).
- **Mods**: `otclient/mods/`.
- **Protobuf**: `otclient/src/protobuf/`.

## Compartilhado / apoio
- **Documentação e referências**: `docs/`, `ai/`, `codex-client-readmes/`.
