local linkedTasksWindow
local linkedTasksButton
local taskBoardWindow
local boardEntriesPanel
local boardDetailsLabel
local boardStartButton
local detailsVisible = false
local currentSelectedTaskId = nil

local currentData = {
  activeTaskId = 0,
  tasks = {}
}

local boardData = {
  activeTaskId = 0,
  tasks = {}
}

local gameCallbacks

local OPCODE_TASK_SYNC = 220
local OPCODE_TASK_UPDATE = 221
local OPCODE_TASK_REQUEST = 222
local OPCODE_TASK_BOARD = 223

local STATUS_COLORS = {
  LOCKED = '#adadad',
  AVAILABLE = '#8bdc65',
  IN_PROGRESS = '#ffd35f',
  COMPLETED = '#68a9ff'
}

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

local function getBoardTask(taskId)
  return boardData.tasks[tonumber(taskId)]
end

local function sendRequest(action)
  local protocol = g_game.getProtocolGame()
  if protocol then
    protocol:sendExtendedOpcode(OPCODE_TASK_REQUEST, action)
  end
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

local function refreshBoardDetails()
  if not boardDetailsLabel then
    return
  end

  local task = getBoardTask(currentSelectedTaskId)
  if not task then
    boardDetailsLabel:setText('Selecione uma task na lista para ver os detalhes.')
    boardStartButton:setEnabled(false)
    return
  end

  boardDetailsLabel:setText(string.format(
    '[%d] %s\nStatus: %s\nProgresso: %d / %d\nObjetivo: %s (%s)\nDescrição: %s\nRecompensa: %d gold | %d xp | %s',
    task.id,
    task.name,
    task.status,
    task.progress,
    task.required,
    task.objectiveType,
    task.objectiveTarget,
    task.description,
    task.rewardGold,
    task.rewardExperience,
    parseItems(task.rewardItems)
  ))

  boardStartButton:setEnabled(task.status == 'AVAILABLE')
end

local function onSelectTaskEntry(widget)
  if not widget then
    return
  end

  currentSelectedTaskId = tonumber(widget:getId())
  refreshBoardDetails()
end

local function refreshBoardList()
  if not boardEntriesPanel then
    return
  end

  boardEntriesPanel:destroyChildren()
  local ids = {}
  for taskId, _ in pairs(boardData.tasks) do
    table.insert(ids, taskId)
  end
  table.sort(ids)

  for _, taskId in ipairs(ids) do
    local task = boardData.tasks[taskId]
    local row = g_ui.createWidget('TaskBoardEntry', boardEntriesPanel)
    row:setId(tostring(task.id))
    row.taskName:setText(string.format('[%d] %s', task.id, task.name))
    row.taskStatus:setText(task.status)
    row.taskStatus:setColor(STATUS_COLORS[task.status] or '#ffffff')
    row.onClick = function()
      onSelectTaskEntry(row)
    end
  end

  local first = boardEntriesPanel:getFirstChild()
  if first then
    onSelectTaskEntry(first)
  else
    currentSelectedTaskId = nil
    refreshBoardDetails()
  end
end

local function openBoard(shouldRequest)
  if not taskBoardWindow then
    return
  end

  taskBoardWindow:setVisible(true)
  taskBoardWindow:raise()
  taskBoardWindow:focus()
  if shouldRequest then
    sendRequest('board')
  end
end

local function parseSyncPayload(payload)
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
  local parts = split(payload, '\t')
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
  refreshWindow()
end

local function parseBoardPayload(payload)
  local lines = split(payload, '\n')
  local parsedBoard = {
    activeTaskId = 0,
    tasks = {}
  }

  for _, line in ipairs(lines) do
    local parts = split(line, '\t')
    if parts[1] == 'BOARD' then
      parsedBoard.activeTaskId = tonumber(parts[2]) or 0
    elseif parts[1] == 'TASK' then
      local task = {
        id = tonumber(parts[2]) or 0,
        status = parts[3] or 'LOCKED',
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
      parsedBoard.tasks[task.id] = task
    end
  end

  boardData = parsedBoard
  refreshBoardList()
  refreshBoardDetails()
  openBoard(false)
end

local function onExtendedOpcode(protocol, opcode, payload)
  if opcode == OPCODE_TASK_SYNC then
    parseSyncPayload(payload)
  elseif opcode == OPCODE_TASK_UPDATE then
    parseUpdatePayload(payload)
  elseif opcode == OPCODE_TASK_BOARD then
    parseBoardPayload(payload)
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

function toggleTaskBoard()
  if not taskBoardWindow then
    return
  end

  local visible = not taskBoardWindow:isVisible()
  taskBoardWindow:setVisible(visible)
  if visible then
    openBoard(true)
    taskBoardWindow:focus()
  end
end

function startSelectedTaskFromBoard()
  local task = getBoardTask(currentSelectedTaskId)
  if not task then
    return
  end

  if task.status ~= 'AVAILABLE' then
    modules.game_textmessage.displayFailureMessage('Apenas tasks AVAILABLE podem ser iniciadas no Task Board.')
    return
  end

  sendRequest(string.format('board_start:%d', task.id))
  sendRequest('board')
end

function toggleDetails()
  detailsVisible = not detailsVisible
  linkedTasksWindow.detailsButton:setText(detailsVisible and 'Ocultar detalhes' or 'Mostrar detalhes')
  refreshWindow()
end

function init()
  linkedTasksWindow = g_ui.displayUI('tasksystem')
  linkedTasksWindow:setVisible(false)

  taskBoardWindow = g_ui.displayUI('taskboard')
  taskBoardWindow:setVisible(false)
  boardEntriesPanel = taskBoardWindow.boardList
  boardDetailsLabel = taskBoardWindow.boardDetails
  boardStartButton = taskBoardWindow.startButton

  linkedTasksButton = modules.client_topmenu.addLeftGameButton('linkedTasksButton', tr('Linked Tasks'), '/images/topbuttons/help', toggleWindow)

  ProtocolGame.registerExtendedOpcode(OPCODE_TASK_SYNC, onExtendedOpcode)
  ProtocolGame.registerExtendedOpcode(OPCODE_TASK_UPDATE, onExtendedOpcode)
  ProtocolGame.registerExtendedOpcode(OPCODE_TASK_BOARD, onExtendedOpcode)

  gameCallbacks = {
    onGameStart = function()
      sendRequest('sync')
    end,
    onGameEnd = function()
      if linkedTasksWindow then
        linkedTasksWindow:setVisible(false)
      end
      if taskBoardWindow then
        taskBoardWindow:setVisible(false)
      end
      currentData = { activeTaskId = 0, tasks = {} }
      boardData = { activeTaskId = 0, tasks = {} }
      currentSelectedTaskId = nil
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
  ProtocolGame.unregisterExtendedOpcode(OPCODE_TASK_BOARD, onExtendedOpcode)

  if linkedTasksButton then
    linkedTasksButton:destroy()
    linkedTasksButton = nil
  end

  if linkedTasksWindow then
    linkedTasksWindow:destroy()
    linkedTasksWindow = nil
  end

  if taskBoardWindow then
    taskBoardWindow:destroy()
    taskBoardWindow = nil
    boardEntriesPanel = nil
    boardDetailsLabel = nil
    boardStartButton = nil
  end
end
