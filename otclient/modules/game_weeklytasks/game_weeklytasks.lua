local OPCODE_ACTION = 240
local OPCODE_EVENT = 241

local window
local button
local state = {}

local function sendAction(actionType, writePayload)
  local protocol = g_game.getProtocolGame()
  if not protocol then
    return
  end

  local msg = OutputMessage.create()
  msg:addU8(actionType)

  if writePayload then
    writePayload(msg)
  end

  protocol:sendExtendedOpcode(OPCODE_ACTION, msg:getBuffer())
end

local function parseOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_EVENT then
    return
  end

  local ok, parsedOrError = pcall(function()
    local msg = InputMessage.create()
    msg:setBuffer(buffer)

    local parsed = {
      state = msg:getU8(),
      difficulty = msg:getString(),
      multiplier = msg:getU16() / 100,
      completedKillTasks = msg:getU16(),
      completedDeliveryTasks = msg:getU16(),
      points = msg:getU32(),
      soulSeals = msg:getU32(),
      expansionUnlocked = msg:getU8() == 1,
      difficulties = {},
      tasks = {},
      shop = {},
    }

    local diffCount = msg:getU8()
    for i = 1, diffCount do
      local name = msg:getString()
      parsed.difficulties[name] = msg:getU16()
    end

    local killCount = msg:getU8()
    for i = 1, killCount do
      parsed.tasks[#parsed.tasks + 1] = {
        id = msg:getU32(),
        taskType = 'kill',
        targetName = msg:getString(),
        currentAmount = msg:getU16(),
        requiredAmount = msg:getU16(),
        isCompleted = msg:getU8() == 1,
      }
    end

    local deliveryCount = msg:getU8()
    for i = 1, deliveryCount do
      parsed.tasks[#parsed.tasks + 1] = {
        id = msg:getU32(),
        taskType = 'delivery',
        itemId = msg:getU16(),
        currentAmount = msg:getU16(),
        requiredAmount = msg:getU16(),
        isCompleted = msg:getU8() == 1,
      }
    end

    local function decodeOfferType(typeCode)
      if typeCode == 1 then return 'expansion' end
      if typeCode == 2 then return 'experience' end
      if typeCode == 3 then return 'seals' end
      if typeCode == 4 then return 'item' end
      return 'unknown'
    end

    local shopCount = msg:getU8()
    for i = 1, shopCount do
      parsed.shop[#parsed.shop + 1] = {
        id = msg:getString(),
        name = msg:getString(),
        price = msg:getU16(),
        type = decodeOfferType(msg:getU8()),
        amount = msg:getU16(),
        itemId = msg:getU16(),
      }
    end

    return parsed
  end)

  if not ok then
    perror('[game_weeklytasks] Failed to parse weekly sync packet: ' .. tostring(parsedOrError))
    return
  end

  state = parsedOrError
  modules.game_weeklytasks.refresh()
end

function refreshDifficultyPage()
  local page = window.difficultyPage
  page:setVisible(state.state == 0)
  if state.state ~= 0 then
    return
  end

  local summary = string.format("Completed kills: %d | Completed deliveries: %d | Points: %d | Seals: %d",
    state.completedKillTasks or 0,
    state.completedDeliveryTasks or 0,
    state.points or 0,
    state.soulSeals or 0)
  page.difficultySummary:setText(summary)

  local lvl = g_game.getLocalPlayer() and g_game.getLocalPlayer():getLevel() or 0
  page.btnBeginner:setEnabled(lvl >= (state.difficulties and state.difficulties.Beginner or 8))
  page.btnAdept:setEnabled(lvl >= (state.difficulties and state.difficulties.Adept or 30))
  page.btnExpert:setEnabled(lvl >= (state.difficulties and state.difficulties.Expert or 150))
  page.btnMaster:setEnabled(lvl >= (state.difficulties and state.difficulties.Master or 300))
end

local function createTaskTile(parent, task)
  local tile = g_ui.createWidget('WeeklyTaskTile', parent)
  tile.deliver:setVisible(task.taskType == 'delivery')
  tile.progress:setText(string.format('%d of %d', task.currentAmount or 0, task.requiredAmount or 0))

  if task.taskType == 'kill' then
    tile.item:setVisible(false)
    tile.creature:setVisible(true)
    tile.title:setText(task.targetName)
    tile.creature:setName(task.targetName)
  else
    tile.item:setVisible(true)
    tile.creature:setVisible(false)
    tile.item:setItemId(task.itemId)
    tile.title:setText(string.format('Item #%d', task.itemId))
    tile.deliver.onClick = function()
      sendAction(3, function(msg) msg:addU32(task.id) end)
    end
  end

  if task.isCompleted then
    tile.deliver:setEnabled(false)
    tile.progress:setText('Completed')
  end

  return tile
end

function refreshActivePage()
  local page = window.activePage
  page:setVisible(state.state == 1)
  if state.state ~= 1 then
    return
  end

  page.killPanel.killList:destroyChildren()
  page.deliveryPanel.deliveryList:destroyChildren()

  for _, task in ipairs(state.tasks or {}) do
    if task.taskType == 'kill' then
      createTaskTile(page.killPanel.killList, task)
    else
      createTaskTile(page.deliveryPanel.deliveryList, task)
    end
  end

  page.weeklyStats:setText(string.format(
    'Difficulty: %s | Completed Kills: %d | Completed Deliveries: %d | Task Points: %d | Soul Seals: %d',
    state.difficulty or '-', state.completedKillTasks or 0, state.completedDeliveryTasks or 0, state.points or 0, state.soulSeals or 0))

  page.multiplierPanel.multiplierInfo:setText(string.format('Multiplier: x%.2f | Total completed: %d', state.multiplier or 1, (state.completedKillTasks or 0) + (state.completedDeliveryTasks or 0)))

  local combo = page.shopPanel.shopOffers
  combo:clearOptions()
  for _, offer in ipairs(state.shop or {}) do
    combo:addOption(string.format('%s (%d pts)', offer.name, offer.price), offer.id)
  end
end

function refresh()
  if not window then
    return
  end

  refreshDifficultyPage()
  refreshActivePage()
end

function show()
  if not window then
    return
  end

  window:show()
  window:raise()
  window:focus()

  if button then
    button:setOn(true)
  end

  sendAction(1)
end

function hide()
  if not window then
    return
  end

  window:hide()

  if button then
    button:setOn(false)
  end
end

function toggle()
  if not window then
    return
  end

  if window:isVisible() then
    hide()
  else
    show()
  end
end

local function online()
  if not button and modules.game_mainpanel and modules.game_mainpanel.addToggleButton then
    button = modules.game_mainpanel.addToggleButton('weeklyTasksButton', tr('Weekly Tasks'), '/images/options/button_weeklytasks', toggle, false, 18)
    button:setOn(false)
  end
end

local function onGameStart()
  online()
  sendAction(1)
end

local function onGameEnd()
  hide()
  state = {}
end

function init()
  window = g_ui.displayUI('game_weeklytasks')
  if not window then
    perror('[game_weeklytasks] Failed to load UI from game_weeklytasks.otui')
    return
  end

  window:hide()

  window.close.onClick = hide
  window.difficultyPage.btnBeginner.onClick = function() sendAction(2, function(msg) msg:addString('Beginner') end) end
  window.difficultyPage.btnAdept.onClick = function() sendAction(2, function(msg) msg:addString('Adept') end) end
  window.difficultyPage.btnExpert.onClick = function() sendAction(2, function(msg) msg:addString('Expert') end) end
  window.difficultyPage.btnMaster.onClick = function() sendAction(2, function(msg) msg:addString('Master') end) end
  window.activePage.shopPanel.buyOffer.onClick = function()
    local option = window.activePage.shopPanel.shopOffers:getCurrentOption()
    local id = option and option.data
    if id then
      sendAction(4, function(msg) msg:addString(id) end)
    end
  end

  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  ProtocolGame.registerExtendedOpcode(OPCODE_EVENT, parseOpcode)

  if g_game.isOnline() then
    online()
  end
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  ProtocolGame.unregisterExtendedOpcode(OPCODE_EVENT)

  if button then
    button:destroy()
    button = nil
  end

  if window then
    window:destroy()
    window = nil
  end
end
