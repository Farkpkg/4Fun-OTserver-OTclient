# Exemplos de implementação: CrystalServer (Lua) + OTClient (Lua)

> **Nota**: os exemplos abaixo são templates práticos e podem exigir ajuste fino para API exata da sua base Canary/Crystal e fork de OTClient.

## 1) CrystalServer (server-side)

## 1.1 `config.lua`

```lua
PaperdollConfig = {
  OPCODE = 92,
  COLOR_MIN = 0,
  COLOR_MAX = 132,
  RATE_LIMIT_MS = 300,
  ALLOWED_SLOTS = {
    hair = true,
    helmet = true,
    armor = true,
    legs = true,
    boots = true,
    weapon_main = true,
    shield_offhand = true,
    cape = true,
  }
}
```

## 1.2 `repository.lua`

```lua
PaperdollRepository = {}

function PaperdollRepository.loadState(playerId)
  local state = {}
  local query = ([[
    SELECT slot, appearance_id, color_primary, color_secondary, color_tertiary, enabled
    FROM player_paperdoll
    WHERE player_id = %d
  ]]):format(playerId)

  local result = db.storeQuery(query)
  if result then
    repeat
      local slot = result.getString(result, "slot")
      state[slot] = {
        appearanceId = result.getNumber(result, "appearance_id"),
        colorPrimary = result.getNumber(result, "color_primary"),
        colorSecondary = result.getNumber(result, "color_secondary"),
        colorTertiary = result.getNumber(result, "color_tertiary"),
        enabled = result.getNumber(result, "enabled") == 1
      }
    until not result.next(result)
    result.free(result)
  end

  return state
end

function PaperdollRepository.saveSlot(playerId, slot, data)
  local sql = ([[
    INSERT INTO player_paperdoll
      (player_id, slot, appearance_id, color_primary, color_secondary, color_tertiary, enabled)
    VALUES
      (%d, %s, %d, %d, %d, %d, %d)
    ON DUPLICATE KEY UPDATE
      appearance_id = VALUES(appearance_id),
      color_primary = VALUES(color_primary),
      color_secondary = VALUES(color_secondary),
      color_tertiary = VALUES(color_tertiary),
      enabled = VALUES(enabled)
  ]]):format(
    playerId,
    db.escapeString(slot),
    data.appearanceId,
    data.colorPrimary or 0,
    data.colorSecondary or 0,
    data.colorTertiary or 0,
    data.enabled and 1 or 0
  )

  return db.query(sql)
end
```

## 1.3 `validator.lua`

```lua
PaperdollValidator = {}

local function inRange(value, min, max)
  return type(value) == "number" and value >= min and value <= max
end

function PaperdollValidator.validateSlotData(player, slot, data, catalogs, unlockedSet)
  if not PaperdollConfig.ALLOWED_SLOTS[slot] then
    return false, "ERR_INVALID_SLOT"
  end

  local appearance = catalogs.byId[data.appearanceId]
  if not appearance or appearance.slot ~= slot or appearance.enabled ~= true then
    return false, "ERR_INVALID_APPEARANCE"
  end

  if not unlockedSet[data.appearanceId] then
    return false, "ERR_NOT_UNLOCKED"
  end

  if appearance.premium and not player:isPremium() then
    return false, "ERR_PREMIUM_REQUIRED"
  end

  if player:getLevel() < (appearance.minLevel or 1) then
    return false, "ERR_LEVEL_REQUIRED"
  end

  if data.colorPrimary and not inRange(data.colorPrimary, PaperdollConfig.COLOR_MIN, PaperdollConfig.COLOR_MAX) then
    return false, "ERR_COLOR_OUT_OF_RANGE"
  end

  return true
end
```

## 1.4 `service.lua`

```lua
PaperdollService = {
  sessionCache = {},
  catalogs = {
    byId = {}
  }
}

local function sendToClient(player, msg)
  local protocol = player:getProtocolGame()
  if not protocol then return end
  protocol:sendExtendedOpcode(PaperdollConfig.OPCODE, json.encode(msg))
end

function PaperdollService.loadForPlayer(player)
  local playerId = player:getGuid()
  local state = PaperdollRepository.loadState(playerId)
  local unlocked = PaperdollRepository.loadUnlocks and PaperdollRepository.loadUnlocks(playerId) or {}

  PaperdollService.sessionCache[playerId] = {
    state = state,
    unlocked = unlocked,
    lastRequestAt = 0
  }
end

function PaperdollService.sendSnapshot(player)
  local playerId = player:getGuid()
  local cache = PaperdollService.sessionCache[playerId]
  if not cache then return end

  sendToClient(player, {
    schemaVersion = 1,
    type = "paperdoll_snapshot",
    data = {
      slots = cache.state,
      unlocked = cache.unlocked
    }
  })
end

function PaperdollService.applyRequest(player, data)
  local playerId = player:getGuid()
  local cache = PaperdollService.sessionCache[playerId]
  if not cache then
    return false, { errorCode = "ERR_INTERNAL" }
  end

  local now = os.mtime and os.mtime() or os.time() * 1000
  if (now - (cache.lastRequestAt or 0)) < PaperdollConfig.RATE_LIMIT_MS then
    return false, { errorCode = "ERR_RATE_LIMIT" }
  end
  cache.lastRequestAt = now

  for slot, slotData in pairs(data.slots or {}) do
    local ok, err = PaperdollValidator.validateSlotData(player, slot, slotData, PaperdollService.catalogs, cache.unlocked)
    if not ok then
      return false, { errorCode = err }
    end
  end

  for slot, slotData in pairs(data.slots or {}) do
    cache.state[slot] = slotData
    PaperdollRepository.saveSlot(playerId, slot, slotData)
  end

  -- Aplique outfit efetivo no personagem aqui (função dependente da base)
  -- player:setOutfit(effectiveOutfit)

  return true, {
    errorCode = nil,
    effectiveState = cache.state
  }
end

function PaperdollService.sendApplyResult(player, requestId, ok, result)
  sendToClient(player, {
    schemaVersion = 1,
    type = "paperdoll_apply_result",
    requestId = requestId,
    data = {
      ok = ok,
      errorCode = result.errorCode,
      effectiveState = result.effectiveState
    }
  })

  if ok then
    sendToClient(player, {
      schemaVersion = 1,
      type = "paperdoll_update",
      data = {
        slots = result.effectiveState
      }
    })
  end
end
```

## 1.5 `events_login.lua` e `events_equip.lua`

```lua
local loginEvent = CreatureEvent("PaperdollLogin")

function loginEvent.onLogin(player)
  PaperdollService.loadForPlayer(player)
  PaperdollService.sendSnapshot(player)
  return true
end

loginEvent:register()
```

```lua
local equipEvent = MoveEvent()

function equipEvent.onEquip(player, item, slot, isCheck)
  if isCheck then return true end
  -- Recompute cosmético derivado de equipment se necessário
  -- PaperdollService.recomputeFromEquipment(player, slot, item)
  return true
end

function equipEvent.onDeEquip(player, item, slot, isCheck)
  if isCheck then return true end
  -- PaperdollService.recomputeFromEquipment(player, slot, nil)
  return true
end

equipEvent:register()
```

## 1.6 `extopcode.lua`

```lua
local creatureEvent = CreatureEvent("PaperdollOpcode")

function creatureEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= PaperdollConfig.OPCODE then
    return false
  end

  local msg = json.decode(buffer)
  if not msg then
    return false
  end

  if msg.type == "paperdoll_apply_request" then
    local ok, result = PaperdollService.applyRequest(player, msg.data or {})
    PaperdollService.sendApplyResult(player, msg.requestId, ok, result)
    return true
  elseif msg.type == "paperdoll_request_snapshot" then
    PaperdollService.sendSnapshot(player)
    return true
  end

  return false
end

creatureEvent:register()
```

---

## 2) OTClient (client-side)

## 2.1 `game_paperdoll.lua`

```lua
Paperdoll = {
  opcode = 92,
  state = {
    slots = {},
    unlocked = {}
  },
  window = nil
}

local function send(msg)
  local protocol = g_game.getProtocolGame()
  if not protocol then return end
  protocol:sendExtendedOpcode(Paperdoll.opcode, json.encode(msg))
end

local function onPaperdollOpcode(protocol, opcode, buffer)
  if opcode ~= Paperdoll.opcode then return end

  local msg = json.decode(buffer)
  if not msg then return end

  if msg.type == 'paperdoll_snapshot' then
    Paperdoll.state.slots = msg.data.slots or {}
    Paperdoll.state.unlocked = msg.data.unlocked or {}
    Paperdoll.refreshUI()
  elseif msg.type == 'paperdoll_update' then
    for slot, data in pairs(msg.data.slots or {}) do
      Paperdoll.state.slots[slot] = data
    end
    Paperdoll.refreshUI()
  elseif msg.type == 'paperdoll_apply_result' then
    if not msg.data.ok then
      modules.game_textmessage.displayFailureMessage('Paperdoll: ' .. (msg.data.errorCode or 'ERR_INTERNAL'))
    end
  end
end

function Paperdoll.init()
  ProtocolGame.registerExtendedOpcode(Paperdoll.opcode, onPaperdollOpcode)
  Paperdoll.window = g_ui.loadUI('paperdoll', modules.game_interface.getRightPanel())
  Paperdoll.window:hide()
end

function Paperdoll.terminate()
  ProtocolGame.unregisterExtendedOpcode(Paperdoll.opcode)
  if Paperdoll.window then
    Paperdoll.window:destroy()
    Paperdoll.window = nil
  end
end

function Paperdoll.open()
  if not Paperdoll.window then return end
  Paperdoll.window:show()
  Paperdoll.window:raise()
  Paperdoll.window:focus()
end

function Paperdoll.applyChanges(slots)
  send({
    schemaVersion = 1,
    type = 'paperdoll_apply_request',
    requestId = tostring(g_clock.millis()),
    data = { slots = slots }
  })
end

function Paperdoll.refreshUI()
  if not Paperdoll.window then return end
  -- Atualize grid/lista/preview com Paperdoll.state
end
```

## 2.2 `paperdoll.otui` (estrutura mínima)

```otui
PaperdollWindow < MainWindow
  id: paperdollWindow
  size: 360 480
  text: tr('Paperdoll')

  Label
    id: title
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    text: tr('Customize your visual')

  Panel
    id: slotsPanel
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: 280

  Button
    id: applyButton
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    text: tr('Apply')
    @onClick: modules.game_paperdoll.applyFromUI()
```

## 2.3 `game_paperdoll.otmod`

```ini
Module
  name: game_paperdoll
  description: Paperdoll custom visual system
  author: your-team
  website: your-project
  scripts: [ game_paperdoll.lua ]
  otuis: [ paperdoll.otui ]
  dependencies: [ game_interface, game_inventory, game_outfit ]
  @onLoad: init()
  @onUnload: terminate()
```

---

## 3) XML de configuração (exemplo resumido)

```xml
<paperdoll version="1">
  <appearances>
    <appearance id="3001" slot="armor" name="Knight Armor Skin" lookType="130" lookAddon="1" minLevel="50" premium="0" unlockType="quest" unlockRef="q_knight_armor" enabled="1"/>
    <appearance id="4101" slot="weapon_main" name="Golden Blade Skin" lookType="131" lookAddon="0" minLevel="80" premium="1" unlockType="shop" unlockRef="offer_9001" enabled="1"/>
  </appearances>
</paperdoll>
```

---

## 4) Resultado esperado

- Jogador loga e recebe snapshot.
- UI mostra apenas aparências desbloqueadas.
- Ao clicar em Apply, client envia request.
- Server valida, persiste e envia estado efetivo.
- Troca de item pode alterar visual derivado em slots sem override.
