TaskBoardProtocol = TaskBoardProtocol or {}

local OPCODE_TASKBOARD = 242

local function requestOpenBoard()
  TaskBoardProtocol.sendAction('open', {})
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_TASKBOARD then
    return
  end

  local ok, payload = pcall(function()
    return json.decode(buffer)
  end)

  if not ok or type(payload) ~= 'table' then
    return
  end

  if payload.type == 'sync' then
    TaskBoardStore.setFullState(payload.data)
    TaskBoardController.renderAll()
    return
  end

  if payload.type == 'delta' then
    local dirty = TaskBoardStore.applyDelta(payload.data)
    TaskBoardController.renderDelta(dirty)

    if dirty.awaitingSync then
      requestOpenBoard()
    end
  end
end

function TaskBoardProtocol.init()
  ProtocolGame.registerExtendedOpcode(OPCODE_TASKBOARD, onExtendedOpcode)
end

function TaskBoardProtocol.terminate()
  ProtocolGame.unregisterExtendedOpcode(OPCODE_TASKBOARD, onExtendedOpcode)
end

function TaskBoardProtocol.sendAction(action, data)
  local protocol = g_game.getProtocolGame()
  if not protocol then
    return false
  end

  local payload = data or {}
  payload.action = action
  protocol:sendExtendedOpcode(OPCODE_TASKBOARD, json.encode(payload))
  return true
end
