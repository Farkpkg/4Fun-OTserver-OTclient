# Bridge de Metatables no RevScriptSys

## Descrição
O arquivo `revscriptsys.lua` redefine metatables de classes Lua para converter atribuições de campos em registro de callbacks tipados (ex.: `onLogin`, `onExtendedOpcode`, `onSay`).

## Localização no Projeto
- server/
  - `crystalserver/data/libs/functions/revscriptsys.lua`

## Arquivos Envolvidos
- `crystalserver/data/libs/functions/revscriptsys.lua`
- `crystalserver/src/lua/functions/events/creature_event_functions.cpp`
- `crystalserver/src/lua/creature/creatureevent.cpp`

## Fluxo de Execução
1. No boot, `load.lua` executa `revscriptsys.lua`.
2. O script aplica `__newindex` para classes como `CreatureEvent`, `TalkAction`, `GlobalEvent`, `MoveEvent`.
3. Ao atribuir `obj.onLogin = fn`, o wrapper chama `self:type("login")` + `self:onLogin(fn)`.
4. O C++ registra e executa callback conforme tipo de evento acionado.

## Dependências
- Metatables expostas por `rawgetmetatable`.
- Enum/tipos de evento suportados no core C++.

## Pontos de Extensão
- Incluir novos aliases de callback no `__newindex` de cada classe.
- Adicionar novos tipos de evento no C++ e refletir no wrapper Lua.
