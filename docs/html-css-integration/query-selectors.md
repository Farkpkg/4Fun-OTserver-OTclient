# Query selectors

## API disponível
- `HtmlNode::querySelector(selector)`
- `HtmlNode::querySelectorAll(selector)`
- `UIWidget::querySelector(selector)`
- `UIWidget::querySelectorAll(selector)`
- wrappers de controller:
  - `Controller:findWidget(query)`
  - `Controller:findWidgets(query)`

## Seletores suportados
- tag (`div`, `button`, `window`)
- id (`#myId`)
- classe (`.classA.classB`)
- atributos (`[attr]`, `[attr=value]`, `~=`, `^=`, `$=`, `*=`, `|=`)
- combinadores:
  - descendente (`A B`)
  - filho direto (`A > B`)
  - adjacente (`A + B`)
  - irmãos gerais (`A ~ B`)
- lista separada por vírgula (`A, B, C`)

## Pseudo-classes
- estado: `:hover`, `:focus`, `:active`, `:focus-visible`, `:focus-within`
- estrutura: `:first-child`, `:last-child`, `:only-child`, `:empty`, `:root`, `:scope`
- nth: `:nth-child(...)`, `:nth-last-child(...)`, `:nth-of-type(...)`, `:nth-last-of-type(...)`
- compostos: `:not(...)`, `:is(...)`, `:where(...)`, `:has(...)`
- extensão OTClient: `:node-all` / `:all-node` / `:nodes` para incluir text nodes

## Estratégia de execução
- parser compila seletor para steps + combinators.
- fase seed otimiza usando índices de `id`, `class`, `tag` no document root.
- matching faz backtracking de combinadores até bater selector inteiro.

## Uso prático
- Controllers usam `findWidget('#id')` para cache de refs.
- manipulação dinâmica usa `widget:querySelectorAll('.line')` e depois altera props.

## Limitações
- não é seletor CSS 100% browser; subset + extensões custom.
- `querySelector` retorna primeiro match na ordem de busca interna (não garante semântica completa de browser em todos edge cases).
