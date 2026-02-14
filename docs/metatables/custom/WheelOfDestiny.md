# WheelOfDestiny

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_wheel/classes/wheelclass.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: canAddPoints, canRemovePoints, changePresetName, checkApplyButton, checkFilledVessels, checkManagerPointsButtons, configureConviction, configureConvictionPerk, configureDedication, configureDedicationPerk, configureEquippedGems, configurePassives, configurePresets, configureRevelationPerks, configureSummary, configureVessels, create, createPreset, deletePreset, determinateCurrentPreset, generateInternalPreset, getExportCode, getSliceIndex, insertPoint, insertUnlockedThe, isLit, isLitFull, loadWheelPresets, onCancelConfig, onChangeGemButton, onConfirmCreatePreset, onConfirmRenamePreset, onCreate, onDeletePreset, onDestinyWheel, onEditCode, onEditName, onExportConfig, onExportPreset, onGemVesselClick, onImportConfig, onImportPreset, onMouseMove, onMouseRelease, onNewPresetSelectionChange, onPreparePresetClick, onPresetClick, onPresetNameChange, onRemoveClick, onRenamePreset, onWheelClick, onWheelPassiveClick, removePoint, removeUnlockedThe, resetPassiveFocus, saveWheelPresets, setupPointsTooltip, showNewPreset, updateCurrentPreset, validadeImportCode
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `WheelOfDestiny`
- Permite override: sim.

## Evidências
- `otclient/modules/game_wheel/classes/wheelclass.lua:2`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
