TaskBoardViewModel = TaskBoardViewModel or {}

local function mapBountyTasks(tasks)
  local mapped = {}

  for _, task in ipairs(tasks or {}) do
    local required = tonumber(task.required) or 0
    local current = tonumber(task.current) or 0
    local percent = required > 0 and math.floor((current / required) * 100) or 0

    mapped[#mapped + 1] = {
      id = task.id,
      monsterName = task.monsterName or task.targetName or 'Unknown Target',
      look = task.look,
      current = current,
      required = required,
      completed = task.completed == true,
      claimed = task.claimed == true,
      progressPercent = math.max(0, math.min(percent, 100)),
      progressText = string.format('%d / %d', current, required)
    }
  end

  return mapped
end

local function mapWeeklyTasks(tasks)
  local mapped = {
    kill = {},
    delivery = {}
  }

  for _, task in ipairs(tasks or {}) do
    local required = tonumber(task.required) or 0
    local current = tonumber(task.current) or 0
    local percent = required > 0 and math.floor((current / required) * 100) or 0

    local entry = {
      id = task.id,
      subtype = task.subtype,
      targetName = task.targetName or task.monsterName or 'Weekly Task',
      targetId = task.targetId,
      required = required,
      current = current,
      completed = task.completed == true,
      progressPercent = math.max(0, math.min(percent, 100)),
      progressText = string.format('%d / %d', current, required)
    }

    if task.subtype == 'delivery' then
      mapped.delivery[#mapped.delivery + 1] = entry
    else
      mapped.kill[#mapped.kill + 1] = entry
    end
  end

  return mapped
end


local function mapShopOffers(offers, purchases, points)
  local mapped = {}

  for _, offer in ipairs(offers or {}) do
    local pricePoints = tonumber(offer.pricePoints or offer.price or 0) or 0
    local weeklyLimit = tonumber(offer.weeklyLimit or 0) or 0
    local purchased = tonumber(offer.purchased or purchases[offer.id] or 0) or 0
    local limitReached = offer.limitReached == true or (weeklyLimit > 0 and purchased >= weeklyLimit)
    local blocked = offer.blocked == true
    local canBuy = not blocked and not limitReached and (tonumber(points) or 0) >= pricePoints

    local stateLabel = 'Ready'
    if blocked then
      stateLabel = 'Week blocked'
    elseif limitReached then
      stateLabel = 'Weekly limit reached'
    elseif (tonumber(points) or 0) < pricePoints then
      stateLabel = 'Insufficient points'
    end

    mapped[#mapped + 1] = {
      id = offer.id,
      name = offer.name or offer.id or 'Offer',
      description = offer.description or '',
      pricePoints = pricePoints,
      weeklyLimit = weeklyLimit,
      purchased = purchased,
      blocked = blocked,
      limitReached = limitReached,
      canBuy = canBuy,
      stateLabel = stateLabel,
      iconItemId = offer.iconItemId,
    }
  end

  return mapped
end

local function buildRerollState(server)
  local rerollState = server.rerollState or {}

  return {
    canReroll = rerollState.allowed ~= false,
    reason = rerollState.reason,
  }
end

local function buildMultiplierModel(value)
  local multiplier = tonumber(value) or 1.0
  local tiers = {
    { value = 1.0, label = 'x1' },
    { value = 1.3, label = 'x1.3' },
    { value = 1.7, label = 'x1.7' },
    { value = 2.0, label = 'x2' },
    { value = 2.5, label = 'x2.5' },
  }

  local activeLabel = 'x1'
  for _, tier in ipairs(tiers) do
    if math.abs(multiplier - tier.value) < 0.001 then
      activeLabel = tier.label
      break
    end
  end

  local labels = {}
  for _, tier in ipairs(tiers) do
    if tier.label == activeLabel then
      labels[#labels + 1] = string.format('[%s]', tier.label)
    else
      labels[#labels + 1] = tier.label
    end
  end

  return {
    value = multiplier,
    activeLabel = activeLabel,
    trackText = table.concat(labels, ' | ')
  }
end

function TaskBoardViewModel.build(storeState)
  local server = (storeState and storeState.server) or {}
  local boardState = (server.state and server.state.boardState) or 'WAITING_DIFFICULTY'
  local weeklyProgress = server.weeklyProgress or {}
  local weeklyTasks = mapWeeklyTasks(server.weeklyTasks)
  local rerollState = buildRerollState(server)
  local multiplier = buildMultiplierModel(server.multiplier)

  return {
    ui = {
      selectedTab = storeState.ui.selectedTab
    },
    board = {
      boardState = boardState,
      difficulty = server.state and server.state.difficulty,
      weekKey = server.weekKey,
      difficulties = server.difficulties or { 'Beginner', 'Adept', 'Expert', 'Master' }
    },
    bounty = {
      boardState = boardState,
      showDifficultyGate = boardState == 'WAITING_DIFFICULTY',
      bounties = mapBountyTasks(server.bounties),
      difficulty = server.state and server.state.difficulty,
      canReroll = rerollState.canReroll,
      rerollReason = rerollState.reason,
      canClaim = server.claimAvailable == true
    },
    weekly = {
      boardState = boardState,
      showBlocked = boardState == 'WAITING_DIFFICULTY',
      kills = weeklyTasks.kill,
      deliveries = weeklyTasks.delivery,
      totalCompleted = tonumber(weeklyProgress.totalCompleted) or 0,
      multiplier = multiplier
    },
    shop = {
      offers = mapShopOffers(server.shopOffers or {}, server.shopPurchases or {}, weeklyProgress.taskPoints or 0),
      purchases = server.shopPurchases or {},
      points = tonumber(weeklyProgress.taskPoints) or 0
    }
  }
end
