# Performance

## Custos principais do pipeline
1. **Parsing inicial**: `parseHtml` + `css::parse` (CPU proporcional ao tamanho do markup/css).
2. **Matching CSS**: `querySelectorAll` para cada regra; custo cresce com número de regras e nós.
3. **Criação de widgets**: cada nó HTML element vira `UIWidget`; profundidade e quantidade impactam layout.
4. **Bindings/watchers**: atributos `*` registram observadores e funções de avaliação de expressão.
5. **`*for` reativo**: listas grandes podem gerar inserções/remoções frequentes de subtree.

## Pontos de atenção
- Módulos como Forge possuem HTML grande + muitos bindings (`*if/*for/*...`) e handlers `onhover`.
- `createWidgetFromHTML` em loop pode fragmentar hierarquia se usado sem pooling.
- selectors muito genéricos (`*`, descendentes profundos) aumentam custo de consulta.

## Boas práticas
- preferir IDs/classes específicas em `findWidget/findWidgets`;
- minimizar `*for` em listas massivas sem paginação/virtualização;
- evitar script inline pesado em `<script type="text">`;
- usar `unloadHtml()` quando a tela não está ativa para liberar watchers e widgets;
- manter CSS modular por feature e evitar regras globais excessivas.

## O que já ajuda no engine
- indexação por id/class/tag em `HtmlNode` acelera seeds dos seletores;
- `querySelector` para primeiro match evita varredura completa de retorno;
- widget destroy no `g_html.destroy` limpa subtree e grupos auxiliares.
