TaskBoardController = TaskBoardController or {}

local ui
local refs = {}
local activeMenu = 'challengesMenu'

local SHOP_ICON_BY_OFFER = {
  expansion_unlock = 18544,
  xp_boost_small = 3725,
  soul_pack = 3004,
  supply_token = 3031,
}

local function findChild(widget, id)
  if not widget then return nil end
  local child = widget:getChildById(id)
  if not child and widget.recursiveGetChildById then
    child = widget:recursiveGetChildById(id)
  end
  return child
end

local function safePercent(current, required)
  if (required or 0) <= 0 then return 0 end
  return math.max(0, math.min(100, math.floor(((current or 0) * 100) / required)))
end

local function switchMenu(menuId)
  activeMenu = menuId
  if refs.missionPanel then refs.missionPanel:setVisible(menuId == 'challengesMenu') end
  if refs.progressPanel then refs.progressPanel:setVisible(menuId == 'rewardsMenu') end
  if refs.challengesMenu then refs.challengesMenu:setOn(menuId == 'challengesMenu') end
  if refs.rewardsMenu then refs.rewardsMenu:setOn(menuId == 'rewardsMenu') end
end

local function renderDailyMissions()
  if not refs.dailyMissionsBg then return end
  refs.dailyMissionsBg:destroyChildren()

  local board = TaskBoardStore.getState().board
  local list = board.dailyMissions or {}
  for _, mission in ipairs(list) do
    local widget = g_ui.createWidget('TaskBoardMissionWidget', refs.dailyMissionsBg)
    widget.missionName:setText(mission.name or 'Daily Mission')
    widget.missionProgress:setValue(safePercent(mission.current, mission.required))
    local status = mission.claimed and 'Claimed' or string.format('%d/%d', mission.current or 0, mission.required or 0)
    widget.missionProgressText:setText(status)
  end
end

local function renderBounties()
  if not refs.bountyCardsContainer then return end
  local board = TaskBoardStore.getState().board
  refs.bountyDifficultyGate:setVisible(board.boardState == 'WAITING_DIFFICULTY')
  refs.bountyCardsContainer:setVisible(board.boardState ~= 'WAITING_DIFFICULTY')
  refs.bountyCardsContainer:destroyChildren()

  for _, task in ipairs(board.bounties or {}) do
    local card = g_ui.createWidget('TaskBoardBountyCard', refs.bountyCardsContainer)
    card.title:setText(task.monsterName or 'Bounty')
    card.icon:setItemId(3031)
    card.progressBar:setValue(safePercent(task.current, task.required))
    card.progressText:setText(string.format('%d / %d', task.current or 0, task.required or 0))
    local preview = task.claimed and 'Claimed' or (task.completed and 'Ready to claim' or 'In progress')
    card.rewardPreview:setText(preview)
    card.onDoubleClick = function()
      if task.completed and not task.claimed then
        TaskBoardProtocol.sendAction('claimBounty', { bountyId = task.id })
      end
    end
  end
end

local function renderWeekly()
  if not refs.weeklyKillGrid or not refs.weeklyDeliveryGrid then return end
  local board = TaskBoardStore.getState().board
  refs.weeklyKillGrid:destroyChildren()
  refs.weeklyDeliveryGrid:destroyChildren()

  for _, task in ipairs(board.weeklyTasks or {}) do
    local parent = task.subtype == 'delivery' and refs.weeklyDeliveryGrid or refs.weeklyKillGrid
    local slot = g_ui.createWidget('TaskBoardWeeklySlot', parent)
    slot.title:setText(task.targetName or 'Task')
    slot.icon:setItemId(task.subtype == 'delivery' and (task.targetId or 3031) or 9640)
    slot.progressBar:setValue(safePercent(task.current, task.required))
    slot.progressText:setText(task.completed and 'Completed' or string.format('%d / %d', task.current or 0, task.required or 0))
    if not task.completed and task.subtype == 'delivery' then
      slot.onDoubleClick = function()
        TaskBoardProtocol.sendAction('deliver', { itemId = task.targetId })
      end
    end
  end
end

local function createTrackSlot(parent, step, lane)
  local slot = g_ui.createWidget('TaskBoardTrackRewardSlot', parent)
  slot.levelLabel:setText(string.format('Lv.%d', step.stepId or 0))
  local laneData = lane == 'premium' and step.premium or step.free
  slot.rewardName:setText(laneData and laneData.title or '-')

  local canClaim = (step.unlocked == true) and laneData and not laneData.claimed
  if lane == 'premium' and not TaskBoardStore.getState().board.premiumEnabled then
    canClaim = false
    slot.claimButton:setText('Locked')
  elseif laneData and laneData.claimed then
    slot.claimButton:setText('Claimed')
  elseif step.unlocked then
    slot.claimButton:setText('Claim')
  else
    slot.claimButton:setText('Locked')
  end

  slot.claimButton:setEnabled(canClaim)
  slot.claimButton.onClick = function()
    TaskBoardProtocol.sendAction('claimReward', { stepId = step.stepId, lane = lane })
  end
end

local function renderRewardTrack()
  if not refs.freeTrack or not refs.premiumTrack then return end

  local board = TaskBoardStore.getState().board
  refs.freeTrack:destroyChildren()
  refs.premiumTrack:destroyChildren()

  for _, step in ipairs(board.rewardTrack or {}) do
    createTrackSlot(refs.freeTrack, step, 'free')
    createTrackSlot(refs.premiumTrack, step, 'premium')
  end

  if refs.playerLevel then
    refs.playerLevel:setText(string.format('Level %d', board.playerLevel or 0))
  end
  if refs.currentlyLevelText then
    refs.currentlyLevelText:setText(string.format('%d/%d', board.currentPoints or 0, board.nextStepPoints or 1))
  end
  if refs.levelProgress then
    refs.levelProgress:setValue(safePercent(board.currentPoints or 0, board.nextStepPoints or 1))
  end

  if refs.weeklyProgressBar then
    refs.weeklyProgressBar:setValue((board.weeklyProgress and board.weeklyProgress.totalCompleted) or 0)
  end
  if refs.multiplierState then
    refs.multiplierState:setText(string.format('x%.1f', (board.multiplier and board.multiplier.value) or 1.0))
  end
  applyRewardStepToSlot(slot, step, laneName)
end

local function renderShop()
  if not refs.shopGrid then return end

  local board = TaskBoardStore.getState().board
  refs.shopGrid:destroyChildren()
  for _, offer in ipairs(board.shopOffers or {}) do
    local card = g_ui.createWidget('TaskBoardShopCard', refs.shopGrid)
    card.icon:setItemId(SHOP_ICON_BY_OFFER[offer.id] or 3031)
    card.name:setText(offer.name or 'Offer')
    card.description:setText(string.format('Price: %d task points', offer.price or 0))
    local purchased = board.shopPurchases and board.shopPurchases[offer.id] or 0
    card.cost:setText(string.format('Cost: %d | Purchased: %d', offer.price or 0, purchased or 0))
    card.buy.onClick = function() TaskBoardProtocol.sendAction('buy', { offerId = offer.id }) end
  end
end

local function refreshAll()
  renderDailyMissions()
  renderBounties()
  renderWeekly()
  renderRewardTrack()
  renderShop()
end

function TaskBoardController.setup(window)
  ui = window
  refs = {}
  dailyMissionWidgets = {}
  rewardSlotWidgets = { free = {}, premium = {} }

  refs.closeButton = findChild(ui, 'closeButton')
  refs.mainPanel = findChild(ui, 'mainPanel')
  refs.optionsTabBar = findChild(refs.mainPanel, 'optionsTabBar')
  refs.challengesMenu = findChild(refs.optionsTabBar, 'challengesMenu')
  refs.rewardsMenu = findChild(refs.optionsTabBar, 'rewardsMenu')

  refs.contentPanel = findChild(refs.mainPanel, 'contentPanel')
  refs.missionPanel = findChild(refs.contentPanel, 'missionPanel')
  refs.progressPanel = findChild(refs.contentPanel, 'progressPanel')

  refs.dailyMissionsBg = findChild(refs.missionPanel, 'dailyMissionsBg')
  refs.playerLevel = findChild(refs.missionPanel, 'playerLevel')
  refs.levelProgress = findChild(refs.missionPanel, 'levelProgress')
  refs.currentlyLevelText = findChild(refs.missionPanel, 'currentlyLevelText')

  refs.bountyDifficultyGate = findChild(refs.missionPanel, 'bountyDifficultyGate')
  refs.bountyCardsContainer = findChild(refs.missionPanel, 'bountyCardsContainer')
  refs.difficultyDropdown = findChild(refs.missionPanel, 'difficultyDropdown')
  refs.preferredListButton = findChild(refs.missionPanel, 'preferredListButton')
  refs.rerollButton = findChild(refs.missionPanel, 'rerollButton')
  refs.claimDailyButton = findChild(refs.missionPanel, 'claimDailyButton')

  refs.weeklyKillGrid = findChild(refs.missionPanel, 'weeklyKillGrid')
  refs.weeklyDeliveryGrid = findChild(refs.missionPanel, 'weeklyDeliveryGrid')

  refs.weeklyProgressTrack = findChild(refs.progressPanel, 'weeklyProgressTrack')
  refs.weeklyProgressBar = findChild(refs.weeklyProgressTrack, 'weeklyProgressBar')
  refs.multiplierState = findChild(refs.weeklyProgressTrack, 'multiplierState')
  refs.freeTrack = findChild(refs.progressPanel, 'freeTrack')
  refs.premiumTrack = findChild(refs.progressPanel, 'premiumTrack')
  refs.shopGrid = findChild(refs.progressPanel, 'shopGrid')

  if refs.closeButton then refs.closeButton.onClick = function() modules.game_taskboard.toggle() end end
  if refs.challengesMenu then refs.challengesMenu.onClick = function() switchMenu('challengesMenu') end end
  if refs.rewardsMenu then refs.rewardsMenu.onClick = function() switchMenu('rewardsMenu') end end

  if refs.difficultyDropdown then
    refs.difficultyDropdown:clearOptions()
    for _, difficulty in ipairs(TaskBoardStore.getState().board.difficulties) do
      refs.difficultyDropdown:addOption(difficulty)
    end
    refs.difficultyDropdown.onOptionChange = function(_, text)
      TaskBoardProtocol.sendAction('selectDifficulty', { difficulty = text })
    end
  end

  if refs.rerollButton then refs.rerollButton.onClick = function() TaskBoardProtocol.sendAction('reroll', {}) end end
  if refs.claimDailyButton then refs.claimDailyButton.onClick = function() TaskBoardProtocol.sendAction('claimDaily', {}) end end
  if refs.preferredListButton then refs.preferredListButton.onClick = function() displayInfoBox('Task Board', 'Preferred list can be configured.') end end

  switchMenu(activeMenu)
  refreshAll()
end

function TaskBoardController.onSync(payload)
  if type(payload) ~= 'table' then return end
  TaskBoardStore.applySync(payload)
  if refs.difficultyDropdown and payload.state and payload.state.difficulty then
    refs.difficultyDropdown:setCurrentOption(payload.state.difficulty)
  end
  refreshAll()
end

function TaskBoardController.onDelta(delta)
  TaskBoardStore.reduceDelta(delta)
  refreshAll()
end
