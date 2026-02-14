# GemAtelier

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_wheel/classes/gematelier.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: configurePages, createGemInformation, getDamageAndHealing, getEffectiveLevel, getEquipedGem, getFilledVesselCount, getGemCountByDomain, getGemDataById, getGemDomainById, isGemEquipped, isVesselAvailable, managePage, manageVessel, matchGemText, onClickVessel, onDestroyGem, onHoverGem, onLockGem, onModRedirect, onRevealGem, onSearchChange, onSelectGem, onSortAffinity, onSortQuality, onSwitchDomain, onUnlockGem, redirectToGem, resetFields, setGemUpgradeImage, setupGemSlot, setupGemWidget, setupModAvailable, setupVesselPanel, showGemRevelation, showGems, showLockedOnly
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `GemAtelier`
- Permite override: sim.

## Evidências
- `otclient/modules/game_wheel/classes/gematelier.lua:2`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
