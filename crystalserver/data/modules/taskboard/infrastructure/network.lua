TaskBoardNetwork = TaskBoardNetwork or {}

local basePath = string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardConstants then
    dofile(basePath .. "/constants.lua")
end
if not TaskBoardSerializer then
    dofile(basePath .. "/infrastructure/serializer.lua")
end
if not TaskBoardService then
    dofile(basePath .. "/application/service.lua")
end

function TaskBoardNetwork.sendSync(player, payload)
    local encoded = TaskBoardSerializer.encode({
        type = "sync",
        data = payload or {},
    })

    if not encoded then
        return false
    end

    player:sendExtendedOpcode(TaskBoardConstants.OP_CODE_TASKBOARD, encoded)
    return true
end

function TaskBoardNetwork.sendDelta(player, delta)
    local encoded = TaskBoardSerializer.encode({
        type = "delta",
        data = delta or {},
    })

    if not encoded then
        return false
    end

    player:sendExtendedOpcode(TaskBoardConstants.OP_CODE_TASKBOARD, encoded)
    return true
end

local function dispatchAction(player, action, payload)
    local playerId = player:getGuid()

    if action == TaskBoardConstants.ACTION.OPEN then
        return TaskBoardService.openBoard(playerId, os.date("!%Y-W%V"))
    end

    if action == TaskBoardConstants.ACTION.SELECT_DIFFICULTY then
        return TaskBoardService.selectDifficulty(playerId, payload.difficulty)
    end

    if action == TaskBoardConstants.ACTION.REROLL then
        return TaskBoardService.reroll(playerId, os.time())
    end

    if action == TaskBoardConstants.ACTION.DELIVER then
        local itemId = payload.itemId or payload.targetId
        return TaskBoardService.deliver(playerId, itemId)
    end

    if action == TaskBoardConstants.ACTION.BUY then
        return TaskBoardService.buy(playerId, payload.offerId)
    end

    return nil
end

function TaskBoardNetwork.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= TaskBoardConstants.OP_CODE_TASKBOARD then
        return false
    end

    local payload = TaskBoardSerializer.decode(buffer)
    if type(payload) ~= "table" then
        player:sendCancelMessage("TaskBoard: invalid payload.")
        return false
    end

    local action = payload.action
    if type(action) ~= "string" then
        player:sendCancelMessage("TaskBoard: missing action.")
        return false
    end

    local result = dispatchAction(player, action, payload)
    if type(result) ~= "table" then
        player:sendCancelMessage("TaskBoard: unsupported action.")
        return false
    end

    if result.sync then
        TaskBoardNetwork.sendSync(player, result.sync)
    end

    for _, delta in ipairs(result.deltas or {}) do
        TaskBoardNetwork.sendDelta(player, delta)
    end

    if result.error then
        player:sendCancelMessage(string.format("TaskBoard: %s", tostring(result.error)))
    end

    return true
end

local taskBoardExtendedOpcode = CreatureEvent("TaskBoardExtendedOpcode")

function taskBoardExtendedOpcode.onExtendedOpcode(player, opcode, buffer)
    return TaskBoardNetwork.onExtendedOpcode(player, opcode, buffer)
end

taskBoardExtendedOpcode:register()

return TaskBoardNetwork
