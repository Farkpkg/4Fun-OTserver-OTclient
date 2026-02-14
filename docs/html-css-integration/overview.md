# Integração HTML/CSS no OTClient — Overview

## Escopo analisado
Esta documentação cobre a stack completa de HTML/CSS do cliente OTClient:
- parser HTML (`framework/html/htmlparser.cpp`), árvore `HtmlNode` e query selector;
- parser CSS (`framework/html/cssparser.cpp`) e aplicação de regras em widgets;
- bridge C++↔Lua (`g_html`, `UIWidget:querySelector*`, `append/prepend/insert/remove`);
- bindings reativos `*` e eventos HTML mapeados para callbacks Lua;
- uso real em módulos (`game_forge`, `game_questlog`, `game_modaldialog`, `game_rewardwall`, etc.).

## Varredura global

### Arquivos HTML encontrados
- `otclient/browser/shell.html`
- `otclient/modules/game_shaders/shaders.html`
- `otclient/modules/game_modaldialog/modaldialog.html`
- `otclient/modules/game_htmlsample/htmlsample.html`
- `otclient/modules/game_rewardwall/game_rewardwall.html`
- `otclient/modules/game_rewardwall/#displayUIPickReward.html`
- `otclient/modules/game_questlog/game_questlog.html`
- `otclient/modules/game_actionbar/html/text.html`
- `otclient/modules/game_actionbar/html/passive.html`
- `otclient/modules/game_actionbar/html/object.html`
- `otclient/modules/game_actionbar/html/spells.html`
- `otclient/modules/game_actionbar/html/hotkeys.html`
- `otclient/modules/game_forge/game_forge.html`
- `otclient/modules/game_blessing/blessing.html`

### Arquivos CSS encontrados
- `otclient/modules/game_htmlsample/htmlsample.css`
- `otclient/modules/game_rewardwall/game_rewardwall.css`
- `otclient/modules/game_questlog/game_questlog.css`
- `otclient/modules/game_forge/game_forge.css`
- `otclient/data/styles/html.css` (global)
- `otclient/data/styles/custom.css` (global)

### Módulos/controllers que usam HTML
- `modulelib/controller.lua` (API base `loadHtml/unloadHtml/findWidget/findWidgets/createWidgetFromHTML`)
- `game_questlog/game_questlog.lua`
- `game_forge/game_forge.lua`
- `game_modaldialog/modaldialog.lua`
- `game_htmlsample/htmlsample.lua`
- `game_shaders/shaders.lua`
- `game_rewardwall/game_rewardwall.lua`
- `game_blessing/blessing.lua`
- `game_actionbar/logics/ActionHotkeys.lua`
- `game_actionbar/logics/ActionAssignmentWindows.lua`

### Meta tags e recursos
- `<style>` inline: amplamente usado (modaldialog, blessing, shaders, actionbar...)
- `<link href="...">`: CSS externo por módulo (questlog, rewardwall, htmlsample)
- `<script type="text">`: script inline suportado e executado em contexto de controller (htmlsample).

### Bindings especiais usados
- `*if` (convertido para `*condition-if` internamente)
- `*text`
- `*value`
- `*checked`
- `*for`
- `*visible`, `*disabled`, `*on`, `*color`, `*image-source`, `*item-id`, `*shader`, etc.

## Onde HTML carrega/descarrega
- Carga: `Controller:loadHtml(...)` -> `g_html.load(moduleName,path,parent)` -> `HtmlManager::load`.
- Destruição: `Controller:unloadHtml()` -> `Controller:destroyUI()` -> `g_html.destroy(htmlId)` -> `HtmlManager::destroy`.

## Fluxo de execução (macro)
```text
HTML source
  -> parseHtml() -> HtmlNode tree
  -> readNode() + createWidgetFromNode()
  -> CSS parse/apply (+ estilos globais html.css/custom.css)
  -> mergeStyle OTML nos widgets
  -> __applyOrBindHtmlAttribute (bindings * e attrs)
  -> onCreateByHTML (eventos, label[for], *checked/*value)
  -> runtime Lua (controller) + Query selectors
  -> updates reativos (WidgetWatch + *for watchers)
```

## Observações-chave
1. O sistema **não é browser DOM**; ele converte HTML para widgets OTClient.
2. CSS é usado como camada de estilo declarativa, mas aplicado via propriedades OTML/UIWidget.
3. Bindings com `*` são o núcleo de reatividade (expressão Lua + watch/update).
4. Existem extensões próprias (`*for`, `*image-source`, pseudo `:node-all` etc.) fora do padrão web.
