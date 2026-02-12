forgeWindow = nil
fusionMenu = nil
transferMenu = nil
conversionMenu = nil
historyMenu = nil
resultWindow = nil

selectedItemFusionRadio = nil
selectedConvergenceFusionRadio = nil
selectedItemFusionConvectionRadio = nil

function init()
  forgeWindow = g_ui.displayUI('forge')
  mainPanel = forgeWindow:getChildById('contentPanel')

  fusionMenu = g_ui.loadUI('styles/fusion',  mainPanel)
  fusionMenu:hide()

  transferMenu = g_ui.loadUI('styles/transfer',  mainPanel)
  transferMenu:hide()

  conversionMenu = g_ui.loadUI('styles/conversion',  mainPanel)
  conversionMenu:hide()

  historyMenu = g_ui.loadUI('styles/history',  mainPanel)
  historyMenu:hide()

  resultWindow = g_ui.displayUI('styles/result')
  resultWindow:hide()

  loadMenu('fusionMenu')
  hideForge()

  connect(g_game, {
    onForgeInit = ForgeSystem.init,
    onForgeData = ForgeSystem.onForgeData,
    onForgeFusion = ForgeSystem.onForgeFusion,
    onForgeTransfer = ForgeSystem.onForgeTransfer,
    onForgeHistory = ForgeSystem.onForgeHistory,
    onResourceBalance = onResourceBalance,
    onGameEnd = offlineForge,
  })

end

function terminate()
  if forgeWindow then
    forgeWindow:destroy()
    forgeWindow = nil
  end
  if resultWindow then
    resultWindow:destroy()
    resultWindow = nil
  end
  disconnect(g_game, {
    onForgeInit = ForgeSystem.init,
    onForgeData = ForgeSystem.onForgeData,
    onForgeFusion = ForgeSystem.onForgeFusion,
    onForgeTransfer = ForgeSystem.onForgeTransfer,
    onForgeHistory = ForgeSystem.onForgeHistory,
    onResourceBalance = onResourceBalance,
    onGameEnd = offlineForge,
  })
end

function toggle()
  ForgeSystem.fusionData = {}
  ForgeSystem.fusionConvergenceData = {}
  ForgeSystem.transferData = {}
  ForgeSystem.transferConvergenceData = {}
  if forgeWindow:isVisible() then
    forgeWindow:hide()
    g_client.setInputLockWidget(nil)
  else
    forgeWindow:show(true)
    g_client.setInputLockWidget(forgeWindow)
    ForgeSystem.sideButton = true
    loadMenu('conversionMenu')
    forgeWindow:raise()
    forgeWindow:focus()
  end
end

function hideForge()
  forgeWindow:hide()
  g_client.setInputLockWidget(nil)
end

function show()
  if not forgeWindow:isVisible() then
    forgeWindow:show(true)
    forgeWindow:raise()
    forgeWindow:focus()
    loadMenu('fusionMenu')
  end
  g_client.setInputLockWidget(forgeWindow)


  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  forgeWindow.sliversPanel.slivers:setText(player:getResourceValue(ResourceForgeSlivers))
  forgeWindow.exaltedcorePanel.exaltedcore:setText(player:getResourceValue(ResourceForgeExaltedCore))
  forgeWindow.dustPanel.dust:setText(player:getResourceValue(ResourceForgeDust) .. '/' ..ForgeSystem.maxPlayerDust)
  forgeWindow.moneyPanel.gold:setText(formatMoney(player:getResourceValue(ResourceBank) + player:getResourceValue(ResourceInventary), ","))
end

function loadMenu(menuId)
  --mainPanel:destroyChildren()

  if fusionMenu:isVisible() then
    fusionMenu:hide()
  end

  if transferMenu:isVisible() then
    transferMenu:hide()
  end

  if conversionMenu:isVisible() then
    conversionMenu:hide()
  end

  if historyMenu:isVisible() then
    historyMenu:hide()
  end

  g_game.doThing(false)
  g_game.requestResource(ResourceBank)
  g_game.requestResource(ResourceInventary)
  g_game.requestResource(ResourceForgeDust)
  g_game.requestResource(ResourceForgeSlivers)
  g_game.requestResource(ResourceForgeExaltedCore)
  g_game.doThing(false)

  local fusionMenuButton = forgeWindow.panelButtons:getChildById('fusionButton')
  local transferMenuButton = forgeWindow.panelButtons:getChildById('transferButton')
  local conversionMenuButton = forgeWindow.panelButtons:getChildById('conversionButton')
  local historyMenuButton = forgeWindow.panelButtons:getChildById('historyButton')

  transferMenuButton:setChecked(false)
  conversionMenuButton:setChecked(false)
  historyMenuButton:setChecked(false)
  fusionMenuButton:setChecked(false)
  if menuId == 'fusionMenu' then
    fusionMenu:show(true)
    ForgeSystem.updateFusion()
    fusionMenuButton:setChecked(true)
  elseif menuId == 'transferMenu' then
    transferMenu:show(true)
    ForgeSystem.updateTransfer()
    transferMenuButton:setChecked(true)
  elseif menuId == 'conversionMenu' then
    conversionMenu:show(true)
    ForgeSystem.updateConversion()
    conversionMenuButton:setChecked(true)
  elseif menuId == 'historyMenu' then
    historyMenu:show(true)
    historyMenuButton:setChecked(true)
    g_game.requestForgeHistory()
  end

  local player = g_game.getLocalPlayer()
  if not player then return end

  forgeWindow.sliversPanel.slivers:setText(player:getResourceValue(ResourceForgeSlivers))
  forgeWindow.exaltedcorePanel.exaltedcore:setText(player:getResourceValue(ResourceForgeExaltedCore))
  forgeWindow.dustPanel.dust:setText(player:getResourceValue(ResourceForgeDust) .. '/' ..ForgeSystem.maxPlayerDust)
  forgeWindow.moneyPanel.gold:setText(formatMoney(player:getResourceValue(ResourceBank) + player:getResourceValue(ResourceInventary), ","))
end

function offlineForge()
  forgeWindow:hide()
  resultWindow:hide()
  g_client.setInputLockWidget(nil)
  ForgeSystem.clearFusion()
  ForgeSystem.clearTransfer()

  ForgeSystem.fusionData = {}
  ForgeSystem.fusionConvergenceData = {}
  ForgeSystem.transferData = {}
  ForgeSystem.transferConvergenceData = {}
end

function onResourceBalance(type, amount)
  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  if table.contains({ResourceBank, ResourceInventary, ResourceForgeDust, ResourceForgeSlivers, ResourceForgeExaltedCore}, type) then
    forgeWindow.sliversPanel.slivers:setText(player:getResourceValue(ResourceForgeSlivers))
    forgeWindow.exaltedcorePanel.exaltedcore:setText(player:getResourceValue(ResourceForgeExaltedCore))
    forgeWindow.dustPanel.dust:setText(player:getResourceValue(ResourceForgeDust) .. '/' ..ForgeSystem.maxPlayerDust)
    forgeWindow.moneyPanel.gold:setText(formatMoney(player:getResourceValue(ResourceBank) + player:getResourceValue(ResourceInventary), ","))

    ForgeSystem.checkFusionButton()
    ForgeSystem.updateConversion()
  end
end
