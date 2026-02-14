# Bindings C++ ↔ Lua

## Pipeline real
`registerClass<T, Base>` -> `T` + `T_fieldmethods` + `T_mt` -> metamétodos -> `bindClass*` -> userdata `LuaObjectPtr`.

## Userdata e memória
- `__gc`: `luaObjectCollectEvent` reseta ponteiro e decrementa refs.
- `__eq`: `luaObjectEqualEvent` compara ponteiros userdata.

## Classes registradas
- `AnimatedText` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:916
- `AttachableObject` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:471
- `AttachedEffect` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:834
- `CombinedSoundSource` | categoria=utils | base=['SoundSource'] | registros=otclient/src/framework/luafunctions.cpp:1106
- `Config` | categoria=utils | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:303
- `Connection` | categoria=network | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1011
- `Container` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:455
- `Creature` | categoria=game | base=['Thing'] | registros=otclient/src/client/luafunctions.cpp:597
- `CreatureType` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:586
- `Effect` | categoria=game | base=['Thing'] | registros=otclient/src/client/luafunctions.cpp:825
- `Event` | categoria=utils | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:339
- `House` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:545
- `InputMessage` | categoria=network | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1034
- `Item` | categoria=game | base=['Thing'] | registros=otclient/src/client/luafunctions.cpp:771
- `ItemType` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:678
- `LocalPlayer` | categoria=game | base=['Player'] | registros=otclient/src/client/luafunctions.cpp:925
- `LoginHttp` | categoria=network | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:205
- `LuaObject` | categoria=utils | base=['root'] | registros=otclient/src/framework/luaengine/luainterface.cpp:48
- `Missile` | categoria=game | base=['Thing'] | registros=otclient/src/client/luafunctions.cpp:829
- `Module` | categoria=utils | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:320
- `Monster` | categoria=game | base=['Creature'] | registros=otclient/src/client/luafunctions.cpp:923
- `Npc` | categoria=game | base=['Creature'] | registros=otclient/src/client/luafunctions.cpp:922
- `OutputMessage` | categoria=network | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1055
- `PainterShaderProgram` | categoria=render | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:979
- `Paperdoll` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:870
- `ParticleEffectType` | categoria=render | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:983
- `Player` | categoria=game | base=['Creature'] | registros=otclient/src/client/luafunctions.cpp:921
- `Protocol` | categoria=network | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1016
- `ProtocolGame` | categoria=network | base=['Protocol'] | registros=otclient/src/client/luafunctions.cpp:451
- `ScheduledEvent` | categoria=utils | base=['Event'] | registros=otclient/src/framework/luafunctions.cpp:346
- `Server` | categoria=core | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:999
- `ShaderProgram` | categoria=render | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:978
- `SoundChannel` | categoria=utils | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1112
- `SoundEffect` | categoria=utils | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1109
- `SoundSource` | categoria=utils | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1091
- `Spawn` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:565
- `StaticText` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:908
- `StreamSoundSource` | categoria=utils | base=['SoundSource'] | registros=otclient/src/framework/luafunctions.cpp:1107
- `Thing` | categoria=game | base=['AttachableObject'] | registros=otclient/src/client/luafunctions.cpp:487
- `ThingType` | categoria=render | base=['root'] | registros=otclient/src/client/luafunctions.cpp:684
- `Tile` | categoria=game | base=['AttachableObject'] | registros=otclient/src/client/luafunctions.cpp:988
- `Town` | categoria=game | base=['root'] | registros=otclient/src/client/luafunctions.cpp:575
- `UIAnchorLayout` | categoria=ui | base=['UILayout'] | registros=otclient/src/framework/luafunctions.cpp:913
- `UIBoxLayout` | categoria=ui | base=['UILayout'] | registros=otclient/src/framework/luafunctions.cpp:881
- `UICreature` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1101
- `UIEffect` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1067
- `UIGraph` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1205
- `UIGridLayout` | categoria=ui | base=['UILayout'] | registros=otclient/src/framework/luafunctions.cpp:897
- `UIHorizontalLayout` | categoria=ui | base=['UIBoxLayout'] | registros=otclient/src/framework/luafunctions.cpp:892
- `UIItem` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1047
- `UILayout` | categoria=ui | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:862
- `UIMap` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1114
- `UIMapAnchorLayout` | categoria=ui | base=['UIAnchorLayout'] | registros=otclient/src/client/luafunctions.cpp:1223
- `UIMinimap` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1170
- `UIMissile` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1079
- `UIParticles` | categoria=ui | base=['UIWidget'] | registros=otclient/src/framework/luafunctions.cpp:989
- `UIProgressRect` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1192
- `UIQrCode` | categoria=ui | base=['UIWidget'] | registros=otclient/src/framework/luafunctions.cpp:970
- `UISprite` | categoria=ui | base=['UIWidget'] | registros=otclient/src/client/luafunctions.cpp:1093
- `UITextEdit` | categoria=ui | base=['UIWidget'] | registros=otclient/src/framework/luafunctions.cpp:920
- `UIVerticalLayout` | categoria=ui | base=['UIBoxLayout'] | registros=otclient/src/framework/luafunctions.cpp:886
- `UIWidget` | categoria=ui | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:510
- `WebConnection` | categoria=network | base=['root'] | registros=otclient/src/framework/luafunctions.cpp:1008
