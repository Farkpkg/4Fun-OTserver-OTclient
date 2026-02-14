# Full API Reference (metatables)

## Server
- Tipo: C++ userdata binding
- Categoria: core
- Base(s): -
- Métodos membro: acceptNext, close, isOpen
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## BossCooldown
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: checkTicks, create, getCooldown, hasCooldown, reset, setupCooldown, updateWindow
- Métodos internos: -
- Campos observados: lastTick, search, sort
- Metamétodos: __index

## Circle
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: divideIntoSlices, inArea, isPointInSlice, new
- Métodos internos: -
- Campos observados: _centerX, _centerY, _radius
- Metamétodos: __index

## ControllerAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: startEvent
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## DropTrackerAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: checkMonsterKilled, checkTracker, create, isInDropTracker, loadConfigJson, managerDropItem, removeAllItems, removeItem, reset, saveConfigJson, sendDropedItems, showItemContextMenu, tryAddingMonsterDrop, updateWindow
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## GemAtelier
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: configurePages, createGemInformation, getDamageAndHealing, getEffectiveLevel, getEquipedGem, getFilledVesselCount, getGemCountByDomain, getGemDataById, getGemDomainById, isGemEquipped, isVesselAvailable, managePage, manageVessel, matchGemText, onClickVessel, onDestroyGem, onHoverGem, onLockGem, onModRedirect, onRevealGem, onSearchChange, onSelectGem, onSortAffinity, onSortQuality, onSwitchDomain, onUnlockGem, redirectToGem, resetFields, setGemUpgradeImage, setupGemSlot, setupGemWidget, setupModAvailable, setupVesselPanel, showGemRevelation, showGems, showLockedOnly
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## HuntingAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: addDealDamage, addHealing, addLootedItems, addMonsterKilled, addRawXPGain, addSuppliesItems, addXpGain, checkBalance, clipboardData, create, getBalance, getDamage, getDamageHour, getDamageTicks, getHealing, getHealingHour, getHealingTicks, getKilledMonsters, getLaunchTime, getLoot, getLootedItems, getRawXPGain, getSession, getStartExp, getSupplies, getSuppliesItems, getXpGain, getXpHour, loadConfigJson, reset, saveConfigJson, saveToFile, saveToJson, setBalance, setDamage, setDamageHour, setDamageTicks, setHealing, setHealingHour, setHealingTicks, setKilledMonsters, setLaunchTime, setLoot, setLootedItems, setRawXPGain, setSession, setShowBaseXp, setStartExp, setSupplies, setSuppliesItems, setXpGain, setXpHour, setupStartExp, updateLootedItemValue, updateWindow
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## ImpactAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: addDealDamage, addHealing, checkAnchos, create, damageTypeIsVisible, gaugeDPSIsVisible, gaugeHPSIsVisible, getAllTimeHightDps, graphDPSIsVisible, graphHPSIsVisible, loadConfigJson, openTargetConfig, reset, saveConfigJson, setAllTimeHightDps, setAllTimeHightHps, setDPSGauge, setDPSGraph, setDamageType, setHPSGauge, setHPSGraph, toggleSessionMode, updateGraphics, updateMinuteData, updateWindow
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## InputAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: addInputDamage, checkAnchos, checkDPS, clipboardData, create, damageGraphIsVisible, damageSourceIsVisible, damageTypesIsVisible, loadConfigJson, reset, saveConfigJson, setDamageGraph, setDamageSource, setDamageTypes, toggleDamageSource, toggleSessionMode, updateMinuteData, updateWindow
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## LoadedPlayer
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: getId, getName, getVocation, isLoaded, setId, setName, setVocation
- Métodos internos: -
- Campos observados: playerId, playerName, playerVocation
- Metamétodos: __index

## LootAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: addLootedItems, checkBalance, checkLootHour, create, gaugeIsVisible, getTarget, graphIsVisible, openTargetConfig, reset, setLootPerHourGauge, setLootPerHourGraph, setTarget, updateBasePriceFromLootedItems, updateBasicUI, updateGraph, updateGraphics, updateWindow
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## MarketHistory
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: onBottomListValueChange, onParseMarketHistory, onSelectHistoryChild, onTopListValueChange
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## MarketOwnOffers
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: cancelMarketOffer, onBottomListValueChange, onParseMyOffers, onSelectMyOffersChild, onTopListValueChange
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## PartyHuntAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: clipboardData, create, lootSplitter, onPartyAnalyzer, reset, startEvent, updateWindow
- Métodos internos: -
- Campos observados: lastUpdateTime, updateScheduled
- Metamétodos: __index

## SupplyAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: addSuppliesItems, checkBalance, checkDecrease, checkSupplyHour, create, decreaseWidget, gaugeIsVisible, getItemCount, getTarget, graphIsVisible, openTargetConfig, reset, setSupplyPerHourGauge, setSupplyPerHourGraph, setTarget, updateBasicUI, updateGraph, updateGraphics, updateWidget, updateWindow
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## WheelNode
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: new
- Métodos internos: -
- Campos observados: -
- Metamétodos: -

## WheelOfDestiny
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: canAddPoints, canRemovePoints, changePresetName, checkApplyButton, checkFilledVessels, checkManagerPointsButtons, configureConviction, configureConvictionPerk, configureDedication, configureDedicationPerk, configureEquippedGems, configurePassives, configurePresets, configureRevelationPerks, configureSummary, configureVessels, create, createPreset, deletePreset, determinateCurrentPreset, generateInternalPreset, getExportCode, getSliceIndex, insertPoint, insertUnlockedThe, isLit, isLitFull, loadWheelPresets, onCancelConfig, onChangeGemButton, onConfirmCreatePreset, onConfirmRenamePreset, onCreate, onDeletePreset, onDestinyWheel, onEditCode, onEditName, onExportConfig, onExportPreset, onGemVesselClick, onImportConfig, onImportPreset, onMouseMove, onMouseRelease, onNewPresetSelectionChange, onPreparePresetClick, onPresetClick, onPresetNameChange, onRemoveClick, onRenamePreset, onWheelClick, onWheelPassiveClick, removePoint, removeUnlockedThe, resetPassiveFocus, saveWheelPresets, setupPointsTooltip, showNewPreset, updateCurrentPreset, validadeImportCode
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## Workshop
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: createFragments, getBonusDescription, getBonusValue, getDataByBonus, getEquippedGemBonus, getFragmentList, getGemInformationByBonus, getSideBonusDescription, getSortList, getUpgradeBonus, onSearchChange, onSelectChild, onUpgradeModification, searchModifications, setCurrentPage, showFragmentList
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## XPAnalyser
- Tipo: Pure Lua metatable
- Categoria: custom
- Base(s): -
- Métodos públicos: addRawXPGain, addXpGain, checkAnchos, checkExpHour, create, forceUpdateUI, gaugeIsVisible, getTarget, graphIsVisible, loadConfigJson, openTargetConfig, rawXPIsVisible, reset, saveConfigJson, setGaugeVisible, setGraphVisible, setRawXPVisible, setupLevel, setupStartExp, updateBasicUI, updateCalculations, updateExpensiveUI, updateGraph, updateGraphics, updateNextLevel, updateTooltip, updateWindow
- Métodos internos: -
- Campos observados: -
- Metamétodos: __index

## AnimatedText
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: getColor, getOffset, getText
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## AttachableObject
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: attachEffect, attachParticleEffect, attachWidget, clearAttachedEffects, clearAttachedParticlesEffect, detachEffect, detachEffectById, detachParticleEffectByName, detachWidget, detachWidgetById, getAttachedEffectById, getAttachedEffects, getAttachedWidgetById, getAttachedWidgets
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## AttachedEffect
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: attachEffect, canDrawOnUI, clone, getDirection, getDuration, getId, getSpeed, isFollowingOwner, isPermanent, move, setBounce, setCanDrawOnUI, setDirOffset, setDirection, setDisableWalkAnimation, setDrawOrder, setDuration, setFade, setFollowOwner, setHideOwner, setLight, setLoop, setOffset, setOnTop, setOnTopByDir, setOpacity, setPermanent, setPulse, setShader, setSize, setSpeed, setTransform
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Container
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: getCapacity, getContainerItem, getFirstIndex, getId, getItem, getItems, getItemsCount, getName, getSize, getSlotPosition, hasPages, hasParent, isClosed, isUnlocked
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Creature
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Thing
- Métodos membro: attachPaperdoll, canBeSeen, canShoot, clearPaperdolls, clearText, detachPaperdollById, getBaseSpeed, getDirection, getEmblem, getHealthPercent, getIcon, getIcons, getId, getManaPercent, getMasterId, getName, getOutfit, getPaperdollById, getPaperdolls, getShield, getSkull, getSpeed, getStaticSquareColor, getStepDuration, getStepProgress, getStepTicksLeft, getText, getTimedSquareColor, getType, getTyping, getVocation, getWalkTicksElapsed, getWidgetInformation, hideStaticSquare, isCovered, isDead, isDisabledWalkAnimation, isFullHealth, isInvisible, isStaticSquareVisible, isTimedSquareVisible, isWalking, jump, sendTyping, setBounce, setDirection, setDisableWalkAnimation, setDrawOutfitColor, setEmblemTexture, setIconTexture, setIconsTexture, setManaPercent, setMountShader, setOutfit, setShieldTexture, setSkullTexture, setStaticWalking, setText, setTypeTexture, setTyping, setTypingIconTexture, setVocation, setWidgetInformation, showStaticSquare
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## CreatureType
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: cast, getName, getOutfit, getSpawnTime, setName, setOutfit, setSpawnTime
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Effect
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Thing
- Métodos membro: setId
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## House
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: addDoor, getEntry, getId, getName, getRent, getSize, getTile, getTownId, removeDoor, removeDoorById, setEntry, setId, setName, setRent, setSize, setTile, setTownId
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Item
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Thing
- Métodos membro: addContainerItem, addContainerItemIndexed, clearContainerItems, clone, getActionId, getCharges, getClothSlot, getContainerItem, getContainerItems, getCount, getCountOrSubType, getDescription, getDurationTime, getId, getMarketData, getMeanPrice, getName, getNpcSaleData, getServerId, getSubType, getTeleportDestination, getText, getTier, getTooltip, getUniqueId, hasClockExpire, hasExpire, hasExpireStop, hasWearOut, isDualWield, isFluidContainer, isMarketable, isStackable, removeContainerItem, setActionId, setCount, setDescription, setTeleportDestination, setText, setTier, setTooltip, setUniqueId
- Métodos estáticos: create, createOtb
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## ItemType
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: getClientId, getServerId, isWritable
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## LocalPlayer
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Player
- Métodos membro: autoWalk, canWalk, getBaseMagicLevel, getBlessings, getExperience, getFreeCapacity, getHarmony, getHealth, getInventoryCount, getInventoryItem, getLevel, getLevelPercent, getMagicLevel, getMagicLevelPercent, getMana, getManaShield, getMaxHealth, getMaxMana, getMaxManaShield, getOfflineTrainingTime, getRegenerationTime, getResourceBalance, getSkillBaseLevel, getSkillLevel, getSkillLevelPercent, getSoul, getStamina, getStates, getStoreExpBoostTime, getTotalCapacity, getTotalMoney, getVocation, hasEquippedItemId, hasSight, isAutoWalking, isKnown, isPreWalking, isPremium, isSerene, isServerWalking, isSupplyStashAvailable, isWalkLocked, lockWalk, preWalk, setExperience, setFreeCapacity, setHealth, setInventoryItem, setKnown, setLevel, setMagicLevel, setMana, setManaShield, setResourceBalance, setSkill, setSoul, setStamina, setStates, setTotalCapacity, stopAutoWalk, unlockWalk
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Missile
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Thing
- Métodos membro: setId, setPath
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Monster
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Creature
- Métodos membro: -
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Npc
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Creature
- Métodos membro: -
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Paperdoll
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: canDrawOnUI, clone, getBodyColor, getFeetColor, getHeadColor, getId, getLegsColor, getSpeed, hasAddon, removeAddon, reset, setAddon, setAddons, setBodyColor, setCanDrawOnUI, setColor, setColorByOutfit, setDirOffset, setFeetColor, setHeadColor, setLegsColor, setMountDirOffset, setMountOffset, setMountOnTopByDir, setOffset, setOnTop, setOnTopByDir, setOnlyAddon, setOpacity, setPriority, setShader, setShowOnMount, setSizeFactor, setSpeed, setUseMountPattern
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Player
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): Creature
- Métodos membro: -
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Spawn
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: addCreature, getCenterPos, getCreatures, getRadius, removeCreature, setCenterPos, setRadius
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## StaticText
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: addMessage, getColor, setColor, setFont, setText
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Thing
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): AttachableObject
- Métodos membro: canAnimate, getClassification, getDefaultAction, getExactSize, getId, getMarketData, getMeanPrice, getNpcSaleData, getParentContainer, getPosition, getScaleFactor, getStackPos, getStackPriority, getTile, hasExpireStop, hasWearout, isAmmo, isContainer, isCreature, isEffect, isForceUse, isFullGround, isGround, isGroundBorder, isHighlighted, isHookSouth, isIgnoreLook, isItem, isLocalPlayer, isLyingCorpse, isMarked, isMarketable, isMissile, isMonster, isMultiUse, isNotMoveable, isNpc, isOnBottom, isOnTop, isPickupable, isPlayer, isRotateable, isStackable, isTopEffect, isTranslucent, isUnwrapable, isUsable, isWrapable, setAnimate, setHighlight, setId, setMarked, setPosition, setScaleFactor, setShader
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Tile
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): AttachableObject
- Métodos membro: addThing, canShoot, clean, getCreatures, getFlags, getGround, getItems, getPosition, getText, getThing, getThingCount, getThingStackPos, getThings, getTimer, getTopCreature, getTopLookThing, getTopMoveThing, getTopMultiUseThing, getTopThing, getTopUseThing, hasElevation, hasFlag, hasFloorChange, isClickable, isCompletelyCovered, isCovered, isEmpty, isFullGround, isFullyOpaque, isHouseTile, isLookPossible, isPathable, isSelected, isWalkable, overwriteMinimapColor, remFlag, removeThing, select, setFill, setFlag, setFlags, setText, setTimer, unselect
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Town
- Tipo: C++ userdata binding
- Categoria: game
- Base(s): -
- Métodos membro: getId, getName, getPos, getTemplePos, setId, setName, setPos, setTemplePos
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Connection
- Tipo: C++ userdata binding
- Categoria: network
- Base(s): -
- Métodos membro: getIp
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## InputMessage
- Tipo: C++ userdata binding
- Categoria: network
- Base(s): -
- Métodos membro: decryptRsa, eof, getBuffer, getMessageSize, getReadSize, getString, getU16, getU32, getU64, getU8, getUnreadSize, peekU16, peekU32, peekU64, peekU8, setBuffer, skipBytes
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## LoginHttp
- Tipo: C++ userdata binding
- Categoria: network
- Base(s): -
- Métodos membro: httpLogin
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## OutputMessage
- Tipo: C++ userdata binding
- Categoria: network
- Base(s): -
- Métodos membro: addBytes, addPaddingBytes, addString, addU16, addU32, addU64, addU8, encryptRsa, getBuffer, getMessageSize, getWritePos, reset, setBuffer, setMessageSize, setWritePos
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Protocol
- Tipo: C++ userdata binding
- Categoria: network
- Base(s): -
- Métodos membro: connect, disconnect, enableChecksum, enableXteaEncryption, enabledSequencedPackets, generateXteaKey, getConnection, getXteaKey, isConnected, isConnecting, recv, send, setConnection, setXteaKey
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## ProtocolGame
- Tipo: C++ userdata binding
- Categoria: network
- Base(s): Protocol
- Métodos membro: sendExtendedOpcode
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## WebConnection
- Tipo: C++ userdata binding
- Categoria: network
- Base(s): -
- Métodos membro: getIp
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## PainterShaderProgram
- Tipo: C++ userdata binding
- Categoria: render
- Base(s): -
- Métodos membro: addMultiTexture
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## ParticleEffectType
- Tipo: C++ userdata binding
- Categoria: render
- Base(s): -
- Métodos membro: getDescription, getName
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## ShaderProgram
- Tipo: C++ userdata binding
- Categoria: render
- Base(s): -
- Métodos membro: -
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## ThingType
- Tipo: C++ userdata binding
- Categoria: render
- Base(s): -
- Métodos membro: blockProjectile, exportImage, getAnimationPhases, getCategory, getClassification, getClothSlot, getDefaultAction, getDescription, getDisplacement, getDisplacementX, getDisplacementY, getElevation, getGroundSpeed, getHeight, getId, getLayers, getLensHelp, getLight, getMarketData, getMaxTextLength, getMeanPrice, getMinimapColor, getName, getNpcSaleData, getNumPatternX, getNumPatternY, getNumPatternZ, getRealSize, getSize, getSkillWheelGemQualityId, getSkillWheelGemVocationId, getSprites, getWidth, hasAttribute, hasClockExpire, hasDisplacement, hasElevation, hasExpire, hasExpireStop, hasFloorChange, hasLensHelp, hasLight, hasMiniMapColor, hasSkillWheelGem, hasWearOut, isAmmo, isAnimateAlways, isChargeable, isCloth, isContainer, isDontHide, isDualWield, isFluidContainer, isForceUse, isFullGround, isGround, isGroundBorder, isHangable, isHookEast, isHookSouth, isIgnoreLook, isLyingCorpse, isMarketable, isMultiUse, isNotMoveable, isNotPathable, isNotWalkable, isOnBottom, isOnTop, isPickupable, isPodium, isRotateable, isSplash, isStackable, isTopEffect, isTranslucent, isUnwrapable, isUsable, isWrapable, isWritable, isWritableOnce, setPathable
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIAnchorLayout
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UILayout
- Métodos membro: centerIn, fill, removeAnchors
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIBoxLayout
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UILayout
- Métodos membro: setFitChildren, setSpacing
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UICreature
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: getCreature, getCreatureSize, getDirection, isCentered, setCenter, setCreature, setCreatureSize, setDirection, setOutfit
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIEffect
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: clearEffect, getEffect, getEffectId, isEffectVisible, isVirtual, setEffect, setEffectId, setEffectVisible, setVirtual
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIGraph
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: addValue, clear, createGraph, getGraphsCount, setCapacity, setGraphVisible, setInfoLineColor, setInfoText, setLineColor, setLineWidth, setShowInfo, setShowLabels, setTextBackground, setTitle
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIGridLayout
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UILayout
- Métodos membro: getCellSize, getCellSpacing, getNumColumns, getNumLines, isUIGridLayout, setCellHeight, setCellSize, setCellSpacing, setCellWidth, setFlow, setNumColumns, setNumLines
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIHorizontalLayout
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIBoxLayout
- Métodos membro: setAlignRight
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIItem
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: clearItem, getFlipDirection, getItem, getItemCount, getItemCountOrSubType, getItemId, getItemSubType, isItemVisible, isVirtual, setFlipDirection, setItem, setItemCount, setItemId, setItemSubType, setItemVisible, setShowCount, setVirtual
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UILayout
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): -
- Métodos membro: addWidget, applyStyle, disableUpdates, enableUpdates, getParentWidget, isUIAnchorLayout, isUIBoxLayout, isUIGridLayout, isUIHorizontalLayout, isUIVerticalLayout, isUpdateDisabled, isUpdating, removeWidget, setParent, update, updateLater
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIMap
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: clearTiles, drawSelf, followCreature, getCameraPosition, getFloorViewMode, getFollowingCreature, getMaxZoomIn, getMaxZoomOut, getMinimumAmbientLight, getNextShader, getPosition, getShader, getSightSpectators, getSpectators, getTile, getVisibleDimension, getZoom, isDrawingHealthBars, isDrawingLights, isDrawingManaBar, isDrawingNames, isInRange, isKeepAspectRatioEnabled, isLimitVisibleRangeEnabled, isLimitedVisibleDimension, isSwitchingShader, lockVisibleFloor, movePixels, setAntiAliasingMode, setCameraPosition, setCrosshairTexture, setDrawHarmony, setDrawHealthBars, setDrawHighlightTarget, setDrawLights, setDrawManaBar, setDrawNames, setDrawViewportEdge, setFloorFading, setFloorViewMode, setKeepAspectRatio, setLimitVisibleDimension, setLimitVisibleRange, setMaxZoomIn, setMaxZoomOut, setMinimumAmbientLight, setShader, setShadowFloorIntensity, setVisibleDimension, setZoom, unlockVisibleFloor, zoomIn, zoomOut
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIMapAnchorLayout
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIAnchorLayout
- Métodos membro: -
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIMinimap
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: anchorPosition, centerInPosition, fillPosition, floorDown, floorUp, getCameraPosition, getMaxZoom, getMinZoom, getScale, getTilePoint, getTilePosition, getTileRect, getZoom, setCameraPosition, setMaxZoom, setMixZoom, setZoom, zoomIn, zoomOut
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIMissile
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: clearMissile, getDirection, getMissile, getMissileId, isMissileVisible, isVirtual, setDirection, setMissile, setMissileId, setMissileVisible, setVirtual
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIParticles
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: addEffect, clearEffects, setEffect
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIProgressRect
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: getDuration, getPercent, getTimeElapsed, setDuration, setPercent, showProgress, showTime, start, stop
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIQrCode
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: getCode, getCodeBorder, setCode, setCodeBorder
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UISprite
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: clearSprite, getSpriteId, hasSprite, setSpriteColor, setSpriteId
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UITextEdit
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIWidget
- Métodos membro: appendText, blinkCursor, clearSelection, copy, cut, del, getCursorPos, getDisplayedText, getMaxLength, getSelection, getSelectionBackgroundColor, getSelectionColor, getSelectionEnd, getSelectionStart, getTextPos, getTextTotalSize, getTextVirtualOffset, getTextVirtualSize, hasSelection, isChangingCursorImage, isCursorVisible, isEditable, isMultiline, isSelectable, isShiftNavigation, isTextHidden, moveCursorHorizontally, moveCursorVertically, paste, removeCharacter, selectAll, setChangeCursorImage, setCursorPos, setCursorVisible, setEditable, setMaxLength, setMultiline, setSelectable, setSelection, setSelectionBackgroundColor, setSelectionColor, setShiftNavigation, setTextHidden, setTextVirtualOffset, setValidCharacters, wrapText
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIVerticalLayout
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): UIBoxLayout
- Métodos membro: isAlignBottom, setAlignBottom
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## UIWidget
- Tipo: C++ userdata binding
- Categoria: ui
- Base(s): -
- Métodos membro: addAnchor, addChild, append, applyStyle, backwardsGetWidgetById, bindRectToParent, breakAnchors, centerIn, clearText, containsMarginPoint, containsPaddingPoint, containsPoint, destroy, destroyChildren, disable, disableUpdateTemporarily, enable, fill, focus, focusChild, focusNextChild, focusPreviousChild, getAnchorType, getAnchoredLayout, getAnchors, getAutoFocusPolicy, getAutoRepeatDelay, getBackgroundColor, getBackgroundHeight, getBackgroundOffset, getBackgroundOffsetX, getBackgroundOffsetY, getBackgroundRect, getBackgroundSize, getBackgroundWidth, getBorderBottomColor, getBorderBottomWidth, getBorderLeftColor, getBorderLeftWidth, getBorderRightColor, getBorderRightWidth, getBorderTopColor, getBorderTopWidth, getCenter, getChildAfter, getChildBefore, getChildById, getChildByIndex, getChildByPos, getChildByState, getChildByStyleName, getChildCount, getChildIndex, getChildren, getChildrenRect, getColor, getDisplay, getDrawText, getFirstChild, getFocusedChild, getFont, getHeight, getHoveredChild, getHtmlId, getIconAlign, getIconClip, getIconColor, getIconHeight, getIconOffset, getIconOffsetX, getIconOffsetY, getIconRect, getIconSize, getIconWidth, getId, getImageBorderBottom, getImageBorderLeft, getImageBorderRight, getImageBorderTop, getImageClip, getImageColor, getImageHeight, getImageOffset, getImageOffsetX, getImageOffsetY, getImageRect, getImageSize, getImageSource, getImageTextureHeight, getImageTextureWidth, getImageWidth, getLastChild, getLastClickPosition, getLastFocusReason, getLayout, getMarginBottom, getMarginLeft, getMarginRect, getMarginRight, getMarginTop, getMaxHeight, getMaxSize, getMaxWidth, getMinHeight, getMinSize, getMinWidth, getNextWidget, getOpacity, getPaddingBottom, getPaddingLeft, getPaddingRect, getPaddingRight, getPaddingTop, getParent, getPosition, getPrevWidget, getRect, getReverseChildren, getRootParent, getRotation, getSize, getSource, getStyle, getStyleName, getText, getTextAlign, getTextByPos, getTextOffset, getTextSize, getVirtualOffset, getWidth, getX, getY, grabKeyboard, grabMouse, hasAnchoredLayout, hasChild, hasChildren, hasEventListener, hasShader, hide, hideChildren, html, insert, insertChild, intersects, intersectsMargin, intersectsPadding, isActive, isAlternate, isChecked, isChildHovered, isChildLocked, isClipping, isDestroyed, isDisabled, isDraggable, isDragging, isEffectivelyVisible, isEnabled, isExplicitlyEnabled, isExplicitlyVisible, isFirst, isFirstOnStyle, isFixedSize, isFocusable, isFocused, isHidden, isHovered, isImageAutoResize, isImageFixedRatio, isImageSmooth, isLast, isMiddle, isOn, isOnHtml, isPhantom, isPressed, isTextWrap, isVisible, lock, lockChild, lower, lowerChild, mergeStyle, move, moveChildToIndex, prepend, querySelector, querySelectorAll, raise, raiseChild, recursiveGetChildById, recursiveGetChildByPos, recursiveGetChildByState, recursiveGetChildren, recursiveGetChildrenByMarginPos, recursiveGetChildrenByPos, recursiveGetChildrenByState, recursiveGetChildrenByStyleName, remove, removeAnchor, removeChild, removeChildByIndex, removeChildren, removeEventListener, reorderChildren, resize, resizeToText, rotate, setAutoFocusPolicy, setAutoRepeatDelay, setBackgroundColor, setBackgroundDrawOrder, setBackgroundHeight, setBackgroundOffset, setBackgroundOffsetX, setBackgroundOffsetY, setBackgroundRect, setBackgroundSize, setBackgroundWidth, setBorderColor, setBorderColorBottom, setBorderColorLeft, setBorderColorRight, setBorderColorTop, setBorderDrawOrder, setBorderWidth, setBorderWidthBottom, setBorderWidthLeft, setBorderWidthRight, setBorderWidthTop, setBottom, setChecked, setClipping, setColor, setColoredText, setConditionIf, setDisabled, setDisplay, setDraggable, setEnabled, setEventListener, setFixedSize, setFocusable, setFont, setFontScale, setHeight, setIcon, setIconAlign, setIconClip, setIconColor, setIconDrawOrder, setIconHeight, setIconOffset, setIconOffsetX, setIconOffsetY, setIconRect, setIconSize, setIconWidth, setId, setImageAutoResize, setImageBorder, setImageBorderBottom, setImageBorderLeft, setImageBorderRight, setImageBorderTop, setImageClip, setImageColor, setImageDrawOrder, setImageFixedRatio, setImageHeight, setImageOffset, setImageOffsetX, setImageOffsetY, setImageRect, setImageRepeated, setImageSize, setImageSmooth, setImageSource, setImageWidth, setLastFocusReason, setLayout, setLeft, setMargin, setMarginBottom, setMarginHorizontal, setMarginLeft, setMarginRight, setMarginTop, setMarginVertical, setMaxHeight, setMaxSize, setMaxWidth, setMinHeight, setMinSize, setMinWidth, setOn, setOpacity, setPadding, setPaddingBottom, setPaddingHorizontal, setPaddingLeft, setPaddingRight, setPaddingTop, setPaddingVertical, setParent, setPhantom, setPlacement, setPosition, setRect, setRight, setRotation, setShader, setSize, setStroke, setStyle, setStyleFromNode, setTTFFont, setText, setTextAlign, setTextAutoResize, setTextDrawOrder, setTextHorizontalAutoResize, setTextOffset, setTextOverflowCharacter, setTextOverflowLength, setTextVerticalAutoResize, setTextWrap, setTop, setVirtualOffset, setVisible, setWidgetId, setWidth, setX, setY, show, showChildren, ungrabKeyboard, ungrabMouse, unlock, unlockChild, updateLayout, updateParentLayout
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## CombinedSoundSource
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): SoundSource
- Métodos membro: -
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Config
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): -
- Métodos membro: clear, exists, getFileName, getList, getNode, getNodeSize, getOrCreateNode, getValue, mergeNode, remove, save, setList, setNode, setValue
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Event
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): -
- Métodos membro: cancel, execute, isCanceled, isExecuted
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## LuaObject
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): -
- Métodos membro: getClassName
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## Module
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): -
- Métodos membro: canReload, canUnload, getAuthor, getAutoLoadPriority, getDescription, getName, getSandbox, getVersion, getWebsite, isAutoLoad, isLoaded, isReloadble, isSandboxed, load, reload, unload
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## ObjectPool
- Tipo: Pure Lua metatable
- Categoria: utils
- Base(s): -
- Métodos públicos: clear, get, new, release
- Métodos internos: -
- Campos observados: pool
- Metamétodos: __index

## ScheduledEvent
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): Event
- Métodos membro: cyclesExecuted, delay, maxCycles, nextCycle, remainingTicks, ticks
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## SoundChannel
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): -
- Métodos membro: disable, enable, enqueue, getGain, getId, isEnabled, play, setEnabled, setGain, stop
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## SoundEffect
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): -
- Métodos membro: setPreset
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## SoundSource
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): -
- Métodos membro: isPlaying, play, removeEffect, setEffect, setFading, setGain, setLooping, setName, setPosition, setReferenceDistance, setRelative, setVelocity, stop
- Métodos estáticos: create
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

## StreamSoundSource
- Tipo: C++ userdata binding
- Categoria: utils
- Base(s): SoundSource
- Métodos membro: -
- Métodos estáticos: -
- Fields bindados: -
- Metamétodos: __index, __newindex, __eq, __gc

