# Game State Synchronization

## Escopo

Este guia cobre como o estado do jogo e sincronizado no client: parse -> Game::process* -> callbacks Lua. Para parsing, veja `src/client/network.md`.

## Fluxo principal

- `ProtocolGame::parseMessage()` chama `parse*()`.
- `parse*()` extrai dados e chama `Game::process*()`.
- `Game::process*()` atualiza estado e dispara `g_lua.callGlobalField`.

## Estado central (Game)

- `m_localPlayer`, `m_containers`, `m_vips`.
- `m_online`, `m_dead`, `m_fightMode`, `m_chaseMode`, `m_pvpMode`.
- `m_attackingCreature`, `m_followingCreature`.

## Categorias de process*

- Sessao: `processLogin`, `processGameStart`, `processGameEnd`.
- Comunicação: `processTalk`, `processTextMessage`, `processChannel*`.
- Inventario/containers: `processOpenContainer`, `processContainer*`.
- Social: `processVipAdd`, `processVipStateChange`.
- Modos de combate: `processPlayerModes`.

## Callbacks Lua comuns

- `onLogin`, `onGameStart`, `onGameEnd`.
- `onTalk`, `onTextMessage`.
- `onOpenChannel`, `onCloseChannel`.
- `onVipStateChange`, `onAddVip`.

## Thread safety

- Atualizacoes criticas podem usar `g_dispatcher` para garantir main thread.
- Ex.: `processEnterGame()` usa `g_dispatcher.addEvent`.

## Onde editar

- Estado e process* em `src/client/game.*`.
- Callbacks Lua em `modules/gamelib` e `modules/game_*`.
