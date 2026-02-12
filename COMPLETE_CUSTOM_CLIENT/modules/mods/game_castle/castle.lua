teams = nil
finalResult = nil

local allianceKills = 0
local hordeKills = 0
local allianceDeaths = 0
local hordeDeaths = 0
local playersData = {}
local destroyEvent = nil
local appearEvent = nil

function init()
  teams = g_ui.displayUI('styles/teams')
  finalResult = g_ui.displayUI('styles/info')
  hide()

  finalResult:hide()

  hordeHP = teams.horde:recursiveGetChildById("hordeHp")
  hordeTowerHP = teams.horde:recursiveGetChildById("towerHp")
  hordeHPLabel = teams.horde:recursiveGetChildById("crystalHealthLabel")
  ahordeTowerHPLabel = teams.horde:recursiveGetChildById("towerHealthLabel")

  allianceHP = teams.alliance:recursiveGetChildById("allianceHp")
  allianceTowerHP = teams.alliance:recursiveGetChildById("towerHp")
  allianceHPLabel = teams.alliance:recursiveGetChildById("crystalHealthLabel")
  allianceTowerHPLabel = teams.alliance:recursiveGetChildById("towerHealthLabel")

  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onCastleData = onCastleData,
    onCastleWinner = onCastleWinner,
    onCastleKills = onCastleKills
	})

end

function online()
  local benchmark = g_clock.millis()
  playersData = {}
  consoleln("Castle loaded in " .. (g_clock.millis() - benchmark) / 1000 .. " seconds.")
end

function offline()
  removeEvent(destroyEvent)
  destroyEvent = nil
  hide()
end

function terminate()
  if teams then
    teams:destroy()
    teams = nil
  end

  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onCastleData = onCastleData,
    onCastleWinner = onCastleWinner,
    onCastleKills = onCastleKills
  })

end

function toggle()
  if teams:isVisible() then
    teams:hide()
  else
    teams:show(true)
  end
end

function hide()
  teams:hide()
end

function show()
  teams:show(true)
end

function onCastleData(team, teamName, size, kills, crystalLife, towerPercent)
  if not teams:isVisible() then
    teams:show(true)
  end

  if destroyEvent then
    removeEvent(destroyEvent)
  end

  destroyEvent = scheduleEvent(function() hide() end, 60000)

  if team == 1 then
    allianceKills = kills
    updateAllianceData(crystalLife, towerPercent)
  else
    hordeKills = kills
    updateHordeData(crystalLife, towerPercent)
  end
end

local function comparePlayers(a, b)
  if a.kills == b.kills then
    return a.deaths < b.deaths
  else
    return a.kills > b.kills
  end
end

function onCastleWinner(name, winnerOutfit)
  if destroyEvent then
    removeEvent(destroyEvent)
  end

  playersData = {}
  destroyEvent = scheduleEvent(function() hide() end, 3000)

  -- final result window
  finalResult:show(true)
  finalResult.contentPanel.winnerName:setText(name)
  finalResult.onClick = function()
    g_window.setClipboardText(name)
    modules.game_textmessage.displayStatusMessage(tr('You copied the winning player\'s name!'))
  end
  finalResult.contentPanel.trophy:setItemId(49659)
  finalResult.contentPanel.allianceCount:setText(allianceKills)
  finalResult.contentPanel.allianceCount:setColor('#20a0ff')
  finalResult.contentPanel.hordeCount:setText(hordeKills)
  finalResult.contentPanel.hordeCount:setColor('#d33c3c')

  finalResult.contentPanel.winnerOutfit:setOutfit(winnerOutfit)
end

function updateHordeData(crystalLife, towerPercent)
  local firstTower = towerPercent[1]
  local secondTower = towerPercent[2]

  hordeHP:setPercent(crystalLife)
  hordeHPLabel:setText(crystalLife .. "%")
  hordeTowerHP:setPercent((firstTower + secondTower) / 2)
  ahordeTowerHPLabel:setText((firstTower + secondTower) / 2 .. "%")
end

function updateAllianceData(crystalLife, towerPercent)
  local firstTower = towerPercent[1]
  local secondTower = towerPercent[2]

  allianceHP:setPercent(crystalLife)
  allianceHPLabel:setText(crystalLife .. "%")
  allianceTowerHP:setPercent((firstTower + secondTower) / 2)
  allianceTowerHPLabel:setText((firstTower + secondTower) / 2 .. "%")
end

function onCastleKills(teamId, statsData)
  if appearEvent then appearEvent:cancel() end

  local team = teamId == 2 and "Horde" or "Alliance"
  local color = (team == "Horde") and "#d33c3c" or "#20a0ff"
  for _, d in pairs(statsData) do
    table.insert(playersData, {name = d[1], team = team, kills = d[2], deaths = d[3], color = color})
  end

  appearEvent = scheduleEvent(function()
    createPlayerStats()
  end,
  500)
end

function createPlayerStats()
   -- Simula dados dos jogadores
  table.sort(playersData, comparePlayers)

  finalResult.contentPanel.killsRank:destroyChildren()

  for rank, playerData in ipairs(playersData) do
      local widget = g_ui.createWidget('PlayerWidget', finalResult.contentPanel.killsRank)
      widget:setBackgroundColor((rank % 2 == 0) and '#414141' or '#484848')

      if rank == 1 then
        widget:setMarginTop(16)

        local mvpLabel = g_ui.createWidget('UILabel', widget)
        mvpLabel:setText('MVP')
        mvpLabel:setColor('$var-text-cip-color-yellow')
        mvpLabel:setFont('$var-cip-font')
        mvpLabel:setTextAutoResize(true)
        mvpLabel:addAnchor(AnchorRight, 'name', AnchorRight)
        mvpLabel:addAnchor(AnchorVerticalCenter, 'name', AnchorVerticalCenter)
        mvpLabel:setMarginRight(9)
      end

      widget.rank:setText(tostring(rank))
      widget.name:setText(playerData.name)
      widget.name:setColor(playerData.color)
      widget.kills:setText(tostring(playerData.kills))
      widget.deaths:setText(tostring(playerData.deaths))
  end
end
