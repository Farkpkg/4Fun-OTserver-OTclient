TaskBoardController = TaskBoardController or {}

local ui
local tabs = {}

local function createMockBountyCards()
  if not ui then return end
  ui.bountyPage.bountyCardsContainer:destroyChildren()

  for index = 1, 3 do
    local card = g_ui.createWidget('TaskBoardBountyCard', ui.bountyPage.bountyCardsContainer)
    card.title:setText(string.format('Bounty #%d', index))
    card.progressText:setText('0 / 100')
    card.rewardPreview:setText('Reward preview')
  end
end

local function createMockWeeklySlots()
  if not ui then return end
  ui.weeklyPage.weeklyTop.weeklyKillPanel.weeklyKillGrid:destroyChildren()
  ui.weeklyPage.weeklyTop.weeklyDeliveryPanel.weeklyDeliveryGrid:destroyChildren()

  for index = 1, 6 do
    local killSlot = g_ui.createWidget('TaskBoardWeeklySlot', ui.weeklyPage.weeklyTop.weeklyKillPanel.weeklyKillGrid)
    killSlot.title:setText(string.format('Kill Task %d', index))
    killSlot.progressText:setText('0/0')

    local deliverySlot = g_ui.createWidget('TaskBoardWeeklySlot', ui.weeklyPage.weeklyTop.weeklyDeliveryPanel.weeklyDeliveryGrid)
    deliverySlot.title:setText(string.format('Delivery Task %d', index))
    deliverySlot.progressText:setText('0/0')
  end
end

local function createMockShopCards()
  if not ui then return end
  ui.shopPage.shopGrid:destroyChildren()

  for index = 1, 6 do
    local card = g_ui.createWidget('TaskBoardShopCard', ui.shopPage.shopGrid)
    card.name:setText(string.format('Offer %d', index))
    card.description:setText('Shop item description placeholder.')
    card.cost:setText('Cost: 0')
  end
end

local function applyViewModel(vm)
  if not ui then return end

  ui.bountyPage.bountyDifficultyGate:setVisible(vm.bounty.showDifficultyGate)
  ui.bountyPage.bountyCardsContainer:setVisible(not vm.bounty.showDifficultyGate)
end

local function selectTab(tabId)
  TaskBoardStore.setSelectedTab(tabId)
  applyViewModel(TaskBoardViewModel.build(TaskBoardStore.getState()))
end

function TaskBoardController.setup(window)
  ui = window

  ui.closeButton.onClick = function()
    modules.game_taskboard.toggle()
  end

  ui.tabBar:setContentWidget(ui.tabContent)
  tabs.bounty = ui.tabBar:addTab('Bounty Tasks', ui.bountyPage)
  tabs.weekly = ui.tabBar:addTab('Weekly Tasks', ui.weeklyPage)
  tabs.shop = ui.tabBar:addTab('Hunting Task Shop', ui.shopPage)

  ui.tabBar.onTabChange = function(_, tab)
    if tab == tabs.bounty then
      selectTab('bounty')
    elseif tab == tabs.weekly then
      selectTab('weekly')
    elseif tab == tabs.shop then
      selectTab('shop')
    end
  end

  ui.bountyPage.bountyToolbar.difficultyDropdown.onOptionChange = function(widget, text)
    local currentState = TaskBoardStore.getState()
    currentState.board.difficulty = text
    TaskBoardStore.replaceState(currentState)
    applyViewModel(TaskBoardViewModel.build(currentState))
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
