TaskBoardWeeklyService = TaskBoardWeeklyService or {}

local basePath = string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardDomainModels then
    dofile(basePath .. "/domain/models.lua")
end
if not TaskBoardDomainValidator then
    dofile(basePath .. "/domain/validator.lua")
end
if not TaskBoardDomainCalculator then
    dofile(basePath .. "/domain/calculator.lua")
end
if not TaskBoardRepository then
    dofile(basePath .. "/infrastructure/repository.lua")
end
if not TaskBoardCache then
    dofile(basePath .. "/infrastructure/cache.lua")
end
if not TaskBoardConstants then
    dofile(basePath .. "/constants.lua")
end

local TASK_POINTS_PER_COMPLETION = 10
local SOUL_SEALS_PER_COMPLETION = 1

local function getCache(playerId)
    local cache = TaskBoardCache.get(playerId)
    if not cache then
        cache = TaskBoardRepository.loadSnapshot(playerId)
    end

    cache = cache or {
        state = TaskBoardDomainModels.PlayerTaskState:new({ playerId = playerId }):toDTO(),
        weeklyTasks = {},
        weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
        multiplier = { value = 1.0, nextThreshold = 4 },
    }
    TaskBoardCache.set(playerId, cache)
    return cache
end

local function hydrateWeeklyTasks(taskDtos)
    local list = {}
    for _, dto in ipairs(taskDtos or {}) do
        list[#list + 1] = TaskBoardDomainModels.WeeklyTask:new(dto)
    end
    return list
end

local function serializeWeeklyTasks(tasks)
    local dtos = {}
    for _, task in ipairs(tasks or {}) do
        dtos[#dtos + 1] = task:toDTO()
    end
    return dtos
end

local function saveCache(playerId, cache)
    TaskBoardCache.set(playerId, cache)
    TaskBoardRepository.saveSnapshot(playerId, cache)
end

function TaskBoardWeeklyService.recalcProgress(playerId)
    local cache = getCache(playerId)
    local progress = TaskBoardDomainModels.WeeklyProgress:new(cache.weeklyProgress)
    local weeklyTasks = hydrateWeeklyTasks(cache.weeklyTasks)

    progress:recalcFromTasks(weeklyTasks)

    local multiplierMeta = TaskBoardDomainCalculator.getMultiplier(progress.totalCompleted)
    cache.weeklyProgress = progress:toDTO()
    cache.multiplier = multiplierMeta

    saveCache(playerId, cache)

    return {
        events = {
            {
                type = TaskBoardConstants.DELTA_EVENT.PROGRESS_UPDATED,
                data = cache.weeklyProgress,
            },
            {
                type = TaskBoardConstants.DELTA_EVENT.MULTIPLIER_UPDATED,
                data = multiplierMeta,
            },
        },
        progress = cache.weeklyProgress,
        multiplier = multiplierMeta,
    }
end

function TaskBoardWeeklyService.incrementKill(playerId, monsterName)
    local cache = getCache(playerId)
    local weeklyTasks = hydrateWeeklyTasks(cache.weeklyTasks)
    local updatedTask = nil
    local rewardApplied = false

    for _, task in ipairs(weeklyTasks) do
        if TaskBoardDomainValidator.validateKill(task:toDTO(), monsterName) then
            local wasCompleted = task:isComplete()
            task:increment(1)
            updatedTask = task:toDTO()

            if not wasCompleted and task:isComplete() then
                local progress = TaskBoardDomainModels.WeeklyProgress:new(cache.weeklyProgress)
                progress.taskPoints = progress.taskPoints + TASK_POINTS_PER_COMPLETION
                progress.soulSeals = progress.soulSeals + SOUL_SEALS_PER_COMPLETION
                cache.weeklyProgress = progress:toDTO()
                rewardApplied = true
            end
            break
        end
    end

    if not updatedTask then
        return { events = {} }
    end

    cache.weeklyTasks = serializeWeeklyTasks(weeklyTasks)
    saveCache(playerId, cache)

    local recalc = TaskBoardWeeklyService.recalcProgress(playerId)
    local events = {
        {
            type = TaskBoardConstants.DELTA_EVENT.TASK_UPDATED,
            data = {
                scope = "weekly",
                task = updatedTask,
            },
        },
    }

    if rewardApplied then
        events[#events + 1] = {
            type = TaskBoardConstants.DELTA_EVENT.PROGRESS_UPDATED,
            data = TaskBoardCache.get(playerId).weeklyProgress,
        }
    end

    for _, event in ipairs(recalc.events or {}) do
        events[#events + 1] = event
    end

    return { events = events }
end

function TaskBoardWeeklyService.deliverItem(playerId, itemId)
    local cache = getCache(playerId)
    local weeklyTasks = hydrateWeeklyTasks(cache.weeklyTasks)
    local updatedTask = nil
    local rewardApplied = false

    for _, task in ipairs(weeklyTasks) do
        if TaskBoardDomainValidator.validateDelivery(task:toDTO(), itemId) then
            local wasCompleted = task:isComplete()
            task:increment(1)
            updatedTask = task:toDTO()

            if not wasCompleted and task:isComplete() then
                local progress = TaskBoardDomainModels.WeeklyProgress:new(cache.weeklyProgress)
                progress.taskPoints = progress.taskPoints + TASK_POINTS_PER_COMPLETION
                progress.soulSeals = progress.soulSeals + SOUL_SEALS_PER_COMPLETION
                cache.weeklyProgress = progress:toDTO()
                rewardApplied = true
            end
            break
        end
    end

    if not updatedTask then
        return { events = {}, error = "DELIVERY_NOT_APPLICABLE" }
    end

    cache.weeklyTasks = serializeWeeklyTasks(weeklyTasks)
    saveCache(playerId, cache)

    local recalc = TaskBoardWeeklyService.recalcProgress(playerId)
    local events = {
        {
            type = TaskBoardConstants.DELTA_EVENT.TASK_UPDATED,
            data = {
                scope = "weekly",
                task = updatedTask,
            },
        },
    }

    if rewardApplied then
        events[#events + 1] = {
            type = TaskBoardConstants.DELTA_EVENT.PROGRESS_UPDATED,
            data = TaskBoardCache.get(playerId).weeklyProgress,
        }
    end

    for _, event in ipairs(recalc.events or {}) do
        events[#events + 1] = event
    end

    return { events = events }
end

return TaskBoardWeeklyService
