TaskBoardShopService = TaskBoardShopService or {}

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
if not TaskBoardConstants then
    dofile(basePath .. "/constants.lua")
end

local OFFERS = {
    expansion_unlock = {
        id = "expansion_unlock",
        name = "Weekly Expansion Unlock",
        description = "Unlock extra weekly task slots for this week.",
        pricePoints = 250,
        weeklyLimit = 1,
    },
    xp_boost_small = {
        id = "xp_boost_small",
        name = "XP Crate",
        description = "Gain an instant burst of bonus experience.",
        pricePoints = 80,
        weeklyLimit = 5,
    },
    soul_pack = {
        id = "soul_pack",
        name = "Soul Seal Pack",
        description = "Receive additional Soul Seals.",
        pricePoints = 60,
        weeklyLimit = 10,
    },
    supply_token = {
        id = "supply_token",
        name = "Supply Token",
        description = "Claim useful hunt supply tokens.",
        pricePoints = 40,
        weeklyLimit = 10,
    },
}

local OFFER_ORDER = {
    "expansion_unlock",
    "xp_boost_small",
    "soul_pack",
    "supply_token",
}

local function getCache(playerId)
    local cache = TaskBoardCache.get(playerId) or {
        state = TaskBoardDomainModels.PlayerTaskState:new({ playerId = playerId }):toDTO(),
        weeklyProgress = TaskBoardDomainModels.WeeklyProgress:new():toDTO(),
        shopPurchases = {},
    }
    TaskBoardCache.set(playerId, cache)
    return cache
end

local function saveState(playerId, cache)
    TaskBoardCache.set(playerId, cache)
    TaskBoardRepository.savePlayerState(playerId, cache.state)
end

function TaskBoardShopService.getOffers(playerId)
    local cache = getCache(playerId)
    local offers = {}
    cache.shopPurchases = cache.shopPurchases or {}

    for _, offerId in ipairs(OFFER_ORDER) do
        local baseOffer = OFFERS[offerId]
        if baseOffer then
            local purchased = cache.shopPurchases[baseOffer.id] or 0
            offers[#offers + 1] = {
                id = baseOffer.id,
                name = baseOffer.name,
                description = baseOffer.description,
                pricePoints = baseOffer.pricePoints,
                weeklyLimit = baseOffer.weeklyLimit,
                purchased = purchased,
                limitReached = purchased >= baseOffer.weeklyLimit,
                blocked = false,
            }
        end
    end

    return offers
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

    cache.shopPurchases = cache.shopPurchases or {}
    local alreadyPurchased = cache.shopPurchases[offer.id] or 0
    if alreadyPurchased >= offer.weeklyLimit then
        return {
            events = {},
            error = "SHOP_WEEKLY_LIMIT_REACHED",
        }
    end

    local progress = TaskBoardDomainModels.WeeklyProgress:new(cache.weeklyProgress)
    if progress.taskPoints < offer.pricePoints then
        return {
            events = {},
            error = "NOT_ENOUGH_TASK_POINTS",
        }
    end

    progress.taskPoints = progress.taskPoints - offer.pricePoints
    cache.weeklyProgress = progress:toDTO()

    cache.shopPurchases[offer.id] = alreadyPurchased + 1
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
                    weeklyLimit = offer.weeklyLimit,
                    limitReached = cache.shopPurchases[offer.id] >= offer.weeklyLimit,
                },
            },
        },
    }
end

return TaskBoardShopService
