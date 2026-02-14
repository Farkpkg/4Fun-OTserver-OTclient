# Creature

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** Thing
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
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
