TaskBoardGenerator = TaskBoardGenerator or {}

local basePath = _G.TaskBoardBasePath or string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardDomainModels then
    dofile(basePath .. "/domain/models.lua")
end

local BOUNTY_POOLS = {
    Beginner = { "Rat", "Cave Rat", "Troll", "Orc", "Minotaur", "Rotworm" },
    Adept = { "Dragon Lord", "Werewolf", "Hydra", "Medusa", "Nightmare", "Hero" },
    Expert = { "Guzzlemaw", "Vexclaw", "Hellflayer", "Frazzlemaw", "Silencer", "Demon" },
    Master = { "Cloak of Terror", "Brachiodemon", "Infernal Demon", "Thanatursus", "Sphinx", "Crypt Warden" },
}

local WEEKLY_KILL_POOLS = {
    Beginner = {
        { name = "Rat", required = 50 },
        { name = "Cave Rat", required = 80 },
        { name = "Troll", required = 120 },
        { name = "Orc", required = 100 },
        { name = "Minotaur", required = 110 },
        { name = "Rotworm", required = 120 },
    },
    Adept = {
        { name = "Dragon Lord", required = 120 },
        { name = "Werewolf", required = 160 },
        { name = "Hydra", required = 200 },
        { name = "Medusa", required = 220 },
        { name = "Nightmare", required = 200 },
        { name = "Hero", required = 180 },
    },
    Expert = {
        { name = "Guzzlemaw", required = 280 },
        { name = "Vexclaw", required = 250 },
        { name = "Hellflayer", required = 220 },
        { name = "Frazzlemaw", required = 300 },
        { name = "Silencer", required = 240 },
        { name = "Demon", required = 200 },
    },
    Master = {
        { name = "Cloak of Terror", required = 300 },
        { name = "Brachiodemon", required = 260 },
        { name = "Infernal Demon", required = 260 },
        { name = "Thanatursus", required = 280 },
        { name = "Sphinx", required = 350 },
        { name = "Crypt Warden", required = 360 },
    },
}

local WEEKLY_DELIVERY_POOLS = {
    Beginner = {
        { itemId = 268, name = "Carrot", required = 80 },
        { itemId = 2666, name = "Meat", required = 60 },
        { itemId = 2671, name = "Ham", required = 80 },
        { itemId = 2696, name = "Cheese", required = 40 },
        { itemId = 237, name = "Meat", required = 120 },
        { itemId = 3725, name = "Brown Mushroom", required = 20 },
    },
    Adept = {
        { itemId = 236, name = "Strong Mana Potion", required = 300 },
        { itemId = 238, name = "Strong Health Potion", required = 250 },
        { itemId = 239, name = "Great Health Potion", required = 200 },
        { itemId = 7642, name = "Great Mana Potion", required = 120 },
        { itemId = 7643, name = "Ultimate Health Potion", required = 110 },
        { itemId = 7439, name = "Berserk Potion", required = 40 },
    },
    Expert = {
        { itemId = 16126, name = "Blue Crystal Shard", required = 100 },
        { itemId = 16127, name = "Green Crystal Shard", required = 80 },
        { itemId = 16128, name = "Red Crystal Shard", required = 80 },
        { itemId = 3031, name = "Gold Coin", required = 120 },
        { itemId = 5948, name = "Red Dragon Leather", required = 80 },
        { itemId = 6492, name = "Wailing Widow's Necklace", required = 60 },
    },
    Master = {
        { itemId = 3035, name = "Platinum Coin", required = 200 },
        { itemId = 3033, name = "Small Diamond", required = 500 },
        { itemId = 3160, name = "Green Gem", required = 150 },
        { itemId = 3161, name = "Red Gem", required = 150 },
        { itemId = 3156, name = "Small Sapphire", required = 100 },
        { itemId = 3157, name = "Small Ruby", required = 100 },
    },
}

local function copyList(source)
    local list = {}
    for _, entry in ipairs(source or {}) do
        list[#list + 1] = entry
    end
    return list
end

local function takeFirstN(source, amount)
    local selected = {}
    for index = 1, math.min(amount, #source) do
        selected[#selected + 1] = source[index]
    end
    return selected
end

function TaskBoardGenerator.generateBounties(difficulty, weekKey)
    local pool = copyList(BOUNTY_POOLS[difficulty] or BOUNTY_POOLS.Beginner)
    local selected = takeFirstN(pool, 3)
    local list = {}

    for index, monsterName in ipairs(selected) do
        list[#list + 1] = TaskBoardDomainModels.BountyTask:new({
            id = string.format("bounty:%s:%s:%d", tostring(weekKey or ""), tostring(difficulty or ""), index),
            monsterName = monsterName,
            required = 100,
            current = 0,
            completed = false,
            claimed = false,
        })
    end

    return list
end

function TaskBoardGenerator.generateWeeklyTasks(difficulty, weekKey)
    local killPool = takeFirstN(copyList(WEEKLY_KILL_POOLS[difficulty] or WEEKLY_KILL_POOLS.Beginner), 3)
    local deliveryPool = takeFirstN(copyList(WEEKLY_DELIVERY_POOLS[difficulty] or WEEKLY_DELIVERY_POOLS.Beginner), 3)
    local list = {}

    for index, entry in ipairs(killPool) do
        list[#list + 1] = TaskBoardDomainModels.WeeklyTask:new({
            id = string.format("weekly:kill:%s:%s:%d", tostring(weekKey or ""), tostring(difficulty or ""), index),
            subtype = "kill",
            targetName = entry.name,
            targetId = 0,
            required = entry.required,
            current = 0,
            completed = false,
        })
    end

    for index, entry in ipairs(deliveryPool) do
        list[#list + 1] = TaskBoardDomainModels.WeeklyTask:new({
            id = string.format("weekly:delivery:%s:%s:%d", tostring(weekKey or ""), tostring(difficulty or ""), index),
            subtype = "delivery",
            targetName = entry.name,
            targetId = entry.itemId,
            required = entry.required,
            current = 0,
            completed = false,
        })
    end

    return list
end

return TaskBoardGenerator
