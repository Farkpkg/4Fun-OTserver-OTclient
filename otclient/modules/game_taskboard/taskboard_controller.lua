TaskBoardController = TaskBoardController or {}

local ui
local tabs = {}
local refs = {}

local function findChild(widget, id, required)
  if not widget then
    if required then
      print(string.format('Taskboard: %s não encontrada', id))
    end
    return nil
  end

  local child = widget:getChildById(id)
  if not child and widget.recursiveGetChildById then
    child = widget:recursiveGetChildById(id)
  end

  if required and not child then
    print(string.format('Taskboard: %s não encontrada', id))
  end

  return child
end

local function createMockBountyCards()
  if not refs.bountyCardsContainer then return end
  refs.bountyCardsContainer:destroyChildren()

  for index = 1, 3 do
    local card = g_ui.createWidget('TaskBoardBountyCard', refs.bountyCardsContainer)
    card.title:setText(string.format('Bounty #%d', index))
    card.progressText:setText('0 / 100')
    card.rewardPreview:setText('Reward preview')
  end
end

local function createMockWeeklySlots()
  if not refs.weeklyKillGrid or not refs.weeklyDeliveryGrid then return end
  refs.weeklyKillGrid:destroyChildren()
  refs.weeklyDeliveryGrid:destroyChildren()

  for index = 1, 6 do
    local killSlot = g_ui.createWidget('TaskBoardWeeklySlot', refs.weeklyKillGrid)
    killSlot.title:setText(string.format('Kill Task %d', index))
    killSlot.progressText:setText('0/0')

    local deliverySlot = g_ui.createWidget('TaskBoardWeeklySlot', refs.weeklyDeliveryGrid)
    deliverySlot.title:setText(string.format('Delivery Task %d', index))
    deliverySlot.progressText:setText('0/0')
  end
end

local function createMockShopCards()
  if not refs.shopGrid then return end
  refs.shopGrid:destroyChildren()

  for index = 1, 6 do
    local card = g_ui.createWidget('TaskBoardShopCard', refs.shopGrid)
    card.name:setText(string.format('Offer %d', index))
    card.description:setText('Shop item description placeholder.')
    card.cost:setText('Cost: 0')
  end
end

local function applyViewModel(vm)
  if not refs.bountyDifficultyGate or not refs.bountyCardsContainer then return end

  refs.bountyDifficultyGate:setVisible(vm.bounty.showDifficultyGate)
  refs.bountyCardsContainer:setVisible(not vm.bounty.showDifficultyGate)
end

local function selectTab(tabId)
  TaskBoardStore.setSelectedTab(tabId)
  applyViewModel(TaskBoardViewModel.build(TaskBoardStore.getState()))
end

function TaskBoardController.setup(window)
  ui = window
  refs = {}

  refs.closeButton = findChild(ui, 'closeButton', true)
  refs.tabBar = findChild(ui, 'tabBar', true)
  refs.tabContent = findChild(ui, 'tabContent', true)

  refs.bountyPage = findChild(ui, 'bountyPage', true)
  if not refs.bountyPage then
    return
  end

  refs.weeklyPage = findChild(ui, 'weeklyPage', true)
  refs.shopPage = findChild(ui, 'shopPage', true)
  refs.bountyDifficultyGate = findChild(refs.bountyPage, 'bountyDifficultyGate', true)
  refs.bountyCardsContainer = findChild(refs.bountyPage, 'bountyCardsContainer', true)
  refs.bountyToolbar = findChild(refs.bountyPage, 'bountyToolbar', true)
  refs.difficultyDropdown = findChild(refs.bountyToolbar, 'difficultyDropdown', true)
  refs.weeklyKillGrid = findChild(refs.weeklyPage, 'weeklyKillGrid', true)
  refs.weeklyDeliveryGrid = findChild(refs.weeklyPage, 'weeklyDeliveryGrid', true)
  refs.shopGrid = findChild(refs.shopPage, 'shopGrid', true)

  if not refs.closeButton or not refs.tabBar or not refs.tabContent or not refs.weeklyPage or not refs.shopPage then
    return
  end

  refs.closeButton.onClick = function()
    modules.game_taskboard.toggle()
  end

  refs.tabBar:setContentWidget(refs.tabContent)
  tabs.bounty = refs.tabBar:addTab('Bounty Tasks', refs.bountyPage)
  tabs.weekly = refs.tabBar:addTab('Weekly Tasks', refs.weeklyPage)
  tabs.shop = refs.tabBar:addTab('Hunting Task Shop', refs.shopPage)

  refs.tabBar.onTabChange = function(_, tab)
    if tab == tabs.bounty then
      selectTab('bounty')
    elseif tab == tabs.weekly then
      selectTab('weekly')
    elseif tab == tabs.shop then
      selectTab('shop')
    end
  end

  if refs.difficultyDropdown then
    refs.difficultyDropdown.onOptionChange = function(_, text)
      local currentState = TaskBoardStore.getState()
      currentState.board.difficulty = text
      TaskBoardStore.replaceState(currentState)
      applyViewModel(TaskBoardViewModel.build(currentState))
    end
  end

  createMockBountyCards()
  createMockWeeklySlots()
  createMockShopCards()
  applyViewModel(TaskBoardViewModel.build(TaskBoardStore.getState()))
end

function TaskBoardController.onSync(payload)
  if type(payload) ~= 'table' then return end

  local currentState = TaskBoardStore.getState()
  currentState.board.boardState = payload.state and payload.state.boardState or currentState.board.boardState
  currentState.board.difficulty = payload.state and payload.state.difficulty or currentState.board.difficulty
  TaskBoardStore.replaceState(currentState)

  applyViewModel(TaskBoardViewModel.build(currentState))
end

function TaskBoardController.onDelta(delta)
  TaskBoardStore.reduceDelta(delta)
  applyViewModel(TaskBoardViewModel.build(TaskBoardStore.getState()))
end
