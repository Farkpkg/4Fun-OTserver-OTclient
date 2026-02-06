---
alwaysApply: true
---
# Guia de UI Framework (Widgets, Layouts, OTUI)

## Escopo

Este guia cobre a base de UI em C++: UIManager, UIWidget, layouts, estilos OTUI e integracao com Lua.

## Arquitetura

- Arvore de widgets gerenciada por `UIManager` (singleton `g_ui`).
- `UIWidget` e a classe base para todos os widgets.
- Widgets organizados em hierarquia com foco, eventos e layout.

## Classes principais

- `UIManager`: criacao e gestao de widgets.
- `UIWidget`: propriedades, eventos, render.
- `UITextEdit`: input, selecao, validacao.
- `UILabel`, `UIButton`, `UIPanel`: widgets base.

## Layouts

- `UIAnchorLayout`, `UIVerticalLayout`, `UIHorizontalLayout`, `UIGridLayout`.
- Layout responde a tamanho do pai e organiza filhos automaticamente.

## Estilos e OTUI

- Estilos declarativos em `.otui` via `UIWidgetBaseStyle`.
- Suporta heranca e estados (hover, focus, pressed).

## Integracao com Lua

- Bindings expostos em `src/framework/luafunctions.cpp`.
- Modulos Lua criam e manipulam widgets via `g_ui`.

## Texto e fontes

- Texto renderizado com `BitmapFont`/`CachedText`.
- `UIWidgetText` e `UITextEdit` controlam alinhamento e wrap.

## Referencias locais

- `src/framework/ui/uimanager.*`
- `src/framework/ui/uiwidget.*`
- `src/framework/ui/uilayout.*`
- `src/framework/ui/uitextedit.*`
- `src/framework/ui/uiwidgetbasestyle.*`
- `src/framework/graphics/bitmapfont.*`
- `src/framework/graphics/cachedtext.*`
