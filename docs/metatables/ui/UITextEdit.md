# UITextEdit

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
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
