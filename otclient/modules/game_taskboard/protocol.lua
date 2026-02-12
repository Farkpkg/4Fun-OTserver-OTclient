TaskBoardProtocol = TaskBoardProtocol or {}

local OPCODE_TASKBOARD = 242

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_TASKBOARD then
    return
  end

  local ok, payload = pcall(json.decode, buffer)
  if not ok or type(payload) ~= 'table' then
    return
  end

  if payload.type == 'sync' then
    TaskBoardController.onSync(payload.data or {})
  elseif payload.type == 'delta' then
    TaskBoardController.onDelta(payload.data or {})
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
    return
  end

  local payload = data or {}
  payload.action = action
  protocol:sendExtendedOpcode(OPCODE_TASKBOARD, json.encode(payload))
end
