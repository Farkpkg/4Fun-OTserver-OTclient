TaskBoardStore = TaskBoardStore or {}

local state = {
  ui = {
    selectedTab = 'bounty'
  },
  board = {
    boardState = 'WAITING_DIFFICULTY',
    difficulty = nil,
    difficulties = { 'Beginner', 'Adept', 'Expert', 'Master' }
  }
}

local function shallowCopyTable(source)
  local target = {}
  for key, value in pairs(source or {}) do
    target[key] = value
  end
  return target
end

function TaskBoardStore.getState()
  return state
end

function TaskBoardStore.setSelectedTab(tabId)
  state.ui.selectedTab = tabId
  return state
end

function TaskBoardStore.replaceState(nextState)
  state = nextState or state
  return state
end

function TaskBoardStore.reduceDelta(delta)
  if type(delta) ~= 'table' then
    return state
  end

  local next = shallowCopyTable(state)
  next.board = shallowCopyTable(state.board)

  if delta.type == 'weekRotated' then
    next.board.boardState = 'WAITING_DIFFICULTY'
  elseif delta.type == 'taskUpdated' and type(delta.data) == 'table' then
    if delta.data.state and delta.data.state.boardState then
      next.board.boardState = delta.data.state.boardState
    end
  end

  state = next
  return state
end
