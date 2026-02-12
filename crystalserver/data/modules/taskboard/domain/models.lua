TaskBoardDomainModels = TaskBoardDomainModels or {}

local WeeklyTask = {}
WeeklyTask.__index = WeeklyTask

function WeeklyTask:new(data)
    local source = data or {}
    local obj = setmetatable({}, self)

    obj.id = source.id
    obj.subtype = source.subtype
    obj.targetName = source.targetName or ""
    obj.targetId = source.targetId or 0
    obj.required = math.max(0, tonumber(source.required) or 0)
    obj.current = math.max(0, tonumber(source.current) or 0)
    obj.completed = source.completed == true or obj.current >= obj.required

    if obj.completed then
        obj.current = obj.required
    end

    return obj
end

function WeeklyTask:increment(amount)
    local step = math.max(0, tonumber(amount) or 0)
    if self.completed or step == 0 then
        return self.current
    end

    self.current = math.min(self.required, self.current + step)
    self.completed = self.current >= self.required
    return self.current
end

function WeeklyTask:isComplete()
    return self.completed == true
end

function WeeklyTask:toDTO()
    return {
        id = self.id,
        subtype = self.subtype,
        targetName = self.targetName,
        targetId = self.targetId,
        required = self.required,
        current = self.current,
        completed = self.completed,
    }
end

local BountyTask = {}
BountyTask.__index = BountyTask

function BountyTask:new(data)
    local source = data or {}
    local obj = setmetatable({}, self)

    obj.id = source.id
    obj.monsterName = source.monsterName or ""
    obj.required = math.max(0, tonumber(source.required) or 0)
    obj.current = math.max(0, tonumber(source.current) or 0)
    obj.completed = source.completed == true or obj.current >= obj.required
    obj.claimed = source.claimed == true

    if obj.completed then
        obj.current = obj.required
    end

    return obj
end

function BountyTask:increment(amount)
    local step = math.max(0, tonumber(amount) or 0)
    if self.completed or step == 0 then
        return self.current
    end

    self.current = math.min(self.required, self.current + step)
    self.completed = self.current >= self.required
    return self.current
end

function BountyTask:isComplete()
    return self.completed == true
end

function BountyTask:markClaimed()
    self.claimed = true
end

function BountyTask:toDTO()
    return {
        id = self.id,
        monsterName = self.monsterName,
        required = self.required,
        current = self.current,
        completed = self.completed,
        claimed = self.claimed,
    }
end

local PlayerTaskState = {}
PlayerTaskState.__index = PlayerTaskState

function PlayerTaskState:new(data)
    local source = data or {}
    local obj = setmetatable({}, self)

    obj.playerId = source.playerId
    obj.weekKey = source.weekKey or ""
    obj.boardState = source.boardState or "WAITING_DIFFICULTY"
    obj.difficulty = source.difficulty or ""

    return obj
end

function PlayerTaskState:toDTO()
    return {
        playerId = self.playerId,
        weekKey = self.weekKey,
        boardState = self.boardState,
        difficulty = self.difficulty,
    }
end

local WeeklyProgress = {}
WeeklyProgress.__index = WeeklyProgress

function WeeklyProgress:new(data)
    local source = data or {}
    local obj = setmetatable({}, self)

    obj.completedKills = math.max(0, tonumber(source.completedKills) or 0)
    obj.completedDeliveries = math.max(0, tonumber(source.completedDeliveries) or 0)
    obj.totalCompleted = math.max(0, tonumber(source.totalCompleted) or (obj.completedKills + obj.completedDeliveries))
    obj.taskPoints = math.max(0, tonumber(source.taskPoints) or 0)
    obj.soulSeals = math.max(0, tonumber(source.soulSeals) or 0)

    return obj
end

function WeeklyProgress:recalcFromTasks(taskList)
    local kills = 0
    local deliveries = 0

    for _, task in ipairs(taskList or {}) do
        local isCompleted = false

        if type(task) == "table" then
            if type(task.isComplete) == "function" then
                isCompleted = task:isComplete()
            else
                isCompleted = task.completed == true
            end

            if isCompleted then
                local subtype = task.subtype
                if subtype == "kill" then
                    kills = kills + 1
                elseif subtype == "delivery" then
                    deliveries = deliveries + 1
                end
            end
        end
    end

    self.completedKills = kills
    self.completedDeliveries = deliveries
    self.totalCompleted = kills + deliveries

    return {
        completedKills = self.completedKills,
        completedDeliveries = self.completedDeliveries,
        totalCompleted = self.totalCompleted,
        taskPoints = self.taskPoints,
        soulSeals = self.soulSeals,
    }
end

function WeeklyProgress:toDTO()
    return {
        completedKills = self.completedKills,
        completedDeliveries = self.completedDeliveries,
        totalCompleted = self.totalCompleted,
        taskPoints = self.taskPoints,
        soulSeals = self.soulSeals,
    }
end

TaskBoardDomainModels.WeeklyTask = WeeklyTask
TaskBoardDomainModels.BountyTask = BountyTask
TaskBoardDomainModels.PlayerTaskState = PlayerTaskState
TaskBoardDomainModels.WeeklyProgress = WeeklyProgress

return TaskBoardDomainModels
