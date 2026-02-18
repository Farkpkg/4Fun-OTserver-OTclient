# UI System (OTClient)

## Stack UI

- Layout declarativo OTUI (`*.otui`).
- Lógica em Lua por módulo (`*.lua`).
- Recursos visuais em `otclient/data/images`, `otclient/data/styles`, `otclient/data/fonts`.

## Construção da interface principal

- `startup` prepara janela, tamanho mínimo, posição e ciclo de inicialização.
- `client` controla experiência inicial (música/startscreen + entrada no jogo).
- `game_interface` integra painéis de HUD e módulos de gameplay.

## Padrões operacionais

- Widgets criados por `g_ui.displayUI` ou `g_ui.createWidget`.
- Eventos conectados por `connect(...)` e removidos em `disconnect(...)`.
- Estados persistentes simples em `g_settings` / `g_configs`.

## Acoplamento com protocolo

Módulos UI de jogo dependem de callbacks de `ProtocolGame` para:

- atualização de inventário/conteineres,
- mensagens de texto,
- dados de battle list,
- janelas funcionais (trade, market, outfit, etc.).
