-- Adicionar battle por instancia igual ao Hunting
-- Defaults 20 battle + 1 principal
-- so pode deixar 20 aberto

mainBattleWindow = nil
editNameBattleWindow = nil

mouseWidget = nil

local maxBattleWindow = 21

-- Objects
if not battleClasses then
  battleClasses = {}
end

local keybindOpenBattle = KeyBind:getKeyBind("Windows", "Show/hide battle list")
local keybindOpenSecondaryBattle = KeyBind:getKeyBind("Windows", "Open secondary battle list")

function init()
  g_ui.importStyle('battlebutton')

  mainBattleWindow = g_ui.loadUI('battle', m_interface.getRightPanel())
  keybindOpenBattle:active()
  keybindOpenSecondaryBattle:active()

  mouseWidget = g_ui.createWidget('UIButton')
  mouseWidget:setId('MouseWidget_Battle')
  mouseWidget:setVisible(false)
  mouseWidget:setFocusable(false)
  mouseWidget.cancelNextRelease = false

  for i = 1, maxBattleWindow, 1 do
    local battleClass = BattleClass.create()
    battleClass:configure(i)
    battleClass:setSecondary(i ~= 1)
    table.insert(battleClasses, battleClass)
  end
end

function terminate()
  keybindOpenBattle:deactive()
  keybindOpenSecondaryBattle:deactive()

  mouseWidget:destroy()
end

function toggle()
  local mainBattle = getMainBattle().window
  if modules.game_sidebuttons.isButtonVisible("battleListWidget") then
    mainBattle:close()
    modules.game_sidebuttons.setButtonVisible("battleListWidget", false)
  else
    if m_interface.addToPanels(mainBattle) then
      mainBattle:open()
      modules.game_sidebuttons.setButtonVisible("battleListWidget", true)
      mainBattle:getParent():moveChildToIndex(mainBattle, #mainBattle:getParent():getChildren())
    end
  end
end

function close()
  local mainBattle = getMainBattle().window
  mainBattle:close()
end

function open()
  local mainBattle = getMainBattle().window
  if m_interface.addToPanels(mainBattle) then
    mainBattle:open()
    mainBattle:getParent():moveChildToIndex(mainBattle, #mainBattle:getParent():getChildren())
    modules.game_sidebuttons.setButtonVisible("battleListWidget", true)
  end
end

function onMiniWindowClose(window)
  for _, data in pairs(battleClasses)  do
    if data:getWindow():getId() == window:getId() and window:getId() ~= "battleWindow" then
      data:close()
      break
    end
  end

  local visibleCount = 0
  for _, data in pairs(battleClasses) do
    if data:getWindow() and data:getWindow():isVisible() then
      visibleCount = visibleCount + 1
    end
  end

  if visibleCount == 0 then
    modules.game_sidebuttons.setButtonVisible("battleListWidget", false)
  end
end

function isHidingFilters()
  local settings = g_settings.getNode('BattleList')
  if not settings then
    return false
  end
  return settings['hidingFilters']
end

function setHidingFilters(state)
  settings = {}
  settings['hidingFilters'] = state
  g_settings.mergeNode('BattleList', settings)
end

function hideFilterPanel(id)
  local object = battleClasses[id]
  if not object then
    return
  end

  local filterPanel = object:getFilterPanel()
  local toggleFilterButton = object:getToggleFilterButton()
  if not filterPanel then
	 return
  end

  local battleWindow = object:getWindow()
  object.showFilters = false
  filterPanel.originalHeight = filterPanel:getHeight()
  filterPanel:setHeight(0)
  toggleFilterButton:getParent():setMarginTop(0)
  toggleFilterButton:setImageClip(torect("0 0 21 12"))
  setHidingFilters(true)
  filterPanel:setVisible(false)
  battleWindow:setContentMinimumHeight(56)
  toggleFilterButton:setOn(false)
end

function showFilterPanel(id)
  local object = battleClasses[id]
  if not object then
    return
  end

  local filterPanel = object:getFilterPanel()
  local toggleFilterButton = object:getToggleFilterButton()
  if not filterPanel then
   return
  end

  if filterPanel.originalHeight == 0 then
    filterPanel.originalHeight = 50
  end

  local battleWindow = object:getWindow()
  object.showFilters = true
  toggleFilterButton:getParent():setMarginTop(5)
  filterPanel:setHeight(filterPanel.originalHeight)
  toggleFilterButton:setImageClip(torect("21 0 21 12"))
  setHidingFilters(false)
  filterPanel:setVisible(true)

  toggleFilterButton:setOn(true)
  if battleWindow:getHeight() < 115 then
    battleWindow:setHeight(115)
  end

  battleWindow:setContentMinimumHeight(115)
end

function toggleFilterPanel(self)
  local id = self.bid
  local object = battleClasses[id]
  if not object then
    return
  end

  local filterBattleButton = self:getChildById('filterBattleButton')
  local filterPanel = object:getFilterPanel()
  if not filterPanel then
   return
  end

  if filterPanel:isVisible() then
    filterBattleButton:setOn(false)
    hideFilterPanel(id)
  else
    filterBattleButton:setOn(true)
    showFilterPanel(id)
  end
end

function setSortType(state)
  settings = {}
  settings['sortType'] = state
  g_settings.mergeNode('BattleList', settings)
end

-- other functions
function onBattleButtonMouseRelease(self, mousePosition, mouseButton)
  if mouseWidget.cancelNextRelease then
    mouseWidget.cancelNextRelease = false
    return false
  end

  local creature = self:getCreature()
  if creature then
    if ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton) or (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
      mouseWidget.cancelNextRelease = true
      g_game.look(creature, true)
      return true
    elseif mouseButton == MouseLeftButton and g_keyboard.isShiftPressed() then
      g_game.look(creature, true)
      return true
    elseif mouseButton == MouseLeftButton and not g_mouse.isPressed(MouseRightButton) then
      if g_game.getAttackingCreature() == creature then
        modules.game_helper.helperConfig.currentLockedTargetId = 0
        g_game.cancelAttack()
        g_game.attack(nil)
      else
        modules.game_helper.helperConfig.currentLockedTargetId = creature:getId()
        g_game.attack(creature)
      end
      return true
    elseif mouseButton == MouseRightButton and not g_mouse.isPressed(MouseLeftButton) then
      local player = g_game.getLocalPlayer()
      local creatureName = creature:getName()
      local isPlayer = creature:isPlayer()
      local isNpc = creature:isNpc()

      local menu = g_ui.createWidget('PopupMenu')
      menu:setGameMenu(true)

      if not isNpc then
        if g_game.getAttackingCreature() == creature then
          menu:addOption(tr('Stop Attack'), function()  modules.game_helper.helperConfig.currentLockedTargetId = 0; g_game.attack(nil) end)
        else
          menu:addOption(tr('Attack'), function() modules.game_helper.helperConfig.currentLockedTargetId = creature:getId(); g_game.attack(creature) end)
        end
      elseif isNpc then
        menu:addOption(tr('Talk'), function()
          local distance = math.max(math.abs(player:getPosition().x - creature:getPosition().x), math.abs(player:getPosition().y - creature:getPosition().y))
          if distance > 3 then
            return modules.game_textmessage.displayFailureMessage(tr('You are too far away.'))
          end
		  g_game.sendNPCTalk(creature:getId())
        end)
      end
      menu:addOption(tr('Follow'), function() g_game.follow(creature) end)
      menu:addOption(tr('Look'), function() g_game.look(creature, true) end)
      if isPlayer then
        menu:addSeparator()
        menu:addOption(tr('Message to ' .. creatureName), function () g_game.openPrivateChannel(creatureName) end)
        if not player:hasVip(creatureName) then
          menu:addOption(tr('Add ' .. creatureName .. ' to VIP list'), function () g_game.addVip(creatureName) end)
        end
        if modules.game_console.Communication:isIgnored(creatureName) then
          menu:addOption(tr('Unignore') .. ' ' .. creatureName, function() modules.game_console.Communication:removeIgnoredPlayer(creatureName) end)
        else
          menu:addOption(tr('Ignore') .. ' ' .. creatureName, function() modules.game_console.Communication:addIgnoredPlayer(creatureName) end)
        end
        local localPlayerShield = player:getShield()
        local creatureShield = creature:getShield()
        if localPlayerShield == ShieldNone or localPlayerShield == ShieldWhiteBlue then
          if creatureShield == ShieldWhiteYellow then
            menu:addOption(tr('Join %s\'s Party', creature:getName()), function() g_game.partyJoin(creature:getId()) end)
          else
            menu:addOption(tr('Invite %s to Party', creature:getName()), function() g_game.partyInvite(creature:getId()) end)
          end
        elseif localPlayerShield == ShieldWhiteYellow then
          if creatureShield == ShieldWhiteBlue then
            menu:addOption(tr('Revoke %s\'s Invitation', creature:getName()), function() g_game.partyRevokeInvitation(creature:getId()) end)
          end
        elseif localPlayerShield == ShieldYellow or localPlayerShield == ShieldYellowSharedExp or localPlayerShield == ShieldYellowNoSharedExpBlink or localPlayerShield == ShieldYellowNoSharedExp then
          if creatureShield == ShieldWhiteBlue then
            menu:addOption(tr('Revoke %s\'s Invitation', creature:getName()), function() g_game.partyRevokeInvitation(creature:getId()) end)
          elseif creatureShield == ShieldBlue or creatureShield == ShieldBlueSharedExp or creatureShield == ShieldBlueNoSharedExpBlink or creatureShield == ShieldBlueNoSharedExp then
            menu:addOption(tr('Pass Leadership to %s', creature:getName()), function() g_game.partyPassLeadership(creature:getId()) end)
          else
            menu:addOption(tr('Invite to Party'), function() g_game.partyInvite(creature:getId()) end)
          end
        end
        menu:addOption(tr('Inspect %s', creature:getName()), function() print("toDo") end)
        menu:addOption(tr('Revoke %s allowance to inspect me', creature:getName()), function() print("toDo") end)
        menu:addSeparator()
        menu:addOption(tr('Report Name'), function() modules.game_report.doReportName(creature:getName()) end)
        menu:addOption(tr('Report Bot/Macro'), function() modules.game_report.doReportMacro(creature:getId(), creature:getName()) end)
        menu:addSeparator()
        menu:addOption(tr('Copy Name'), function () g_window.setClipboardText(creatureName) end)
      else
        menu:addSeparator()
        menu:addOption(tr('Copy Name'), function () g_window.setClipboardText(creatureName) end)
      end

      menu:display(mousePosition)
      return true
    end
  end
  return false
end

function filterPopUp(widget)
  local id = widget.bid
  local object = battleClasses[id]
  if not object then
    return
  end

  object:onFilterPopup()
end

function addBattleWindow()
  for i = 2, maxBattleWindow do
    local data = battleClasses[i]
    if data and data:getWindow() and not data:getWindow():isVisible() and m_interface.addToPanels(data:getWindow()) then
      data:showBattle()
      data:getWindow():getParent():moveChildToIndex(data:getWindow(), data:getWindow():getParent():getChildCount())
      return
    end
  end

  modules.game_textmessage.displayFailureMessage(tr("You cannot open more battle lists."))
end

function updateBattleIconCreatures(widget, checked)
  local displaName = {
    ['showPlayers'] = 'Players',
    ['showNPCs'] = 'NPCs',
    ['showKnights'] = 'Knights',
    ['showPaladins'] = 'Paladins',
    ['showDruids'] = 'Druids',
    ['showSorcerers'] = 'Sorceres',
    ['showMonks'] = 'Monks',
    ['showSummons'] = 'Summons',
    ['showMonsters'] = 'Monsters',
    ['showNonSkulled'] = 'Non-Skulled Players',
    ['showParty'] = 'Party Members',
    ['showOwnGuilds'] = 'Members of Own Guild',
  }

  local name = displaName[widget:getId()]
  if not name then
    return
  end

  local window = widget:getParent():getParent():getParent()
  if not window then return end
  local battle = window.battle
  if not battle then return end
  local panel = window.battle.panel
  if not panel then return end

  panel:setFilter(widget:getId(), checked)

  widget:setTooltip((checked and 'Hide' or 'Show') .. ' ' .. name)
end

function onPlayerLoad(bCondig)
  for id, config in pairs(bCondig) do
    if config.isPartyView then
      goto continue
    end

    local data = battleClasses[id + 1]
    if (data and data:getWindow()) or data.window:isVisible() then
      data:setName(config.name)
      for _, value in pairs(config.battleListFilters) do
        local invertedValue = value:gsub("hide", "show")
        local button = data.filterPanel.buttons:getChildById(invertedValue)
        if button then
        data.panel:setFilter(invertedValue)
          button:setChecked(false)
        end
      end
      data.panel:setSortType(config.battleListSortOrder[1])
      data.sortType[1] = config.battleListSortOrder[1]
      if config.contentMaximized then
        data.window:maximize()
      else
        data.window:minimize()
      end

      scheduleEvent(function() setupBattlePanel(data, id + 1, config.showFilters) end, (id + 1) * 1000, "setupBattlePanel")

      if config.contentHeight < data:getWindow():getMinimumHeight() then
        config.contentHeight = data:getWindow():getMinimumHeight()
      end

      data:getWindow():setHeight(config.contentHeight)
      data.window:setVisible(true)
    end
    ::continue::
  end
end

function setupBattlePanel(data, id, showFilters)
  local filterBattleButton = data.window:getChildById('filterBattleButton')
  local filterPanel = data:getFilterPanel()
  if not filterPanel then
   return
  end
  if not showFilters then
    if not filterPanel:isVisible() then
      return
    end
    hideFilterPanel(id)
    filterBattleButton:setOn(false)
  else
    if filterPanel:isVisible() then
      return
    end
    showFilterPanel(id)
    filterBattleButton:setOn(true)
  end
end

function onPlayerUnload()
  for k, data in pairs(battleClasses) do
    if data and data:getWindow():isOpened() then
      data:registerInSideBars()
    end
  end

  modules.game_party_list.PartyClass:registerInSideBars()
end

function moveBattle(instance, panel, height, minimized)
  local data = battleClasses[instance + 1]

  if (data and data:getWindow()) or data.window:isVisible() then
    local window = data.window

    window:setParent(panel)
    window:open()
    data:showBattle()
    window:maximize()
    window:setHeight(height)

    return window
  end

  return nil
end

function chooseNextCreature()
  if not rootWidget:getChildById("gameRootPanel"):isFocused() then
    return
  end

  local creatures = getMainBattle().panel:getVisibleCreatures()
  local attackedCreature = g_game.getAttackingCreature()
  local nextChild = nil
  local breakNext = false

  local firstAttacked = nil
  for i = 1, #creatures do
    local creature = creatures[i]
    if creature ~= attackedCreature then
      firstAttacked = creature
    end
    if firstAttacked then
      break
    end
  end

  for i = 1, #creatures do
    local creature = creatures[i]

    nextChild = creature
    if breakNext then
      break
    end

    if creature == attackedCreature then
      breakNext = true
      nextChild = firstAttacked
    end
  end

  if not breakNext then
    nextChild = firstAttacked
  end

  if nextChild then
    g_game.attack(nextChild)
    modules.game_helper.helperConfig.currentLockedTargetId = nextChild:getId()
  end
end

function getCreatures()
  return getMainBattle().panel:getVisibleCreatures()
end

function getAttackableCreatures()
  return getMainBattle().panel:getAttackableCreatures()
end

function choosePrevCreature()
  if not rootWidget:getChildById("gameRootPanel"):isFocused() then
    return
  end
  local creatures = getMainBattle().panel:getVisibleCreatures()
  local attackedCreature = g_game.getAttackingCreature()
  local prevChild = nil

  local firstAttacked = nil
  for i = #creatures, 1, -1 do
    local creature = creatures[i]
    if creature ~= attackedCreature then
      firstAttacked = creature
      break
    end
  end

  for i = 1, #creatures do
    local creature = creatures[i]
    if creature == attackedCreature then
      if not prevChild then
        prevChild = firstAttacked
      end
      break
    end
    prevChild = creature
  end

  if prevChild then
    g_game.attack(prevChild)
    modules.game_helper.helperConfig.currentLockedTargetId = prevChild:getId()
  end
end

function getMainBattle()
  for k, data in pairs(battleClasses) do
    if not data.secondary then
      return data
    end
  end

  return battleClasses[1]
end

