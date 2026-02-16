# Creature

- **Tipo:** C++ userdata binding
- **Categoria:** game
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** Thing
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: attachPaperdoll, canBeSeen, canShoot, clearPaperdolls, clearText, detachPaperdollById, getBaseSpeed, getDirection, getEmblem, getHealthPercent, getIcon, getIcons, getId, getManaPercent, getMasterId, getName, getOutfit, getPaperdollById, getPaperdolls, getShield, getSkull, getSpeed, getStaticSquareColor, getStepDuration, getStepProgress, getStepTicksLeft, getText, getTimedSquareColor, getType, getTyping, getVocation, getWalkTicksElapsed, getWidgetInformation, hideStaticSquare, isCovered, isDead, isDisabledWalkAnimation, isFullHealth, isInvisible, isStaticSquareVisible, isTimedSquareVisible, isWalking, jump, sendTyping, setBounce, setDirection, setDisableWalkAnimation, setDrawOutfitColor, setEmblemTexture, setIconTexture, setIconsTexture, setManaPercent, setMountShader, setOutfit, setShieldTexture, setSkullTexture, setStaticWalking, setText, setTypeTexture, setTyping, setTypingIconTexture, setVocation, setWidgetInformation, showStaticSquare
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Creature -> Thing`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:597`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
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
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
