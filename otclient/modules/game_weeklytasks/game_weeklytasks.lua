local OPCODE_ACTION = 240
local OPCODE_EVENT = 241

local window
local button
local state = {}

local SHOP_ICON_BY_TYPE = {
  expansion = 18544,
  experience = 3725,
  seals = 3004,
  item = 3031
}

local function fmtReward(task)
  if task.taskType == 'kill' then
    return string.format('Hunt %d %s', task.requiredAmount or 0, task.targetName or 'creatures')
  end

  return string.format('Deliver %d x %s', task.requiredAmount or 0, task.itemName or string.format('Item #%d', task.itemId or 0))
end

local function fmtShopDescription(offer)
  if offer.type == 'expansion' then
    return 'Unlocks +3 kill and +3 delivery tasks every week.'
  elseif offer.type == 'experience' then
    return string.format('Grants %s experience.', offer.amount or 0)
  elseif offer.type == 'seals' then
    return string.format('Grants %s Soul Seals.', offer.amount or 0)
  elseif offer.type == 'item' then
    return string.format('Grants %dx item #%d.', offer.amount or 1, offer.itemId or 0)
  end

  return 'Weekly task shop offer.'
end

local function sendAction(payload)
  local protocol = g_game.getProtocolGame()
  if protocol then
    protocol:sendExtendedOpcode(OPCODE_ACTION, json.encode(payload))
  end
end

local function parseOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_EVENT then
    return
  end

  local data = json.decode(buffer)
  if not data then
    return
  end

  state = data
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
    tile.reward:setText(fmtReward(task))
    if task.outfit then
      tile.creature:setOutfit(task.outfit)
    else
      tile.creature:setVisible(false)
      tile.item:setVisible(true)
      tile.item:setItemId(9640)
    end
  else
    tile.item:setVisible(true)
    tile.creature:setVisible(false)
    tile.item:setItemId(task.itemId)
    tile.title:setText(task.itemName or string.format('Item #%d', task.itemId))
    tile.reward:setText(fmtReward(task))
    tile.deliver.onClick = function()
      sendAction({ action = 'deliver', entryId = task.id })
    end
  end

  if task.isCompleted then
    tile.deliver:setEnabled(false)
    tile.progress:setText('Completed')
  end

  return tile
end

local function createShopTile(parent, offer)
  local tile = g_ui.createWidget('WeeklyTaskShopTile', parent)
  local iconId = offer.itemId or SHOP_ICON_BY_TYPE[offer.type] or 3031

  tile.offerItem:setItemId(iconId)
  tile.offerName:setText(offer.name or 'Offer')
  tile.offerDescription:setText(fmtShopDescription(offer))
  tile.offerPrice:setText(string.format('%d task points', offer.price or 0))
  tile.buyButton.onClick = function()
    sendAction({ action = 'shopPurchase', offerId = offer.id })
  end
end

function refreshActivePage()
  local page = window.activePage
  page:setVisible(state.state == 1)
  if state.state ~= 1 then
    return
  end

  page.killPanel.killList:destroyChildren()
  page.deliveryPanel.deliveryList:destroyChildren()
  page.shopPanel:destroyChildren()

  local killCount = 0
  local deliveryCount = 0
  for _, task in ipairs(state.tasks or {}) do
    if task.taskType == 'kill' then
      createTaskTile(page.killPanel.killList, task)
      killCount = killCount + 1
    else
      createTaskTile(page.deliveryPanel.deliveryList, task)
      deliveryCount = deliveryCount + 1
    end
  end

  page.weeklyStats:setText(string.format(
    'Difficulty: %s | Completed Kills: %d | Completed Deliveries: %d | Task Points: %d | Soul Seals: %d',
    state.difficulty or '-', state.completedKillTasks or 0, state.completedDeliveryTasks or 0, state.points or 0, state.soulSeals or 0))

  page.multiplierPanel.multiplierInfo:setText(string.format('Multiplier: x%.2f | Total completed: %d', state.multiplier or 1, (state.completedKillTasks or 0) + (state.completedDeliveryTasks or 0)))

  for _, offer in ipairs(state.shop or {}) do
    createShopTile(page.shopPanel, offer)
  end
end

function refresh()
  if not window then return end
  refreshDifficultyPage()
  refreshActivePage()
end

local function onGameStart()
  sendAction({ action = 'sync' })
end

local function onGameEnd()
  if window then window:setVisible(false) end
  state = {}
end

function toggle()
  if not window then return end
  window:setVisible(not window:isVisible())
  if window:isVisible() then
    sendAction({ action = 'sync' })
    window:raise()
    window:focus()
  end
end

function init()
  window = g_ui.displayUI('game_weeklytasks')
  window:setVisible(false)

  window.close.onClick = toggle
  window.difficultyPage.btnBeginner.onClick = function() sendAction({ action = 'selectDifficulty', difficulty = 'Beginner' }) end
  window.difficultyPage.btnAdept.onClick = function() sendAction({ action = 'selectDifficulty', difficulty = 'Adept' }) end
  window.difficultyPage.btnExpert.onClick = function() sendAction({ action = 'selectDifficulty', difficulty = 'Expert' }) end
  window.difficultyPage.btnMaster.onClick = function() sendAction({ action = 'selectDifficulty', difficulty = 'Master' }) end

  if modules.client_topmenu and modules.client_topmenu.addLeftGameButton then
    button = modules.client_topmenu.addLeftGameButton('weeklyTasksButton', tr('Weekly Tasks'), '/images/topbuttons/questlog', toggle)
  end

  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  ProtocolGame.registerExtendedOpcode(OPCODE_EVENT, parseOpcode)
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
