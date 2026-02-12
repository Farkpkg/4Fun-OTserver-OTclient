TaskBoardRepository = TaskBoardRepository or {}

local TABLE_PLAYERS = "player_taskboard_state"
local TABLE_TASKS = "player_taskboard_tasks"

local function getJsonLib()
    if type(json) == "table" and type(json.encode) == "function" and type(json.decode) == "function" then
        return json
    end

    local ok, jsonLib = pcall(require, "json")
    if ok and type(jsonLib) == "table" and type(jsonLib.encode) == "function" and type(jsonLib.decode) == "function" then
        return jsonLib
    end

    return nil
end

local function encodeJson(value)
    local jsonLib = getJsonLib()
    if not jsonLib then
        return "{}"
    end

    local ok, encoded = pcall(jsonLib.encode, value)
    if not ok or type(encoded) ~= "string" then
        return "{}"
    end

    return encoded
end

local function decodeJson(payload)
    if type(payload) ~= "string" or payload == "" then
        return nil
    end

    local jsonLib = getJsonLib()
    if not jsonLib then
        return nil
    end

    local ok, data = pcall(jsonLib.decode, payload)
    if not ok then
        return nil
    end

    return data
end

local function fetchSingleRow(query)
    local resultId = db.storeQuery(query)
    if not resultId then
        return nil
    end

    local row = {
        playerId = Result.getNumber(resultId, "player_id"),
        weekKey = Result.getString(resultId, "week_key"),
        boardState = Result.getString(resultId, "board_state"),
        difficulty = Result.getString(resultId, "difficulty"),
        weeklyProgress = Result.getString(resultId, "weekly_progress"),
        multiplier = Result.getString(resultId, "multiplier"),
        rerollState = Result.getString(resultId, "reroll_state"),
        shopPurchases = Result.getString(resultId, "shop_purchases"),
        stateVersion = Result.getNumber(resultId, "state_version"),
    }

    Result.free(resultId)
    return row
end

function TaskBoardRepository.ensureTables()
    db.query(string.format([[CREATE TABLE IF NOT EXISTS `%s` (
        `player_id` INT UNSIGNED NOT NULL,
        `week_key` VARCHAR(16) NOT NULL DEFAULT '',
        `board_state` VARCHAR(32) NOT NULL DEFAULT 'WAITING_DIFFICULTY',
        `difficulty` VARCHAR(32) NOT NULL DEFAULT '',
        `weekly_progress` TEXT NULL,
        `multiplier` TEXT NULL,
        `reroll_state` TEXT NULL,
        `shop_purchases` TEXT NULL,
        `state_version` INT UNSIGNED NOT NULL DEFAULT 0,
        `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`player_id`),
        CONSTRAINT `fk_player_taskboard_state_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;]], TABLE_PLAYERS))

    db.query(string.format([[CREATE TABLE IF NOT EXISTS `%s` (
        `player_id` INT UNSIGNED NOT NULL,
        `task_id` VARCHAR(96) NOT NULL,
        `week_key` VARCHAR(16) NOT NULL DEFAULT '',
        `scope` VARCHAR(16) NOT NULL,
        `payload` TEXT NOT NULL,
        `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`player_id`, `task_id`),
        KEY `idx_player_week_scope` (`player_id`, `week_key`, `scope`),
        CONSTRAINT `fk_player_taskboard_tasks_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;]], TABLE_TASKS))


    db.query(string.format("ALTER TABLE `%s` ADD COLUMN `state_version` INT UNSIGNED NOT NULL DEFAULT 0", TABLE_PLAYERS))
    return true
end

function TaskBoardRepository.loadPlayerState(playerId)
    local row = fetchSingleRow(string.format(
        "SELECT `player_id`, `week_key`, `board_state`, `difficulty`, `weekly_progress`, `multiplier`, `reroll_state`, `shop_purchases`, `state_version` FROM `%s` WHERE `player_id` = %d",
        TABLE_PLAYERS,
        tonumber(playerId) or 0
    ))

    if not row then
        return nil
    end

    return {
        playerId = row.playerId,
        weekKey = row.weekKey,
        boardState = row.boardState,
        difficulty = row.difficulty,
    }
end

function TaskBoardRepository.savePlayerState(playerId, state)
    local data = state or {}
    local weekKey = tostring(data.weekKey or "")
    local boardState = tostring(data.boardState or "WAITING_DIFFICULTY")
    local difficulty = tostring(data.difficulty or "")

    return db.query(string.format(
        "INSERT INTO `%s` (`player_id`, `week_key`, `board_state`, `difficulty`) VALUES (%d, %s, %s, %s) ON DUPLICATE KEY UPDATE `week_key` = VALUES(`week_key`), `board_state` = VALUES(`board_state`), `difficulty` = VALUES(`difficulty`)",
        TABLE_PLAYERS,
        tonumber(playerId) or 0,
        db.escapeString(weekKey),
        db.escapeString(boardState),
        db.escapeString(difficulty)
    ))
end

function TaskBoardRepository.loadTasks(playerId, weekKey)
    local tasks = {}
    local resultId = db.storeQuery(string.format(
        "SELECT `scope`, `payload` FROM `%s` WHERE `player_id` = %d AND `week_key` = %s",
        TABLE_TASKS,
        tonumber(playerId) or 0,
        db.escapeString(tostring(weekKey or ""))
    ))

    if not resultId then
        return tasks
    end

    repeat
        local scope = Result.getString(resultId, "scope")
        local payload = decodeJson(Result.getString(resultId, "payload"))
        if type(payload) == "table" then
            tasks[#tasks + 1] = {
                scope = scope,
                payload = payload,
            }
        end
    until not Result.next(resultId)

    Result.free(resultId)
    return tasks
end

function TaskBoardRepository.saveTask(playerId, task)
    if type(task) ~= "table" or type(task.id) ~= "string" then
        return false
    end

    local scope = task.monsterName and "bounty" or "weekly"
    local weekKey = tostring(task.id:match("^[^:]+:[^:]*:([^:]+):") or "")
    if weekKey == "" then
        weekKey = tostring(task.weekKey or "")
    end

    return db.query(string.format(
        "INSERT INTO `%s` (`player_id`, `task_id`, `week_key`, `scope`, `payload`) VALUES (%d, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE `week_key` = VALUES(`week_key`), `scope` = VALUES(`scope`), `payload` = VALUES(`payload`)",
        TABLE_TASKS,
        tonumber(playerId) or 0,
        db.escapeString(task.id),
        db.escapeString(weekKey),
        db.escapeString(scope),
        db.escapeString(encodeJson(task))
    ))
end


local function sanitizeProgress(progress)
    local source = type(progress) == "table" and progress or {}
    local completedKills = math.max(0, tonumber(source.completedKills) or 0)
    local completedDeliveries = math.max(0, tonumber(source.completedDeliveries) or 0)
    local totalCompleted = math.max(0, tonumber(source.totalCompleted) or (completedKills + completedDeliveries))
    return {
        completedKills = completedKills,
        completedDeliveries = completedDeliveries,
        totalCompleted = totalCompleted,
        taskPoints = math.max(0, tonumber(source.taskPoints) or 0),
        soulSeals = math.max(0, tonumber(source.soulSeals) or 0),
    }
end

local function sanitizeTaskList(list, scope)
    local out = {}
    for _, task in ipairs(type(list) == "table" and list or {}) do
        if type(task) == "table" and type(task.id) == "string" and task.id ~= "" then
            local required = math.max(0, tonumber(task.required) or 0)
            local current = math.max(0, tonumber(task.current) or 0)
            if current > required and required > 0 then
                current = required
            end
            local dto = {
                id = task.id,
                required = required,
                current = current,
                completed = task.completed == true or (required > 0 and current >= required),
            }
            if scope == "bounty" then
                dto.monsterName = tostring(task.monsterName or "")
                dto.claimed = task.claimed == true
            else
                dto.subtype = tostring(task.subtype or "kill")
                dto.targetName = tostring(task.targetName or "")
                dto.targetId = tonumber(task.targetId) or 0
            end
            out[#out + 1] = dto
        end
    end
    return out
end

local function sanitizeSnapshot(playerId, snapshot)
    local source = type(snapshot) == "table" and snapshot or {}
    local state = type(source.state) == "table" and source.state or {}
    local boardState = tostring(state.boardState or "WAITING_DIFFICULTY")
    if boardState ~= "WAITING_DIFFICULTY" and boardState ~= "ACTIVE" then
        boardState = "WAITING_DIFFICULTY"
    end

    local loaded = {
        state = {
            playerId = tonumber(playerId) or tonumber(state.playerId) or 0,
            weekKey = tostring(source.weekKey or state.weekKey or ""),
            boardState = boardState,
            difficulty = tostring(state.difficulty or ""),
        },
        weekKey = tostring(source.weekKey or state.weekKey or ""),
        bounties = sanitizeTaskList(source.bounties, "bounty"),
        weeklyTasks = sanitizeTaskList(source.weeklyTasks, "weekly"),
        weeklyProgress = sanitizeProgress(source.weeklyProgress),
        multiplier = type(source.multiplier) == "table" and source.multiplier or { value = 1.0, nextThreshold = 4 },
        rerollState = type(source.rerollState) == "table" and source.rerollState or nil,
        shopPurchases = type(source.shopPurchases) == "table" and source.shopPurchases or {},
        premiumEnabled = source.premiumEnabled == true,
        stateVersion = math.max(0, tonumber(source.stateVersion) or 0),
    }

    return loaded
end

function TaskBoardRepository.saveSnapshot(playerId, snapshot)
    local data = sanitizeSnapshot(playerId, snapshot)
    TaskBoardRepository.savePlayerState(playerId, data.state or {})

    db.query(string.format(
        "UPDATE `%s` SET `weekly_progress` = %s, `multiplier` = %s, `reroll_state` = %s, `shop_purchases` = %s, `state_version` = %d WHERE `player_id` = %d",
        TABLE_PLAYERS,
        db.escapeString(encodeJson(data.weeklyProgress or {})),
        db.escapeString(encodeJson(data.multiplier or {})),
        db.escapeString(encodeJson(data.rerollState or {})),
        db.escapeString(encodeJson(data.shopPurchases or {})),
        math.max(0, tonumber(data.stateVersion) or 0),
        tonumber(playerId) or 0
    ))

    for _, dto in ipairs(data.bounties or {}) do
        TaskBoardRepository.saveTask(playerId, dto)
    end

    for _, dto in ipairs(data.weeklyTasks or {}) do
        TaskBoardRepository.saveTask(playerId, dto)
    end

    return true
end

function TaskBoardRepository.loadSnapshot(playerId)
    local row = fetchSingleRow(string.format(
        "SELECT `player_id`, `week_key`, `board_state`, `difficulty`, `weekly_progress`, `multiplier`, `reroll_state`, `shop_purchases`, `state_version` FROM `%s` WHERE `player_id` = %d",
        TABLE_PLAYERS,
        tonumber(playerId) or 0
    ))

    if not row then
        return nil
    end

    local tasks = TaskBoardRepository.loadTasks(playerId, row.weekKey)
    local bounties = {}
    local weeklyTasks = {}

    for _, entry in ipairs(tasks) do
        if entry.scope == "bounty" then
            bounties[#bounties + 1] = entry.payload
        else
            weeklyTasks[#weeklyTasks + 1] = entry.payload
        end
    end

    local loaded = {
        state = {
            playerId = row.playerId,
            weekKey = row.weekKey,
            boardState = row.boardState,
            difficulty = row.difficulty,
        },
        weekKey = row.weekKey,
        bounties = bounties,
        weeklyTasks = weeklyTasks,
        weeklyProgress = decodeJson(row.weeklyProgress) or {},
        multiplier = decodeJson(row.multiplier) or { value = 1.0, nextThreshold = 4 },
        rerollState = decodeJson(row.rerollState) or nil,
        shopPurchases = decodeJson(row.shopPurchases) or {},
        stateVersion = math.max(0, tonumber(row.stateVersion) or 0),
    }

    return sanitizeSnapshot(playerId, loaded)
end


function TaskBoardRepository.setStateVersion(playerId, stateVersion)
    return db.query(string.format(
        "UPDATE `%s` SET `state_version` = %d WHERE `player_id` = %d",
        TABLE_PLAYERS,
        math.max(0, tonumber(stateVersion) or 0),
        tonumber(playerId) or 0
    ))
end

function TaskBoardRepository.clearWeek(playerId, oldWeekKey)
    return db.query(string.format(
        "DELETE FROM `%s` WHERE `player_id` = %d AND `week_key` = %s",
        TABLE_TASKS,
        tonumber(playerId) or 0,
        db.escapeString(tostring(oldWeekKey or ""))
    ))
end

return TaskBoardRepository
