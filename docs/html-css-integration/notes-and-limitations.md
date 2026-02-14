# Notes and limitations

## Diagrama textual (mapa de dependências)
```text
HTML source (.html)
  -> htmlparser.cpp (parseHtml)
  -> HtmlNode tree (id/class/tag indexes)
  -> htmlmanager.cpp (createWidgetFromNode)
  -> cssparser.cpp (parse style/link/global css)
  -> applyStyleSheet + selector match (queryselector.cpp)
  -> OTML mergeStyle (UIWidget::mergeStyle)
  -> Lua bridge (__applyOrBindHtmlAttribute / onCreateByHTML / __scriptHtml)
  -> Controller methods + events
  -> UI update (WidgetWatch, onChange/onClick/onHover, *for reactivity)
```

## Limitações estruturais
1. Não é browser engine completa: sem JS DOM APIs padrão, sem layout web full.
2. Compatibilidade CSS parcial e orientada a OTML/UIWidget.
3. `@media` é parseado, porém sem semântica completa de media query runtime de browser.
4. Propriedades não mapeadas para widget style podem não ter efeito.
5. `loadHtml(path,parent)` no Controller usa `g_ui.getRootWidget()` no load interno atual.

## Código em experimentação/legado
- Existem comentários de incompatibilidade CSS em módulos (`modaldialog.lua`, largura 100%).
- Há HTML com script comentado (`game_actionbar/html/passive.html`).
- Alguns módulos misturam HTML e criação manual `g_ui.createWidget(...)`.

## Possíveis bugs/riscos
- markup muito dinâmico com `*for` em listas grandes pode gerar churn de widgets.
- seletores amplos em CSS podem gerar custo elevado sem necessidade.
- duplicate IDs em subtree HTML geram warning no runtime (`uiwidgethtml.cpp`).

## Melhorias sugeridas
- tabela oficial de compatibilidade CSS/HTML por versão do client;
- validação estática de bindings (`*expr`) antes da execução;
- profiler de query selector e watchers por tela;
- documentação oficial de eventos HTML suportados e payloads.
