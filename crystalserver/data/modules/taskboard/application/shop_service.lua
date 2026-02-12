TaskBoardShopService = TaskBoardShopService or {}

local basePath = _G.TaskBoardBasePath or string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardDomainModels then
    dofile(basePath .. "/domain/models.lua")
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

local OFFERS = {
    expansion_unlock = { id = "expansion_unlock", name = "Weekly Expansion Unlock", price = 250 },
    xp_boost_small = { id = "xp_boost_small", name = "XP Crate", price = 80 },
    soul_pack = { id = "soul_pack", name = "Soul Seal Pack", price = 60 },
    supply_token = { id = "supply_token", name = "Supply Token", price = 40 },
}

local function getCache(playerId)
    local cache = TaskBoardCache.get(playerId)
    if not cache then
        cache = TaskBoardRepository.loadSnapshot(playerId)
    end

    cache = cache or {
        state = TaskBoardDomainModels.PlayerTaskState:new({ playerId = playerId }):toDTO(),
        weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
        shopPurchases = {},
    }
    TaskBoardCache.set(playerId, cache)
    return cache
end

local function saveState(playerId, cache)
    TaskBoardCache.set(playerId, cache)
    TaskBoardRepository.saveSnapshot(playerId, cache)
end

function TaskBoardShopService.buy(playerId, offerId)
    local cache = getCache(playerId)
    local offer = OFFERS[tostring(offerId or "")]
    if not offer then
        return {
            events = {},
            error = "SHOP_OFFER_NOT_FOUND",
        }
    end

    local progress = TaskBoardDomainModels.WeeklyProgress:new(cache.weeklyProgress)
    if progress.taskPoints < offer.price then
        return {
            events = {},
            error = "NOT_ENOUGH_TASK_POINTS",
        }
    end

    progress.taskPoints = progress.taskPoints - offer.price
    cache.weeklyProgress = progress:toDTO()

    cache.shopPurchases = cache.shopPurchases or {}
    cache.shopPurchases[offer.id] = (cache.shopPurchases[offer.id] or 0) + 1

    saveState(playerId, cache)

    return {
        events = {
            {
                type = TaskBoardConstants.DELTA_EVENT.PROGRESS_UPDATED,
                data = cache.weeklyProgress,
            },
            {
                type = TaskBoardConstants.DELTA_EVENT.SHOP_UPDATED,
                data = {
                    offerId = offer.id,
                    purchased = cache.shopPurchases[offer.id],
                },
            },
        },
    }
end


function TaskBoardShopService.getOffers()
    local offers = {}
    for _, offer in pairs(OFFERS) do
        offers[#offers + 1] = {
            id = offer.id,
            name = offer.name,
            price = offer.price,
        }
    end

    table.sort(offers, function(a, b)
        return a.price < b.price
    end)

    return offers
end

return TaskBoardShopService
