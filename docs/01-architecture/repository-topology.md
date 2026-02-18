# Arquitetura Geral do Repositório

## Descrição
O repositório é dividido em dois executáveis principais: `otclient` (cliente) e `crystalserver` (servidor). A integração ocorre por protocolo de jogo e por eventos Lua acionados a partir do núcleo C++.

## Localização no Projeto
- client/
  - `otclient/`
- server/
  - `crystalserver/`

## Arquivos Envolvidos
- `otclient/init.lua`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/protocolgamesend.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/game/game.cpp`
- `crystalserver/data/core.lua`

## Fluxo de Execução
1. O OTClient inicia por `otclient/init.lua` e carrega paths, configs e módulos por prioridade.
2. O CrystalServer inicializa Lua via `data/core.lua`, carregando bibliotecas e sistemas.
3. O socket de jogo no servidor processa pacotes em `ProtocolGame`.
4. Pacotes de opcode estendido no servidor são encaminhados para eventos Lua de jogador.
5. No cliente, opcodes estendidos recebidos são repassados para callbacks Lua registrados.

## Dependências
- Runtime C++ de ambos os projetos.
- Sistema Lua no client (`modules/*`) e no server (`data/libs`, `data/scripts`).
- Protocolo de jogo (`ProtocolGame`) em ambos os lados.

## Pontos de Extensão
- Novos módulos de client via `*.otmod` e carga automática.
- Novos scripts de servidor em `crystalserver/data/scripts/*`.
- Novos opcodes estendidos via callbacks Lua registrados nos dois lados.
