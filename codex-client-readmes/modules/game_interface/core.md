# Game Interface Core (Fluxo de Inicio)

## Escopo

Este guia detalha como a interface principal e criada no `gameinterface.lua`.

## Fluxo de inicializacao (alto nivel)

1. `init()` carrega o layout base via `g_ui.displayUI('gameinterface')`.
2. Cria referencias globais para paineis (root, map, left/right/top/bottom).
3. Conecta eventos de `g_game` (onGameStart/onGameEnd).
4. Registra keybinds e handlers de mouse.
5. Aplica configuracoes salvas (view mode, tamanhos e opcoes).

## Quando o jogo inicia

- `onGameStart()` mostra paines, aplica view mode e ativa input.
- `gameRootPanel` vira o container principal para outros modulos.

## Quando o jogo termina

- `onGameEnd()` limpa estado, esconde paineis e desconecta handlers.

## Onde editar

- `modules/game_interface/gameinterface.lua` (init, onGameStart, onGameEnd).
- `modules/game_interface/gameinterface.otui` (estrutura visual base).
