<!-- tags: - server - c++ - lua priority: critical -->

## LLM Summary
- **What**: Visão geral do CrystalServer e seus subsistemas.
- **Why**: Centraliza contexto do backend e suas integrações.
- **Where**: crystalserver/src, crystalserver/data
- **How**: Descreve estrutura, fluxo de execução, debug e performance.
- **Extends**: Scripts Lua e dados em crystalserver/data; ajustes em config.lua.
- **Risks**: Mudanças em protocolo ou núcleo do jogo impactam cliente e gameplay.

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
1. **Inicialização**: ponto de entrada em `crystalserver/src/main.cpp`, chamando `CrystalServer::run()` em `crystalserver/src/crystalserver.cpp`.
2. **Carregamento**: configuração, dados e scripts Lua são carregados durante o `run()` antes de iniciar o game state.
3. **Rede**: o servidor sobe protocolos de login/status e o protocolo de jogo.
4. **Loop de jogo**: o núcleo em `crystalserver/src/game/` coordena eventos, agendamentos e atualizações do mundo.

## Exemplos práticos (do código)
- **Inicialização e bootstrap**: `main()` delega para `CrystalServer::run()` e dispara o carregamento de módulos e mapas antes de iniciar o serviço de rede.
  - Referências: `crystalserver/src/main.cpp`, `crystalserver/src/crystalserver.cpp`.
- **Configuração de logs**: o nível de log é definido em `logLevel` no `config.lua.dist` (com observação sobre debug/trace em builds de debug).
  - Referência: `crystalserver/config.lua.dist`.
- **Logs escritos por scripts**: scripts Lua escrevem logs em `CORE_DIRECTORY/logs/...` (ex.: logins e comandos).
  - Referências: `crystalserver/data/libs/functions/player.lua`, `crystalserver/data/libs/functions/functions.lua`.

## Debug e troubleshooting
- **Sintoma: servidor inicia sem logs de detalhe**
  - **Possível causa**: nível de log baixo ou build sem debug/trace.
  - **Onde investigar**: ajuste `logLevel` em `config.lua.dist` e observe as notas sobre debug/trace.
- **Sintoma: scripts não carregam**
  - **Possível causa**: erro na carga de scripts Lua ou diretórios inexistentes.
  - **Onde investigar**: carregamento e erros são registrados por `Scripts::loadScripts`.
- **Breakpoints sugeridos**
  - `main()` em `crystalserver/src/main.cpp`.
  - `CrystalServer::run()` em `crystalserver/src/crystalserver.cpp` (carregamento inicial e transição de estados).
  - `game` loop e operações centrais em `crystalserver/src/game/game.cpp`.

## Performance e otimização
- **Pontos sensíveis**
  - **Dispatcher/scheduler**: eventos e tarefas assíncronas são agendadas pelo dispatcher, impactando latência e throughput.
  - **Loop de jogo**: o núcleo do game é o ponto crítico de execução contínua.
- **Onde investigar**
  - `crystalserver/src/game/scheduling/dispatcher.hpp` (agendamento e execução de tarefas).
  - `crystalserver/src/game/game.cpp` (nó central de lógica do jogo).

## Pontos de extensão e customização
- **Onde é seguro modificar**
  - Scripts Lua em `crystalserver/data/scripts/` (ações, movimentos, spells, runes, weapons).
  - Registros e dados em `crystalserver/data/XML/`.
  - Configurações em `crystalserver/config.lua.dist`.
- **Onde exigir coordenação**
  - Alterações em protocolos (login/status/jogo) exigem compatibilidade com o cliente.

## Integrações
- **Cliente**: comunicação via protocolos na camada `crystalserver/src/server/network/protocol/`.
- **Banco de dados**: leitura/gravação em `crystalserver/src/database/` e `crystalserver/src/io/`.
- **Scripts Lua**: carga e execução a partir de `crystalserver/data/scripts/` e `crystalserver/data/events/`.
- **Configuração/XML**: parâmetros em `crystalserver/config.lua.dist` e definições em `crystalserver/data/XML/`.

## LLM Extension Points
- **Safe to extend**: Scripts Lua em data/scripts e configurações em config.lua.dist.
- **Use with caution**: Camada de protocolo e ciclo principal do jogo.
- **Do not modify**: Alterar opcodes ou fluxo de login sem coordenar com o cliente.

