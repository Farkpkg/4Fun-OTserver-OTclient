# Bindings C++ ↔ Lua

## Pipeline
`registerClass<T, Base>` -> cria `T`, `T_fieldmethods`, `T_mt` -> instala metamétodos -> `bindClassMemberFunction`/`bindClassStaticFunction` -> userdata compartilhado (`std::shared_ptr`) para Lua.

## Gestão de memória
- `__gc` chama `luaObjectCollectEvent`, que faz `LuaObjectPtr::reset()` e decrementa contador de refs (`m_totalObjRefs`).
- Igualdade userdata usa `__eq` via comparação de ponteiros inteligentes (`LuaObjectPtr`).

## Registros detectados
- `AnimatedText` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:916
- `AttachableObject` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:471
- `AttachedEffect` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:834
- `CombinedSoundSource` base=['SoundSource'] registros: otclient/src/framework/luafunctions.cpp:1106
- `Config` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:303
- `Connection` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1011
- `Container` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:455
- `Creature` base=['Thing'] registros: otclient/src/client/luafunctions.cpp:597
- `CreatureType` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:586
- `Effect` base=['Thing'] registros: otclient/src/client/luafunctions.cpp:825
- `Event` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:339
- `House` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:545
- `InputMessage` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1034
- `Item` base=['Thing'] registros: otclient/src/client/luafunctions.cpp:771
- `ItemType` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:678
- `LocalPlayer` base=['Player'] registros: otclient/src/client/luafunctions.cpp:925
- `LoginHttp` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:205
- `LuaObject` base=['LuaObject/root'] registros: otclient/src/framework/luaengine/luainterface.cpp:48
- `Missile` base=['Thing'] registros: otclient/src/client/luafunctions.cpp:829
- `Module` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:320
- `Monster` base=['Creature'] registros: otclient/src/client/luafunctions.cpp:923
- `Npc` base=['Creature'] registros: otclient/src/client/luafunctions.cpp:922
- `OutputMessage` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1055
- `PainterShaderProgram` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:979
- `Paperdoll` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:870
- `ParticleEffectType` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:983
- `Player` base=['Creature'] registros: otclient/src/client/luafunctions.cpp:921
- `Protocol` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1016
- `ProtocolGame` base=['Protocol'] registros: otclient/src/client/luafunctions.cpp:451
- `ScheduledEvent` base=['Event'] registros: otclient/src/framework/luafunctions.cpp:346
- `Server` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:999
- `ShaderProgram` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:978
- `SoundChannel` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1112
- `SoundEffect` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1109
- `SoundSource` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1091
- `Spawn` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:565
- `StaticText` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:908
- `StreamSoundSource` base=['SoundSource'] registros: otclient/src/framework/luafunctions.cpp:1107
- `Thing` base=['AttachableObject'] registros: otclient/src/client/luafunctions.cpp:487
- `ThingType` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:684
- `Tile` base=['AttachableObject'] registros: otclient/src/client/luafunctions.cpp:988
- `Town` base=['LuaObject/root'] registros: otclient/src/client/luafunctions.cpp:575
- `UIAnchorLayout` base=['UILayout'] registros: otclient/src/framework/luafunctions.cpp:913
- `UIBoxLayout` base=['UILayout'] registros: otclient/src/framework/luafunctions.cpp:881
- `UICreature` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1101
- `UIEffect` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1067
- `UIGraph` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1205
- `UIGridLayout` base=['UILayout'] registros: otclient/src/framework/luafunctions.cpp:897
- `UIHorizontalLayout` base=['UIBoxLayout'] registros: otclient/src/framework/luafunctions.cpp:892
- `UIItem` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1047
- `UILayout` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:862
- `UIMap` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1114
- `UIMapAnchorLayout` base=['UIAnchorLayout'] registros: otclient/src/client/luafunctions.cpp:1223
- `UIMinimap` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1170
- `UIMissile` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1079
- `UIParticles` base=['UIWidget'] registros: otclient/src/framework/luafunctions.cpp:989
- `UIProgressRect` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1192
- `UIQrCode` base=['UIWidget'] registros: otclient/src/framework/luafunctions.cpp:970
- `UISprite` base=['UIWidget'] registros: otclient/src/client/luafunctions.cpp:1093
- `UITextEdit` base=['UIWidget'] registros: otclient/src/framework/luafunctions.cpp:920
- `UIVerticalLayout` base=['UIBoxLayout'] registros: otclient/src/framework/luafunctions.cpp:886
- `UIWidget` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:510
- `WebConnection` base=['LuaObject/root'] registros: otclient/src/framework/luafunctions.cpp:1008
