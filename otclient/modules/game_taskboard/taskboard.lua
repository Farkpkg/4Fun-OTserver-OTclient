local window
local windowContent
local button

local function ensureWindow()
  if window and not window:isDestroyed() then
    return true
  end

  if not WindowFactory or not WindowFactory.createStandardWindow then
    g_logger.error('[game_taskboard] WindowFactory is unavailable')
    return false
  end

  window, _ = WindowFactory.createStandardWindow({
    id = 'taskBoardWindow',
    title = tr('Task Board'),
    width = 980,
    height = 620,
    imageSource = '/images/ui/window',
    imageBorder = 6,
    padding = 0,
    ensureContentPanel = true,
    contentId = 'contentPanel',
  })

  if not window then
    g_logger.error('[game_taskboard] Failed to create Task Board window via WindowFactory')
    return false
  end

  local contentHost = window:getChildById('contentPanel')
  if not contentHost then
    g_logger.error('[game_taskboard] WindowFactory did not provide contentPanel')
    window:destroy()
    window = nil
    return false
  end

  windowContent = g_ui.createWidget('TaskBoardWindowContent', contentHost)
  if not windowContent then
    g_logger.error('[game_taskboard] Failed to create TaskBoardWindowContent')
    window:destroy()
    window = nil
    return false
  end

  window:hide()
  window.onEscape = function() toggle() end
  TaskBoardController.setup(windowContent)
  return true
end

function toggle()
  if not ensureWindow() then
    return
  end

  window:setVisible(not window:isVisible())
  if window:isVisible() then
    TaskBoardProtocol.sendAction('open', {})
    window:raise()
    window:focus()
  end

  if button then
    button:setOn(window:isVisible())
  end
end

local function onGameStart()
  TaskBoardProtocol.sendAction('open', {})
end

local function onGameEnd()
  if window then
    window:setVisible(false)
  end

  if button then
    button:setOn(false)
  end

  if TaskBoardStore and TaskBoardStore.clearState then
    TaskBoardStore.clearState()
  end
  if TaskBoardController and TaskBoardController.reset then
    TaskBoardController.reset()
  end
end

function init()
  g_ui.importStyle('components/bounty_card.otui')
  g_ui.importStyle('components/weekly_slot.otui')
  g_ui.importStyle('components/shop_card.otui')
  g_ui.importStyle('components/progress_track.otui')
  g_ui.importStyle('components/talisman_panel.otui')
  g_ui.importStyle('taskboard.otui')

  TaskBoardProtocol.init()
  ensureWindow()

  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })

  if modules.game_mainpanel and modules.game_mainpanel.addToggleButton then
    button = modules.game_mainpanel.addToggleButton('taskBoardButton', tr('Task Board'), '/images/options/button_weeklytasks', toggle, false, 45)
    if button then
      button:setOn(false)
    end
  end
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  TaskBoardProtocol.terminate()

  if button then
    button:destroy()
    button = nil
  end

  if TaskBoardStore and TaskBoardStore.clearState then
    TaskBoardStore.clearState()
  end
  if TaskBoardController and TaskBoardController.reset then
    TaskBoardController.reset()
  end

  if windowContent then
    windowContent:destroy()
    windowContent = nil
  end

  if window then
    window:destroy()
    window = nil
  end
end
