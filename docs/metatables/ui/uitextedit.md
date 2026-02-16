---
title: Uitextedit
tags: [metatables]
date: 2026-02-16
---

# UITextEdit

- **Tipo:** C++ userdata binding
- **Categoria:** ui
<<<<<<< HEAD
- **Localização:** otclient/src/framework/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/framework/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: appendText, blinkCursor, clearSelection, copy, cut, del, getCursorPos, getDisplayedText, getMaxLength, getSelection, getSelectionBackgroundColor, getSelectionColor, getSelectionEnd, getSelectionStart, getTextPos, getTextTotalSize, getTextVirtualOffset, getTextVirtualSize, hasSelection, isChangingCursorImage, isCursorVisible, isEditable, isMultiline, isSelectable, isShiftNavigation, isTextHidden, moveCursorHorizontally, moveCursorVertically, paste, removeCharacter, selectAll, setChangeCursorImage, setCursorPos, setCursorVisible, setEditable, setMaxLength, setMultiline, setSelectable, setSelection, setSelectionBackgroundColor, setSelectionColor, setShiftNavigation, setTextHidden, setTextVirtualOffset, setValidCharacters, wrapText
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UITextEdit -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:920`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: appendText, blinkCursor, clearSelection, copy, create, cut, del, getCursorPos, getDisplayedText, getMaxLength, getSelection, getSelectionBackgroundColor, getSelectionColor, getSelectionEnd, getSelectionStart, getTextPos, getTextTotalSize, getTextVirtualOffset, getTextVirtualSize, hasSelection, isChangingCursorImage, isCursorVisible, isEditable, isMultiline, isSelectable, isShiftNavigation, isTextHidden, moveCursorHorizontally, moveCursorVertically, paste, removeCharacter, selectAll, setChangeCursorImage, setCursorPos, setCursorVisible, setEditable, setMaxLength, setMultiline, setSelectable, setSelection, setSelectionBackgroundColor, setSelectionColor, setShiftNavigation, setTextHidden, setTextVirtualOffset, setValidCharacters, wrapText
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: UITextEdit -> UIWidget
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/framework/luafunctions.cpp:920`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
