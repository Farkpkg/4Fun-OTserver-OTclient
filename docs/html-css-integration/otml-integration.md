# OTML integration

## Conversão CSS -> OTML
No `HtmlManager::applyAttributesAndStyles`:
1. estilos resolvidos + inline style são mesclados;
2. cada propriedade vira `OTMLNode(tag=prop, value=...)`;
3. metaprops (pseudo states) viram nós filhos (`$hover`, `$focus`, etc.);
4. widget recebe `mergeStyle(otml)`.

## Prefixo `--`
No parser CSS (`parse_decls`):
- propriedade iniciando com `--` tem prefixo removido antes de virar declaration.
Isso permite escrever, por ex.:
- `--image-source`, `--icon-color`, `--text-auto-resize` etc.

## Integração com estilos OTUI
- classes de HTML (`class="..."`) chamam `g_ui.getStyle(className)` e `widget->mergeStyle(style)`.
- tags HTML podem mapear para estilos OTUI específicos (`QtComboBox`, `TextEdit`, `MultilineTextEdit`...).
- controllers frequentemente fazem `g_ui.importStyle('...otui')` + `loadHtml(...)`.

## Atributos especiais de imagem
Tag `<img ...>` traduz atributos para namespace OTML de imagem:
- `src -> image-source`
- `clip -> image-clip`
- `size -> image-size`
- `offset -> image-offset`
- etc.

## Anchors/layout em HTML
Atributo `layout="key: value; ..."` é parseado e convertido para bloco OTML `layout`.
Também existem propriedades `anchors.*` no mecanismo base de style.

## Widgets custom
Qualquer estilo existente no UIManager pode ser instanciado por tag equivalente.
Ex.: `uicreature`, `GoldLabel2`, `RewardButton3`, etc. em módulos HTML.

## Conclusão
A integração HTML/CSS do OTClient é, na prática, uma DSL que compila para OTML + `UIWidget`.
Não substitui OTML; ela o encapsula com sintaxe mais web-like e bindings reativos.
