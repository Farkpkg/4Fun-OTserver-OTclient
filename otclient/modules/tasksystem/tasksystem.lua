local linkedTasksWindow
local linkedTasksButton
local detailsVisible = false
local currentData = {
  activeTaskId = 0,
  tasks = {}
}
local gameCallbacks

local OPCODE_TASK_SYNC = 220
local OPCODE_TASK_UPDATE = 221
local OPCODE_TASK_REQUEST = 222

local function normalizePayload(payload)
  if not payload then
    return nil
  end

  if type(payload) == 'string' then
    if payload == '' then
      return nil
    end
    return payload
  end

  local getUnreadSize = payload.getUnreadSize
  local getString = payload.getString
  if type(getUnreadSize) == 'function' and type(getString) == 'function' then
    local unread = payload:getUnreadSize()
    if not unread or unread <= 0 then
      return nil
    end
    return payload:getString()
  end

  return nil
end

local function split(input, separator)
  if not input or input == '' then
    return {}
  end

  local result = {}
  for token in string.gmatch(input, '([^' .. separator .. ']+)') do
    table.insert(result, token)
  end
  return result
end

local function parseItems(text)
  if not text or text == 'none' then
    return 'Nenhum item.'
  end

  local entries = split(text, ',')
  local parsed = {}
  for _, entry in ipairs(entries) do
    local parts = split(entry, ':')
    table.insert(parsed, string.format('%sx item %s', parts[2] or '0', parts[1] or '?'))
  end
  return table.concat(parsed, ', ')
end

local function getTask(taskId)
  return currentData.tasks[tonumber(taskId)]
end

local function refreshWindow()
  if not linkedTasksWindow then
    return
  end

  local activeTask = getTask(currentData.activeTaskId)
  if not activeTask then
    linkedTasksWindow.taskName:setText('Task ativa: Nenhuma')
    linkedTasksWindow.taskProgress:setText('Progresso: -')
    linkedTasksWindow.taskReward:setText('Recompensa: -')
    linkedTasksWindow.taskDescription:setText('Use !task start <taskId> para iniciar uma task.')
    linkedTasksWindow.taskDetails:setText('')
    return
  end

  linkedTasksWindow.taskName:setText(string.format('Task ativa: [%d] %s', activeTask.id, activeTask.name))
  linkedTasksWindow.taskProgress:setText(string.format('Progresso: %d / %d', activeTask.progress, activeTask.required))
  linkedTasksWindow.taskReward:setText(string.format('Recompensa: %d gold | %d xp', activeTask.rewardGold, activeTask.rewardExperience))
  linkedTasksWindow.taskDescription:setText(activeTask.description)

  if detailsVisible then
    linkedTasksWindow.taskDetails:setText(string.format('Objetivo: %s (%s)\nItens: %s', activeTask.objectiveType, activeTask.objectiveTarget, parseItems(activeTask.rewardItems)))
  else
    linkedTasksWindow.taskDetails:setText('')
  end
end

local function parseSyncPayload(payload)
  if not payload or payload == '' then
    return
  end
  if payload == 'sync' or payload == 'check' then
    return
  end

  -- Expected format (string payload):
  -- ACTIVE\t<taskId>\n
  -- TASK\t<id>\t<status>\t<progress>\t<required>\t<name>\t<description>\t<objectiveType>\t<objectiveTarget>\t<rewardGold>\t<rewardExperience>\t<rewardItems>
  local lines = split(payload, '\n')
  local parsedData = {
    activeTaskId = 0,
    tasks = {}
  }

  for _, line in ipairs(lines) do
    local parts = split(line, '\t')
    if parts[1] == 'ACTIVE' then
      parsedData.activeTaskId = tonumber(parts[2]) or 0
    elseif parts[1] == 'TASK' then
      local task = {
        id = tonumber(parts[2]) or 0,
        status = tonumber(parts[3]) or 0,
        progress = tonumber(parts[4]) or 0,
        required = tonumber(parts[5]) or 0,
        name = parts[6] or '',
        description = parts[7] or '',
        objectiveType = parts[8] or '',
        objectiveTarget = parts[9] or '',
        rewardGold = tonumber(parts[10]) or 0,
        rewardExperience = tonumber(parts[11]) or 0,
        rewardItems = parts[12] or 'none'
      }
      parsedData.tasks[task.id] = task
    end
  end

  currentData = parsedData
  refreshWindow()
end

local function parseUpdatePayload(payload)
  if not payload or payload == '' then
    return
  end
  if payload == 'sync' or payload == 'check' then
    return
  end

  local parts = split(payload, '\t')
  if #parts < 5 then
    return
  end
  if parts[1] ~= 'UPDATE' then
    return
  end

  local taskId = tonumber(parts[2])
  if not taskId or not currentData.tasks[taskId] then
    return
  end

  currentData.tasks[taskId].status = tonumber(parts[3]) or currentData.tasks[taskId].status
  currentData.tasks[taskId].progress = tonumber(parts[4]) or currentData.tasks[taskId].progress
  currentData.tasks[taskId].required = tonumber(parts[5]) or currentData.tasks[taskId].required
  if currentData.tasks[taskId].status == 2 and currentData.activeTaskId == taskId then
    currentData.activeTaskId = 0
  end
  refreshWindow()
end

local function onExtendedOpcode(protocol, opcode, payload)
  local normalizedPayload = normalizePayload(payload)
  if not normalizedPayload then
    return
  end

  if opcode == OPCODE_TASK_SYNC then
    parseSyncPayload(normalizedPayload)
  elseif opcode == OPCODE_TASK_UPDATE then
    parseUpdatePayload(normalizedPayload)
  end
end

local function sendRequest(action)
  local protocol = g_game.getProtocolGame()
  if protocol then
    protocol:sendExtendedOpcode(OPCODE_TASK_REQUEST, action)
  end
end

function toggleWindow()
  if not linkedTasksWindow then
    return
  end

  local visible = not linkedTasksWindow:isVisible()
  linkedTasksWindow:setVisible(visible)
  if visible then
    sendRequest('sync')
    linkedTasksWindow:raise()
    linkedTasksWindow:focus()
  end
end

function toggleDetails()
  detailsVisible = not detailsVisible
  linkedTasksWindow.detailsButton:setText(detailsVisible and 'Ocultar detalhes' or 'Mostrar detalhes')
  refreshWindow()
end

function init()
  linkedTasksWindow = g_ui.displayUI('tasksystem')
  linkedTasksWindow:setVisible(false)

  linkedTasksButton = modules.client_topmenu.addLeftGameButton('linkedTasksButton', tr('Linked Tasks'), '/images/topbuttons/help', toggleWindow)

  ProtocolGame.registerExtendedOpcode(OPCODE_TASK_SYNC, onExtendedOpcode)
  ProtocolGame.registerExtendedOpcode(OPCODE_TASK_UPDATE, onExtendedOpcode)

  gameCallbacks = {
    onGameStart = function()
      sendRequest('sync')
    end,
    onGameEnd = function()
      if linkedTasksWindow then
        linkedTasksWindow:setVisible(false)
      end
      currentData = { activeTaskId = 0, tasks = {} }
    end
  }

  connect(g_game, gameCallbacks)
end

function terminate()
  if gameCallbacks then
    disconnect(g_game, gameCallbacks)
    gameCallbacks = nil
  end

  ProtocolGame.unregisterExtendedOpcode(OPCODE_TASK_SYNC, onExtendedOpcode)
  ProtocolGame.unregisterExtendedOpcode(OPCODE_TASK_UPDATE, onExtendedOpcode)

  if linkedTasksButton then
    linkedTasksButton:destroy()
    linkedTasksButton = nil
  end

  if linkedTasksWindow then
    linkedTasksWindow:destroy()
    linkedTasksWindow = nil
  end
end
