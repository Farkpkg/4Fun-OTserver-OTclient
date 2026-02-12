TaskBoardNetwork = TaskBoardNetwork or {}

local basePath = _G.TaskBoardBasePath or string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardConstants then
    dofile(basePath .. "/constants.lua")
end
if not TaskBoardSerializer then
    dofile(basePath .. "/infrastructure/serializer.lua")
end
if not TaskBoardService then
    dofile(basePath .. "/application/service.lua")
end
if not TaskBoardDomainValidator then
    dofile(basePath .. "/domain/validator.lua")
end

local MAX_PAYLOAD_SIZE = 32 * 1024

function TaskBoardNetwork.sendSync(player, payload)
    local encoded = TaskBoardSerializer.encode({
        type = "sync",
        data = payload or {},
    })

    if not encoded then
        return false
    end

    player:sendExtendedOpcode(TaskBoardConstants.OP_CODE_TASKBOARD, encoded)
    traceDebug(string.format("[taskboard] sync bytes=%d", #encoded))
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
    traceDebug(string.format("[taskboard] delta bytes=%d", #encoded))
    return true
end


local function nowMs()
    return math.floor((os.clock() or 0) * 1000)
end

local function isPlayerActive(player)
    if not player then
        return false
    end

    if type(player.isRemoved) == "function" and player:isRemoved() then
        return false
    end

    if type(player.isOnline) == "function" and not player:isOnline() then
        return false
    end

    return true
end

local function playerActionKey(player)
    return tonumber(player and player:getGuid()) or 0
end

local function canProcessAction(playerId, action)
    if action == TaskBoardConstants.ACTION.OPEN then
        return true
    end

    local last = tonumber(LastActionAt[playerId]) or 0
    local now = nowMs()
    if (now - last) < ACTION_MIN_INTERVAL_MS then
        return false
    end

    if LastActionAt[playerId] == nil then
        ActionTrackSize = ActionTrackSize + 1
    end
    LastActionAt[playerId] = now
    return true
end

local function reject(errorCode)
    return {
        sync = nil,
        deltas = {},
        error = errorCode,
    }
end

local function dispatchAction(player, action, payload)
    local playerId = player:getGuid()

    if action == TaskBoardConstants.ACTION.OPEN then
        return TaskBoardService.openBoard(playerId, os.date("!%Y-W%V"))
    end

    if action == TaskBoardConstants.ACTION.SELECT_DIFFICULTY then
        if not TaskBoardDomainValidator.validateDifficulty(payload.difficulty) then
            return reject("INVALID_DIFFICULTY")
        end
        return TaskBoardService.selectDifficulty(playerId, payload.difficulty)
    end

    if action == TaskBoardConstants.ACTION.REROLL then
        return TaskBoardService.reroll(playerId, os.time())
    end

    if action == TaskBoardConstants.ACTION.DELIVER then
        local itemId = tonumber(payload.itemId or payload.targetId)
        if not itemId or itemId <= 0 then
            return reject("INVALID_DELIVERY_ITEM")
        end
        return TaskBoardService.deliver(playerId, itemId)
    end

    if action == TaskBoardConstants.ACTION.BUY then
        if not TaskBoardDomainValidator.validateOfferId(payload.offerId) then
            return reject("INVALID_OFFER_ID")
        end
        return TaskBoardService.buy(playerId, payload.offerId)
    end

    if action == TaskBoardConstants.ACTION.CLAIM_BOUNTY then
        if not TaskBoardDomainValidator.validateTaskId(payload.bountyId) then
            return reject("INVALID_BOUNTY_ID")
        end
        return TaskBoardService.claimBounty(playerId, payload.bountyId)
    end

    if action == TaskBoardConstants.ACTION.CLAIM_DAILY then
        return TaskBoardService.claimDaily(playerId)
    end

    if action == TaskBoardConstants.ACTION.CLAIM_REWARD then
        local stepId = tonumber(payload.stepId)
        if not stepId then
            return reject("INVALID_REWARD_STEP")
        end
        local lane = tostring(payload.lane or "free")
        return TaskBoardService.claimReward(playerId, stepId, lane)
    end

    return reject("UNSUPPORTED_ACTION")
end

function TaskBoardNetwork.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= TaskBoardConstants.OP_CODE_TASKBOARD then
        return false
    end

    if type(buffer) ~= "string" or buffer == "" then
        player:sendCancelMessage("TaskBoard: EMPTY_PAYLOAD")
        return false
    end

    if #buffer > MAX_PAYLOAD_SIZE then
        player:sendCancelMessage("TaskBoard: PAYLOAD_TOO_LARGE")
        return false
    end

    local payload = TaskBoardSerializer.decode(buffer)
    if type(payload) ~= "table" then
        player:sendCancelMessage("TaskBoard: INVALID_PAYLOAD")
        return false
    end

    local action = payload.action
    if type(action) ~= "string" then
        player:sendCancelMessage("TaskBoard: MISSING_ACTION")
        return false
    end

    local result = dispatchAction(player, action, payload)
    if type(result) ~= "table" then
        player:sendCancelMessage("TaskBoard: INTERNAL_DISPATCH_ERROR")
        return false
    end

    local deltas = result.deltas or {}
    local versions = {}
    if #deltas > 0 and TaskBoardService.reserveDeltaVersions then
        versions = TaskBoardService.reserveDeltaVersions(playerId, #deltas) or {}
    end

    if result.sync then
        result.sync.stateVersion = TaskBoardService.currentStateVersion and TaskBoardService.currentStateVersion(playerId) or result.sync.stateVersion
        TaskBoardNetwork.sendSync(player, result.sync)
    end

    traceDebug(string.format("[taskboard] emit player=%d action=%s deltas=%d", playerId, tostring(action), #deltas))

    for index, delta in ipairs(deltas) do
        if type(delta) == "table" then
            delta.version = tonumber(versions[index]) or nil
            delta.timestamp = os.time()
            TaskBoardNetwork.sendDelta(player, delta)
        end
    end

    if result.error then
        player:sendCancelMessage(string.format("TaskBoard: %s", tostring(result.error)))
        traceDebug(string.format("[taskboard] reject action=%s player=%d reason=%s", tostring(action), playerId, tostring(result.error)))
    end

    return true
end

local taskBoardExtendedOpcode = CreatureEvent("TaskBoardExtendedOpcode")

function taskBoardExtendedOpcode.onExtendedOpcode(player, opcode, buffer)
    return TaskBoardNetwork.onExtendedOpcode(player, opcode, buffer)
end

taskBoardExtendedOpcode:register()

return TaskBoardNetwork
