WeeklyTasks = WeeklyTasks or {}

WeeklyTasks.opcode = {
    action = 240,
    event = 241,
}

WeeklyTasks.state = {
    waitingDifficulty = 0,
    active = 1,
}

WeeklyTasks.difficulty = {
    Beginner = { level = 8 },
    Adept = { level = 30 },
    Expert = { level = 150 },
    Master = { level = 300 },
}

WeeklyTasks.countWithoutExpansion = 6
WeeklyTasks.countWithExpansion = 9

local function fileExists(path)
    local file = io.open(path, "r")
    if not file then
        return false
    end

    file:close()
    return true
end

local function resolveConfigPath(fileName)
    local dataDirectory = configManager.getString(configKeys.DATA_DIRECTORY)
    local candidates = {
        string.format("data/weeklytasks/%s", fileName),
        string.format("%s/weeklytasks/%s", dataDirectory, fileName),
    }

    for _, candidate in ipairs(candidates) do
        if fileExists(candidate) then
            return candidate
        end
    end

    return nil
end

local function loadConfig(fileName)
    local resolvedPath = resolveConfigPath(fileName)
    if not resolvedPath then
        print(string.format("[weekly_tasks] Missing config file: %s (checked data/weeklytasks and %s/weeklytasks)", fileName, configManager.getString(configKeys.DATA_DIRECTORY)))
        return false
    end

    dofile(resolvedPath)
    return true
end

if not loadConfig("monsters.lua") then
    print("[weekly_tasks] Config folder missing: data/weeklytasks/")
end
loadConfig("delivery_items.lua")
loadConfig("rewards.lua")

local function nowWeekKey()
    return os.date("%Y-%W")
end

local function fetchSingleRow(query)
    local resultId = db.storeQuery(query)
    if not resultId then
        return nil
    end

    local row = {
        id = Result.getNumber(resultId, "player_id"),
        weekKey = Result.getString(resultId, "week_key"),
        state = Result.getNumber(resultId, "state"),
        difficulty = Result.getString(resultId, "difficulty"),
        completedKillTasks = Result.getNumber(resultId, "completed_kill_tasks"),
        completedDeliveryTasks = Result.getNumber(resultId, "completed_delivery_tasks"),
        points = Result.getNumber(resultId, "earned_task_points"),
        soulSeals = Result.getNumber(resultId, "earned_soul_seals"),
        multiplier = Result.getNumber(resultId, "reward_multiplier"),
    }

    Result.free(resultId)
    return row
end

function WeeklyTasks.ensureTables()
    db.query([[CREATE TABLE IF NOT EXISTS `player_weekly_tasks` (
        `player_id` INT(11) NOT NULL,
        `week_key` VARCHAR(16) NOT NULL,
        `state` TINYINT(3) NOT NULL DEFAULT 0,
        `difficulty` VARCHAR(16) NOT NULL DEFAULT '',
        `completed_kill_tasks` SMALLINT(5) NOT NULL DEFAULT 0,
        `completed_delivery_tasks` SMALLINT(5) NOT NULL DEFAULT 0,
        `earned_task_points` INT(11) NOT NULL DEFAULT 0,
        `earned_soul_seals` INT(11) NOT NULL DEFAULT 0,
        `reward_multiplier` FLOAT NOT NULL DEFAULT 1,
        `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`player_id`),
        CONSTRAINT `fk_player_weekly_tasks_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;]])

    db.query([[CREATE TABLE IF NOT EXISTS `player_weekly_task_entries` (
        `id` INT(10) NOT NULL AUTO_INCREMENT,
        `player_id` INT(11) NOT NULL,
        `week_key` VARCHAR(16) NOT NULL,
        `task_type` VARCHAR(16) NOT NULL,
        `target_name` VARCHAR(64) NOT NULL DEFAULT '',
        `item_id` INT(11) NOT NULL DEFAULT 0,
        `required_count` SMALLINT(5) NOT NULL DEFAULT 0,
        `progress_count` SMALLINT(5) NOT NULL DEFAULT 0,
        `difficulty_tier` VARCHAR(16) NOT NULL DEFAULT '',
        `completed` TINYINT(1) NOT NULL DEFAULT 0,
        PRIMARY KEY (`id`),
        KEY `idx_player_week` (`player_id`, `week_key`),
        KEY `idx_week_key` (`week_key`),
        CONSTRAINT `fk_player_weekly_task_entries_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;]])

    db.query([[CREATE TABLE IF NOT EXISTS `player_weekly_unlocks` (
        `player_id` INT(11) NOT NULL,
        `expansion_unlocked` TINYINT(1) NOT NULL DEFAULT 0,
        KEY `idx_weekly_unlocks_player_id` (`player_id`),
        PRIMARY KEY (`player_id`),
        CONSTRAINT `fk_player_weekly_unlocks_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;]])
end

function WeeklyTasks.ensurePlayerUnlock(player)
    db.query(string.format("INSERT IGNORE INTO `player_weekly_unlocks` (`player_id`, `expansion_unlocked`) VALUES (%d, 0)", player:getGuid()))
end

function WeeklyTasks.isExpansionUnlocked(player)
    local resultId = db.storeQuery(string.format("SELECT `expansion_unlocked` FROM `player_weekly_unlocks` WHERE `player_id` = %d", player:getGuid()))
    if not resultId then
        return false
    end

    local unlocked = Result.getNumber(resultId, "expansion_unlocked") == 1
    Result.free(resultId)
    return unlocked
end

function WeeklyTasks.getMultiplierByCompleted(completedTotal)
    for _, entry in ipairs(WeeklyTaskRewards.multiplierByCompletedTasks) do
        if completedTotal >= entry.min and completedTotal <= entry.max then
            return entry.value
        end
    end
    return 1.0
end

function WeeklyTasks.resetPlayer(player)
    local playerId = player:getGuid()
    local weekKey = nowWeekKey()

    db.query(string.format("DELETE FROM `player_weekly_task_entries` WHERE `player_id` = %d", playerId))
    db.query(string.format([[INSERT INTO `player_weekly_tasks`
        (`player_id`,`week_key`,`state`,`difficulty`,`completed_kill_tasks`,`completed_delivery_tasks`,`earned_task_points`,`earned_soul_seals`,`reward_multiplier`)
        VALUES (%d,%s,%d,'',0,0,0,0,1)
        ON DUPLICATE KEY UPDATE
        `week_key` = VALUES(`week_key`),
        `state` = VALUES(`state`),
        `difficulty` = VALUES(`difficulty`),
        `completed_kill_tasks` = VALUES(`completed_kill_tasks`),
        `completed_delivery_tasks` = VALUES(`completed_delivery_tasks`),
        `earned_task_points` = VALUES(`earned_task_points`),
        `earned_soul_seals` = VALUES(`earned_soul_seals`),
        `reward_multiplier` = VALUES(`reward_multiplier`)]],
        playerId,
        db.escapeString(weekKey),
        WeeklyTasks.state.waitingDifficulty
    ))
end

function WeeklyTasks.ensureCurrentWeek(player)
    WeeklyTasks.ensurePlayerUnlock(player)

    local weekKey = nowWeekKey()
    local row = fetchSingleRow(string.format("SELECT * FROM `player_weekly_tasks` WHERE `player_id` = %d", player:getGuid()))
    if not row or row.weekKey ~= weekKey then
        WeeklyTasks.resetPlayer(player)
    end
end

local function randomFromPool(pool, amount)
    local available = {}
    for _, entry in ipairs(pool) do
        table.insert(available, entry)
    end

    local selected = {}
    while #selected < amount and #available > 0 do
        local index = math.random(1, #available)
        table.insert(selected, available[index])
        table.remove(available, index)
    end
    return selected
end

function WeeklyTasks.generateTasks(player, difficulty)
    local playerId = player:getGuid()
    local weekKey = nowWeekKey()
    local expansionUnlocked = WeeklyTasks.isExpansionUnlocked(player)
    local taskCount = expansionUnlocked and WeeklyTasks.countWithExpansion or WeeklyTasks.countWithoutExpansion

    local monsterPool = WeeklyMonsters[difficulty] or {}
    local deliveryPool = WeeklyDeliveryItems[difficulty] or {}

    local selectedMonsters = randomFromPool(monsterPool, taskCount)
    local selectedItems = randomFromPool(deliveryPool, taskCount)

    for _, monster in ipairs(selectedMonsters) do
        db.query(string.format(
            "INSERT INTO `player_weekly_task_entries` (`player_id`,`week_key`,`task_type`,`target_name`,`required_count`,`progress_count`,`difficulty_tier`,`completed`) VALUES (%d,%s,'kill',%s,%d,0,%s,0)",
            playerId,
            db.escapeString(weekKey),
            db.escapeString(monster.name),
            monster.amount,
            db.escapeString(difficulty)
        ))
    end

    for _, itemTask in ipairs(selectedItems) do
        db.query(string.format(
            "INSERT INTO `player_weekly_task_entries` (`player_id`,`week_key`,`task_type`,`item_id`,`required_count`,`progress_count`,`difficulty_tier`,`completed`) VALUES (%d,%s,'delivery',%d,%d,0,%s,0)",
            playerId,
            db.escapeString(weekKey),
            itemTask.itemId,
            itemTask.amount,
            db.escapeString(difficulty)
        ))
    end

    db.query(string.format(
        "UPDATE `player_weekly_tasks` SET `state` = %d, `difficulty` = %s WHERE `player_id` = %d",
        WeeklyTasks.state.active,
        db.escapeString(difficulty),
        playerId
    ))
end

function WeeklyTasks.getTaskRows(player)
    local rows = {}
    local resultId = db.storeQuery(string.format(
        "SELECT * FROM `player_weekly_task_entries` WHERE `player_id` = %d AND `week_key` = %s ORDER BY `task_type`, `id` ASC",
        player:getGuid(), db.escapeString(nowWeekKey())
    ))

    if not resultId then
        return rows
    end

    repeat
        table.insert(rows, {
            id = Result.getNumber(resultId, "id"),
            taskType = Result.getString(resultId, "task_type"),
            targetName = Result.getString(resultId, "target_name"),
            itemId = Result.getNumber(resultId, "item_id"),
            requiredAmount = Result.getNumber(resultId, "required_count"),
            currentAmount = Result.getNumber(resultId, "progress_count"),
            difficultyTier = Result.getString(resultId, "difficulty_tier"),
            isCompleted = Result.getNumber(resultId, "completed") == 1,
        })
    until not Result.next(resultId)

    Result.free(resultId)
    return rows
end

function WeeklyTasks.getHeader(player)
    local row = fetchSingleRow(string.format("SELECT * FROM `player_weekly_tasks` WHERE `player_id` = %d", player:getGuid()))
    if not row then
        return {
            state = WeeklyTasks.state.waitingDifficulty,
            difficulty = "",
            completedKillTasks = 0,
            completedDeliveryTasks = 0,
            points = 0,
            soulSeals = 0,
            multiplier = 1,
        }
    end

    return {
        state = row.state,
        difficulty = row.difficulty,
        completedKillTasks = row.completedKillTasks,
        completedDeliveryTasks = row.completedDeliveryTasks,
        points = row.points,
        soulSeals = row.soulSeals,
        multiplier = row.multiplier,
    }
end

local function appendU8(parts, value)
    local v = math.max(0, math.min(255, math.floor(value or 0)))
    parts[#parts + 1] = string.char(v)
end

local function appendU16(parts, value)
    local v = math.max(0, math.min(65535, math.floor(value or 0)))
    parts[#parts + 1] = string.char(v % 256, math.floor(v / 256) % 256)
end

local function appendU32(parts, value)
    local v = math.max(0, math.floor(value or 0))
    parts[#parts + 1] = string.char(
        v % 256,
        math.floor(v / 256) % 256,
        math.floor(v / 65536) % 256,
        math.floor(v / 16777216) % 256
    )
end

local function appendString(parts, value)
    local text = tostring(value or "")
    appendU16(parts, #text)
    parts[#parts + 1] = text
end

local function difficultyTypeToCode(typeName)
    if typeName == "expansion" then
        return 1
    elseif typeName == "experience" then
        return 2
    elseif typeName == "seals" then
        return 3
    elseif typeName == "item" then
        return 4
    end

    return 0
end

function WeeklyTasks.sendSync(player)
    local header = WeeklyTasks.getHeader(player)
    local tasks = WeeklyTasks.getTaskRows(player)

    local killTasks = {}
    local deliveryTasks = {}
    for _, task in ipairs(tasks) do
        if task.taskType == "kill" then
            killTasks[#killTasks + 1] = task
        else
            deliveryTasks[#deliveryTasks + 1] = task
        end
    end

    local parts = {}
    appendU8(parts, header.state)
    appendString(parts, header.difficulty)
    appendU16(parts, math.floor((header.multiplier or 1) * 100))
    appendU16(parts, header.completedKillTasks)
    appendU16(parts, header.completedDeliveryTasks)
    appendU32(parts, header.points)
    appendU32(parts, header.soulSeals)
    appendU8(parts, WeeklyTasks.isExpansionUnlocked(player) and 1 or 0)

    appendU8(parts, 4)
    appendString(parts, "Beginner")
    appendU16(parts, WeeklyTasks.difficulty.Beginner.level)
    appendString(parts, "Adept")
    appendU16(parts, WeeklyTasks.difficulty.Adept.level)
    appendString(parts, "Expert")
    appendU16(parts, WeeklyTasks.difficulty.Expert.level)
    appendString(parts, "Master")
    appendU16(parts, WeeklyTasks.difficulty.Master.level)

    appendU8(parts, #killTasks)
    for _, task in ipairs(killTasks) do
        appendU32(parts, task.id)
        appendString(parts, task.targetName)
        appendU16(parts, task.currentAmount)
        appendU16(parts, task.requiredAmount)
        appendU8(parts, task.isCompleted and 1 or 0)
    end

    appendU8(parts, #deliveryTasks)
    for _, task in ipairs(deliveryTasks) do
        appendU32(parts, task.id)
        appendU16(parts, task.itemId)
        appendU16(parts, task.currentAmount)
        appendU16(parts, task.requiredAmount)
        appendU8(parts, task.isCompleted and 1 or 0)
    end

    local shop = WeeklyTaskRewards.shop or {}
    appendU8(parts, #shop)
    for _, offer in ipairs(shop) do
        appendString(parts, offer.id)
        appendString(parts, offer.name)
        appendU16(parts, offer.price or 0)
        appendU8(parts, difficultyTypeToCode(offer.type))
        appendU16(parts, offer.amount or 0)
        appendU16(parts, offer.itemId or 0)
    end

    player:sendExtendedOpcode(WeeklyTasks.opcode.event, table.concat(parts))
end

function WeeklyTasks.updateCompletionAndRewards(player)
    local tasks = WeeklyTasks.getTaskRows(player)
    local killCompleted, deliveryCompleted = 0, 0

    for _, task in ipairs(tasks) do
        if task.isCompleted then
            if task.taskType == "kill" then
                killCompleted = killCompleted + 1
            else
                deliveryCompleted = deliveryCompleted + 1
            end
        end
    end

    local completedTotal = killCompleted + deliveryCompleted
    local multiplier = WeeklyTasks.getMultiplierByCompleted(completedTotal)

    db.query(string.format(
        "UPDATE `player_weekly_tasks` SET `completed_kill_tasks`=%d, `completed_delivery_tasks`=%d, `reward_multiplier`=%.2f WHERE `player_id`=%d",
        killCompleted,
        deliveryCompleted,
        multiplier,
        player:getGuid()
    ))
end

function WeeklyTasks.applyTaskReward(player)
    local header = WeeklyTasks.getHeader(player)
    local experience = math.floor(player:getLevel() * WeeklyTaskRewards.baseExperiencePerLevel * header.multiplier)
    local points = WeeklyTaskRewards.pointsPerTask
    local soulSeals = WeeklyTaskRewards.soulSealsPerTask

    if experience > 0 then
        player:addExperience(experience, true)
    end

    db.query(string.format(
        "UPDATE `player_weekly_tasks` SET `earned_task_points` = `earned_task_points` + %d, `earned_soul_seals` = `earned_soul_seals` + %d WHERE `player_id` = %d",
        points,
        soulSeals,
        player:getGuid()
    ))
end

function WeeklyTasks.trySelectDifficulty(player, difficulty)
    local entry = WeeklyTasks.difficulty[difficulty]
    if not entry then
        return false, "Invalid difficulty."
    end

    if player:getLevel() < entry.level then
        return false, string.format("Level %d is required for %s.", entry.level, difficulty)
    end

    local header = WeeklyTasks.getHeader(player)
    if header.state ~= WeeklyTasks.state.waitingDifficulty then
        return false, "Difficulty has already been selected for this week."
    end

    WeeklyTasks.generateTasks(player, difficulty)
    WeeklyTasks.sendSync(player)
    return true, "Difficulty selected."
end

local function getPlayerFromKiller(killer)
    if not killer then
        return nil
    end

    if killer:isPlayer() then
        return killer
    end

    if killer:isMonster() and killer:getMaster() and killer:getMaster():isPlayer() then
        return killer:getMaster()
    end

    return nil
end

function WeeklyTasks.onMonsterDeath(creature, killer, mostDamageKiller)
    if not creature or not creature:isMonster() then
        return false
    end

    if creature:hasBeenSummoned() then
        return false
    end

    local player = getPlayerFromKiller(killer) or getPlayerFromKiller(mostDamageKiller)
    if not player then
        return false
    end

    WeeklyTasks.ensureCurrentWeek(player)
    local header = WeeklyTasks.getHeader(player)
    if header.state ~= WeeklyTasks.state.active then
        return false
    end

    local targetName = creature:getName():lower()
    local tasks = WeeklyTasks.getTaskRows(player)

    for _, task in ipairs(tasks) do
        if task.taskType == "kill" and not task.isCompleted and task.targetName:lower() == targetName then
            local nextCurrent = math.min(task.currentAmount + 1, task.requiredAmount)
            local completed = nextCurrent >= task.requiredAmount and 1 or 0
            db.query(string.format(
                "UPDATE `player_weekly_task_entries` SET `progress_count` = %d, `completed` = %d WHERE `id` = %d",
                nextCurrent, completed, task.id
            ))
            if completed == 1 then
                WeeklyTasks.applyTaskReward(player)
            end
            WeeklyTasks.updateCompletionAndRewards(player)
            WeeklyTasks.sendSync(player)
            break
        end
    end

    return true
end

function WeeklyTasks.registerMonsterDeathEvents()
    local names = {}
    for _, list in pairs(WeeklyMonsters) do
        for _, monster in ipairs(list) do
            local key = monster.name:lower()
            if not names[key] then
                names[key] = monster.name
            end
        end
    end

    for _, monsterName in pairs(names) do
        local mType = MonsterType(monsterName)
        if mType then
            mType:registerEvent("WeeklyTasksMonsterDeath")
        end
    end
end

local function countItemInDepotChest(container, itemId)
    if not container then
        return 0
    end

    local total = container:getItemCountById(itemId)
    for _, item in ipairs(container:getItems() or {}) do
        local sub = item:getContainer()
        if sub then
            total = total + countItemInDepotChest(sub, itemId)
        end
    end
    return total
end

local function removeFromContainer(container, itemId, count)
    if not container or count <= 0 then
        return count
    end

    for _, item in ipairs(container:getItems() or {}) do
        if count <= 0 then
            break
        end

        local sub = item:getContainer()
        if sub then
            count = removeFromContainer(sub, itemId, count)
        elseif item:getId() == itemId then
            local itemCount = item:getCount() or 1
            local removeCount = math.min(itemCount, count)
            item:remove(removeCount)
            count = count - removeCount
        end
    end

    return count
end

function WeeklyTasks.tryDeliver(player, taskEntryId)
    WeeklyTasks.ensureCurrentWeek(player)

    local resultId = db.storeQuery(string.format(
        "SELECT * FROM `player_weekly_task_entries` WHERE `id`=%d AND `player_id`=%d AND `task_type`='delivery'",
        taskEntryId,
        player:getGuid()
    ))

    if not resultId then
        return false, "Delivery task not found."
    end

    local task = {
        id = Result.getNumber(resultId, "id"),
        itemId = Result.getNumber(resultId, "item_id"),
        required = Result.getNumber(resultId, "required_count"),
        current = Result.getNumber(resultId, "progress_count"),
        completed = Result.getNumber(resultId, "completed") == 1,
    }
    Result.free(resultId)

    if task.completed then
        return false, "Task already completed."
    end

    local missing = task.required - task.current
    if missing <= 0 then
        return false, "Task already completed."
    end

    local inventoryCount = player:getItemCount(task.itemId)
    local stashCount = player:getStashItemCount(task.itemId)
    local depotCount = 0
    for depotId = 0, 20 do
        local depotChest = player:getDepotChest(depotId, false)
        depotCount = depotCount + countItemInDepotChest(depotChest, task.itemId)
    end

    local totalAvailable = inventoryCount + stashCount + depotCount
    if totalAvailable < missing then
        return false, string.format("Not enough items. Need %d, available %d (inventory+stash+depot).", missing, totalAvailable)
    end

    local toRemove = missing
    local removedInventory = math.min(inventoryCount, toRemove)
    if removedInventory > 0 then
        player:removeItem(task.itemId, removedInventory)
        toRemove = toRemove - removedInventory
    end

    if toRemove > 0 then
        for depotId = 0, 20 do
            if toRemove <= 0 then
                break
            end
            local depotChest = player:getDepotChest(depotId, false)
            toRemove = removeFromContainer(depotChest, task.itemId, toRemove)
        end
    end

    if toRemove > 0 then
        -- Stash validation is supported, but stash removal is not exposed in Lua API in this distribution.
        return false, "Unable to remove all items from stash/depot with current API."
    end

    local nextCurrent = task.required
    db.query(string.format("UPDATE `player_weekly_task_entries` SET `progress_count`=%d, `completed`=1 WHERE `id`=%d", nextCurrent, task.id))

    WeeklyTasks.applyTaskReward(player)
    WeeklyTasks.updateCompletionAndRewards(player)
    WeeklyTasks.sendSync(player)
    return true, "Delivery task completed."
end

function WeeklyTasks.purchaseShop(player, offerId)
    local selected
    for _, offer in ipairs(WeeklyTaskRewards.shop) do
        if offer.id == offerId then
            selected = offer
            break
        end
    end

    if not selected then
        return false, "Offer not found."
    end

    local header = WeeklyTasks.getHeader(player)
    if header.points < selected.price then
        return false, "Not enough task points."
    end

    db.query(string.format("UPDATE `player_weekly_tasks` SET `earned_task_points` = `earned_task_points` - %d WHERE `player_id` = %d", selected.price, player:getGuid()))

    if selected.type == "expansion" then
        db.query(string.format("UPDATE `player_weekly_unlocks` SET `expansion_unlocked` = 1 WHERE `player_id` = %d", player:getGuid()))
    elseif selected.type == "experience" then
        player:addExperience(selected.amount, true)
    elseif selected.type == "seals" then
        db.query(string.format("UPDATE `player_weekly_tasks` SET `earned_soul_seals` = `earned_soul_seals` + %d WHERE `player_id` = %d", selected.amount, player:getGuid()))
    elseif selected.type == "item" then
        player:addItem(selected.itemId, selected.amount)
    end

    WeeklyTasks.sendSync(player)
    return true, "Purchase completed."
end

local function readU8(buffer, offset)
    if offset > #buffer then
        return nil, offset
    end

    return string.byte(buffer, offset), offset + 1
end

local function readU16(buffer, offset)
    if offset + 1 > #buffer then
        return nil, offset
    end

    local b1 = string.byte(buffer, offset)
    local b2 = string.byte(buffer, offset + 1)
    return (b2 * 256) + b1, offset + 2
end

local function readU32(buffer, offset)
    if offset + 3 > #buffer then
        return nil, offset
    end

    local b1 = string.byte(buffer, offset)
    local b2 = string.byte(buffer, offset + 1)
    local b3 = string.byte(buffer, offset + 2)
    local b4 = string.byte(buffer, offset + 3)
    return (((b4 * 256 + b3) * 256 + b2) * 256) + b1, offset + 4
end

local function readString(buffer, offset)
    local length
    length, offset = readU16(buffer, offset)
    if not length then
        return nil, offset
    end

    local endPos = offset + length - 1
    if endPos > #buffer then
        return nil, offset
    end

    local value = buffer:sub(offset, endPos)
    return value, endPos + 1
end

function WeeklyTasks.handleClientAction(player, payload)
    local offset = 1
    local action
    action, offset = readU8(payload, offset)
    if action == nil then
        return false
    end

    if action == 1 then -- sync
        WeeklyTasks.ensureCurrentWeek(player)
        WeeklyTasks.sendSync(player)
        return true
    end

    if action == 2 then -- selectDifficulty
        local difficulty
        difficulty, offset = readString(payload, offset)
        if not difficulty then
            return false
        end

        local ok, message = WeeklyTasks.trySelectDifficulty(player, difficulty)
        if not ok then
            player:sendCancelMessage(message)
        end
        return ok
    end

    if action == 3 then -- deliver
        local entryId
        entryId, offset = readU32(payload, offset)
        if not entryId then
            return false
        end

        local ok, message = WeeklyTasks.tryDeliver(player, entryId)
        if not ok then
            player:sendCancelMessage(message)
        end
        return ok
    end

    if action == 4 then -- shopPurchase
        local offerId
        offerId, offset = readString(payload, offset)
        if not offerId then
            return false
        end

        local ok, message = WeeklyTasks.purchaseShop(player, offerId)
        if not ok then
            player:sendCancelMessage(message)
        end
        return ok
    end

    return false
end

function WeeklyTasks.resetAllForWeek()
    local weekKey = nowWeekKey()
    db.query("DELETE FROM `player_weekly_task_entries`")
    db.query(string.format(
        "UPDATE `player_weekly_tasks` SET `week_key`=%s, `state`=%d, `difficulty`='', `completed_kill_tasks`=0, `completed_delivery_tasks`=0, `earned_task_points`=0, `earned_soul_seals`=0, `reward_multiplier`=1",
        db.escapeString(weekKey), WeeklyTasks.state.waitingDifficulty
    ))

    for _, player in pairs(Game.getPlayers()) do
        WeeklyTasks.ensureCurrentWeek(player)
        WeeklyTasks.sendSync(player)
    end
end
