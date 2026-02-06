[Wiki](../README.md) > Servidor

# Servidor (CrystalServer)

## Visão geral
O CrystalServer é o backend responsável por simular o mundo do jogo, manter estado persistente e processar todas as regras de gameplay. Ele concentra a lógica de jogo, a camada de rede e a integração com banco de dados.

## Papel no projeto
- Mantém o estado do mundo e dos jogadores.
- Processa ações e regras (combate, itens, mapas, eventos).
- Integra com scripts Lua para extensibilidade.
- Expõe comunicação com o cliente via protocolos.

## Localização no repositório
- Código principal: `crystalserver/src/`
- Scripts e dados: `crystalserver/data/`, `crystalserver/data-crystal/`, `crystalserver/data-global/`
- Configuração base: `crystalserver/config.lua.dist`
- Testes: `crystalserver/tests/`

## Estrutura interna (alto nível)
- `crystalserver/src/game/` — núcleo do jogo, ciclo principal e regras.
- `crystalserver/src/server/` — servidor, sinais e camada de rede.
- `crystalserver/src/server/network/` — conexão, mensagens e protocolos.
- `crystalserver/src/creatures/` — criaturas, NPCs, jogadores e combate.
- `crystalserver/src/items/` — itens e tipos de item.
- `crystalserver/src/map/` — mapa e carregamento.
- `crystalserver/src/database/` + `crystalserver/src/io/` — persistência e I/O.
- `crystalserver/src/lua/` — integração com Lua.
- `crystalserver/src/config/` — carregamento de configuração.
- `crystalserver/src/security/` — segurança e validações.

## Fluxo de execução (alto nível)
1. **Inicialização**: ponto de entrada em `crystalserver/src/main.cpp`, chamando inicialização em `crystalserver/src/crystalserver.cpp`.
2. **Carregamento**: configuração, dados e scripts Lua são carregados a partir de `crystalserver/config.lua.dist` e `crystalserver/data/`.
3. **Rede**: o servidor inicia a camada de rede em `crystalserver/src/server/` e aguarda conexões.
4. **Loop de jogo**: o núcleo em `crystalserver/src/game/` coordena eventos, agendamentos e atualizações do mundo.

## Integrações
- **Cliente**: comunicação via protocolos na camada `crystalserver/src/server/network/protocol/`.
- **Banco de dados**: leitura/gravação em `crystalserver/src/database/` e `crystalserver/src/io/`.
- **Scripts Lua**: carga e execução a partir de `crystalserver/data/scripts/` e `crystalserver/data/events/`.
- **Configuração/XML**: parâmetros em `crystalserver/config.lua.dist` e definições em `crystalserver/data/XML/`.
