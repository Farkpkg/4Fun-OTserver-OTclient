TaskBoardStore = TaskBoardStore or {}

local store = {
  ui = {
    selectedTab = 'bounty'
  },
  server = {}
}

local function cloneList(source)
  local list = {}
  for index, value in ipairs(source or {}) do
    list[index] = value
  end
  return list
end

local function upsertTask(taskList, task)
  if type(task) ~= 'table' then
    return
  end

  for index, existing in ipairs(taskList) do
    if existing.id == task.id then
      taskList[index] = task
      return
    end
  end

  taskList[#taskList + 1] = task
end

function TaskBoardStore.getState()
  return store
end

function TaskBoardStore.setSelectedTab(tabId)
  store.ui.selectedTab = tabId
  return store
end

function TaskBoardStore.setFullState(newState)
  store.server = type(newState) == 'table' and newState or {}
  store.server.__awaitingSync = false
  return store
end

function TaskBoardStore.resetServerState(keepUi)
  store.server = { __awaitingSync = true }
  if not keepUi then
    store.ui.selectedTab = 'bounty'
  end
  return store
end

function TaskBoardStore.applyDelta(delta)
  local dirty = {}

  if type(delta) ~= 'table' then
    return dirty
  end

  local eventType = delta.type or delta.event
  local payload = type(delta.data) == 'table' and delta.data or {}

  if eventType == 'taskUpdated' then
    if payload.state then
      store.server.state = payload.state
      dirty.state = true
    end

    if payload.rerollState then
      store.server.rerollState = payload.rerollState
      dirty.rerollState = true
    end

    if payload.scope == 'bounty' then
      if payload.tasks then
        store.server.bounties = cloneList(payload.tasks)
        dirty.bountyFull = true
      elseif payload.task then
        store.server.bounties = store.server.bounties or {}
        upsertTask(store.server.bounties, payload.task)
        dirty.bountyTaskId = payload.task.id
      end
      dirty.bounty = true
    elseif payload.scope == 'weekly' then
      if payload.tasks then
        store.server.weeklyTasks = cloneList(payload.tasks)
        dirty.weeklyFull = true
      elseif payload.task then
        store.server.weeklyTasks = store.server.weeklyTasks or {}
        upsertTask(store.server.weeklyTasks, payload.task)
        dirty.weeklyTaskId = payload.task.id
      end
      dirty.weekly = true
    end
  elseif eventType == 'progressUpdated' then
    store.server.weeklyProgress = payload
    dirty.progress = true
  elseif eventType == 'multiplierUpdated' then
    store.server.multiplier = payload.value or payload.multiplier or store.server.multiplier
    dirty.multiplier = true
  elseif eventType == 'shopUpdated' then
    store.server.shopPurchases = store.server.shopPurchases or {}
    store.server.shopOffers = store.server.shopOffers or {}

    if payload.offerId then
      local purchased = payload.purchased or payload.count or 0
      store.server.shopPurchases[payload.offerId] = purchased
      dirty.shopOfferId = payload.offerId

      for index, offer in ipairs(store.server.shopOffers) do
        if offer.id == payload.offerId then
          local updated = offer
          updated.purchased = purchased
          if payload.weeklyLimit ~= nil then
            updated.weeklyLimit = payload.weeklyLimit
          end
          if payload.limitReached ~= nil then
            updated.limitReached = payload.limitReached
          end
          if payload.blocked ~= nil then
            updated.blocked = payload.blocked
          end
          store.server.shopOffers[index] = updated
          break
        end
      end
    end

    dirty.shop = true
  elseif eventType == 'weekRotated' then
    store.server = { __awaitingSync = true }
    dirty.reset = true
    dirty.awaitingSync = true
  end

  return dirty
end
