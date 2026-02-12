local lockedLevel = 7

if not GameMasterOptions then
  GameMasterOptions = {}
end

function init()
  connect(g_game, {
    onGameStart = onStartGame,
    onViewFloor = onViewFloor,
    onGotoPlayer = onGotoPlayer,
  })

  connect(LocalPlayer, {
    onPositionChange = onPlayerPositionChange
  })
end

function terminate()
  disconnect(g_game, {
    onGameStart = onStartGame,
    onViewFloor = onViewFloor,
    onGotoPlayer = onGotoPlayer,
  })

  disconnect(LocalPlayer, {
    onPositionChange = onPlayerPositionChange
  })
end

function onStartGame()
  local benchmark = g_clock.millis()
	lockedLevel = 7
	local player = g_game.getLocalPlayer()
	if player and player:getPosition() then
		lockedLevel = player:getPosition().z
	end

  if GameMasterOptions.targetName then
    local n = GameMasterOptions.targetName
    scheduleEvent(function()
      ExecuteGoto(n)
    end, 1000)
    GameMasterOptions.targetName = nil
  end

  GameMasterOptions = {}
  consoleln("Game Master loaded in " .. (g_clock.millis() - benchmark) / 1000 .. " seconds.")
end

function onPlayerPositionChange(creature, newPos, oldPos)
    lockedLevel = creature:getPosition().z
    m_interface.getMapPanel():unlockVisibleFloor()
end

function onViewFloor(upView)
    if not upView then
        lockedLevel = lockedLevel + 1
        m_interface.getMapPanel():lockVisibleFloor(lockedLevel)
    else
        lockedLevel = lockedLevel - 1
        m_interface.getMapPanel():lockVisibleFloor(lockedLevel)
    end
end

function onGotoPlayer(targetName, worldId)
  GameMasterOptions.targetName = targetName
  modules.client_entergame.SetLoginOption(worldId)
end

function ExecuteGoto(targetName)
  g_game.doThing(false)
  g_game.talk("/goto " .. targetName)
  g_game.doThing(true)
end
