HuntFinder = {
  widget = nil,
  searchInputBox = nil,
  teamSizeBox = nil,
  filterBox = nil,
  listPanel = nil,
  huntInfoPanel = nil,
  vocationFilter = nil,

  vocation = "Knight",
  teamSize = "Solo",
  level = 1,
  sortType = 1,
}

function HuntFinder.init()
  HuntFinder.widget = g_ui.displayUI('styles/huntfinder')
  HuntFinder.widget:hide()

  HuntFinder.searchInputBox = HuntFinder.widget:recursiveGetChildById('searchInputBox')
  HuntFinder.teamSizeBox = HuntFinder.widget:recursiveGetChildById('teamSizeBox')
  HuntFinder.filterBox = HuntFinder.widget:recursiveGetChildById('filterBox')

  HuntFinder.listPanel = HuntFinder.widget:recursiveGetChildById('listPanel')
  HuntFinder.huntInfoPanel = HuntFinder.widget:recursiveGetChildById('huntInfoPanel')
  HuntFinder.backButton = HuntFinder.widget:recursiveGetChildById('backButton')
  HuntFinder.vocationFilter = HuntFinder.widget:recursiveGetChildById('vocationBox')
  HuntFinder.searchText = HuntFinder.widget:recursiveGetChildById('searchText')
  HuntFinder.searchIcon = HuntFinder.widget:recursiveGetChildById('searchIcon')

  if HuntFinder.searchText then
    HuntFinder.searchText.onTextChange = function(widget, text)
      HuntFinder.searchQuery = text:len() > 0 and text:lower() or nil
      if HuntFinder.searchIcon then
        HuntFinder.searchIcon:setEnabled(text:len() > 0)
      end
      HuntFinder:showListPanel()
      ListPanel:displayHunts()
    end
  end

  HuntConfig:loadJson()
  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = offline,
    onMonsterInfo = onMonsterInfo,
  })
end

function HuntFinder.terminate()
  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = offline,
    onMonsterInfo = onMonsterInfo,
  })

  ListPanel:clear()
  MapFinder:clear()
  HuntInfo:clear()
  if HuntFinder.widget then
    HuntFinder.widget:destroy()
    HuntFinder.widget = nil
  end

  HuntFinder.searchInputBox = nil
  HuntFinder.teamSizeBox = nil
  HuntFinder.filterBox = nil
  HuntFinder.listPanel = nil
  HuntFinder.huntInfoPanel = nil
  HuntFinder.vocationFilter = nil
end

function HuntFinder:setVocation(vocation)
  HuntFinder.vocation = vocation
  HuntFinder:showListPanel()
  ListPanel:displayHunts()
end

function HuntFinder:setTeamSize(teamSize)
  if teamSize ~= "Solo" and teamSize ~= "Duo" and teamSize ~= "Party x4" then
    teamSize = "Solo"
  end
  HuntFinder.teamSize = teamSize

  if HuntFinder.teamSizeBox then
    HuntFinder.teamSizeBox:setCurrentOption(teamSize)
  end

  HuntFinder:showListPanel()
  ListPanel:displayHunts()
end

function HuntFinder:setSortType(sortType)
  HuntFinder.sortType = sortType
  HuntFinder:showListPanel()
  ListPanel:displayHunts()
end

function HuntFinder:onLevelEdit(newLevel)
  local level = tonumber(newLevel)
  if not level then
    return
  end
  HuntFinder.level = level
  HuntFinder:showListPanel()
  ListPanel:displayHunts()
end

function HuntFinder:showListPanel()
  if not HuntFinder.widget then
    return
  end
  if HuntFinder.listPanel:isVisible() then
    return
  end
  HuntFinder.listPanel:setVisible(true)
  HuntFinder.huntInfoPanel:setVisible(false)
  HuntFinder.backButton:setVisible(false)
  HuntFinder.widget:setWidth(747)
end

function HuntFinder:showHuntInfo(hunt)
  if not HuntFinder.widget then
    return
  end
  if HuntFinder.huntInfoPanel:isVisible() then
    return
  end
  HuntFinder.listPanel:setVisible(false)
  HuntFinder.huntInfoPanel:setVisible(true)
  HuntFinder.backButton:setVisible(true)
  HuntFinder.widget:setWidth(920)
  HuntInfo:displayHunt(hunt)
end

function onGameStart()
  ListPanel.init()
  HuntInfo.init()
  MapFinder.init()
end

function offline()
  hide()
end

function show()
  HuntFinder.widget:show(true)
  HuntFinder.widget:raise()
  HuntFinder.widget:focus()
  HuntFinder:showListPanel()
  ListPanel:displayHunts()
  g_client.setInputLockWidget(HuntFinder.widget)

  HuntFinder.searchText:setText("")
  HuntFinder.searchQuery = nil
  if HuntFinder.searchIcon then
    HuntFinder.searchIcon:setEnabled(false)
  end

  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  HuntFinder.searchInputBox:setValue(HuntConfig:getPlayerFloorLevel(player:getLevel()))
  HuntFinder.vocationFilter:setCurrentOption(translateVocationName(player:getVocation()))
end

function hide()
  HuntFinder.widget:hide()
  g_client.setInputLockWidget(nil)
end

function onMonsterInfo(monsters)
  HuntInfo:setMonsters(monsters)
end