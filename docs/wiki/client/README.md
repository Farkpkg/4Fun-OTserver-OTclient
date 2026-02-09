<!-- tags: - client - c++ - lua - ui priority: critical -->

## LLM Summary
- **What**: Visão geral do OTClient, framework e módulos.
- **Why**: Orienta renderização, UI e comunicação com servidor.
- **Where**: otclient/src, otclient/modules, otclient/data
- **How**: Explica bootstrap, módulos e integração via protocolo.
- **Extends**: Módulos em otclient/modules e layouts em otclient/data/styles.
- **Risks**: Mudanças em protocolo ou módulos críticos quebram login/jogo.

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

## Exemplos práticos (do código)
- **Arquivo de log do cliente**: o logger cria o arquivo no diretório de trabalho via `g_logger.setLogFile(...)` no bootstrap.
  - Referência: `otclient/init.lua`.
- **Módulo de inventário**: o módulo `game_inventory` manipula slots e atualiza UI conforme o estado do jogador.
  - Referência: `otclient/modules/game_inventory/inventory.lua`.
- **Transição de estado no jogo**: `Game::processGameStart()` ajusta FPS e agenda eventos de ping/conexão.
  - Referência: `otclient/src/client/game.cpp`.

## Debug e troubleshooting
- **Sintoma: módulos não carregam**
  - **Possível causa**: falha no carregamento de scripts ou dependências.
  - **Onde investigar**: mensagens de erro são geradas no carregamento de módulos.
- **Sintoma: cliente sem log**
  - **Possível causa**: falha no `setLogFile` ou diretório de trabalho inválido.
  - **Onde investigar**: configuração do logger em `otclient/init.lua`.
- **Breakpoints sugeridos**
  - `Game::processLogin` / `processGameStart` em `otclient/src/client/game.cpp`.
  - Carregamento de módulos em `otclient/src/framework/core/module.cpp`.

## Performance e otimização
- **Pontos sensíveis**
  - **Ciclo de jogo**: atualizações de conexão e eventos são agendadas no `Game`.
  - **FPS**: o cliente ajusta alvo de FPS ao entrar/sair do jogo.
- **Onde investigar**
  - `otclient/src/client/game.cpp` (eventos de ping, FPS e estados).

## Sistemas de hunt tasks (coexistentes)
- No cliente também existem dois fluxos distintos: o fluxo nativo de **Task Hunting/Prey** e o fluxo **custom por extended opcode**.
- Mapeamento completo (server + client): `docs/wiki/game-systems/hunting-tasks/README.md`.

## Pontos de extensão e customização
- **Onde é seguro modificar**
  - Módulos e layouts em `otclient/modules/`.
  - Estilos e componentes em `otclient/data/styles/`.
- **Onde exigir coordenação**
  - Alterações no protocolo exigem alinhamento com o servidor e `protocolcodes`.

## Integrações
- **Servidor**: protocolos de rede em `otclient/src/client/protocolgame*.cpp`.
- **UI/OTUI**: layouts e estilos em `otclient/data/styles/` e módulos em `otclient/modules/`.
- **Assets**: sprites, fontes e sons em `otclient/data/`.

## LLM Extension Points
- **Safe to extend**: Módulos em otclient/modules e estilos em otclient/data/styles.
- **Use with caution**: Carregamento de módulos e integração com g_game.
- **Do not modify**: Protocolos/opcodes sem sincronização com o servidor.

