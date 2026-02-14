# CSS properties

## Pipeline CSS
1. `css::parse(cssText)` gera `StyleSheet` (regras + seletores + declarations + `!important`).
2. `HtmlManager::applyStyleSheet(...)` executa selector matching em `HtmlNode::querySelectorAll`.
3. Declarações são acumuladas no mapa de estilos do nó (`styles`, `$hover`, `$focus`, etc.).
4. `applyAttributesAndStyles` converte para OTML e chama `widget->mergeStyle(...)`.

## Pseudos/estado suportados na camada CSS
Mapeados para estados de widget:
- `:hover`, `:focus`, `:active`, `:checked`, `:disabled`, `:pressed`, `:dragging`
- `:first-child`, `:last-child`, `:nth-child(even|odd|an+b)`
- `:first-of-type`, `:last-of-type`, `:nth-of-type`, `:nth-last-of-type`
- `:not(...)`, `:is(...)`, `:where(...)`, `:has(...)`

## Propriedades UI/OTML explicitamente suportadas
(derivadas do parser de estilo base de `UIWidget::parseBaseStyle`):
- dimensões/posição: `x`, `y`, `pos`, `width`, `height`, `min-width`, `max-width`, `min-height`, `max-height`, `rect`, `size`, `min-size`, `max-size`, `top/right/bottom/left`, `position`
- box model: `margin*`, `padding*`, `border*`, `opacity`, `rotation`
- visibilidade/interação: `visible`, `visibility`, `enabled`, `checked`, `on`, `focusable`, `draggable`, `phantom`, `pointer-events`, `clipping`
- draw assets: `background*`, `icon*`, `shader`, draw orders (`background-draw-order`, `image-draw-order`, `icon-draw-order`, `border-draw-order`, `text-draw-order`)
- layout: `layout`, `display`, `overflow`, `float`, `clear`, `justify-items`
- flex: `flex-direction`, `flex-wrap`, `justify-content`, `align-items`, `align-content`, `gap`, `row-gap`, `column-gap`, `flex`, `flex-grow`, `flex-shrink`, `flex-basis`, `order`, `align-self`
- texto/cor: `color`, `line-height`
- eventos declarativos: `events`

## Propriedades herdáveis no HTML manager
`isInheritable()` considera herdáveis:
`color`, `cursor`, `direction`, `font*`, `letter-spacing`, `line-height`, `text-*`, `unicode-bidi`, `white-space`, `word-spacing`, `writing-mode`, `hyphens`, `text-lang`.

## Diferenças vs CSS de browser
- Não é CSSOM web completo.
- Unidades e parsing são orientados ao motor OTML/UIWidget.
- Propriedades podem ser nomes OTML diretos (`--image-source`, etc.).
- Media queries não filtram por viewport real no parser atual (blocos `@media` são processados recursivamente sem checagem de condição real).

## CSS não suportado (prático)
- Qualquer propriedade sem mapeamento em UIWidget/OTML tende a ser ignorada/sem efeito visual.
- Recursos web avançados (grid CSS completo de browser, calc sofisticado, variáveis CSS padrão runtime, animations keyframes web) não são equivalentes 1:1.

## Sugestões
- adicionar validação/linter para declarar warning de propriedade desconhecida.
- documentar oficialmente tabela de compatibilidade CSS-OTML.
