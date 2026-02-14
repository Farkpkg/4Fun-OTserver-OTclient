# UITextEdit

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Definição/registro:** otclient/src/framework/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
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
