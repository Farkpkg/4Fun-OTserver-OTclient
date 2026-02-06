---
alwaysApply: true
---
# Guia OTUI

## Escopo

- Documenta formato OTUI, layouts e propriedades de widgets.
- OTUI é parseado por `OTMLDocument`/`OTMLNode` (framework OTML) e consumido por `UIManager`.
- Os termos técnicos seguem a nomenclatura original em inglês.
- Para detalhes do framework de UI em C++, consulte `src/framework/ui/AGENTS.md`.
- Para traducoes e I18N, consulte `data/locales/AGENTS.md`.

## Estrutura da pasta data (assets)

- `data/styles/`: estilos OTUI base (carregados por `modules/client_styles/AGENTS.md`).
- `data/things/<versao>/`: assets de Things (appearances/sprites/catalog). Veja `src/client/assets.md` e `src/protobuf/AGENTS.md`.
- `data/particles/`: efeitos `.otps` e texturas (carregados via `g_particles`).
- `data/images/`: sprites e UI images.
- `data/fonts/`: fontes `.otfont` e assets de fonte.
- `data/cursors/`: cursores.
- `data/sounds/`: audio.
- `data/json/`: configs auxiliares.
- `data/locales/`: traducoes.

### Shaders e styles

- Propriedade `shader:` pode aparecer em OTUI (ex: janelas/outfit).
- Shaders GLSL vivem em `modules/game_shaders/AGENTS.md`.

## Formato OTUI

Formato declarativo de UI (OTML) para widgets, estilos e layouts. A base de parsing e execucao fica no C++ (ver `src/framework/ui/AGENTS.md` e `src/framework/otml`).

---

# OTUI Layouts Documentation

Layouts in OTUI are used to organize and position child widgets within a parent widget. Each layout type has specific properties and behaviors that can be configured in OTUI files.

---

## 1. **Box Layout**

### Description
The `UIBoxLayout` is a base class for layouts that arrange widgets in a single direction (horizontal or vertical). It provides basic properties like spacing and child fitting.

### Common Properties
- **`spacing`**: Sets the spacing between child widgets.
  - **Type**: Integer.
  - **Example**: `spacing: 10`
- **`fit-children`**: Automatically adjusts the parent widget's size to fit its children.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `fit-children: true`

---

## 2. **Vertical Layout**

### Description
The `UIVerticalLayout` arranges child widgets vertically, from top to bottom or bottom to top (if `align-bottom` is enabled).

### Properties
- **`align-bottom`**: Aligns child widgets to the bottom of the parent widget.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `align-bottom: true`

### Example
```otui
VerticalLayout
  spacing: 5
  fit-children: true
  align-bottom: false
  children:
    Label
      text: "Item 1"
    Label
      text: "Item 2"
```

---

## 3. **Horizontal Layout**

### Description
The `UIHorizontalLayout` arranges child widgets horizontally, from left to right or right to left (if `align-right` is enabled).

### Properties
- **`align-right`**: Aligns child widgets to the right of the parent widget.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `align-right: true`

### Example
```otui
HorizontalLayout
  spacing: 10
  fit-children: true
  align-right: false
  children:
    Button
      text: "OK"
    Button
      text: "Cancel"
```

---

## 4. **Grid Layout**

### Description
The `UIGridLayout` arranges child widgets in a grid with configurable cell sizes, spacing, and flow.

### Properties
- **`cell-size`**: Sets the size of each grid cell.
  - **Type**: `Size` (e.g., `width height`).
  - **Example**: `cell-size: 50 50`
- **`cell-width`**: Sets the width of each grid cell.
  - **Type**: Integer.
  - **Example**: `cell-width: 50`
- **`cell-height`**: Sets the height of each grid cell.
  - **Type**: Integer.
  - **Example**: `cell-height: 50`
- **`cell-spacing`**: Sets the spacing between grid cells.
  - **Type**: Integer.
  - **Example**: `cell-spacing: 5`
- **`num-columns`**: Sets the number of columns in the grid.
  - **Type**: Integer.
  - **Example**: `num-columns: 3`
- **`num-lines`**: Sets the number of rows in the grid.
  - **Type**: Integer.
  - **Example**: `num-lines: 2`
- **`fit-children`**: Automatically adjusts the parent widget's size to fit its children.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `fit-children: true`
- **`auto-spacing`**: Automatically adjusts spacing between cells to fit the grid.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `auto-spacing: true`
- **`flow`**: Enables flow layout, where widgets are placed in rows based on available space.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `flow: true`

### Example
```otui
GridLayout
  cell-size: 50 50
  cell-spacing: 10
  num-columns: 3
  fit-children: true
  flow: true
  children:
    Button
      text: "1"
    Button
      text: "2"
    Button
      text: "3"
    Button
      text: "4"
```

---

## 5. **Anchor Layout**

### Description
The `UIAnchorLayout` allows precise positioning of child widgets by anchoring them to specific edges or centers of other widgets or the parent widget.

### Properties
- **`anchors.*`**: Defines anchors for the widget. Anchors specify how a widget is positioned relative to another widget or the parent widget.
  - **Type**: String (e.g., `fill`, `centerIn`, or `widget.edge`).
  - **Examples**:
    - `anchors.fill: parent`
    - `anchors.centerIn: parent`
    - `anchors.left: otherWidget.right`

### Special Anchors
- **`fill`**: Stretches the widget to fill the parent or another widget.
- **`centerIn`**: Centers the widget within the parent or another widget.

### Example
```otui
AnchorLayout
  children:
    Label
      text: "Centered"
      anchors.centerIn: parent
    Button
      text: "Bottom Right"
      anchors.bottom: parent.bottom
      anchors.right: parent.right
```

---

## Summary Table

| Layout Type       | Key Properties                                                                 | Description                                                                 |
|--------------------|--------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **Box Layout**     | `spacing`, `fit-children`                                                     | Base layout for vertical and horizontal layouts.                           |
| **Vertical Layout**| `align-bottom`                                                               | Arranges widgets vertically.                                               |
| **Horizontal Layout**| `align-right`                                                              | Arranges widgets horizontally.                                             |
| **Grid Layout**    | `cell-size`, `cell-spacing`, `num-columns`, `fit-children`, `flow`            | Arranges widgets in a grid.                                                |
| **Anchor Layout**  | `anchors.*`                                                                  | Positions widgets using anchors relative to other widgets or the parent.   |

---

This documentation provides an overview of how to use layouts in OTUI files, including their properties and examples. Each layout type is designed to handle specific use cases for widget arrangement and positioning.# Guia de Edição de Arquivos OTUI para LLMs

Este documento descreve as regras e melhores práticas para editar arquivos OTUI corretamente, evitando erros de configuração de layout. Baseado na análise do editor OTUI (`Otui.py`).

---

## 📋 Índice

1. [Sistema de Coordenadas](#sistema-de-coordenadas)
2. [Layouts Automáticos](#layouts-automáticos)
3. [Sistema de Anchors](#sistema-de-anchors)
4. [Padding e Margins](#padding-e-margins)
5. [Regras de Exclusão Mútua](#regras-de-exclusão-mútua)
6. [Ordem de Processamento](#ordem-de-processamento)
7. [Erros Comuns e Como Evitá-los](#erros-comuns-e-como-evitá-los)
8. [Exemplos Práticos](#exemplos-práticos)

---

## 🎯 Sistema de Coordenadas

### Regra Fundamental: Coordenadas Sempre Relativas

**IMPORTANTE**: A propriedade `pos` **SEMPRE** representa coordenadas **relativas ao widget pai**, nunca coordenadas absolutas na tela.

```otui
UIWindow
  id: mainWindow
  size: 800 600
  pos: 0 0  # Posição relativa à cena (raiz)

  UILabel
    id: titleLabel
    pos: 10 20  # Posição relativa ao mainWindow, não à tela!
    size: 200 30
```

### Como Funciona

- **Widget Raiz**: `pos: 0 0` = origem da cena
- **Widget Filho**: `pos: 10 20` = 10px da esquerda e 20px do topo **do pai**, não da tela

### ❌ Erro Comum

```otui
# ERRADO - Assumir coordenadas absolutas
UIWindow
  id: parent
  size: 400 300

  UILabel
    id: child
    pos: 500 500  # ERRADO! Isso coloca o widget FORA do pai
```

### ✅ Correto

```otui
# CORRETO - Coordenadas relativas ao pai
UIWindow
  id: parent
  size: 400 300

  UILabel
    id: child
    pos: 50 50  # CORRETO! 50px da esquerda e topo do pai
```

---

## 📐 Layouts Automáticos

### Tipos de Layout

O OTUI suporta dois tipos de layout automático:

1. **`layout: vertical`** - Organiza filhos verticalmente (de cima para baixo)
2. **`layout: horizontal`** - Organiza filhos horizontalmente (da esquerda para direita)

### Regra Crítica: Widgets em Layout NÃO TÊM `pos`

**Quando um widget pai tem `layout: vertical` ou `layout: horizontal`, os filhos NÃO devem ter a propriedade `pos` definida.**

O layout calcula automaticamente a posição dos filhos baseado em:
- Ordem de declaração
- `layout-spacing` (espaçamento entre filhos)
- `padding` do container
- `layout-align` (alinhamento)

### ❌ Erro Comum

```otui
# ERRADO - Definir pos em widgets dentro de layout
UIWindow
  id: container
  layout: vertical
  layout-spacing: 5
  padding: 10

  UILabel
    id: label1
    pos: 10 20  # ERRADO! Layout vai ignorar ou causar conflito
    size: 100 30

  UILabel
    id: label2
    pos: 10 60  # ERRADO! Layout vai ignorar ou causar conflito
    size: 100 30
```

### ✅ Correto

```otui
# CORRETO - Deixar o layout calcular as posições
UIWindow
  id: container
  layout: vertical
  layout-spacing: 5
  padding: 10

  UILabel
    id: label1
    # SEM pos - layout calcula automaticamente
    size: 100 30

  UILabel
    id: label2
    # SEM pos - layout calcula automaticamente
    size: 100 30
```

### Propriedades de Layout

```otui
UIWindow
  id: container
  layout: vertical          # ou 'horizontal'
  layout-spacing: 10      # Espaçamento entre filhos
  layout-align: center     # Alinhamento (left/center/right para vertical, top/center/bottom para horizontal)
  padding: 10               # Padding interno do container
```

### Como o Layout Funciona

1. **Layout Vertical**:
   - Posiciona filhos de cima para baixo
   - Respeita `padding` (top, right, bottom, left)
   - Adiciona `layout-spacing` entre cada filho
   - Alinha horizontalmente baseado em `layout-align`

2. **Layout Horizontal**:
   - Posiciona filhos da esquerda para direita
   - Respeita `padding`
   - Adiciona `layout-spacing` entre cada filho
   - Alinha verticalmente baseado em `layout-align`

### Exceção: Widgets com Anchors

Widgets que usam `anchors.*` **podem** estar dentro de um layout, mas o layout **ignora** esses widgets. Apenas widgets sem anchors e sem `pos` são organizados pelo layout.

---

## 🔗 Sistema de Anchors

### O que são Anchors?

Anchors permitem posicionar widgets relativamente às bordas ou centro de outro widget (geralmente o pai).

### Tipos de Anchors

```otui
anchors.fill: parent                    # Preenche todo o espaço do pai
anchors.left: parent.left               # Ancora à esquerda do pai
anchors.right: parent.right            # Ancora à direita do pai
anchors.top: parent.top                 # Ancora ao topo do pai
anchors.bottom: parent.bottom           # Ancora à base do pai
anchors.horizontalCenter: parent        # Centraliza horizontalmente
anchors.verticalCenter: parent          # Centraliza verticalmente
anchors.centerIn: parent                # Centraliza completamente
```

### Regra: Anchors Calculam Posição Automaticamente

**Quando um widget usa anchors, a propriedade `pos` é calculada automaticamente pelo sistema.** Não defina `pos` manualmente quando usar anchors.

### ❌ Erro Comum

```otui
# ERRADO - Definir pos com anchors
UIWindow
  id: parent
  size: 400 300

  UILabel
    id: child
    anchors.fill: parent
    pos: 10 10  # ERRADO! Anchors sobrescrevem pos
```

### ✅ Correto

```otui
# CORRETO - Deixar anchors calcular pos
UIWindow
  id: parent
  size: 400 300

  UILabel
    id: child
    anchors.fill: parent
    # SEM pos - anchors calculam automaticamente
```

### Anchors e Margins

Você pode combinar anchors com margins:

```otui
UILabel
  id: label
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.top: parent.top
  margin-left: 10
  margin-right: 10
  margin-top: 5
  # O widget terá largura = largura do pai - 20px (margins)
  # E estará 5px abaixo do topo
```

### Anchors e Padding do Pai

**IMPORTANTE**: Anchors respeitam o `padding` do widget pai. O espaço interno (após padding) é usado para cálculo.

```otui
UIWindow
  id: container
  size: 400 300
  padding: 20  # Padding de 20px em todos os lados

  UILabel
    id: child
    anchors.fill: parent
    # O label terá tamanho 360x260 (400-40, 300-40)
    # E posição 20,20 (dentro do padding)
```

---

## 📏 Padding e Margins

### Diferença entre Padding e Margin

- **`padding`**: Espaço interno do widget (dentro das bordas)
- **`margin-*`**: Espaço externo do widget (fora das bordas)

### Formato de Padding

```otui
padding: 10              # Todos os lados: 10px
padding: 10 20           # Vertical: 10px, Horizontal: 20px
padding: 10 20 30 40     # Top: 10px, Right: 20px, Bottom: 30px, Left: 40px
```

### Formato de Margin

```otui
margin-top: 10
margin-right: 20
margin-bottom: 30
margin-left: 40
```

### Como Padding Afeta Layouts

O padding reduz o espaço disponível para os filhos:

```otui
UIWindow
  id: container
  size: 400 300
  layout: vertical
  padding: 20  # Reduz espaço interno para 360x260
  layout-spacing: 5

  UILabel
    id: label1
    size: 100 30
    # Será posicionado em (20, 20) - dentro do padding

  UILabel
    id: label2
    size: 100 30
    # Será posicionado em (20, 55) - 20 (padding) + 30 (altura label1) + 5 (spacing)
```

---

## ⚠️ Regras de Exclusão Mútua

### Regra 1: Layout vs Pos

**NÃO combine `layout` no pai com `pos` nos filhos.**

```otui
# ERRADO
UIWindow
  layout: vertical
  UILabel
    pos: 10 20  # Conflito! Layout vai ignorar ou causar comportamento inesperado

# CORRETO
UIWindow
  layout: vertical
  UILabel
    # SEM pos - layout calcula
```

### Regra 2: Anchors vs Pos

**NÃO defina `pos` quando usar `anchors.*`.**

```otui
# ERRADO
UILabel
  anchors.fill: parent
  pos: 10 20  # Conflito! Anchors sobrescrevem pos

# CORRETO
UILabel
  anchors.fill: parent
  # SEM pos - anchors calculam
```

### Regra 3: Layout vs Anchors

**Widgets com anchors são ignorados pelo layout.** Isso é permitido, mas entenda o comportamento:

```otui
UIWindow
  id: container
  layout: vertical
  layout-spacing: 5

  UILabel
    id: inLayout
    # Este widget será organizado pelo layout

  UILabel
    id: anchored
    anchors.fill: parent
    # Este widget é IGNORADO pelo layout
    # O layout só organiza widgets sem anchors e sem pos
```

### Regra 4: Múltiplos Anchors

Você pode combinar múltiplos anchors:

```otui
# Estica horizontalmente, ancora ao topo
UILabel
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.top: parent.top
  margin-top: 10
  margin-left: 10
  margin-right: 10
```

---

## 🔄 Ordem de Processamento

O sistema processa as propriedades nesta ordem:

1. **Anchors** (se presentes) - Calcula posição e tamanho
2. **Layout** (se presente no pai) - Organiza filhos sem anchors e sem pos
3. **Pos manual** (se não houver anchors) - Usa posição definida

### Prioridade

```
Anchors > Layout > Pos Manual
```

### Exemplo de Processamento

```otui
UIWindow
  id: parent
  size: 400 300
  layout: vertical
  padding: 10

  UILabel
    id: child1
    # SEM anchors, SEM pos
    # → Layout organiza este widget

  UILabel
    id: child2
    anchors.fill: parent
    # → Anchors calculam posição (ignora layout)

  UILabel
    id: child3
    pos: 50 50
    # → Usa pos manual (ignora layout, pois tem pos definida)
```

---

## 🐛 Erros Comuns e Como Evitá-los

### Erro 1: Coordenadas Absolutas

**Problema**: Assumir que `pos` é absoluta na tela.

```otui
# ERRADO
UIWindow
  size: 400 300
  UILabel
    pos: 500 500  # Widget fora do pai!
```

**Solução**: Sempre pensar em coordenadas relativas ao pai.

```otui
# CORRETO
UIWindow
  size: 400 300
  UILabel
    pos: 50 50  # Relativo ao pai
```

### Erro 2: Pos em Layout

**Problema**: Definir `pos` em widgets dentro de layout.

```otui
# ERRADO
UIWindow
  layout: vertical
  UILabel
    pos: 10 20  # Layout ignora ou causa conflito
```

**Solução**: Remover `pos` e deixar o layout calcular.

```otui
# CORRETO
UIWindow
  layout: vertical
  UILabel
    # SEM pos
```

### Erro 3: Pos com Anchors

**Problema**: Definir `pos` quando usar anchors.

```otui
# ERRADO
UILabel
  anchors.fill: parent
  pos: 10 10  # Anchors sobrescrevem
```

**Solução**: Remover `pos` quando usar anchors.

```otui
# CORRETO
UILabel
  anchors.fill: parent
  # SEM pos
```

### Erro 4: Ignorar Padding

**Problema**: Não considerar padding ao calcular posições.

```otui
# ERRADO - Assumir que pos: 0 0 é no canto do pai
UIWindow
  padding: 20
  UILabel
    pos: 0 0  # Na verdade está em (20, 20) devido ao padding
```

**Solução**: Entender que padding afeta o espaço interno.

```otui
# CORRETO - Padding reduz espaço disponível
UIWindow
  padding: 20
  UILabel
    pos: 0 0  # Está 20px da borda do pai (dentro do padding)
```

### Erro 5: Layout sem Filhos

**Problema**: Definir layout sem filhos (não é erro, mas inútil).

```otui
# Funciona, mas não faz nada
UIWindow
  layout: vertical
  # SEM filhos
```

**Solução**: Layout só faz sentido com filhos.

### Erro 6: Múltiplos Sistemas de Posicionamento

**Problema**: Tentar usar layout, anchors e pos ao mesmo tempo.

```otui
# ERRADO - Confuso e pode causar comportamento inesperado
UIWindow
  layout: vertical
  UILabel
    anchors.fill: parent
    pos: 10 10
```

**Solução**: Escolher um sistema e usar consistentemente.

---

## 📚 Exemplos Práticos

### Exemplo 1: Layout Vertical Simples

```otui
UIWindow
  id: mainWindow
  size: 400 500
  layout: vertical
  layout-spacing: 10
  padding: 20

  UILabel
    id: title
    size: 360 40
    text: "Título"
    # Posição calculada: (20, 20) - dentro do padding

  UILabel
    id: subtitle
    size: 360 30
    text: "Subtítulo"
    # Posição calculada: (20, 70) - 20 (padding) + 40 (altura title) + 10 (spacing)

  UIButton
    id: button
    size: 200 50
    text: "Clique"
    # Posição calculada: (20, 110) - continuação do layout
```

### Exemplo 2: Anchors para Preencher

```otui
UIWindow
  id: container
  size: 600 400
  padding: 15

  UILabel
    id: header
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    margin-top: 15
    margin-left: 15
    margin-right: 15
    size: 570 50
    # Largura = 600 - 15 (padding) - 15 (margin-left) - 15 (margin-right) = 555px
    # Mas size define 570, então será 570px
    # Posição: (15, 15) - dentro do padding + margin-top

  UILabel
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: header.bottom
    anchors.bottom: parent.bottom
    margin-left: 15
    margin-right: 15
    margin-top: 10
    margin-bottom: 15
    # Preenche o espaço restante verticalmente
    # Largura = 600 - 15 (padding) - 15 (margin-left) - 15 (margin-right) = 555px
    # Altura = calculada automaticamente pelos anchors
```

### Exemplo 3: Layout Horizontal com Alinhamento

```otui
UIWindow
  id: toolbar
  size: 600 60
  layout: horizontal
  layout-spacing: 5
  layout-align: center
  padding: 10

  UIButton
    id: btn1
    size: 100 40
    text: "Botão 1"
    # Posição Y calculada para centralizar verticalmente

  UIButton
    id: btn2
    size: 100 40
    text: "Botão 2"
    # Posição X = 10 (padding) + 100 (largura btn1) + 5 (spacing) = 115

  UIButton
    id: btn3
    size: 100 40
    text: "Botão 3"
    # Posição X = 10 + 100 + 5 + 100 + 5 = 220
```

### Exemplo 4: Misturando Layout e Anchors

```otui
UIWindow
  id: complex
  size: 500 400
  layout: vertical
  layout-spacing: 5
  padding: 10

  UILabel
    id: title
    size: 480 30
    text: "Título"
    # Organizado pelo layout

  UILabel
    id: separator
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: title.bottom
    margin-top: 5
    margin-left: 10
    margin-right: 10
    size: 480 2
    # IGNORADO pelo layout (tem anchors)
    # Posicionado após title usando anchors

  UILabel
    id: content
    size: 480 200
    text: "Conteúdo"
    # Organizado pelo layout (continua após separator)
```

### Exemplo 5: Centralização com Anchors

```otui
UIWindow
  id: dialog
  size: 400 300

  UILabel
    id: centeredLabel
    anchors.horizontalCenter: parent
    anchors.verticalCenter: parent
    size: 200 50
    text: "Centralizado"
    # Centralizado horizontal e verticalmente no pai
```

---

## ✅ Checklist para Edição

Antes de editar um arquivo OTUI, verifique:

- [ ] **Coordenadas são relativas ao pai?** Não use coordenadas absolutas.
- [ ] **Widgets em layout não têm `pos`?** Remova `pos` de filhos quando o pai tem `layout`.
- [ ] **Widgets com anchors não têm `pos`?** Deixe anchors calcular a posição.
- [ ] **Padding está sendo considerado?** Lembre-se que padding reduz espaço interno.
- [ ] **Não há conflito entre sistemas?** Escolha um: layout, anchors ou pos manual.
- [ ] **Margins estão corretas?** Use `margin-*` para espaçamento externo.
- [ ] **Ordem de widgets faz sentido?** Em layouts, a ordem de declaração importa.

---

## 🎓 Resumo das Regras

1. **`pos` sempre relativa ao pai** - Nunca use coordenadas absolutas
2. **Layout remove `pos` dos filhos** - Widgets em layout não devem ter `pos`
3. **Anchors calculam `pos` automaticamente** - Não defina `pos` com anchors
4. **Padding reduz espaço interno** - Considere padding ao calcular posições
5. **Anchors ignoram layout** - Widgets com anchors não são organizados pelo layout
6. **Prioridade: Anchors > Layout > Pos Manual**

---

## 📖 Referências

- Código fonte: `Otui.py` (linhas 751-914)
- Funções principais:
  - `_check_layout_constraints()` - Verifica regras de layout
  - `apply_layout()` - Aplica layout vertical/horizontal
  - `update_geometry_from_anchors()` - Calcula posição com anchors
  - `apply_properties()` - Aplica propriedades na ordem correta

---

**Última atualização**: Baseado na análise do código `Otui.py` v2317 linhas.

Here is the documentation for using `UIWidgetText` in OTUI. This widget allows you to display and style text with various properties such as alignment, wrapping, font customization, and more.

---

# Using `UIWidgetText` in OTUI

The `UIWidgetText` widget is used to display text in the user interface. It supports a variety of properties to control the appearance, alignment, and behavior of the text.

---

## Text Style Properties

### 1. **Text Content**

- **`text`**: The text to be displayed in the widget.
  - **Type**: String.
  - **Example**: `text: "Hello, World!"`

---

### 2. **Text Alignment**

- **`text-align`**: Specifies the alignment of the text within the widget.
  - **Type**: String.
  - **Values**:
    - `left`
    - `right`
    - `center`
    - `top-left`
    - `top-right`
    - `bottom-left`
    - `bottom-right`
  - **Example**: `text-align: center`

---

### 3. **Text Offset**

- **`text-offset`**: Sets the offset of the text within the widget.
  - **Type**: `Point` (e.g., `x y`).
  - **Example**: `text-offset: 10 5`

---

### 4. **Text Wrapping**

- **`text-wrap`**: Enables or disables text wrapping.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-wrap: true`

---

### 5. **Text Auto-Resize**

- **`text-auto-resize`**: Automatically resizes the widget to fit the text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-auto-resize: true`

- **`text-horizontal-auto-resize`**: Automatically resizes the widget's width to fit the text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-horizontal-auto-resize: true`

- **`text-vertical-auto-resize`**: Automatically resizes the widget's height to fit the text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-vertical-auto-resize: true`

---

### 6. **Text Case**

- **`text-only-upper-case`**: Converts all text to uppercase.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-only-upper-case: true`

---

### 7. **Font Customization**

- **`font`**: Specifies the font to be used for the text.
  - **Type**: String (font name).
  - **Example**: `font: "verdana-11px"`

- **`font-scale`**: Scales the font size.
  - **Type**: Float.
  - **Example**: `font-scale: 1.5`

---

## Example OTUI Definition

```otui
Widget
  id: exampleTextWidget
  text: "Hello, OTClient!"
  text-align: center
  text-offset: 5 5
  text-wrap: true
  text-auto-resize: true
  text-only-upper-case: false
  font: "verdana-11px"
  font-scale: 1.2
```

---

## Advanced Features

### Colored Text

The `UIWidgetText` widget supports colored text using a special syntax. Colors can be applied to specific parts of the text.

- **Syntax**: `{text,color}`
  - **Example**: `{Hello,#FF0000} {World,#00FF00}`

### Example with Colored Text

```otui
Widget
  id: coloredTextWidget
  text: "{Hello,#FF0000} {World,#00FF00}"
  text-align: left
  font: "verdana-11px"
```

---

## Summary Table

| Property                     | Type       | Description                                      | Example                     |
|------------------------------|------------|--------------------------------------------------|-----------------------------|
| `text`                       | String     | The text to display.                            | `text: "Hello, World!"`     |
| `text-align`                 | String     | Aligns the text within the widget.              | `text-align: center`        |
| `text-offset`                | Point      | Sets the offset of the text.                    | `text-offset: 10 5`         |
| `text-wrap`                  | Boolean    | Enables or disables text wrapping.              | `text-wrap: true`           |
| `text-auto-resize`           | Boolean    | Resizes the widget to fit the text.             | `text-auto-resize: true`    |
| `text-horizontal-auto-resize`| Boolean    | Resizes the widget's width to fit the text.      | `text-horizontal-auto-resize: true` |
| `text-vertical-auto-resize`  | Boolean    | Resizes the widget's height to fit the text.     | `text-vertical-auto-resize: true` |
| `text-only-upper-case`       | Boolean    | Converts all text to uppercase.                 | `text-only-upper-case: true`|
| `font`                       | String     | Specifies the font to use.                      | `font: "verdana-11px"`      |
| `font-scale`                 | Float      | Scales the font size.                           | `font-scale: 1.5`           |

---

This documentation provides a comprehensive guide to using `UIWidgetText` in OTUI. It covers all the properties available for customizing text appearance and behavior.Here is the documentation for using `UITextEdit` in OTUI. This widget is an advanced text input field that supports features like text editing, selection, placeholders, and more.

---

# Using `UITextEdit` in OTUI

The `UITextEdit` widget is a versatile text input field that allows users to input, edit, and interact with text. It supports various properties for customization, including text alignment, selection, placeholders, and more.

---

## UITextEdit Style Properties

### 1. **Text Content**

- **`text`**: The text to be displayed or edited in the widget.
  - **Type**: String.
  - **Example**: `text: "Enter your name"`

- **`text-hidden`**: Hides the text by replacing it with asterisks (e.g., for password fields).
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `text-hidden: true`

---

### 2. **Text Behavior**

- **`editable`**: Enables or disables text editing.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `editable: true`

- **`multiline`**: Allows multiple lines of text.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `multiline: true`

- **`max-length`**: Sets the maximum number of characters allowed in the text field.
  - **Type**: Integer.
  - **Example**: `max-length: 50`

- **`shift-navigation`**: Enables navigation using the Shift key.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `shift-navigation: true`

---

### 3. **Text Selection**

- **`selectable`**: Enables or disables text selection.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `selectable: true`

- **`selection-color`**: Sets the color of the selected text.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `selection-color: #FFFFFF`

- **`selection-background-color`**: Sets the background color of the selected text.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `selection-background-color: #0000FF`

- **`selection`**: Defines the selection range as a point (start and end positions).
  - **Type**: `Point` (e.g., `start end`).
  - **Example**: `selection: 0 5`

---

### 4. **Cursor Behavior**

- **`cursor-visible`**: Shows or hides the text cursor.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `cursor-visible: true`

- **`change-cursor-image`**: Changes the cursor image when hovering over the text field.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `change-cursor-image: true`

---

### 5. **Scrolling**

- **`auto-scroll`**: Automatically scrolls the text field to keep the cursor visible.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `auto-scroll: true`

---

### 6. **Placeholder**

- **`placeholder`**: Sets the placeholder text to display when the text field is empty.
  - **Type**: String.
  - **Example**: `placeholder: "Enter text here"`

- **`placeholder-color`**: Sets the color of the placeholder text.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `placeholder-color: #AAAAAA`

- **`placeholder-align`**: Aligns the placeholder text within the widget.
  - **Type**: String.
  - **Values**:
    - `left`
    - `right`
    - `center`
    - `top-left`
    - `top-right`
    - `bottom-left`
    - `bottom-right`
  - **Example**: `placeholder-align: center`

- **`placeholder-font`**: Specifies the font for the placeholder text.
  - **Type**: String (font name).
  - **Example**: `placeholder-font: "verdana-11px"`

---

## Example OTUI Definition

```otui
TextEdit
  id: exampleTextEdit
  text: "Hello, World!"
  text-hidden: false
  editable: true
  multiline: true
  max-length: 100
  selectable: true
  selection-color: #FFFFFF
  selection-background-color: #0000FF
  cursor-visible: true
  auto-scroll: true
  placeholder: "Type something..."
  placeholder-color: #AAAAAA
  placeholder-align: center
  placeholder-font: "verdana-11px"
```

---

## Summary Table

| Property                     | Type       | Description                                      | Example                     |
|------------------------------|------------|--------------------------------------------------|-----------------------------|
| `text`                       | String     | The text to display or edit.                    | `text: "Hello, World!"`     |
| `text-hidden`                | Boolean    | Hides the text (e.g., for passwords).           | `text-hidden: true`         |
| `editable`                   | Boolean    | Enables or disables text editing.               | `editable: true`            |
| `multiline`                  | Boolean    | Allows multiple lines of text.                  | `multiline: true`           |
| `max-length`                 | Integer    | Sets the maximum number of characters.          | `max-length: 50`            |
| `selectable`                 | Boolean    | Enables or disables text selection.             | `selectable: true`          |
| `selection-color`            | Color      | Sets the color of the selected text.            | `selection-color: #FFFFFF`  |
| `selection-background-color` | Color      | Sets the background color of the selection.     | `selection-background-color: #0000FF` |
| `cursor-visible`             | Boolean    | Shows or hides the text cursor.                 | `cursor-visible: true`      |
| `auto-scroll`                | Boolean    | Automatically scrolls to keep the cursor visible.| `auto-scroll: true`         |
| `placeholder`                | String     | Sets the placeholder text.                      | `placeholder: "Enter text"` |
| `placeholder-color`          | Color      | Sets the color of the placeholder text.         | `placeholder-color: #AAAAAA`|
| `placeholder-align`          | String     | Aligns the placeholder text.                    | `placeholder-align: center` |
| `placeholder-font`           | String     | Specifies the font for the placeholder text.    | `placeholder-font: "verdana-11px"` |

---

This documentation provides a comprehensive guide to using `UITextEdit` in OTUI. It covers all the properties available for customizing the behavior and appearance of the text input field.

Here is the documentation for defining the style of an image in OTUI using the properties handled in uiwidgetimage.cpp.

---

# Defining Image Styles in OTUI

The `UIWidget` class supports various properties for styling images. These properties allow you to define the source, size, position, appearance, and behavior of images in your OTUI files.

---

## Image Style Properties

### 1. **Image Source**

- **`image-source`**: Specifies the source of the image.
  - **Type**: String.
  - **Format**: 
    - File path (e.g., `images/example.png`).
    - Base64-encoded string (e.g., `base64:...`).
    - `"none"` to remove the image.
  - **Example**:
    ```otui
    image-source: "images/example.png"
    image-source: "base64:...encoded-data..."
    image-source: "none"
    ```

---

### 2. **Image Position**

- **`image-offset-x`**: Sets the horizontal offset of the image.
  - **Type**: Integer.
  - **Example**: `image-offset-x: 10`

- **`image-offset-y`**: Sets the vertical offset of the image.
  - **Type**: Integer.
  - **Example**: `image-offset-y: 20`

- **`image-offset`**: Sets both horizontal and vertical offsets as a point.
  - **Type**: `Point` (e.g., `x y`).
  - **Example**: `image-offset: 10 20`

---

### 3. **Image Size**

- **`image-width`**: Sets the width of the image.
  - **Type**: Integer.
  - **Example**: `image-width: 100`

- **`image-height`**: Sets the height of the image.
  - **Type**: Integer.
  - **Example**: `image-height: 50`

- **`image-size`**: Sets both width and height of the image.
  - **Type**: `Size` (e.g., `width height`).
  - **Example**: `image-size: 100 50`

---

### 4. **Image Clipping**

- **`image-rect`**: Defines the rectangle of the image to be displayed.
  - **Type**: `Rect` (e.g., `x y width height`).
  - **Example**: `image-rect: 0 0 50 50`

- **`image-clip`**: Specifies the clipping rectangle for the image.
  - **Type**: `Rect` (e.g., `x y width height`).
  - **Example**: `image-clip: 10 10 40 40`

---

### 5. **Image Appearance**

- **`image-fixed-ratio`**: Maintains the aspect ratio of the image.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-fixed-ratio: true`

- **`image-repeated`**: Repeats the image to fill the widget.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-repeated: true`

- **`image-smooth`**: Enables smoothing for the image.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-smooth: true`

- **`image-color`**: Applies a color overlay to the image.
  - **Type**: `Color` (e.g., `#RRGGBBAA`).
  - **Example**: `image-color: #FF0000FF`

---

### 6. **Image Borders**

- **`image-border-top`**: Sets the top border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-top: 5`

- **`image-border-right`**: Sets the right border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-right: 5`

- **`image-border-bottom`**: Sets the bottom border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-bottom: 5`

- **`image-border-left`**: Sets the left border size of the image.
  - **Type**: Integer.
  - **Example**: `image-border-left: 5`

- **`image-border`**: Sets all border sizes to the same value.
  - **Type**: Integer.
  - **Example**: `image-border: 5`

---

### 7. **Image Behavior**

- **`image-auto-resize`**: Automatically resizes the widget to fit the image.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-auto-resize: true`

- **`image-individual-animation`**: Enables individual animation for animated textures.
  - **Type**: Boolean (`true` or `false`).
  - **Example**: `image-individual-animation: true`

---

## Example OTUI Definition

```otui
Widget
  id: exampleWidget
  image-source: "images/example.png"
  image-offset: 10 20
  image-size: 100 50
  image-fixed-ratio: true
  image-smooth: true
  image-border: 5
  image-color: #FFFFFF80
  image-auto-resize: true
```

---

This documentation provides a comprehensive overview of the image-related properties available in OTUI. These properties allow you to customize the appearance and behavior of images in your widgets.Here is a detailed documentation of the OTUI properties handled in uiwidgetbasestyle.cpp. Each property is mapped to its corresponding C++ method and includes a description of its purpose and expected arguments.

---

# OTUI Properties Documentation

## General Properties

### `background-draw-order`
- **Description**: Sets the draw order of the widget's background.
- **Arguments**: Integer.

### `border-draw-order`
- **Description**: Sets the draw order of the widget's border.
- **Arguments**: Integer.

### `icon-draw-order`
- **Description**: Sets the draw order of the widget's icon.
- **Arguments**: Integer.

### `image-draw-order`
- **Description**: Sets the draw order of the widget's image.
- **Arguments**: Integer.

### `text-draw-order`
- **Description**: Sets the draw order of the widget's text.
- **Arguments**: Integer.

---

## Position and Size

### `x`, `y`
- **Description**: Sets the x or y position of the widget.
- **Arguments**: Integer.

### `pos`
- **Description**: Sets the position of the widget as a point.
- **Arguments**: `Point` (e.g., `x y`).

### `width`, `height`
- **Description**: Sets the width or height of the widget.
- **Arguments**: Integer.

### `min-width`, `max-width`
- **Description**: Sets the minimum or maximum width of the widget.
- **Arguments**: Integer.

### `min-height`, `max-height`
- **Description**: Sets the minimum or maximum height of the widget.
- **Arguments**: Integer.

### `rect`
- **Description**: Sets the widget's rectangle (position and size).
- **Arguments**: `Rect` (e.g., `x y width height`).

---

## Background

### `background`
- **Description**: Sets the background color of the widget.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

### `background-color`
- **Description**: Alias for `background`.

### `background-offset-x`, `background-offset-y`
- **Description**: Sets the x or y offset of the background.
- **Arguments**: Integer.

### `background-offset`
- **Description**: Sets the offset of the background as a point.
- **Arguments**: `Point` (e.g., `x y`).

### `background-width`, `background-height`
- **Description**: Sets the width or height of the background.
- **Arguments**: Integer.

### `background-size`
- **Description**: Sets the size of the background.
- **Arguments**: `Size` (e.g., `width height`).

### `background-rect`
- **Description**: Sets the rectangle of the background.
- **Arguments**: `Rect` (e.g., `x y width height`).

---

## Icon

### `icon`
- **Description**: Sets the icon texture file.
- **Arguments**: String (file path).

### `icon-source`
- **Description**: Alias for `icon`.

### `icon-color`
- **Description**: Sets the color of the icon.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

### `icon-offset-x`, `icon-offset-y`
- **Description**: Sets the x or y offset of the icon.
- **Arguments**: Integer.

### `icon-offset`
- **Description**: Sets the offset of the icon as a point.
- **Arguments**: `Point` (e.g., `x y`).

### `icon-width`, `icon-height`
- **Description**: Sets the width or height of the icon.
- **Arguments**: Integer.

### `icon-size`
- **Description**: Sets the size of the icon.
- **Arguments**: `Size` (e.g., `width height`).

### `icon-rect`
- **Description**: Sets the rectangle of the icon.
- **Arguments**: `Rect` (e.g., `x y width height`).

### `icon-clip`
- **Description**: Sets the clipping rectangle of the icon.
- **Arguments**: `Rect` (e.g., `x y width height`).

### `icon-align`
- **Description**: Sets the alignment of the icon.
- **Arguments**: Alignment string (e.g., `top-left`, `center`, etc.).

---

## Visual Properties

### `opacity`
- **Description**: Sets the opacity of the widget.
- **Arguments**: Float (0.0 to 1.0).

### `rotation`
- **Description**: Sets the rotation of the widget.
- **Arguments**: Float (degrees).

---

## State Properties

### `enabled`
- **Description**: Enables or disables the widget.
- **Arguments**: Boolean (`true` or `false`).

### `visible`
- **Description**: Sets the visibility of the widget.
- **Arguments**: Boolean (`true` or `false`).

### `checked`
- **Description**: Sets the checked state of the widget.
- **Arguments**: Boolean (`true` or `false`).

### `draggable`
- **Description**: Enables or disables dragging for the widget.
- **Arguments**: Boolean (`true` or `false`).

### `on`
- **Description**: Sets the "on" state of the widget.
- **Arguments**: Boolean (`true` or `false`).

### `focusable`
- **Description**: Enables or disables focus for the widget.
- **Arguments**: Boolean (`true` or `false`).

### `auto-focus`
- **Description**: Sets the auto-focus policy of the widget.
- **Arguments**: String (e.g., `none`, `first`, etc.).

### `phantom`
- **Description**: Sets the widget as a phantom (invisible to input).
- **Arguments**: Boolean (`true` or `false`).

---

## Size Constraints

### `size`
- **Description**: Sets the size of the widget.
- **Arguments**: `Size` (e.g., `width height`).

### `fixed-size`
- **Description**: Sets whether the widget has a fixed size.
- **Arguments**: Boolean (`true` or `false`).

### `min-size`, `max-size`
- **Description**: Sets the minimum or maximum size of the widget.
- **Arguments**: `Size` (e.g., `width height`).

---

## Clipping

### `clipping`
- **Description**: Enables or disables clipping for the widget.
- **Arguments**: Boolean (`true` or `false`).

---

## Border

### `border`
- **Description**: Sets the border width and color.
- **Arguments**: String (e.g., `width color`).

### `border-width`
- **Description**: Sets the border width.
- **Arguments**: Integer.

### `border-width-top`, `border-width-right`, `border-width-bottom`, `border-width-left`
- **Description**: Sets the border width for each side.
- **Arguments**: Integer.

### `border-color`
- **Description**: Sets the border color.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

### `border-color-top`, `border-color-right`, `border-color-bottom`, `border-color-left`
- **Description**: Sets the border color for each side.
- **Arguments**: `Color` (e.g., `#RRGGBBAA`).

---

## Margin and Padding

### `margin`
- **Description**: Sets the margin for all sides.
- **Arguments**: Integer or `top right bottom left`.

### `margin-top`, `margin-right`, `margin-bottom`, `margin-left`
- **Description**: Sets the margin for a specific side.
- **Arguments**: Integer.

### `padding`
- **Description**: Sets the padding for all sides.
- **Arguments**: Integer or `top right bottom left`.

### `padding-top`, `padding-right`, `padding-bottom`, `padding-left`
- **Description**: Sets the padding for a specific side.
- **Arguments**: Integer.

---

## Layout

### `layout`
- **Description**: Sets the layout type for the widget.
- **Arguments**: String (e.g., `horizontalBox`, `verticalBox`, `grid`, `anchor`).

---

## Anchors

### `anchors.*`
- **Description**: Defines anchors for the widget.
- **Arguments**: String (e.g., `fill`, `centerIn`, or `widget.edge`).

---

This documentation provides a comprehensive overview of the OTUI properties handled in uiwidgetbasestyle.cpp. Each property is mapped to its corresponding method and includes its purpose and expected arguments.
