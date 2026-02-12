local window
local button

function toggle()
  if not window then
    return
  end

  window:setVisible(not window:isVisible())
  if window:isVisible() then
    TaskBoardProtocol.sendAction('open', {})
    window:raise()
    window:focus()
  end
end

local function onGameStart()
  TaskBoardProtocol.sendAction('open', {})
end

local function onGameEnd()
  if window then
    window:setVisible(false)
  end
end

function init()
  g_ui.importStyle('components/bounty_card.otui')
  g_ui.importStyle('components/weekly_slot.otui')
  g_ui.importStyle('components/shop_card.otui')
  g_ui.importStyle('components/progress_track.otui')
  g_ui.importStyle('components/talisman_panel.otui')

  window = g_ui.displayUI('taskboard')
  window:setVisible(false)

  TaskBoardController.setup(window)
  TaskBoardProtocol.init()

  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })

  if modules.client_topmenu and modules.client_topmenu.addLeftGameButton then
    button = modules.client_topmenu.addLeftGameButton('taskBoardButton', tr('Task Board'), '/images/topbuttons/questlog', toggle)
  end
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  TaskBoardProtocol.terminate()

  if button then
    button:destroy()
    button = nil
  end

  if window then
    window:destroy()
    window = nil
  end
end
