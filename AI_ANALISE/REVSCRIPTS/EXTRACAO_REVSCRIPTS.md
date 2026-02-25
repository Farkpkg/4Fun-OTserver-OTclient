# Extração Técnica — REVSCRIPTS (CrystalServer)

Baseado no `Extracao.md` (`AI_EXTRATOR.md`), com foco no ecossistema **RevScriptSys** (metatable bridge + classes de evento + padrões de registro + ciclo de carga/reload).

---

## 1. Visão Geral

**Elemento analisado:** `REVSCRIPTS` / `RevScriptSys`.

No workspace, RevScriptSys é a camada Lua que transforma atribuições declarativas (`obj.onX = function ...`) em registro real de callbacks/eventos C++ via metatables (`__newindex`).

Ele cobre principalmente:
- registro de **Action**, **TalkAction**, **CreatureEvent**, **MoveEvent**, **GlobalEvent**, **Weapon**, **Spell**;
- bridge para **EventCallback** (callbacks de baixo nível ligados a eventos C++);
- support para tipos de conteúdo **MonsterType** e **NpcType**;
- carregamento recursivo do datapack em `data/scripts` e `data/monster`.

**Atuação no sistema:**
- (x) Servidor
- ( ) Cliente
- ( ) Ambos

> Observação: não há RevScriptSys no OTClient; a integração com cliente acontece indiretamente (por exemplo, scripts server-side que enviam mensagens/opcodes).

---

## 2. Localização no Código

### 2.1 Núcleo RevScriptSys

- `crystalserver/data/libs/functions/revscriptsys.lua`
- `crystalserver/data/libs/functions/load.lua`

### 2.2 Loader de scripts e ciclo de inicialização/reload

- `crystalserver/src/lua/scripts/scripts.cpp`
- `crystalserver/src/crystalserver.cpp`
- `crystalserver/src/game/functions/game_reload.cpp`

### 2.3 APIs Lua expostas em C++ (classes RevScript)

- `crystalserver/src/lua/functions/events/action_functions.cpp`
- `crystalserver/src/lua/functions/events/talk_action_functions.cpp`
- `crystalserver/src/lua/functions/events/creature_event_functions.cpp`
- `crystalserver/src/lua/functions/events/move_event_functions.cpp`
- `crystalserver/src/lua/functions/events/global_event_functions.cpp`
- `crystalserver/src/lua/functions/items/weapon_functions.cpp`
- `crystalserver/src/lua/functions/creatures/combat/spell_functions.cpp`
- `crystalserver/src/lua/functions/events/event_callback_functions.cpp`
- `crystalserver/src/lua/callbacks/event_callback.cpp`
- `crystalserver/src/lua/functions/creatures/monster/monster_type_functions.cpp`
- `crystalserver/src/lua/functions/creatures/npc/npc_type_functions.cpp`
- `crystalserver/src/lua/functions/core/game/game_functions.cpp`

### 2.4 Exemplos reais de uso RevScript (datapack)

- `crystalserver/data/scripts/actions/items/dolls.lua`
- `crystalserver/data/scripts/talkactions/player/commands.lua`
- `crystalserver/data/scripts/creaturescripts/player/login.lua`
- `crystalserver/data/scripts/movements/trap.lua`
- `crystalserver/data/scripts/globalevents/global_server_save.lua`
- `crystalserver/data/scripts/weapons/scripts/poison_arrow.lua`
- `crystalserver/data/scripts/spells/healing/light_healing.lua`
- `crystalserver/data/scripts/eventcallbacks/monster/ondroploot_prey.lua`
- `crystalserver/data/scripts/eventcallbacks/README.md`
- `crystalserver/data-crystal/monster/mammals/rat.lua`

---

## 3. Código Extraído (trechos relevantes)

### 3.1 `revscriptsys.lua` — bridge via metatable

```lua
-- Action
rawgetmetatable("Action").__newindex = function(self, key, value)
    if key == "onUse" then
        self:onUse(value)
        return
    end
    rawset(self, key, value)
end

-- TalkAction
rawgetmetatable("TalkAction").__newindex = function(self, key, value)
    if key == "onSay" then
        self:onSay(value)
        return
    end
    rawset(self, key, value)
end

-- CreatureEvent
if key == "onLogin" then self:type("login"); self:onLogin(value)
elseif key == "onExtendedOpcode" then self:type("extendedopcode"); self:onExtendedOpcode(value) end

-- MoveEvent
if key == "onStepIn" then self:type("stepin"); self:onStepIn(value)
elseif key == "onStepOut" then self:type("stepout"); self:onStepOut(value) end

-- GlobalEvent
if key == "onTime" then self:onTime(value)
elseif key == "onStartup" then self:type("startup"); self:onStartup(value) end

-- Weapon / Spell
if key == "onUseWeapon" then self:onUseWeapon(value) end
if key == "onCastSpell" then self:onCastSpell(value) end

-- EventCallback
local func = eventCallbacks[key]
if func and type(func) == "function" then
    func(self, value)
    self:type(key)
end
```

### 3.2 Ordem de carga do servidor

```lua
-- data/libs/functions/load.lua
dofile(CORE_DIRECTORY .. "/libs/functions/revscriptsys.lua")
```

```cpp
// crystalserver.cpp
load core.lua
load core/scripts/lib
load core/scripts
load datapack/scripts/lib
load datapack/scripts
load datapack/monster
```

```cpp
// scripts.cpp
for (recursive_directory_iterator(dir)) {
  if (file.extension() == ".lua") {
    if (file starts with '#') skip;
    scriptInterface.loadFile(...)
  }
}
```

### 3.3 Exemplo de padrão RevScript em Lua

```lua
local dolls = Action()
function dolls.onUse(player, item, fromPosition, target, toPosition, isHotkey)
  ...
end
for itemId in pairs(dollsTable) do dolls:id(itemId) end
dolls:register()
```

```lua
local spell = Spell("instant")
function spell.onCastSpell(creature, variant)
  return combat:execute(creature, variant)
end
spell:words("exura")
spell:register()
```

```lua
local callback = EventCallback("MonsterOnDropLootPrey")
function callback.monsterOnDropLoot(monster, corpse)
  ...
end
callback:register()
```

```lua
local mType = Game.createMonsterType("Rat")
local monster = { ... }
mType:register(monster)
```

### 3.4 Exposição C++ para Lua (constructors + register)

```cpp
Lua::registerSharedClass(L, "Action", "", ActionFunctions::luaCreateAction);
Lua::registerMethod(L, "Action", "register", ActionFunctions::luaActionRegister);

Lua::registerSharedClass(L, "TalkAction", "", TalkActionFunctions::luaCreateTalkAction);
Lua::registerMethod(L, "TalkAction", "register", TalkActionFunctions::luaTalkActionRegister);

Lua::registerSharedClass(L, "CreatureEvent", "", CreatureEventFunctions::luaCreateCreatureEvent);
Lua::registerMethod(L, "CreatureEvent", "register", CreatureEventFunctions::luaCreatureEventRegister);

Lua::registerSharedClass(L, "MoveEvent", "", MoveEventFunctions::luaCreateMoveEvent);
Lua::registerMethod(L, "MoveEvent", "register", MoveEventFunctions::luaMoveEventRegister);

Lua::registerSharedClass(L, "GlobalEvent", "", GlobalEventFunctions::luaCreateGlobalEvent);
Lua::registerMethod(L, "GlobalEvent", "register", GlobalEventFunctions::luaGlobalEventRegister);

Lua::registerSharedClass(L, "Weapon", "", WeaponFunctions::luaCreateWeapon);
Lua::registerMethod(L, "Weapon", "register", WeaponFunctions::luaWeaponRegister);

Lua::registerMethod(L, "Spell", "register", SpellFunctions::luaSpellRegister);
Lua::registerMethod(L, "EventCallback", "register", EventCallbackFunctions::luaEventCallbackRegister);
```

---

## 4. Fluxo de Execução

### 4.1 Boot do servidor

`CrystalServer::loadModules()`
↓
`core.lua` + libs core (`load.lua`)
↓
`dofile(.../revscriptsys.lua)` configura metatables (`__newindex`) de classes Lua
↓
`g_scripts().loadScripts(...)` carrega arquivos `.lua` recursivamente
↓
cada script executa `local x = Class(...)` + `x:register()`
↓
registro interno nos subsistemas C++ de eventos/actions/spells/etc.

### 4.2 Atribuição declarativa em Lua

`script.lua` faz:

```lua
local talkaction = TalkAction("!x")
function talkaction.onSay(player, words, param) ... end
talkaction:register()
```

Fluxo interno:
1. `talkaction.onSay = function` aciona `TalkAction.__newindex` definido em `revscriptsys.lua`.
2. Bridge chama `self:onSay(value)` (método real da userdata C++).
3. `:register()` finaliza o binding no dispatcher correspondente.

### 4.3 Reload

`GameReload::reloadScripts()`
↓
`g_scripts().clearAllScripts()` + limpeza de estado auxiliar
↓
recarrega `core/scripts/lib`, `datapack/scripts`, `core/scripts`
↓
recarrega monstros, npcs, itens (ordem importante)

---

## 5. Dependências

RevScriptSys depende de:

- **Metatables Lua** das classes expostas pelo C++ (`Action`, `Spell`, `CreatureEvent`, etc.).
- **LuaScriptInterface / Scripts loader** (`scripts.cpp`) para percorrer e executar scripts.
- **Registries C++** de eventos/ações/spells/weapons/talkactions.
- **Game API global** (`Game.getEventCallbacks`, `Game.createMonsterType`, `Game.getTalkActions`, etc.).
- **Configurações** como `showScriptsLogInConsole` (log de carga) e flags de segurança de script.
- **Estrutura de pastas do datapack** (`data/scripts`, `data/monster`, `data/npc`).

---

## 6. Integração Server ↔ Client

**Não encontrado no código** um módulo RevScriptSys no cliente OTClient.

Integração ocorre indiretamente:
- scripts RevScript (server) podem acionar APIs que resultam em envio de pacote/opcode;
- o processamento client-side ocorre no protocolo/módulos do OTClient, fora do escopo de implementação do RevScriptSys.

---

## 7. Pontos de Modificação

### 7.1 Alterar semântica de binding declarativo
- arquivo: `crystalserver/data/libs/functions/revscriptsys.lua`
- uso: adicionar novo alias `onX`, mudar `type(...)` automático, adicionar validações/log.

### 7.2 Alterar pipeline de carregamento/reload
- arquivos: `scripts.cpp`, `crystalserver.cpp`, `game_reload.cpp`
- uso: ordem de carga, filtros de arquivos, logs, política de recarga.

### 7.3 Expor novos métodos/classes para scripts
- arquivos em `src/lua/functions/**`
- uso: registrar nova classe Lua, método `register`, setters/getters, callbacks.

### 7.4 Ajustar contratos de callbacks avançados
- arquivos: `event_callback_functions.cpp`, `event_callback.cpp`, scripts em `data/scripts/eventcallbacks`
- uso: novos tipos de callback, ordem de execução, regras de short-circuit por retorno.

---

## 8. Riscos e Efeitos Colaterais

- **Quebra de compatibilidade de scripts** ao alterar `__newindex`/nomes (`onSay`, `onUse`, `onCastSpell`, etc.).
- **Eventos silenciosamente não registrados** se `:register()` for omitido ou se type key não mapear corretamente.
- **Diferenças de ordem de carga** podem quebrar dependências implícitas entre scripts.
- **Reload parcial** pode deixar estado órfão se limpeza e re-registro não estiverem simétricos.
- **Callbacks com retorno boolean/ReturnValue** podem alterar fluxo crítico de combate/movimento/loot.
- **Custos de performance** ao adicionar lógica pesada em callbacks de alta frequência (ex.: `onThink`, `monsterOnDropLoot`, `playerOnMoveItem`).

---

## 9. Resumo Técnico

RevScriptSys é o coração da experiência de scripting moderna do CrystalServer: ele injeta uma API declarativa sobre classes Lua/C++ por metatables, permite registro unificado de eventos e callbacks, e opera junto ao loader recursivo de scripts no boot/reload.

Na prática, quase todo o conteúdo gameplay scriptável (ações, falas, spells, movimentos, eventos globais, callbacks de player/party/monster, monstros e NPCs) passa por esse modelo.

---

## 10. Sugestões (Opcional)

1. **Checklist de lint para RevScripts**: validar automaticamente ausência de `:register()`, assinatura incompatível, e typos de callback.
2. **Mapa de cobertura de eventos**: gerar relatório de quais eventos têm 0/1/N callbacks ativos.
3. **Observabilidade por categoria**: métricas por tipo de callback (latência, contagem, falhas) durante runtime.
4. **Documentar ordem efetiva de carga** em um guia único para evitar dependências ocultas.

---

## Apêndice — Indicadores de Escala (workspace atual)

Contagens aproximadas por padrão encontrado:

- `Action(`: **113**
- `TalkAction(`: **148**
- `CreatureEvent(`: **28**
- `MoveEvent(`: **19**
- `GlobalEvent(`: **11**
- `Weapon(`: **6**
- `Spell(`: **236**
- `EventCallback(`: **28**
- `Game.createMonsterType(`: **1652**
- `Game.createNpcType(`: **32**

Esses números reforçam que RevScriptSys é camada estrutural do datapack (não um módulo isolado).
