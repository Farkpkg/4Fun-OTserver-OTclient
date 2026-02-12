TaskBoardController = TaskBoardController or {}

local ui
local tabs = {}
local bountyCards = {}
local bountyById = {}
local weeklyKillSlots = {}
local weeklyKillById = {}
local weeklyDeliverySlots = {}
local weeklyDeliveryById = {}
local shopCards = {}
local shopCardByOfferId = {}
local pendingShopPurchases = {}
local pendingReroll = false
local isUpdatingDifficulty = false

local function updateDifficultyDropdown(vm)
  local dropdown = ui.bountyPage.bountyToolbar.difficultyDropdown
  isUpdatingDifficulty = true

  dropdown:clearOptions()
  for _, difficulty in ipairs(vm.board.difficulties or {}) do
    dropdown:addOption(difficulty)
  end

  dropdown:setEnabled(vm.bounty.boardState == 'WAITING_DIFFICULTY')
  if vm.board.difficulty then
    dropdown:setCurrentOption(vm.board.difficulty)
  end

  isUpdatingDifficulty = false
end

local function updateToolbar(vm)
  local rerollButton = ui.bountyPage.bountyToolbar.rerollButton
  local claimDailyButton = ui.bountyPage.bountyToolbar.claimDailyButton

  rerollButton:setEnabled(vm.bounty.canReroll and not pendingReroll)
  if pendingReroll then
    rerollButton:setTooltip('Reroll pending server confirmation')
  else
    rerollButton:setTooltip(vm.bounty.canReroll and '' or (vm.bounty.rerollReason or 'Reroll unavailable'))
  end

  claimDailyButton:setEnabled(vm.bounty.canClaim)
end

local function setBountyCardState(card, bounty, isBlocked)
  local hasData = bounty ~= nil

  if not hasData then
    card:setEnabled(false)
    card:setOpacity(0.45)
    card.title:setText('Empty Slot')
    card.progressBar:setValue(0)
    card.progressText:setText('0 / 0')
    card.actionButton:setEnabled(false)
    card.actionButton:setText('Unavailable')
    card.completedOverlay:setVisible(false)
    card.blockedOverlay:setVisible(isBlocked)
    card.monsterPreview:setOutfit({
      type = 0,
      auxType = 0,
      head = 0,
      body = 0,
      legs = 0,
      feet = 0,
      addons = 0,
      mount = 0,
    })
    return
  end

  card:setEnabled(true)
  card:setOpacity(isBlocked and 0.55 or 1.0)
  card.title:setText(bounty.monsterName)
  card.progressBar:setValue(bounty.progressPercent)
  card.progressText:setText(bounty.progressText)

  card.completedOverlay:setVisible(bounty.completed)
  card.blockedOverlay:setVisible(isBlocked)

  if bounty.look and card.monsterPreview.setOutfit then
    card.monsterPreview:setOutfit(bounty.look)
  end

  if bounty.claimed then
    card.actionButton:setText('Claimed')
    card.actionButton:setEnabled(false)
  elseif bounty.completed then
    card.actionButton:setText('Completed')
    card.actionButton:setEnabled(false)
  else
    card.actionButton:setText('Track')
    card.actionButton:setEnabled(not isBlocked)
  end

  card.actionButton.onClick = function()
    if bounty.completed and not bounty.claimed then
      TaskBoardProtocol.sendAction('claimBounty', { bountyId = bounty.id })
    end
  end
end

local function ensureBountyCards()
  if #bountyCards > 0 then
    return
  end

  local container = ui.bountyPage.bountyCardsContainer
  for _ = 1, 3 do
    bountyCards[#bountyCards + 1] = g_ui.createWidget('TaskBoardBountyCard', container)
  end
end

local function rebuildBountyIndex(bounties)
  bountyById = {}
  for index, bounty in ipairs(bounties or {}) do
    if bounty.id then
      bountyById[bounty.id] = index
    end
  end
end

local function renderBounty(vm)
  ensureBountyCards()
  pendingReroll = false

  ui.bountyPage.bountyDifficultyGate:setVisible(vm.bounty.showDifficultyGate)
  ui.bountyPage.bountyCardsContainer:setVisible(not vm.bounty.showDifficultyGate)

  updateToolbar(vm)
  rebuildBountyIndex(vm.bounty.bounties)

  for index = 1, 3 do
    local bounty = vm.bounty.bounties[index]
    setBountyCardState(bountyCards[index], bounty, vm.bounty.showDifficultyGate)
  end
end

local function renderSingleBountyCard(vm, bountyId)
  ensureBountyCards()
  updateToolbar(vm)

  local bountyIndex = bountyById[bountyId]
  if not bountyIndex or bountyIndex > 3 then
    renderBounty(vm)
    return
  end

  local bounty = vm.bounty.bounties[bountyIndex]
  setBountyCardState(bountyCards[bountyIndex], bounty, vm.bounty.showDifficultyGate)
end

local function setWeeklySlotState(slot, task, isBlocked)
  if not task then
    slot:setEnabled(false)
    slot:setOpacity(0.45)
    slot.title:setText('Empty Slot')
    slot.progressBar:setValue(0)
    slot.progressText:setText('0 / 0')
    slot.completedOverlay:setVisible(false)
    slot.blockedOverlay:setVisible(isBlocked)
    return
  end

  slot:setEnabled(true)
  slot:setOpacity(isBlocked and 0.55 or 1.0)
  slot.title:setText(task.targetName)
  slot.progressBar:setValue(task.progressPercent)
  slot.progressText:setText(task.progressText)
  slot.completedOverlay:setVisible(task.completed)
  slot.blockedOverlay:setVisible(isBlocked)
end

local function ensureWeeklySlots()
  if #weeklyKillSlots == 0 then
    local killGrid = ui.weeklyPage.weeklyTop.weeklyKillPanel.weeklyKillGrid
    for _ = 1, 3 do
      weeklyKillSlots[#weeklyKillSlots + 1] = g_ui.createWidget('TaskBoardWeeklySlot', killGrid)
    end
  end

  if #weeklyDeliverySlots == 0 then
    local deliveryGrid = ui.weeklyPage.weeklyTop.weeklyDeliveryPanel.weeklyDeliveryGrid
    for _ = 1, 3 do
      weeklyDeliverySlots[#weeklyDeliverySlots + 1] = g_ui.createWidget('TaskBoardWeeklySlot', deliveryGrid)
    end
  end
end

local function rebuildWeeklyIndex(tasks, indexMap)
  for key in pairs(indexMap) do
    indexMap[key] = nil
  end

  for index, task in ipairs(tasks or {}) do
    if task.id then
      indexMap[task.id] = index
    end
  end
end

local function renderWeeklyTrack(vm)
  local progressTrack = ui.weeklyPage.weeklyBottom.weeklyProgressTrack
  progressTrack.weeklyProgressBar:setValue(vm.weekly.totalCompleted or 0)
  progressTrack.multiplierState:setText(vm.weekly.multiplier.trackText)
end

local function renderWeekly(vm)
  ensureWeeklySlots()

  rebuildWeeklyIndex(vm.weekly.kills, weeklyKillById)
  rebuildWeeklyIndex(vm.weekly.deliveries, weeklyDeliveryById)

  for index = 1, 3 do
    setWeeklySlotState(weeklyKillSlots[index], vm.weekly.kills[index], vm.weekly.showBlocked)
    setWeeklySlotState(weeklyDeliverySlots[index], vm.weekly.deliveries[index], vm.weekly.showBlocked)
  end

  renderWeeklyTrack(vm)
end

local function renderSingleWeeklyTask(vm, taskId)
  ensureWeeklySlots()

  local killIndex = weeklyKillById[taskId]
  if killIndex and killIndex <= 3 then
    setWeeklySlotState(weeklyKillSlots[killIndex], vm.weekly.kills[killIndex], vm.weekly.showBlocked)
    return
  end

  local deliveryIndex = weeklyDeliveryById[taskId]
  if deliveryIndex and deliveryIndex <= 3 then
    setWeeklySlotState(weeklyDeliverySlots[deliveryIndex], vm.weekly.deliveries[deliveryIndex], vm.weekly.showBlocked)
    return
  end

  renderWeekly(vm)
end

local function setShopCardState(card, offer)
  card.name:setText(offer.name)
  card.description:setText(offer.description)
  card.cost:setText(string.format('Cost: %d', offer.pricePoints))
  card.limit:setText(string.format('Weekly limit: %d', offer.weeklyLimit))
  card.purchased:setText(string.format('Purchased: %d', offer.purchased))
  card.state:setText(offer.stateLabel)

  card:setOpacity((offer.blocked or offer.limitReached) and 0.6 or 1.0)
  card.buy:setEnabled(offer.canBuy and not pendingShopPurchases[offer.id])
  card.buy.onClick = function()
    if pendingShopPurchases[offer.id] then
      return
    end

    pendingShopPurchases[offer.id] = true
    if not TaskBoardProtocol.sendAction('buy', { offerId = offer.id }) then
      pendingShopPurchases[offer.id] = nil
    end
  end
end

local function ensureShopCards(vm)
  local offers = vm.shop.offers or {}
  local grid = ui.shopPage.shopGrid

  shopCardByOfferId = {}

  for index, offer in ipairs(offers) do
    if not shopCards[index] then
      shopCards[index] = g_ui.createWidget('TaskBoardShopCard', grid)
    end

    shopCards[index]:setVisible(true)
    shopCardByOfferId[offer.id] = index
  end

  for index = #offers + 1, #shopCards do
    shopCards[index]:setVisible(false)
  end
end

local function updateShopHeader(vm)
  if ui.shopPage.shopHeader and ui.shopPage.shopHeader.shopPointsLabel then
    ui.shopPage.shopHeader.shopPointsLabel:setText(string.format('Task Points: %d', vm.shop.points or 0))
  end
end

local function renderShop(vm)
  ensureShopCards(vm)
  updateShopHeader(vm)

  local activeOffers = {}
  for index, offer in ipairs(vm.shop.offers or {}) do
    activeOffers[offer.id] = true
    pendingShopPurchases[offer.id] = nil
    setShopCardState(shopCards[index], offer)
  end

  for offerId in pairs(pendingShopPurchases) do
    if not activeOffers[offerId] then
      pendingShopPurchases[offerId] = nil
    end
  end
end

local function renderSingleShopOffer(vm, offerId)
  updateShopHeader(vm)

  local cardIndex = shopCardByOfferId[offerId]
  if not cardIndex then
    renderShop(vm)
    return
  end

  local offer = vm.shop.offers[cardIndex]
  if not offer then
    renderShop(vm)
    return
  end

  pendingShopPurchases[offerId] = nil
  setShopCardState(shopCards[cardIndex], offer)
end

local function applySelectedTab(tabId)
  if tabId == 'weekly' then
    ui.tabBar:selectTab(tabs.weekly)
  elseif tabId == 'shop' then
    ui.tabBar:selectTab(tabs.shop)
  else
    ui.tabBar:selectTab(tabs.bounty)
  end
end

function TaskBoardController.renderAll()
  if not ui then return end
  local vm = TaskBoardViewModel.build(TaskBoardStore.getState())

  updateDifficultyDropdown(vm)
  renderBounty(vm)
  renderWeekly(vm)
  renderShop(vm)
  applySelectedTab(vm.ui.selectedTab)
end

function TaskBoardController.renderDelta(dirty)
  if not ui then return end
  local vm = TaskBoardViewModel.build(TaskBoardStore.getState())

  if dirty.reset then
    pendingReroll = false
    pendingShopPurchases = {}
    renderBounty(vm)
    renderWeekly(vm)
    renderShop(vm)
    return
  end

  if dirty.state then
    updateDifficultyDropdown(vm)
    renderBounty(vm)
    renderWeekly(vm)
  elseif dirty.bounty then
    if dirty.bountyTaskId and not dirty.bountyFull then
      renderSingleBountyCard(vm, dirty.bountyTaskId)
    else
      renderBounty(vm)
    end
  end

  if dirty.weekly then
    if dirty.weeklyTaskId and not dirty.weeklyFull then
      renderSingleWeeklyTask(vm, dirty.weeklyTaskId)
    else
      renderWeekly(vm)
    end
  elseif dirty.progress or dirty.multiplier then
    renderWeeklyTrack(vm)
  end

  if dirty.shop then
    if dirty.shopOfferId and not dirty.progress then
      renderSingleShopOffer(vm, dirty.shopOfferId)
    else
      renderShop(vm)
    end
  elseif dirty.progress then
    renderShop(vm)
  end
end

local function selectTab(tabId)
  TaskBoardStore.setSelectedTab(tabId)
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

  ui.bountyPage.bountyToolbar.difficultyDropdown.onOptionChange = function(_, text)
    if isUpdatingDifficulty then
      return
    end

    TaskBoardProtocol.sendAction('selectDifficulty', { difficulty = text })
  end

  ui.bountyPage.bountyToolbar.rerollButton.onClick = function()
    if pendingReroll then
      return
    end

    pendingReroll = TaskBoardProtocol.sendAction('reroll', {}) == true
  end

  ui.bountyPage.bountyToolbar.claimDailyButton.onClick = function()
    TaskBoardProtocol.sendAction('claimBounty', {})
  end

  ui.bountyPage.bountyToolbar.preferredListButton.onClick = function()
    -- placeholder for next phase; server action not wired yet.
  end

  TaskBoardController.renderAll()
end
