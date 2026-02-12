TaskBoardService = TaskBoardService or {}

local basePath = string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardDomainModels then
    dofile(basePath .. "/domain/models.lua")
end
if not TaskBoardGenerator then
    dofile(basePath .. "/application/generator.lua")
end
if not TaskBoardResetService then
    dofile(basePath .. "/application/reset_service.lua")
end
if not TaskBoardBountyService then
    dofile(basePath .. "/application/bounty_service.lua")
end
if not TaskBoardWeeklyService then
    dofile(basePath .. "/application/weekly_service.lua")
end
if not TaskBoardShopService then
    dofile(basePath .. "/application/shop_service.lua")
end
if not TaskBoardRepository then
    dofile(basePath .. "/infrastructure/repository.lua")
end
if not TaskBoardCache then
    dofile(basePath .. "/infrastructure/cache.lua")
end

local function appendEvents(target, source)
    for _, event in ipairs((source and source.events) or {}) do
        target[#target + 1] = event
    end
end

local function getCache(playerId)
    local cache = TaskBoardCache.get(playerId) or {
        state = TaskBoardDomainModels.PlayerTaskState:new({ playerId = playerId }):toDTO(),
        bounties = {},
        weeklyTasks = {},
        weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
        multiplier = 1.0,
        shopPurchases = {},
    }
    TaskBoardCache.set(playerId, cache)
    return cache
end

local function buildSyncPayload(playerId)
    local cache = getCache(playerId)
    return {
        state = cache.state,
        weekKey = cache.weekKey,
        bounties = cache.bounties or {},
        weeklyTasks = cache.weeklyTasks or {},
        weeklyProgress = cache.weeklyProgress or TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
        multiplier = cache.multiplier or 1.0,
        rerollState = cache.rerollState,
        shopPurchases = cache.shopPurchases or {},
        shopOffers = TaskBoardShopService.getOffers(playerId),
        playerId = playerId,
    }
end

function TaskBoardService.openBoard(playerId, currentWeekKey)
    local deltas = {}
    local resetResult = TaskBoardResetService.ensureWeek(playerId, currentWeekKey)

    if resetResult.rotated then
        deltas[#deltas + 1] = {
            type = "weekRotated",
            data = {
                weekKey = currentWeekKey,
            },
        }
    end

    return {
        sync = buildSyncPayload(playerId),
        deltas = deltas,
    }
end

function TaskBoardService.selectDifficulty(playerId, difficulty)
    local deltas = {}
    local cache = getCache(playerId)
    local bountyResult = TaskBoardBountyService.selectDifficulty(playerId, difficulty)
    appendEvents(deltas, bountyResult)

    if bountyResult.error then
        return {
            sync = nil,
            deltas = deltas,
            error = bountyResult.error,
        }
    end

    local weeklyTasks = TaskBoardGenerator.generateWeeklyTasks(difficulty, cache.weekKey)
    local serialized = {}
    for _, task in ipairs(weeklyTasks) do
        local dto = task:toDTO()
        serialized[#serialized + 1] = dto
        TaskBoardRepository.saveTask(playerId, dto)
    end

    cache = getCache(playerId)
    cache.weeklyTasks = serialized
    cache.weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new(cache.weeklyProgress):toDTO()
    TaskBoardCache.set(playerId, cache)

    local recalc = TaskBoardWeeklyService.recalcProgress(playerId)
    appendEvents(deltas, recalc)

    deltas[#deltas + 1] = {
        type = "taskUpdated",
        data = {
            scope = "weekly",
            tasks = serialized,
        },
    }

    return {
        sync = buildSyncPayload(playerId),
        deltas = deltas,
    }
end

function TaskBoardService.reroll(playerId, currentTimeUTC)
    local result = TaskBoardBountyService.reroll(playerId, currentTimeUTC)
    return {
        sync = nil,
        deltas = result.events or {},
        error = result.error,
    }
end

function TaskBoardService.onKill(playerId, monsterName)
    local deltas = {}

    local bountyResult = TaskBoardBountyService.incrementKill(playerId, monsterName)
    appendEvents(deltas, bountyResult)

    local weeklyResult = TaskBoardWeeklyService.incrementKill(playerId, monsterName)
    appendEvents(deltas, weeklyResult)

    return {
        sync = nil,
        deltas = deltas,
        error = bountyResult.error or weeklyResult.error,
    }
end

function TaskBoardService.deliver(playerId, itemId)
    local result = TaskBoardWeeklyService.deliverItem(playerId, itemId)
    return {
        sync = nil,
        deltas = result.events or {},
        error = result.error,
    }
end


function TaskBoardService.claimBounty(playerId, bountyId)
    local result = TaskBoardBountyService.claimBounty(playerId, bountyId)
    return {
        sync = nil,
        deltas = result.events or {},
        error = result.error,
    }
end

function TaskBoardService.buy(playerId, offerId)
    local result = TaskBoardShopService.buy(playerId, offerId)
    return {
        sync = nil,
        deltas = result.events or {},
        error = result.error,
    }
end

return TaskBoardService
