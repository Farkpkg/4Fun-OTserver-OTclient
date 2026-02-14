# UI da Cyclopedia

## 1) Construção do módulo

### OTMod
`game_cyclopedia.otmod`:
- scripts: `game_cyclopedia`, `tab/*`, `utils`
- autoload: true
- lifecycle:
  - `@onLoad: controllerCyclopedia:init()`
  - `@onUnload: controllerCyclopedia:terminate()`

### Controller
`game_cyclopedia.lua` cria `controllerCyclopedia = Controller:new()` com:
- `setUI('game_cyclopedia')`
- hooks de `onGameStart`, `onGameEnd`, `onTerminate`
- registro central de callbacks de rede em `registerEvents(g_game, {...})`

## 2) Composição visual

### Janela principal
`game_cyclopedia.otui`:
- `MainWindow` com `buttonSelection` no topo
- botão por tab: items, bestiary, charms, map, houses, character, bosstiary, bossSlot, magicalArchives
- `contentContainer` onde cada tab é carregado dinamicamente via `g_ui.loadUI`

### Widgets compartilhados
`cyclopedia_widgets.otui` e `cyclopedia_pages.otui`:
- widgets de achievement, listas de item, aparência de personagem, mortes/kills
- componentes reutilizados por tabs (House, CharacterListItem, CharacterAppearance etc.)

## 3) Navegação

### Seleção de janela
- `toggle(defaultWindow)` abre/fecha Cyclopedia.
- `SelectWindow(type, isBackButtonPress)` controla mudança de tab.
- `show(defaultWindow)` inicia janela com tab padrão.

### Back stack
- `tabStack` mantém histórico para botão Back.
- `previousType` e `windowTypes` coordenam estado ativo.

## 4) Eventos e callbacks

### Entrada (UI -> lógica)
- clicks dos botões de tabs
- filtros dropdown/checkbox
- campo de busca + Enter
- paginação next/prev

### Saída (rede -> UI)
- callbacks `g_game.onParse...` e `g_game.onUpdate...` alimentam widgets imediatamente.

## 5) Tooltip e componentes
- Tooltips base usam `modules/corelib/ui/tooltip.lua`.
- Em Cyclopedia há tooltips específicos para categorias, stars, ícones e botões contextuais.

## 6) Estado e persistência local
- Trackers e filtros são salvos por personagem (cache local em arquivos/estruturas Lua).
- Itens possuem persistência JSON de preços custom e listas auxiliares.

## 7) Módulos incompletos
- `magicalArchives` atualmente apenas carrega painel e ajusta visibilidade de barras (sem regras complexas adicionais).
