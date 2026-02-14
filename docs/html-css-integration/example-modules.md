# Example modules (casos de uso reais)

## 1) Quest Log
- HTML: `modules/game_questlog/game_questlog.html`
- CSS: `modules/game_questlog/game_questlog.css`
- Controller: `modules/game_questlog/game_questlog.lua`

Fluxo:
1. `questLogController:onInit()` chama `loadHtml('game_questlog.html')`.
2. Controller captura refs com `findWidget('#...')` e caminhos diretos em `ui`.
3. Eventos de `<select onchange=...>` e botões são roteados para métodos `self:*`.
4. Dados de quests vindos de `g_game` alimentam widgets/listas.

## 2) Forge
- HTML: `modules/game_forge/game_forge.html`
- CSS: `modules/game_forge/game_forge.css`
- Controller: `modules/game_forge/game_forge.lua`

Fluxo:
1. `ForgeController:show()` faz `loadHtml('game_forge.html')` lazy.
2. Tela usa bindings extensivos (`*if`, `*for`, `*checked`, `*disabled`, `*color`, `*image-clip`, etc.).
3. Ações de usuário (`onclick`, `onhover`) chamam handlers de domínio (fusion/transfer/conversion/history).
4. Estado controller -> binding watch -> atualização reativa da UI.

## 3) ModalDialog
- HTML: `modules/game_modaldialog/modaldialog.html`
- CSS: inline `<style>` no próprio HTML
- Controller: `modules/game_modaldialog/modaldialog.lua`

Fluxo:
1. `controllerModal:loadHtml('modaldialog.html')`.
2. Widgets dinamicamente inseridos com `createWidgetFromHTML(choiceHtml, parent)`.
3. Fechamento por `onescape`/`onclick` dispara `unloadHtml()`.

## 4) HTML Sample (módulo demonstrativo)
- HTML: `modules/game_htmlsample/htmlsample.html`
- CSS: `modules/game_htmlsample/htmlsample.css`
- Controller: `modules/game_htmlsample/htmlsample.lua`

Destaques:
- `<script type="text">` inicializa variáveis no `self`.
- `{{...}}` para texto dinâmico.
- `*for` iterando lista de jogadores.
- `*value` e `*checked` com two-way binding.

## 5) Reward Wall
- HTML: `modules/game_rewardwall/game_rewardwall.html`
- CSS: `modules/game_rewardwall/game_rewardwall.css`
- Controller: `modules/game_rewardwall/game_rewardwall.lua`

Destaques:
- uso de `<link href="...css" />`.
- muitos handlers `onhover`/`onclick` via atributos HTML.
- integração com requests de backend e atualização visual.

## 6) Shaders
- HTML: `modules/game_shaders/shaders.html`
- CSS: inline `<style>`
- Controller: `modules/game_shaders/shaders.lua`

Destaques:
- `<select onchange="...">` para map/outfit/mount/text shaders.
- load com parent custom: `self:loadHtml('shaders.html', modules.game_interface.getMapPanel())`.

## 7) Blessing
- HTML: `modules/game_blessing/blessing.html`
- CSS: inline `<style>`
- Controller: `modules/game_blessing/blessing.lua`

Destaques:
- `*if` e `*on` para visibilidade/estado premium.
- alterna entre `loadHtml` e `unloadHtml` durante show/hide.

## Login e Inventory
Na varredura atual, **não foi encontrado** módulo de Login/Inventory usando `loadHtml(...)`.
Essas telas permanecem majoritariamente no pipeline OTUI tradicional nesta base.
