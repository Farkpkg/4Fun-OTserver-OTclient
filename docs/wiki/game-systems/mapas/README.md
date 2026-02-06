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

## Exemplo prático (do código)
- `CrystalServer::loadMaps()` carrega o mapa principal e mapas customizados quando habilitado.

## Debug e troubleshooting
- **Sintoma: mapa não carrega**
  - **Possível causa**: caminho de mapa inválido ou erro de carregamento.
  - **Onde investigar**: `CrystalServer::loadMaps()` e configuração de mapa.

## Performance e otimização
- **Ponto sensível**: atualizações frequentes de mapa geram mais tráfego de rede e renderização no cliente.

## Pontos de extensão
- Scripts de movimentos em `crystalserver/data/scripts/movements/` interagem com tiles.
- Eventos de mapa podem ser registrados via `crystalserver/data/events/`.
