# API reference

## g_html (singleton)

### `g_html.load(moduleName, htmlPath, parent) -> htmlId`
Carrega HTML do módulo, parseia, cria widgets e retorna ID raiz.

### `g_html.destroy(htmlId)`
Destrói widgets e grupos associados ao HTML.

### `g_html.getRootWidget(htmlId) -> UIWidget|nil`
Retorna primeiro widget filho dentro de `<html>`.

### `g_html.createWidgetFromHTML(htmlString, parent, htmlId) -> UIWidget|nil`
Parse dinâmico de trecho HTML e inserção no parent dentro do contexto de um HTML root existente.

### `g_html.addGlobalStyle(path)`
Adiciona stylesheet global (ex.: `data/styles/html.css`, `custom.css`).

---

## Controller helpers (modulelib)

### `Controller:loadHtml(path, parent?)`
Wrapper de `g_html.load`; define `self.htmlId` e `self.ui`.

### `Controller:unloadHtml()`
Descarrega HTML atual (`g_html.destroy`) via `destroyUI`.

### `Controller:findWidget(cssQuery)`
Retorna `self.ui:querySelector(...)`.

### `Controller:findWidgets(cssQuery)`
Retorna `self.ui:querySelectorAll(...)`.

### `Controller:createWidgetFromHTML(html, parent)`
Wrapper de `g_html.createWidgetFromHTML` usando `self.htmlId`.

---

## UIWidget methods

### `widget:querySelector(selector) -> UIWidget|nil`
Busca primeiro nó que casa com o seletor.

### `widget:querySelectorAll(selector) -> UIWidget[]`
Busca todos os nós que casam.

### `widget:append(htmlString) -> UIWidget|nil`
Insere HTML no final dos filhos.

### `widget:prepend(htmlString) -> UIWidget|nil`
Insere no início.

### `widget:insert(index, htmlString) -> UIWidget|nil`
Insere em posição específica.

### `widget:html(htmlString) -> UIWidget|nil`
Destrói filhos atuais e substitui por novo conteúdo.

### `widget:remove(cssQuery) -> number`
Remove nós filhos que casarem com query.

### `widget:isOnHtml() -> bool`
Indica se o widget está vinculado ao pipeline HTML.

---

## HtmlNode (engine-level)
- `querySelector`, `querySelectorAll`
- `append`, `prepend`, `insert`, `remove`, `clear`, `destroy`
- `innerHTML`, `outerHTML`, `setInnerHTML`, `setOuterHTML`

> Normalmente acessado via `UIWidget`, não diretamente pelos módulos Lua de jogo.
