# Creature

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** Thing
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: attachPaperdoll, canBeSeen, canShoot, clearPaperdolls, clearText, create, detachPaperdollById, getBaseSpeed, getDirection, getEmblem, getHealthPercent, getIcon, getIcons, getId, getManaPercent, getMasterId, getName, getOutfit, getPaperdollById, getPaperdolls, getShield, getSkull, getSpeed, getStaticSquareColor, getStepDuration, getStepProgress, getStepTicksLeft, getText, getTimedSquareColor, getType, getTyping, getVocation, getWalkTicksElapsed, getWidgetInformation, hideStaticSquare, isCovered, isDead, isDisabledWalkAnimation, isFullHealth, isInvisible, isStaticSquareVisible, isTimedSquareVisible, isWalking, jump, sendTyping, setBounce, setDirection, setDisableWalkAnimation, setDrawOutfitColor, setEmblemTexture, setIconTexture, setIconsTexture, setManaPercent, setMountShader, setOutfit, setShieldTexture, setSkullTexture, setStaticWalking, setText, setTypeTexture, setTyping, setTypingIconTexture, setVocation, setWidgetInformation, showStaticSquare
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Creature -> Thing
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:597`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
