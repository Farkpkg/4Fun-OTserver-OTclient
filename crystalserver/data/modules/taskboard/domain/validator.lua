TaskBoardDomainValidator = TaskBoardDomainValidator or {}

local function normalizeLowerString(value)
    if type(value) ~= "string" then
        return ""
    end
    return value:lower()
end


local DIFFICULTIES = {
    Beginner = true,
    Adept = true,
    Expert = true,
    Master = true,
}

function TaskBoardDomainValidator.validateDifficulty(difficulty)
    if type(difficulty) ~= "string" then
        return false
    end
    return DIFFICULTIES[difficulty] == true
end

function TaskBoardDomainValidator.validateOfferId(offerId)
    return type(offerId) == "string" and offerId ~= ""
end

function TaskBoardDomainValidator.validateTaskId(taskId)
    return type(taskId) == "string" and taskId ~= ""
end

function TaskBoardDomainValidator.validateKill(task, monsterName)
    if type(task) ~= "table" then
        return false
    end

    if task.subtype ~= "kill" then
        return false
    end

    if task.completed == true then
        return false
    end

    return normalizeLowerString(task.targetName) == normalizeLowerString(monsterName)
end

function TaskBoardDomainValidator.validateDelivery(task, itemId)
    if type(task) ~= "table" then
        return false
    end

    if task.subtype ~= "delivery" then
        return false
    end

    if task.completed == true then
        return false
    end

    return tonumber(task.targetId) == tonumber(itemId)
end

function TaskBoardDomainValidator.canSelectDifficulty(state)
    if type(state) ~= "table" then
        return false
    end

    return state.boardState == "WAITING_DIFFICULTY"
end

function TaskBoardDomainValidator.canReroll(rerollState, currentTimeUTC)
    local state = rerollState or {}
    local now = tonumber(currentTimeUTC) or 0

    local dailyLimit = math.max(0, tonumber(state.dailyLimit) or 0)
    local weeklyLimit = math.max(0, tonumber(state.weeklyLimit) or 0)
    local dailyUsed = math.max(0, tonumber(state.dailyUsed) or 0)
    local weeklyUsed = math.max(0, tonumber(state.weeklyUsed) or 0)
    local cooldownUntil = math.max(0, tonumber(state.cooldownUntil) or 0)

    if dailyLimit > 0 and dailyUsed >= dailyLimit then
        return {
            allowed = false,
            reason = "DAILY_LIMIT_REACHED",
        }
    end

    if weeklyLimit > 0 and weeklyUsed >= weeklyLimit then
        return {
            allowed = false,
            reason = "WEEKLY_LIMIT_REACHED",
        }
    end

    if cooldownUntil > now then
        return {
            allowed = false,
            reason = "COOLDOWN_ACTIVE",
        }
    end

    return {
        allowed = true,
        reason = nil,
    }
end

return TaskBoardDomainValidator
