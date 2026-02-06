[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Mapas

# Mapas

## Visão geral
O sistema de mapas gerencia o carregamento, armazenamento e consulta do mundo. O servidor mantém o estado do mapa e o cliente renderiza as camadas visuais.

## Arquivos envolvidos
- **Servidor**: `crystalserver/src/map/`.
- **Cliente**: `otclient/src/client/map*.cpp`, `otclient/src/client/minimap*.cpp`.

## Estrutura interna (alto nível)
- Carregamento e representação de tiles e setores no servidor.
- Renderização e minimapa no cliente.

## Fluxo geral
1. O servidor carrega o mapa durante a inicialização.
2. Atualizações do mapa são enviadas ao cliente via protocolo.
3. O cliente renderiza tiles e minimapa.

## Pontos de extensão
- Scripts de movimentos em `crystalserver/data/scripts/movements/` interagem com tiles.
- Eventos de mapa podem ser registrados via `crystalserver/data/events/`.
