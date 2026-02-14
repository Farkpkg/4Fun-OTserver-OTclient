# Security Analysis de Metatables

## Matriz de risco por metatable
| Metatable | Risco | Motivo | Evidência |
|---|---|---|---|
| AnimatedText | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:916` |
| AttachableObject | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:471` |
| AttachedEffect | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:834` |
| BossCooldown | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/BossCooldown.lua:34` |
| Circle | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_wheel/classes/geometry.lua:2` |
| CombinedSoundSource | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1106` |
| Config | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:303` |
| Connection | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1011` |
| Container | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:455` |
| ControllerAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/Controller.lua:13` |
| Creature | alto | override global de métodos | `otclient/src/client/luafunctions.cpp:597` |
| CreatureType | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:586` |
| DropTrackerAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/DropTrackerAnalyser.lua:83` |
| Effect | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:825` |
| Event | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:339` |
| GemAtelier | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_wheel/classes/gematelier.lua:2` |
| House | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:545` |
| HuntingAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/HuntingAnalyser.lua:124` |
| ImpactAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/ImpactAnalyser.lua:73` |
| InputAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/InputAnalyser.lua:81` |
| InputMessage | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1034` |
| Item | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:771` |
| ItemType | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:678` |
| LoadedPlayer | médio | metatable dinâmica/prototipal mutável | `otclient/modules/gamelib/player.lua:283` |
| LocalPlayer | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:925` |
| LoginHttp | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:205` |
| LootAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/LootAnalyser.lua:66` |
| LuaObject | médio | override global de métodos | `otclient/src/framework/luaengine/luainterface.cpp:48` |
| MarketHistory | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_market/classes/t_history.lua:2` |
| MarketOwnOffers | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_market/classes/t_ownOffers.lua:31` |
| Missile | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:829` |
| Module | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:320` |
| Monster | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:923` |
| Npc | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:922` |
| ObjectPool | médio | metatable dinâmica/prototipal mutável | `otclient/modules/corelib/objectpool.lua:2` |
| OutputMessage | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1055` |
| PainterShaderProgram | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:979` |
| Paperdoll | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:870` |
| ParticleEffectType | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:983` |
| PartyHuntAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/PartyHuntAnalyser.lua:48` |
| Player | alto | override global de métodos | `otclient/src/client/luafunctions.cpp:921` |
| Protocol | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1016` |
| ProtocolGame | alto | override global de métodos | `otclient/src/client/luafunctions.cpp:451` |
| ScheduledEvent | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:346` |
| Server | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:999` |
| ShaderProgram | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:978` |
| SoundChannel | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1112` |
| SoundEffect | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1109` |
| SoundSource | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1091` |
| Spawn | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:565` |
| StaticText | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:908` |
| StreamSoundSource | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1107` |
| SupplyAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/SupplyAnalyser.lua:66` |
| Thing | alto | override global de métodos | `otclient/src/client/luafunctions.cpp:487` |
| ThingType | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:684` |
| Tile | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:988` |
| Town | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:575` |
| UIAnchorLayout | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:913` |
| UIBoxLayout | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:881` |
| UICreature | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1101` |
| UIEffect | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1067` |
| UIGraph | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1205` |
| UIGridLayout | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:897` |
| UIHorizontalLayout | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:892` |
| UIItem | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1047` |
| UILayout | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:862` |
| UIMap | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1114` |
| UIMapAnchorLayout | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1223` |
| UIMinimap | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1170` |
| UIMissile | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1079` |
| UIParticles | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:989` |
| UIProgressRect | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1192` |
| UIQrCode | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:970` |
| UISprite | médio | override global de métodos | `otclient/src/client/luafunctions.cpp:1093` |
| UITextEdit | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:920` |
| UIVerticalLayout | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:886` |
| UIWidget | alto | override global de métodos | `otclient/src/framework/luafunctions.cpp:510` |
| WebConnection | médio | override global de métodos | `otclient/src/framework/luafunctions.cpp:1008` |
| WheelNode | médio | metatable dinâmica/prototipal mutável | `-` |
| WheelOfDestiny | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_wheel/classes/wheelclass.lua:2` |
| Workshop | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_wheel/classes/workshop.lua:2` |
| XPAnalyser | médio | metatable dinâmica/prototipal mutável | `otclient/modules/game_analyser/classes/XPAanalyser.lua:74` |

## Evidências dinâmicas
- `otclient/modules/game_wheel/classes/geometry.lua:5` [setmetatable-id] `local self = setmetatable({}, Circle)`
- `otclient/modules/game_wheel/classes/wheelnode.lua:9` [setmetatable-id] `setmetatable(instance, WheelNode)`
- `otclient/modules/game_battle/battle.lua:18` [getmetatable-alias] `local meta = getmetatable(t)`
- `otclient/modules/game_battle/battle.lua:23` [setmetatable-id] `setmetatable(target, meta)`
- `otclient/modules/game_battle/battle.lua:23` [setmetatable-alias-meta] `setmetatable(target, meta)`
- `otclient/modules/game_battle/battle.lua:443` [setmetatable-inline] `setmetatable(instance, {__index = self})`
- `otclient/modules/game_battle/battle.lua:443` [inline-__index] `setmetatable(instance, {__index = self})`
- `otclient/modules/corelib/util.lua:62` [getmetatable-alias] `local mt = getmetatable(object)`
- `otclient/modules/corelib/table.lua:241` [getmetatable-alias] `local mt = getmetatable(t1)`
- `otclient/modules/corelib/ui/uiwidget.lua:547` [setmetatable-inline] `local menv = setmetatable(locals, { __index = env })`
- `otclient/modules/corelib/ui/uiwidget.lua:547` [inline-__index] `local menv = setmetatable(locals, { __index = env })`
- `otclient/modules/corelib/ui/uiwidget.lua:583` [setmetatable-inline] `setmetatable(baseEnv, { __index = _G })`
- `otclient/modules/corelib/ui/uiwidget.lua:583` [inline-__index] `setmetatable(baseEnv, { __index = _G })`
- `otclient/modules/corelib/ui/uiwidget.lua:600` [setmetatable-inline] `setmetatable(e, { __index = base })`
- `otclient/modules/corelib/ui/uiwidget.lua:600` [inline-__index] `setmetatable(e, { __index = base })`
- `otclient/modules/modulelib/controller.lua:91` [setmetatable-id] `setmetatable(obj, self)`
- `otclient/modules/modulelib/eventcontroller.lua:22` [setmetatable-id] `setmetatable(obj, self)`
