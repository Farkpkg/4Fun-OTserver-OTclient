TaskBoardStore = TaskBoardStore or {}

local OBS_DEBUG = false

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

local function missionKey(id)
  return tostring(id or '')
end

local function rewardKey(stepId, lane)
  return string.format('%s:%s', tostring(stepId or ''), tostring(lane or 'free'))
end

local function buildDailyFromBounties(bounties)
  local daily = {}
  local seen = {}
  for i = 1, 2 do
    local bounty = (bounties or {})[i]
    if bounty and not seen[missionKey(bounty.id)] then
      seen[missionKey(bounty.id)] = true
      daily[#daily + 1] = {
        id = bounty.id,
        name = bounty.monsterName,
        current = bounty.current,
        required = bounty.required,
        completed = bounty.completed,
        claimed = bounty.claimed,
      }
    end
  end
  return daily
end

local function applyProgressDerivedFields(board, progressData)
  local points = tonumber((progressData and progressData.taskPoints) or board.currentPoints or 0) or 0
  points = math.max(0, points)
  local level = math.floor(points / 10)
  board.playerLevel = level
  board.currentPoints = points
  board.nextStepPoints = math.max(10, (level + 1) * 10)
end

local function applyRewardTrackUnlocks(board)
  local totalCompleted = tonumber((board.weeklyProgress and board.weeklyProgress.totalCompleted) or 0) or 0
  for _, step in ipairs(board.rewardTrack or {}) do
    if type(step) == 'table' then
      step.unlocked = totalCompleted >= (tonumber(step.stepId) or 0)
    end
  end
end

local function rebuildIndexes(board)
  board.dailyById = {}
  board.rewardByKey = {}
  board.weeklyById = {}
  board.bountyById = {}

  for index, mission in ipairs(board.dailyMissions or {}) do
    board.dailyById[missionKey(mission.id)] = index
  end

  for index, task in ipairs(board.weeklyTasks or {}) do
    board.weeklyById[missionKey(task.id)] = index
  end

  for index, task in ipairs(board.bounties or {}) do
    board.bountyById[missionKey(task.id)] = index
  end

  for index, step in ipairs(board.rewardTrack or {}) do
    board.rewardByKey[rewardKey(step.stepId, 'free')] = index
    board.rewardByKey[rewardKey(step.stepId, 'premium')] = index
  end
end

local function freshState()
  return {
    meta = { hasSync = false, lastVersion = 0 },
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
      dailyById = {},
      rewardByKey = {},
      weeklyById = {},
      bountyById = {},
    }
  }
end
local state = freshState()

local function cloneBoard(source)
  source = source or {}
  local cloned = {
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
    dailyById = {},
    rewardByKey = {},
    weeklyById = {},
    bountyById = {},
  }
  rebuildIndexes(cloned)
  return cloned
end



function TaskBoardStore.clearState()
  state = freshState()
  return state
end

function TaskBoardStore.getState() return state end
function TaskBoardStore.setSelectedTab(tabId) state.ui.selectedTab = tabId return state end

function TaskBoardStore.applySync(payload)
  payload = type(payload) == 'table' and payload or {}
  local current = state.board

  state = {
    meta = cloneMap(state.meta),
    ui = cloneMap(state.ui),
    board = {
      boardState = payload.state and payload.state.boardState or current.boardState,
      difficulty = payload.state and payload.state.difficulty or current.difficulty,
      difficulties = cloneArray(current.difficulties),
      weekKey = payload.weekKey or current.weekKey,
      bounties = cloneArray(payload.bounties or {}),
      weeklyTasks = cloneArray(payload.weeklyTasks or {}),
      dailyMissions = cloneArray(payload.dailyMissions or buildDailyFromBounties(payload.bounties or {})),
      rewardTrack = cloneArray(payload.rewardTrack or {}),
      playerLevel = payload.playerLevel or current.playerLevel or 0,
      currentPoints = payload.currentPoints or current.currentPoints or 0,
      nextStepPoints = payload.nextStepPoints or current.nextStepPoints or 1,
      premiumEnabled = payload.premiumEnabled == true,
      weeklyProgress = cloneMap(payload.weeklyProgress or current.weeklyProgress),
      multiplier = cloneMap(payload.multiplier or current.multiplier),
      rerollState = payload.rerollState and cloneMap(payload.rerollState) or current.rerollState,
      shopPurchases = cloneMap(payload.shopPurchases or current.shopPurchases),
      shopOffers = cloneArray(payload.shopOffers or current.shopOffers),
      dailyById = {},
      rewardByKey = {},
      weeklyById = {},
      bountyById = {},
    }
  }

  applyProgressDerivedFields(state.board, state.board.weeklyProgress)
  applyRewardTrackUnlocks(state.board)
  rebuildIndexes(state.board)

  state.meta.hasSync = true
  state.meta.lastVersion = math.max(tonumber(payload.stateVersion) or 0, tonumber(state.meta.lastVersion) or 0)
  return state
end

function TaskBoardStore.reduceDelta(delta)
  if type(delta) ~= 'table' then return state end
  if state.meta.hasSync ~= true then return state end

  local deltaVersion = tonumber(delta.version)
  if deltaVersion and deltaVersion <= (tonumber(state.meta.lastVersion) or 0) then
    if OBS_DEBUG and g_logger and g_logger.debug then
      g_logger.debug(string.format('[taskboard] stale delta ignored v=%d last=%d', deltaVersion, tonumber(state.meta.lastVersion) or 0))
    end
    return state
  end

  local next = { meta = cloneMap(state.meta), ui = cloneMap(state.ui), board = cloneBoard(state.board) }
  local data = type(delta.data) == 'table' and delta.data or {}

  if delta.type == 'weekRotated' then
    next.board.boardState = 'WAITING_DIFFICULTY'
    next.board.difficulty = nil
    next.board.bounties = {}
    next.board.weeklyTasks = {}
    next.board.dailyMissions = {}
    next.board.rewardTrack = {}
    rebuildIndexes(next.board)
  elseif delta.type == 'taskUpdated' then
    if data.state and data.state.boardState then
      next.board.boardState = data.state.boardState
      next.board.difficulty = data.state.difficulty
    end

    if data.scope == 'weekly' then
      if type(data.task) == 'table' and data.task.id then
        local key = missionKey(data.task.id)
        local index = next.board.weeklyById[key]
        if index then
          next.board.weeklyTasks[index] = data.task
        else
          next.board.weeklyTasks[#next.board.weeklyTasks + 1] = data.task
          next.board.weeklyById[key] = #next.board.weeklyTasks
        end
      end
    elseif data.scope == 'bounty' then
      if type(data.task) == 'table' and data.task.id then
        local key = missionKey(data.task.id)
        local index = next.board.bountyById[key]
        if index then
          next.board.bounties[index] = data.task
        else
          next.board.bounties[#next.board.bounties + 1] = data.task
          next.board.bountyById[key] = #next.board.bounties
        end
        next.board.dailyMissions = buildDailyFromBounties(next.board.bounties)
        rebuildIndexes(next.board)
      end
    elseif data.scope == 'daily' then
      local missionId = missionKey(data.missionId)
      local index = next.board.dailyById[missionId]
      if index then
        local mission = next.board.dailyMissions[index]
        mission.claimed = data.claimed == true or mission.claimed == true
        if type(data.progress) == 'table' then
          mission.current = tonumber(data.progress.current) or mission.current
          mission.required = tonumber(data.progress.required) or mission.required
        end
        if type(data.name) == 'string' and data.name ~= '' then
          mission.name = data.name
        end
      end
    elseif data.scope == 'rewardTrack' then
      local slot = tonumber(data.slot)
      local lane = data.lane == 'premium' and 'premium' or 'free'
      local index = next.board.rewardByKey[rewardKey(slot, lane)]
      if index then
        local step = next.board.rewardTrack[index]
        if type(step[lane]) ~= 'table' then step[lane] = {} end
        step[lane].claimed = data.claimed == true
      end
    end

    if type(data.rerollState) == 'table' then
      next.board.rerollState = cloneMap(data.rerollState)
    end
  elseif delta.type == 'progressUpdated' then
    if type(data.playerLevel) == 'number' then
      next.board.playerLevel = math.max(0, data.playerLevel)
    end
    if type(data.currentPoints) == 'number' then
      next.board.currentPoints = math.max(0, data.currentPoints)
    end
    if type(data.nextStepPoints) == 'number' then
      next.board.nextStepPoints = math.max(1, data.nextStepPoints)
    end
  elseif delta.type == 'multiplierUpdated' then
    next.board.multiplier = cloneMap(data)
  elseif delta.type == 'shopUpdated' then
    if data.offerId then next.board.shopPurchases[data.offerId] = data.purchased or 0 end
  end

  if deltaVersion then
    next.meta.lastVersion = deltaVersion
  end

  state = next
  return state
end
