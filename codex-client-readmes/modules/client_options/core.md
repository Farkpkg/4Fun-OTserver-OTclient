# Options and Configuration (Fluxo)

## Escopo

Este guia detalha o fluxo de configuracoes em `modules/client_options`.

## Fluxo principal

- `init()` inicializa o controller e carrega defaults.
- `setup()` carrega valores do `g_settings` e monta a UI.
- `setOption()` atualiza valor, executa `action` e persiste.
- `getOption()` fornece leitura para outros modulos.

## Categorias e UI

- Sidebar com categorias e subcategorias.
- Panels dinamicos por `addButton()`/`createCategory()`.
- Widgets: `OptionCheckBox`, `OptionScaleScroll`, combobox.

## Persistencia

- `g_settings.set/get` e `g_settings.save()`.
- Salva ao alterar opcao e ao fechar janela.

## Onde editar

- Logica: `modules/client_options/options.lua`.
- Layout: `modules/client_options/options.otui`.
- Strings: `data/locales/*.lua`.
