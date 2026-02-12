TaskBoardBountyService = TaskBoardBountyService or {}

local basePath = string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardDomainModels then
    dofile(basePath .. "/domain/models.lua")
end
if not TaskBoardDomainValidator then
    dofile(basePath .. "/domain/validator.lua")
end
if not TaskBoardGenerator then
    dofile(basePath .. "/application/generator.lua")
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

local function toTaskInstances(taskDtos)
    local list = {}
    for _, dto in ipairs(taskDtos or {}) do
        list[#list + 1] = TaskBoardDomainModels.BountyTask:new(dto)
    end
    return list
end

local function toTaskDtos(tasks)
    local list = {}
    for _, task in ipairs(tasks or {}) do
        list[#list + 1] = task:toDTO()
    end
    return list
end

local function getCache(playerId)
    local cache = TaskBoardCache.get(playerId)
    if not cache then
        cache = TaskBoardRepository.loadSnapshot(playerId)
    end

    cache = cache or {
        state = TaskBoardDomainModels.PlayerTaskState:new({ playerId = playerId }):toDTO(),
        bounties = {},
        weeklyTasks = {},
        weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
    }
    TaskBoardCache.set(playerId, cache)
    return cache
end

local function saveState(playerId, cache)
    TaskBoardCache.set(playerId, cache)
    TaskBoardRepository.saveSnapshot(playerId, cache)
end

function TaskBoardBountyService.selectDifficulty(playerId, difficulty)
    local cache = getCache(playerId)
    local state = TaskBoardDomainModels.PlayerTaskState:new(cache.state)

    if not TaskBoardDomainValidator.canSelectDifficulty(state:toDTO()) then
        return {
            events = {},
            error = "DIFFICULTY_LOCKED",
        }
    end

    local bounties = TaskBoardGenerator.generateBounties(difficulty, cache.weekKey)
    state.boardState = "ACTIVE"
    state.difficulty = difficulty

    cache.state = state:toDTO()
    cache.bounties = toTaskDtos(bounties)

    saveState(playerId, cache)

    local events = {}
    for index, bounty in ipairs(cache.bounties or {}) do
        events[#events + 1] = {
            type = TaskBoardConstants.DELTA_EVENT.TASK_UPDATED,
            data = {
                scope = "bounty",
                task = bounty,
                state = index == 1 and cache.state or nil,
            },
        }
    end

    return {
        events = events,
    }
end

function TaskBoardBountyService.reroll(playerId, currentTimeUTC)
    local cache = getCache(playerId)
    local state = TaskBoardDomainModels.PlayerTaskState:new(cache.state)
    local rerollState = cache.rerollState or {
        dailyLimit = 1,
        weeklyLimit = 3,
        dailyUsed = 0,
        weeklyUsed = 0,
        cooldownUntil = 0,
    }

    local result = TaskBoardDomainValidator.canReroll(rerollState, currentTimeUTC)
    if not result.allowed then
        return {
            events = {},
            error = result.reason,
        }
    end

    local bounties = TaskBoardGenerator.generateBounties(state.difficulty, cache.weekKey)
    cache.bounties = toTaskDtos(bounties)

    rerollState.dailyUsed = rerollState.dailyUsed + 1
    rerollState.weeklyUsed = rerollState.weeklyUsed + 1
    rerollState.cooldownUntil = (tonumber(currentTimeUTC) or 0) + 86400
    cache.rerollState = rerollState

    saveState(playerId, cache)

    local events = {}
    for index, bounty in ipairs(cache.bounties or {}) do
        events[#events + 1] = {
            type = TaskBoardConstants.DELTA_EVENT.TASK_UPDATED,
            data = {
                scope = "bounty",
                task = bounty,
                rerollState = index == 1 and cache.rerollState or nil,
            },
        }
    end

    return {
        events = events,
    }
end

function TaskBoardBountyService.incrementKill(playerId, monsterName)
    local cache = getCache(playerId)
    local bounties = toTaskInstances(cache.bounties)
    local taskUpdated = nil

    for _, bounty in ipairs(bounties) do
        if not bounty.completed and bounty.monsterName:lower() == tostring(monsterName or ""):lower() then
            bounty:increment(1)
            taskUpdated = bounty:toDTO()
            break
        end
    end

    if not taskUpdated then
        return { events = {} }
    end

    cache.bounties = toTaskDtos(bounties)
    saveState(playerId, cache)

    return {
        events = {
            {
                type = TaskBoardConstants.DELTA_EVENT.TASK_UPDATED,
                data = {
                    scope = "bounty",
                    task = taskUpdated,
                },
            },
        },
    }
end

function TaskBoardBountyService.claimBounty(playerId, bountyId)
    local cache = getCache(playerId)
    local bounties = toTaskInstances(cache.bounties)
    local claimedTask = nil

    for _, bounty in ipairs(bounties) do
        if bounty.id == bountyId and bounty:isComplete() and not bounty.claimed then
            bounty:markClaimed()
            claimedTask = bounty:toDTO()
            break
        end
    end

    if not claimedTask then
        return {
            events = {},
            error = "BOUNTY_NOT_CLAIMABLE",
        }
    end

    cache.bounties = toTaskDtos(bounties)
    saveState(playerId, cache)

    return {
        events = {
            {
                type = TaskBoardConstants.DELTA_EVENT.TASK_UPDATED,
                data = {
                    scope = "bounty",
                    task = claimedTask,
                },
            },
        },
    }
end


function TaskBoardBountyService.claimDaily(playerId)
    local cache = getCache(playerId)
    local bounties = toTaskInstances(cache.bounties)
    local claimedMissions = {}

    for _, bounty in ipairs(bounties) do
        if bounty:isComplete() and not bounty.claimed then
            bounty:markClaimed()
            claimedMissions[#claimedMissions + 1] = {
                missionId = bounty.id,
                claimed = true,
                progress = {
                    current = bounty.current,
                    required = bounty.required,
                },
            }
        end
    end

    if #claimedMissions == 0 then
        return {
            events = {},
            error = "NO_DAILY_CLAIMS_AVAILABLE",
            claimedCount = 0,
        }
    end

    cache.bounties = toTaskDtos(bounties)
    saveState(playerId, cache)

    local events = {}
    for _, mission in ipairs(claimedMissions) do
        events[#events + 1] = {
            type = TaskBoardConstants.DELTA_EVENT.TASK_UPDATED,
            data = {
                scope = "daily",
                missionId = mission.missionId,
                claimed = mission.claimed,
                progress = mission.progress,
            },
        }
    end

    return {
        events = events,
        claimedCount = #claimedMissions,
    }
end

return TaskBoardBountyService
