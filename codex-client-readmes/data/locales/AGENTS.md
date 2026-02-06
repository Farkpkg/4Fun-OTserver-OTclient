---
alwaysApply: true
---
# Guia de Locales (I18N)

## Escopo

Este guia cobre traducoes em `data/locales/*.lua` e uso de `tr()` em Lua/OTUI.

## Arquivos principais

- `data/locales/*.lua` (ex.: `pt.lua`, `es.lua`).

## Uso

- Lua: `tr("Options")`.
- OTUI: `!text: tr('Options')`.

## Onde editar

- Adicionar chave/valor no locale correto.
- Garantir fallback para ingles quando faltar traducao.
