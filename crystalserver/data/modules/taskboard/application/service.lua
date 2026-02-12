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

local getCache

local function appendEvents(target, source)
    for _, event in ipairs((source and source.events) or {}) do
        target[#target + 1] = event
    end
end

local function getCache(playerId)
    local cache = TaskBoardCache.get(playerId)
    if not cache then
        local snapshot = TaskBoardRepository.loadSnapshot(playerId)
        cache = snapshot or {
            state = TaskBoardDomainModels.PlayerTaskState:new({ playerId = playerId }):toDTO(),
            bounties = {},
            weeklyTasks = {},
            weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
            multiplier = { value = 1.0, nextThreshold = 4 },
            shopPurchases = {},
        }
    end

    cache.weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new(cache.weeklyProgress):toDTO()
    if type(cache.multiplier) ~= "table" then
        cache.multiplier = { value = tonumber(cache.multiplier) or 1.0, nextThreshold = 4 }
    end

    TaskBoardCache.set(playerId, cache)
    return cache
end

local function buildRewardTrack(cache)
    local steps = {}
    local totalCompleted = (cache.weeklyProgress and cache.weeklyProgress.totalCompleted) or 0
    local shopOffers = TaskBoardShopService.getOffers()
    local purchases = cache.shopPurchases or {}

    for step = 1, 18 do
        local unlocked = totalCompleted >= step
        local freeOffer = shopOffers[((step - 1) % #shopOffers) + 1]
        local premiumOffer = shopOffers[((step) % #shopOffers) + 1]

        steps[#steps + 1] = {
            stepId = step,
            unlocked = unlocked,
            free = {
                offerId = freeOffer.id,
                title = freeOffer.name,
                claimed = purchases[string.format("track:free:%d", step)] == 1,
            },
            premium = {
                offerId = premiumOffer.id,
                title = premiumOffer.name,
                claimed = purchases[string.format("track:premium:%d", step)] == 1,
            },
        }
    end

    return steps
end

local function buildDailyMissions(cache)
    local missions = {}
    for idx = 1, 2 do
        local bounty = (cache.bounties or {})[idx]
        if bounty then
            missions[#missions + 1] = {
                id = bounty.id,
                name = bounty.monsterName,
                current = bounty.current,
                required = bounty.required,
                completed = bounty.completed,
                claimed = bounty.claimed,
            }
        end
    end
    return missions
end

local function buildSyncPayload(playerId)
    local cache = getCache(playerId)
    local totalCompleted = (cache.weeklyProgress and cache.weeklyProgress.totalCompleted) or 0

    return {
        state = cache.state,
        weekKey = cache.weekKey,
        bounties = cache.bounties or {},
        weeklyTasks = cache.weeklyTasks or {},
        weeklyProgress = cache.weeklyProgress or TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
        multiplier = cache.multiplier or { value = 1.0, nextThreshold = 4 },
        rerollState = cache.rerollState,
        shopPurchases = cache.shopPurchases or {},
        shopOffers = TaskBoardShopService.getOffers(),
        dailyMissions = buildDailyMissions(cache),
        rewardTrack = buildRewardTrack(cache),
        playerLevel = totalCompleted,
        currentPoints = totalCompleted,
        nextStepPoints = math.max(1, totalCompleted + 1),
        premiumEnabled = false,
        playerId = playerId,
        stateVersion = math.max(0, tonumber(cache.stateVersion) or 0),
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

    for _, task in ipairs(serialized) do
        deltas[#deltas + 1] = {
            type = "taskUpdated",
            data = {
                scope = "weekly",
                task = task,
            },
        }
    end

    for _, mission in ipairs(buildDailyMissions(cache)) do
        local dailyDelta = buildDailyMissionDelta(mission)
        if dailyDelta then
            deltas[#deltas + 1] = dailyDelta
        end
    end

    return {
        sync = nil,
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

function TaskBoardService.buy(playerId, offerId)
    local result = TaskBoardShopService.buy(playerId, offerId)
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

function TaskBoardService.claimDaily(playerId)
    local result = TaskBoardBountyService.claimDaily(playerId)
    return {
        sync = nil,
        deltas = result.events or {},
        error = result.error,
    }
end

function TaskBoardService.claimReward(playerId, stepId, lane)
    local cache = getCache(playerId)
    local step = tonumber(stepId)
    if not step or step < 1 or step > 18 then
        return { sync = nil, deltas = {}, error = "INVALID_REWARD_STEP" }
    end

    lane = tostring(lane or "free")
    if lane ~= "free" and lane ~= "premium" then
        return { sync = nil, deltas = {}, error = "INVALID_REWARD_LANE" }
    end

    if lane == "premium" and not cache.premiumEnabled then
        return { sync = nil, deltas = {}, error = "PREMIUM_REQUIRED" }
    end

    local totalCompleted = (cache.weeklyProgress and cache.weeklyProgress.totalCompleted) or 0
    if totalCompleted < step then
        return { sync = nil, deltas = {}, error = "REWARD_LOCKED" }
    end

    cache.shopPurchases = cache.shopPurchases or {}
    local key = string.format("track:%s:%d", lane, step)
    if cache.shopPurchases[key] == 1 then
        return { sync = nil, deltas = {}, error = "REWARD_ALREADY_CLAIMED" }
    end

    cache.shopPurchases[key] = 1
    TaskBoardRepository.saveSnapshot(playerId, cache)
    TaskBoardCache.set(playerId, cache)

    return {
        sync = buildSyncPayload(playerId),
        deltas = {},
    }
end

return TaskBoardService
