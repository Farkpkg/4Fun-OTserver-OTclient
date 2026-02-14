# Events and bindings

## Bindings `*` (reactividade)
O método central é `UIWidget:__applyOrBindHtmlAttribute(attr, value, ...)`.

Comportamento:
- atributo sem `*`: valor direto aplicado em `setXxx` (ou campo Lua fallback);
- atributo com `*`: expressão Lua compilada para função e registrada em watch (`WidgetWatch`) para atualização incremental;
- `*if` é traduzido para `*condition-if` no C++ (`translateAttribute`);
- `*style` é traduzido para `*mergeStyle`;
- para widgets não checkbox/combobox, `*value` vira `*text`.

Bindings comuns encontrados em produção:
- `*if`, `*for`, `*text` (expressões `{{...}}`), `*value`, `*checked`, `*visible`, `*disabled`, `*on`, `*color`, `*image-source`, `*shader`, `*item-id`.

## `*for`
- Capturado em `HtmlManager::checkSpecialCase` e delegado para `UIWidget:__childFor`.
- `__childFor` implementa loop reativo com `table.watchList` (onInsert/onRemove), suportando aliases (`index`, `first`, `last`, `even`, `odd`, etc.).

## Eventos HTML -> Lua
`UIWidget:onCreateByHTML` varre atributos iniciando por `on...` e usa `parseEvents`.

Tabela de tradução principal (`EVENTS_TRANSLATED`):
- `onclick -> onClick`
- `ondoubleclick -> onDoubleClick`
- `onkeydown -> onKeyDown`
- `onkeypress -> onKeyPress`
- `onkeyup -> onKeyUp`
- `onmouse* -> onMouse*`
- `onhover -> onHoverChange`
- `onescape -> onEscape`
- `onfocus -> onFocusChange`
- `ontextchange -> onTextChange`
- etc.

`onchange` é especial e varia por widget:
- `UIComboBox`: `onOptionChange`
- `UICheckBox`: `onCheckChange`
- `UIRadioGroup`: `onSelectionChange`
- `UIScrollBar`: `onValueChange`
- fallback em inputs: `onTextChange`

## Binding reverso de input
Além de leitura, o sistema escreve de volta no controller:
- `*checked`: registra `onCheckChange` e atribui valor via expressão alvo;
- `*value`: usa `onTextChange` ou `onOptionChange` para atualizar campo Lua.

## `label for="..."`
`onCreateByHTML` implementa click forwarding:
- clique no `<label for="id">` chama `onClick` no widget referenciado.

## Script inline
`<script type="text">` vira callback `__scriptHtml(moduleName, script, nodeString)`, executada em contexto do controller (`self`).

## Limitações
- sem sandbox JS; script é Lua embutido.
- erro de expressão/evento é reportado via `ExprHandlerError` (warnings), não interrompe engine inteira.
