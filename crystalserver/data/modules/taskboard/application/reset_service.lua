TaskBoardResetService = TaskBoardResetService or {}

local basePath = string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardDomainModels then
    dofile(basePath .. "/domain/models.lua")
end
if not TaskBoardRepository then
    dofile(basePath .. "/infrastructure/repository.lua")
end
if not TaskBoardCache then
    dofile(basePath .. "/infrastructure/cache.lua")
end

local function mergeCache(playerId, patch)
    local cached = TaskBoardCache.get(playerId) or {}
    for key, value in pairs(patch) do
        cached[key] = value
    end
    TaskBoardCache.set(playerId, cached)
    return cached
end

function TaskBoardResetService.ensureWeek(playerId, currentWeekKey)
    local stateData = TaskBoardRepository.loadPlayerState(playerId)
    local state = TaskBoardDomainModels.PlayerTaskState:new(stateData or {
        playerId = playerId,
        weekKey = currentWeekKey,
        boardState = "WAITING_DIFFICULTY",
        difficulty = "",
    })

    if state.weekKey ~= currentWeekKey then
        if state.weekKey and state.weekKey ~= "" then
            TaskBoardRepository.clearWeek(playerId, state.weekKey)
        end

        state = TaskBoardDomainModels.PlayerTaskState:new({
            playerId = playerId,
            weekKey = currentWeekKey,
            boardState = "WAITING_DIFFICULTY",
            difficulty = "",
        })

        TaskBoardRepository.savePlayerState(playerId, state:toDTO())

        local refreshed = mergeCache(playerId, {
            weekKey = currentWeekKey,
            state = state:toDTO(),
            bounties = {},
            weeklyTasks = {},
            weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
            multiplier = { value = 1.0, nextThreshold = 4 },
            rerollState = nil,
        })
        TaskBoardRepository.saveSnapshot(playerId, refreshed)

        return {
            rotated = true,
            state = state:toDTO(),
        }
    end

    local refreshed = mergeCache(playerId, {
        weekKey = currentWeekKey,
        state = state:toDTO(),
    })
    TaskBoardRepository.saveSnapshot(playerId, refreshed)

    return {
        rotated = false,
        state = state:toDTO(),
    }
end

return TaskBoardResetService
