# HTML parsing

## Parser interno
O parse é feito por `parseHtml(const std::string&)` em `framework/html/htmlparser.cpp`.

Características:
- tokenização manual com suporte a:
  - tags de abertura/fechamento;
  - comentários `<!-- -->`;
  - doctype `<!...>`;
  - atributos com nome estendido (`*`, `@`, `.`, `[]`, `()` e `#` no nome);
  - entidades HTML (`&amp;`, `&#...`, `&#x...`).
- tags void (`img`, `input`, `link`, `meta`, etc.) tratadas como self-contained.
- regras de fechamento implícito (`p`, `li`, `tr`, `td`, etc.) para robustez de markup.

## Construção da árvore DOM-like
A raiz sintética é `tag="root"`, tipo `Element`.
Cada nó é `HtmlNode` com:
- tipo (`Element`, `Text`, `Comment`, `Doctype`);
- `tag`, atributos, classes;
- relação pai/filhos/irmãos;
- índices auxiliares por `id`, `class`, `tag` para acelerar seleção.

## Expressões `{{ ... }}`
Quando parser encontra texto fora de container raw:
- divide literal e expressão;
- cria `HtmlNode` `Text` com `isExpression=true` para conteúdo em `{{ ... }}`.
No build de widget, expressão vira binding `*text`.

## Tratamento de script/style
`script` e `style` são tratados como texto raw no parser.
No `HtmlManager::readNode`:
- `<style>` -> vai para `css::parse(...)`;
- `<link href>` -> carrega arquivo CSS e parseia;
- `<script>` -> string é passada para `UIWidget:__scriptHtml(...)` no root widget.

## Conversão para widgets
`createWidgetFromNode(...)`:
1. resolve estilo-base por tag (`input` -> `TextEdit/QtCheckBox`, `select` -> `QtComboBox`, `textarea` -> `MultilineTextEdit`, `hr` -> `HorizontalSeparator`);
2. cria widget (`g_ui.createWidget`);
3. associa `HtmlNode` ao widget (`setHtmlNode`, `setHtmlRootId`);
4. processa filhos recursivamente.

## Casos especiais no parse/build
- `*for` em child é interceptado por `checkSpecialCase()` e delegado para `__childFor` no parent.
- `<select><option ...>` usa `addOptionFromHtml`.
- scripts podem inicializar estado do controller antes do uso da árvore.

## Limitações importantes
- não há engine JS/DOM completa (apenas execução Lua controlada de scripts inline).
- parsing é tolerante, porém focado no subset usado pelo client.
- comportamento de whitespace é custom (standalone whitespace text nodes podem ser descartados).
