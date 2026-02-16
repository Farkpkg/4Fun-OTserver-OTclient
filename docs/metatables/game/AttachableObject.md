# AttachableObject

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: attachEffect, attachParticleEffect, attachWidget, clearAttachedEffects, clearAttachedParticlesEffect, detachEffect, detachEffectById, detachParticleEffectByName, detachWidget, detachWidgetById, getAttachedEffectById, getAttachedEffects, getAttachedWidgetById, getAttachedWidgets
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `AttachableObject`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:471`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
