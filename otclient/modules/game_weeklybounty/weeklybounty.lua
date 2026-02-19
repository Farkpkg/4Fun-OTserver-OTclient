local weeklyBountyWindow
local weeklyBountyButton

local function difficultyText(difficulty)
  if difficulty == 0 then
    return 'Easy'
  elseif difficulty == 1 then
    return 'Medium'
  elseif difficulty == 2 then
    return 'Hard'
  end

  return 'Unknown'
end

local function refreshBoard()
  if g_game.isOnline() then
    g_game.requestBountyBoard()
  end
end

local function hideWindow()
  if weeklyBountyWindow then
    weeklyBountyWindow:hide()
  end
end

function toggle()
  if not weeklyBountyWindow then
    return
  end

  if weeklyBountyWindow:isVisible() then
    weeklyBountyWindow:hide()
    return
  end

  weeklyBountyWindow:show()
  weeklyBountyWindow:raise()
  weeklyBountyWindow:focus()
  refreshBoard()
end

function acceptOffer(creatureName)
  if not creatureName or creatureName == '' then
    return
  end

  g_game.selectBounty(creatureName)
  refreshBoard()
end

local function setActiveTaskLabel(hasActiveTask, taskCreatureName, taskRequiredKills, taskCurrentKills, taskDifficulty, taskCompleted)
  if not hasActiveTask then
    weeklyBountyWindow.activeTaskLabel:setText('No active bounty task.')
    return
  end

  local statusText = taskCompleted and 'Completed' or 'In Progress'
  local text = string.format('Active: %s | Kills: %d/%d | Difficulty: %s | Status: %s',
    taskCreatureName,
    taskCurrentKills,
    taskRequiredKills,
    difficultyText(taskDifficulty),
    statusText)
  weeklyBountyWindow.activeTaskLabel:setText(text)
end

function onBountyBoard(offerNames, offerRequiredKills, offerDifficulties, hasActiveTask, taskCreatureName, taskRequiredKills, taskCurrentKills, taskDifficulty, taskCompleted)
  if not weeklyBountyWindow then
    return
  end

  setActiveTaskLabel(hasActiveTask, taskCreatureName, taskRequiredKills, taskCurrentKills, taskDifficulty, taskCompleted)

  weeklyBountyWindow.offersList:destroyChildren()

  for i, creatureName in ipairs(offerNames) do
    local row = g_ui.createWidget('BountyOfferRow', weeklyBountyWindow.offersList)
    row.nameLabel:setText(creatureName)
    row.killsLabel:setText(string.format('%d kills', offerRequiredKills[i] or 0))
    row.difficultyLabel:setText(difficultyText(offerDifficulties[i] or 0))
    row.acceptButton.onClick = function()
      acceptOffer(creatureName)
    end
  end
end

function init()
  connect(g_game, {
    onGameEnd = hideWindow,
    onBountyBoard = onBountyBoard
  })

  weeklyBountyWindow = g_ui.displayUI('weeklybounty')
  if not weeklyBountyWindow then
    perror('Failed to load weekly bounty UI (weeklybounty.otui).')
    return
  end

  weeklyBountyWindow:hide()

  weeklyBountyButton = modules.client_topmenu.addLeftGameButton('weeklyBountyButton', tr('Weekly Bounty'), '/images/topbuttons/quests', toggle)

  weeklyBountyWindow.closeButton.onClick = hideWindow
  weeklyBountyWindow.refreshButton.onClick = refreshBoard
  weeklyBountyWindow.claimButton.onClick = function()
    g_game.claimBountyReward()
    refreshBoard()
  end
end

function terminate()
  disconnect(g_game, {
    onGameEnd = hideWindow,
    onBountyBoard = onBountyBoard
  })

  if weeklyBountyButton then
    weeklyBountyButton:destroy()
    weeklyBountyButton = nil
  end

  if weeklyBountyWindow then
    weeklyBountyWindow:destroy()
    weeklyBountyWindow = nil
  end
end
