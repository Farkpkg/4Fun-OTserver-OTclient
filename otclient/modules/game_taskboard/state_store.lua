TaskBoardStore = TaskBoardStore or {}

local function cloneArray(source)
  local out = {}
  for i, value in ipairs(source or {}) do
    out[i] = value
  end
  return out
end

local function cloneMap(source)
  local out = {}
  for key, value in pairs(source or {}) do
    out[key] = value
  end
  return out
end

local state = {
  ui = { selectedTab = 'bounty' },
  board = {
    boardState = 'WAITING_DIFFICULTY',
    difficulty = nil,
    difficulties = { 'Beginner', 'Adept', 'Expert', 'Master' },
    weekKey = nil,
    bounties = {},
    weeklyTasks = {},
    dailyMissions = {},
    rewardTrack = {},
    playerLevel = 0,
    currentPoints = 0,
    nextStepPoints = 1,
    premiumEnabled = false,
    weeklyProgress = { completedKills = 0, completedDeliveries = 0, totalCompleted = 0, taskPoints = 0, soulSeals = 0 },
    multiplier = { value = 1.0, nextThreshold = 4 },
    rerollState = nil,
    shopPurchases = {},
    shopOffers = {},
  }
}

local function cloneBoard(source)
  source = source or {}
  return {
    boardState = source.boardState,
    difficulty = source.difficulty,
    difficulties = cloneArray(source.difficulties),
    weekKey = source.weekKey,
    bounties = cloneArray(source.bounties),
    weeklyTasks = cloneArray(source.weeklyTasks),
    dailyMissions = cloneArray(source.dailyMissions),
    rewardTrack = cloneArray(source.rewardTrack),
    playerLevel = source.playerLevel or 0,
    currentPoints = source.currentPoints or 0,
    nextStepPoints = source.nextStepPoints or 1,
    premiumEnabled = source.premiumEnabled == true,
    weeklyProgress = cloneMap(source.weeklyProgress),
    multiplier = cloneMap(source.multiplier),
    rerollState = source.rerollState and cloneMap(source.rerollState) or nil,
    shopPurchases = cloneMap(source.shopPurchases),
    shopOffers = cloneArray(source.shopOffers),
  }
end

function TaskBoardStore.getState() return state end
function TaskBoardStore.setSelectedTab(tabId) state.ui.selectedTab = tabId return state end

function TaskBoardStore.applySync(payload)
  local current = state.board
  state = {
    ui = cloneMap(state.ui),
    board = {
      boardState = payload.state and payload.state.boardState or current.boardState,
      difficulty = payload.state and payload.state.difficulty or current.difficulty,
      difficulties = cloneArray(current.difficulties),
      weekKey = payload.weekKey or current.weekKey,
      bounties = cloneArray(payload.bounties or {}),
      weeklyTasks = cloneArray(payload.weeklyTasks or {}),
      dailyMissions = cloneArray(payload.dailyMissions or {}),
      rewardTrack = cloneArray(payload.rewardTrack or {}),
      playerLevel = payload.playerLevel or 0,
      currentPoints = payload.currentPoints or 0,
      nextStepPoints = payload.nextStepPoints or 1,
      premiumEnabled = payload.premiumEnabled == true,
      weeklyProgress = cloneMap(payload.weeklyProgress or current.weeklyProgress),
      multiplier = cloneMap(payload.multiplier or current.multiplier),
      rerollState = payload.rerollState and cloneMap(payload.rerollState) or current.rerollState,
      shopPurchases = cloneMap(payload.shopPurchases or current.shopPurchases),
      shopOffers = cloneArray(payload.shopOffers or current.shopOffers),
    }
  }
  return state
end

function TaskBoardStore.reduceDelta(delta)
  if type(delta) ~= 'table' then return state end
  local next = { ui = cloneMap(state.ui), board = cloneBoard(state.board) }
  local data = delta.data or {}
  if delta.type == 'weekRotated' then
    next.board.boardState = 'WAITING_DIFFICULTY'
    next.board.difficulty = nil
    next.board.bounties = {}
    next.board.weeklyTasks = {}
    next.board.dailyMissions = {}
    next.board.rewardTrack = {}
  elseif delta.type == 'taskUpdated' then
    if data.state and data.state.boardState then
      next.board.boardState = data.state.boardState
      next.board.difficulty = data.state.difficulty
    end
    if data.scope == 'bounty' then
      if type(data.tasks) == 'table' then next.board.bounties = cloneArray(data.tasks)
      elseif type(data.task) == 'table' then
        for i,t in ipairs(next.board.bounties) do if t.id == data.task.id then next.board.bounties[i] = data.task break end end
      end
    elseif data.scope == 'weekly' then
      if type(data.tasks) == 'table' then next.board.weeklyTasks = cloneArray(data.tasks)
      elseif type(data.task) == 'table' then
        for i,t in ipairs(next.board.weeklyTasks) do if t.id == data.task.id then next.board.weeklyTasks[i] = data.task break end end
      end
    end
    if type(data.rerollState)=='table' then next.board.rerollState = cloneMap(data.rerollState) end
  elseif delta.type == 'progressUpdated' then
    next.board.weeklyProgress = cloneMap(data)
  elseif delta.type == 'multiplierUpdated' then
    next.board.multiplier = cloneMap(data)
  elseif delta.type == 'shopUpdated' then
    if data.offerId then next.board.shopPurchases[data.offerId] = data.purchased or 0 end
  end
  state = next
  return state
end
