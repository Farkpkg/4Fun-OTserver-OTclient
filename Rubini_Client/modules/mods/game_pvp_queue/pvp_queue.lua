PrestigeBattle = {
	window = nil,
	pickMapWindow = nil,
	matchFoundWindow = nil,
	castWindow = nil,
	rankedPanel = nil,
	highScoresPanel = nil,
	scorePanel = nil,
	playerHistory = nil,
	backButton = nil,
	castInterface = nil,
	countdownPanel = nil,

	minimizeButton = nil,
	minimizedPanel = nil,

	confirmLeaveQueue = nil,
	prestigeInspectWindow = nil,
	queueLimitPopup = nil,

	player = nil,
	playerBasicData = nil,
	queueServerStatus = 0,
	punishmentLeft = 0,
	ticketPrice = 0,
	minLevel = 0,
	timeUntilNextQueue = 0,
	canWatchliveMatch = true,

	closedEvent = nil,
	queueCycleEvent = nil,
	queueWaitingTime = 0, -- seconds
	queuePlayerCount = 0,
	queueMaxWaitingTime = 0,
	currentMatchCount = 0,
	dailyMatchCount = 0,

	matchFoundCycleEvent = nil,
	matchFoundProgressEvent = nil,
	matchFoundTimer = 30, -- seconds

	liveMatchesMap = {},
	playerHistoryEntries = {}
}

function init()
	PrestigeBattle.window = g_ui.displayUI('pvp_queue')
	PrestigeBattle.castWindow = g_ui.createWidget("CastWindow", g_ui.getRootWidget())
	PrestigeBattle.pvpQueueWindow = g_ui.createWidget("BanMapWindow", g_ui.getRootWidget())
	PrestigeBattle.matchFoundWindow = g_ui.createWidget("MatchFound", g_ui.getRootWidget())
	PrestigeBattle.scorePanel = m_interface.getRootPanel():recursiveGetChildById("prestigeGameInfoHUD")
	PrestigeBattle.castInterface = m_interface.getRootPanel():recursiveGetChildById("castInterfacePanel")
	PrestigeBattle.countdownPanel = m_interface.getRootPanel():recursiveGetChildById("prestigeCountdownPanel")
	PrestigeBattle.minimizedPanel = m_interface.getRootPanel():recursiveGetChildById("searchingQueueMinWindow")

	PrestigeBattle.backButton = PrestigeBattle.window:recursiveGetChildById('backButton')
	PrestigeBattle.prestigeWiki = PrestigeBattle.window:recursiveGetChildById('prestigeWiki')
	PrestigeBattle.rankedPanel = PrestigeBattle.window:recursiveGetChildById('rankedPanel')
	PrestigeBattle.playerHistory = PrestigeBattle.window:recursiveGetChildById('playerHistory')
	PrestigeBattle.highScoresPanel = PrestigeBattle.window:recursiveGetChildById('highScoresPanel')
	PrestigeBattle.minimizeButton = PrestigeBattle.window:recursiveGetChildById('minimizeButton')

	PrestigeBattle:loadMenu('rankedMenu')

	PrestigeBattle.window:hide()
	PrestigeBattle.pvpQueueWindow:hide()
	PrestigeBattle.matchFoundWindow:hide()
	PrestigeBattle.castWindow:hide()

	connect(g_game, {
		onGameStart = online,
		onGameEnd = offline,
		onRecvPrestigeArenaBasicData = onRecvBasicData,
		onRecvPrestigeArenaStatus = onRecvStatus,
		onRecvWinnerMap = onRecvWinnerMap,
		onRecvRoundDuration = onRecvRoundDuration,
		onRecvPrestigeArenaLeaderboardData = onRecvPrestigeArenaLeaderboardData,
		onRecvLiveMatches = onRecvLiveMatches,
		onBeginWatchLiveMatch = onBeginWatchLiveMatch,
		onFinishWatchLiveMatch = onFinishWatchBroadcast,
		onRecvMatchHistory = onRecvMatchHistory,
		onRecvPrestigeInspect = onRecvPrestigeInspect
	})
end

function terminate()
	disconnect(g_game, {
		onGameStart = online,
		onGameEnd = offline,
		onRecvPrestigeArenaBasicData = onRecvBasicData,
		onRecvPrestigeArenaStatus = onRecvStatus,
		onRecvWinnerMap = onRecvWinnerMap,
		onRecvRoundDuration = onRecvRoundDuration,
		onRecvPrestigeArenaLeaderboardData = onRecvPrestigeArenaLeaderboardData,
		onRecvLiveMatches = onRecvLiveMatches,
		onBeginWatchLiveMatch = onBeginWatchLiveMatch,
		onFinishWatchLiveMatch = onFinishWatchLiveMatch,
		onRecvMatchHistory = onRecvMatchHistory,
		onRecvPrestigeInspect = onRecvPrestigeInspect
	})
end

function online()
	hide()
	g_minimap.clearPrestigeOpponent()
	PrestigeBattle.player = g_game.getLocalPlayer()
end

function offline()
	hide()
	removeEvent(PrestigeBattle.matchFoundCycleEvent)
	removeEvent(PrestigeBattle.matchFoundProgressEvent)
	removeEvent(PrestigeBattle.queueCycleEvent)
	TypingAnimation:stop("prestigeBattle")

	PrestigeBattle.matchFoundCycleEvent = nil
	PrestigeBattle.matchFoundProgressEvent = nil
	PrestigeBattle.queueCycleEvent = nil
	PrestigeBattle.player = nil
	PrestigeBattle.punishmentLeft = 0
	PrestigeBattle.playerHistoryEntries = {}

	MapPhase:offline()

	if PrestigeBattle.matchFoundWindow:isVisible() then
		PrestigeBattle.matchFoundWindow:hide()
	end

	PrestigeBattle.castInterface:setVisible(false)
	PrestigeBattle.scorePanel:setVisible(false)

	if PrestigeBattle.confirmLeaveQueue then
		PrestigeBattle.confirmLeaveQueue:destroy()
		PrestigeBattle.confirmLeaveQueue = nil
	end

	PrestigeBattle.minimizedPanel:hide()
	PrestigeBattle.countdownPanel:setVisible(false)

	if PrestigeBattle.prestigeInspectWindow then
		PrestigeBattle.prestigeInspectWindow:destroy()
		PrestigeBattle.prestigeInspectWindow = nil
	end

	if PrestigeBattle.closedEvent then
		removeEvent(PrestigeBattle.closedEvent)
		PrestigeBattle.closedEvent = nil
	end

	local searchTimer = PrestigeBattle.rankedPanel:recursiveGetChildById("searchTimer")
	local searchButton = PrestigeBattle.rankedPanel:recursiveGetChildById("searchBattleButton")
	searchTimer:setDuration(0)
	searchTimer:setText("")
	searchTimer:stop()
	searchButton:setText("Search Battle")

	g_client.setInputLockWidget(nil)
end

function show()
	PrestigeBattle.window:show(true)
	PrestigeBattle.window:raise()
	PrestigeBattle.window:focus()

	self:onResourceBalance()

	if PrestigeBattle.prestigeInspectWindow then
		PrestigeBattle.prestigeInspectWindow:destroy()
		PrestigeBattle.prestigeInspectWindow = nil
	end

	g_client.setInputLockWidget(PrestigeBattle.window)
end

function hide()
	PrestigeBattle.window:hide()
	if PrestigeBattle.castWindow:isVisible() then
		PrestigeBattle.castWindow:hide()
	end

	g_client.setInputLockWidget(nil)
end

function onRecvBasicData(data, queueStatus, punishmentLeft, ticketPrice, showPrestigeEmblem, minLevel, timeLeft, currentMatchCount, dailyMatchCount)
	PrestigeBattle.playerBasicData = data
	PrestigeBattle.queueServerStatus = queueStatus
	PrestigeBattle.punishmentLeft = punishmentLeft
	PrestigeBattle.ticketPrice = ticketPrice
	PrestigeBattle.minLevel = minLevel
	PrestigeBattle.timeUntilNextQueue = timeLeft
	PrestigeBattle.currentMatchCount = currentMatchCount
	PrestigeBattle.dailyMatchCount = dailyMatchCount

	PrestigeBattle.window:show(true)
	PrestigeBattle:onOpenWindow()
	PrestigeBattle.scorePanel:setVisible(false)

	local showEmblemBox = PrestigeBattle.window:recursiveGetChildById("checkBoxEmblem")
	showEmblemBox:setChecked(showPrestigeEmblem, true)
end

function onRecvStatus(status, prestigeMaps, canBanMap, punishmentLeft, maxQueueWaitingTime, currentMatchCount, dailyMatchCount)
	if status == 0 then
		if PrestigeBattle.minimizedPanel:isVisible() and PrestigeBattle.queueCycleEvent then
			removeEvent(PrestigeBattle.queueCycleEvent)
			PrestigeBattle.queueCycleEvent = nil
			PrestigeBattle.minimizedPanel:setVisible(false)
			return
		end

		PrestigeBattle.countdownPanel:setVisible(false)
		PrestigeBattle.scorePanel:setVisible(false)
		PrestigeBattle.castInterface:setVisible(false)
		PrestigeBattle.currentMatchCount = currentMatchCount
		PrestigeBattle.dailyMatchCount = dailyMatchCount

		MapPhase:offline()
		g_minimap.clearPrestigeOpponent()
		PrestigeBattle.punishmentLeft = punishmentLeft

		PrestigeBattle:onUpdateMatchCount()
		PrestigeBattle:resetMatchFoundVariables()
		PrestigeBattle:onLeaveQueue()
		PrestigeBattle.window:show(true)
		PrestigeBattle:checkPunishmentTime()
	elseif status == 1 then
		if PrestigeBattle.matchFoundWindow:isVisible() then
			PrestigeBattle:resetMatchFoundVariables()
			PrestigeBattle:onLeaveQueue()
			PrestigeBattle.window:show(true)
		end

		if maxQueueWaitingTime then
			PrestigeBattle.queueMaxWaitingTime = maxQueueWaitingTime
		end

		PrestigeBattle:onEnterQueue()
	elseif status == 2 then
		PrestigeBattle:onMatchFound()
	elseif status == 3 then
		PrestigeBattle:resetMatchFoundVariables()
		MapPhase:displayMaps(prestigeMaps, canBanMap)
	elseif status == 7 then
		PrestigeBattle:updateInterfaceHUD(0)
	elseif status == 8 then
		PrestigeBattle.scorePanel:setVisible(false)
		PrestigeBattle:resetMatchFoundVariables()
		PrestigeBattle:onLeaveQueue()
		MapPhase:offline()
	end
end

function onRecvRoundDuration(status, roundDuration, blueSideScore, redSideScore)
	if not PrestigeBattle.scorePanel:isVisible() then
		PrestigeBattle.scorePanel:setVisible(true)
		MapPhase:reset()
	end

	PrestigeBattle.countdownPanel:setVisible(false)

	if status == 5 then
		PrestigeBattle.countdownPanel.prestigeCountdown:setImageSource("/images/game/ranked-queue/countdown", false)
		PrestigeBattle.countdownPanel:setVisible(true)
	end

	if status == 6 or status == 7 then
		PrestigeBattle.countdownPanel:setVisible(false)
		PrestigeBattle.countdownPanel.prestigeCountdown:setImageSource("")
	end

	if PrestigeBattle.window:isVisible() then
		hide()
	end

	PrestigeBattle:updateInterfaceHUD(roundDuration, blueSideScore, redSideScore)
end

function onRecvWinnerMap(winnerMapId)
	MapPhase:displayWinnerMap(winnerMapId)
end

function onRecvLiveMatches(matches, canWatchliveMatch)
	if PrestigeBattle.scorePanel:isVisible() then
		PrestigeBattle.scorePanel:setVisible(false)
	end

	if PrestigeBattle.castInterface:isVisible() then
		PrestigeBattle.castInterface:setVisible(false)
	end

	PrestigeBattle.canWatchliveMatch = canWatchliveMatch
	PrestigeBattle.liveMatchesMap = matches
	PrestigeBattle.countdownPanel:setVisible(false)
	PrestigeBattle:configureLiveMatchFilters()
	PrestigeBattle:displayLiveMatches()

	modules.game_console.g_chat:reopenChannels()
end

function onBeginWatchLiveMatch()
	PrestigeBattle.castInterface:setVisible(true)
	hide()
end

function onRecvMatchHistory(history)
	PrestigeBattle.playerHistoryEntries = history
	PrestigeBattle:displayPlayerHistory()
end

function onRecvPrestigeArenaLeaderboardData(currentWorld, lastUpdateTime, availableWorlds, currentPage, totalPages, rankings, ranking, vocation, vocations)
	PvpLeaderboard:init(currentWorld, lastUpdateTime, availableWorlds, currentPage, totalPages, rankings, ranking, vocation, vocations)
end

function onRecvPrestigeInspect(data)
	-- Check if the request came from prestige window by checking if window is visible
	local fromPrestigeWindow = PrestigeBattle.window:isVisible()
	PrestigeBattle:showPrestigeInspect(data, fromPrestigeWindow)
end

function PrestigeBattle:requestOpenWindow()
	PrestigeBattle:loadMenu("rankedMenu")
	g_game.sendRequestPrestigeArenaData()
end

function PrestigeBattle:updateInterfaceHUD(roundDuration, blueSideScore, redSideScore)
	local timeText = self.scorePanel:recursiveGetChildById("timeLeftTimer")
	local blueScore = self.scorePanel:recursiveGetChildById("teamBlueScore")
	local redScore = self.scorePanel:recursiveGetChildById("teamRedScore")

	timeText:setText(getTimeInShortWords(roundDuration / 1000))

	if blueSideScore then
		blueScore:setText(blueSideScore)
	end

	if redSideScore then
		redScore:setText(redSideScore)
	end
end

function PrestigeBattle:loadMenu(menuId)
	for _, buttonId in pairs({"rankedMenu", "highscoreMenu", "castMenu"}) do
		local button = self.window:recursiveGetChildById(buttonId)
		if button then
			button:setChecked(false)
		end
	end

	g_game.doThing(false)
	g_game.requestResource(ResourceBank)
	g_game.requestResource(ResourceInventary)
	g_game.doThing(false)

	g_client.setInputLockWidget(self.window)

	local targetButton = self.window:recursiveGetChildById(menuId)

	if targetButton then
		targetButton:setChecked(true)
	end

	local watchButton = self.castWindow:recursiveGetChildById("watchButton")
	watchButton:setVisible(false)

	if menuId == 'rankedMenu' then
		self.playerHistory:hide()
		self.highScoresPanel:hide()
		self.backButton:setVisible(false)
		self.prestigeWiki:setVisible(true)
		self.rankedPanel:show(true)
	elseif menuId == 'highscoreMenu' then
		self.rankedPanel:hide()
		self.playerHistory:hide()
		self.backButton:setVisible(false)
		self.prestigeWiki:setVisible(true)
		self.highScoresPanel:show(true)
		g_game.sendPrestigeArenaLeaderboard(0xFFFF, 1, false, 0,0xFFFFFFFF)
	elseif menuId == 'playerHistory' then
		self.rankedPanel:hide()
		self.highScoresPanel:hide()
		self.prestigeWiki:setVisible(false)
		self.backButton:setVisible(true)
		self.playerHistory:show(true)

		g_game.sendRequestPrestigeArenaHistory()
		self.playerHistory:recursiveGetChildById("playerHistoryContent"):destroyChildren()
	end

	if self.queueCycleEvent ~= nil then
        self.minimizeButton:setVisible(true)
        self.prestigeWiki:setVisible(false)
    else
        self.minimizeButton:setVisible(false)
    end
end

function PrestigeBattle:checkPunishmentTime()
	local searchTimer = self.rankedPanel:recursiveGetChildById("searchTimer")
	local searchButton = self.rankedPanel:recursiveGetChildById("searchBattleButton")
	local availablePlayers = self.rankedPanel:recursiveGetChildById("availablePlayersLabel")

	if self.punishmentLeft > 0 then
		searchTimer.onTimeEnd = function()
			searchButton:setText("Search Battle")
			searchButton:setOn(self.queueServerStatus == QueueOpen)
			availablePlayers:setText("")
			availablePlayers:setColor("$var-text-cip-color")
			self.punishmentLeft = 0
		end

		searchButton:clearText()
		searchButton:setOn(false)
		searchTimer:setDuration(self.punishmentLeft * 1000)
		availablePlayers:setText("You are currently restricted from joining the prestige queue.")
		availablePlayers:setColor("$var-text-cip-store-red")
		searchTimer:start()
	else
		searchButton:setText("Search Battle")
		searchButton:setOn(true)
		availablePlayers:setText("")
		availablePlayers:setColor("$var-text-cip-color")
	end
end

function PrestigeBattle:onOpenWindow()
	if not self.window:isVisible() then
		return
	end

	local minizedPanelVisible = self.minimizedPanel:isVisible()
	local textField = self.window:recursiveGetChildById("searchText")
	textField:clearText()

	g_client.setInputLockWidget(self.window)

	self:onResourceBalance()

	if minizedPanelVisible and self.queueCycleEvent then
		removeEvent(self.queueCycleEvent)
		self.rankedPanel:recursiveGetChildById("queuePanel"):setVisible(false)
		self.rankedPanel:recursiveGetChildById("searchingQueue"):setVisible(true)

		local timerField = self.window:recursiveGetChildById("availableSearchText")
		timerField:setText(getTimeInShortWords(self.queueWaitingTime))

		self.queueCycleEvent = cycleEvent(function()
			g_game.doThing(false)
			self:processQueueEvent()
			g_game.doThing(true)
		end, 1000)
	else
		self.minimizeButton:setVisible(false)
		self.prestigeWiki:setVisible(true)
		self.rankedPanel:recursiveGetChildById("queuePanel"):setVisible(true)
		self.rankedPanel:recursiveGetChildById("searchingQueue"):setVisible(false)
	end

	self:checkPunishmentTime()
	self.minimizedPanel:setVisible(false)

	-- General info
	local nameLabel = self.window:recursiveGetChildById("characterName")
	local outfitWidget = self.window:recursiveGetChildById("outfit")
	local prestigePointsLabel = self.window:recursiveGetChildById("currentlyPrestigeText")
	local prestigeProgress = self.window:recursiveGetChildById("prestigeProgress")
	local actualWinLabel = self.window:recursiveGetChildById("actualWinStreak")
	local divisionLabel = self.window:recursiveGetChildById("divisionRankLabel")

	nameLabel:setText(self.player:getName())
	outfitWidget:setOutfit(self.playerBasicData.currentOutfit)
	prestigePointsLabel:setText(self.playerBasicData.prestigePoints)
	divisionLabel:setText(PrestigeRankData[self.playerBasicData.division].name)
	actualWinLabel:setText(self.playerBasicData.winStreak)
	prestigeProgress:setPercent(GetPrestigePercent(self.playerBasicData.division, self.playerBasicData.prestigePoints))

	-- Current best records in current seasson
	local bestMapLabel = self.window:recursiveGetChildById("seasonBestMap")
	local bestStreakLabel = self.window:recursiveGetChildById("seasonBestStreak")
	local bestDivisionLabel = self.window:recursiveGetChildById("seasonBestDivision")
	local bestPrestigeLabel = self.window:recursiveGetChildById("seasonBestPrestige")

	bestMapLabel:setText(MapData[self.playerBasicData.bestMapId].name)
	bestStreakLabel:setText(string.format("%d Wins", self.playerBasicData.bestStreak))
	bestDivisionLabel:setText(PrestigeRankData[self.playerBasicData.bestDivision].name)
	bestPrestigeLabel:setText(self.playerBasicData.bestPrestigePoints)

	-- All time seasson best records
	local allTimeMapLabel = self.window:recursiveGetChildById("bestMap")
	local allTimeStreakLabel = self.window:recursiveGetChildById("bestStreak")
	local allTimeDivisionLabel = self.window:recursiveGetChildById("bestDivision")
	local allTimePrestigeLabel = self.window:recursiveGetChildById("bestPrestige")

	-- allTimeMapLabel:setText(MapData[self.playerBasicData.allTimeMapId].name)
	-- allTimeStreakLabel:setText(string.format("%d Wins", self.playerBasicData.allTimeStreak))
	-- allTimeDivisionLabel:setText(PrestigeRankData[self.playerBasicData.allTimeDivision].name)
	-- allTimePrestigeLabel:setText(self.playerBasicData.allTimePrestigePoints)

	-- Until the next season
	allTimeMapLabel:setText(MapData[self.playerBasicData.bestMapId].name)
	allTimeStreakLabel:setText(string.format("%d Wins", self.playerBasicData.bestStreak))
	allTimeDivisionLabel:setText(PrestigeRankData[self.playerBasicData.bestDivision].name)
	allTimePrestigeLabel:setText(self.playerBasicData.bestPrestigePoints)

	local announceTextLabel = self.rankedPanel:recursiveGetChildById("announceText")
	local divisionName = PrestigeRankData[self.playerBasicData.division].name

	local searchButton = self.rankedPanel:recursiveGetChildById("searchBattleButton")
	searchButton:setOn(self.queueServerStatus == QueueOpen and self.punishmentLeft == 0)

	if self.queueServerStatus == QueueOpen or self.queueServerStatus == QueueNoMoney then
		local message = string.format(QueueStatusTexts[self.queueServerStatus], divisionName, formatMoney(self.ticketPrice, "."))
		TypingAnimation:start("prestigeBattle", announceTextLabel, message, 20)
		searchButton:setTooltip(string.format(QueueStatusTooltips[self.queueServerStatus], formatMoney(self.ticketPrice, ".")))
	elseif self.queueServerStatus == QueueClose then
		local message = string.format(QueueStatusTexts[self.queueServerStatus], formatTimeBySecondsExtended(math.max(0, self.timeUntilNextQueue - 4)))
		TypingAnimation:start("prestigeBattle", announceTextLabel, message, 20)
		searchButton:setTooltip(QueueStatusTooltips[self.queueServerStatus])

		removeEvent(self.closedEvent)
		self.closedEvent = cycleEvent(function()
			self:processClosedEvent(announceTextLabel)
		end, 1000)

	elseif self.queueServerStatus == QueueLowLevel then
		local message = string.format(QueueStatusTexts[self.queueServerStatus], self.minLevel)
		TypingAnimation:start("prestigeBattle", announceTextLabel, message, 20)
		searchButton:setTooltip(string.format(QueueStatusTooltips[self.queueServerStatus], self.minLevel))
	else
		TypingAnimation:start("prestigeBattle", announceTextLabel, QueueStatusTexts[self.queueServerStatus], 20)
		searchButton:setTooltip(QueueStatusTooltips[self.queueServerStatus])
	end

	local playerRank = self.rankedPanel:recursiveGetChildById("playerRank")
	local currentDivision = self.rankedPanel:recursiveGetChildById("currentDivisionLabel")

	local divisionShader = PrestigeRankData[self.playerBasicData.division].shader or "text_staff"
	currentDivision:setImageShader(divisionShader)

	local imageFolder = "/images/game/ranked-queue/ranks/"

	playerRank:setImageSource(imageFolder .. PrestigeRankData[self.playerBasicData.division].img)
	currentDivision:setText(PrestigeRankData[self.playerBasicData.division].name)

	-- Set searching queue background based on rank
	local background0 = self.rankedPanel:recursiveGetChildById("background0")
	if background0 then
		local bgImagePath = "/images/game/ranked-queue/backgrounds/" .. PrestigeRankData[self.playerBasicData.division].bg0
		background0:setImageSource(bgImagePath)
	end

	local bannerBg = self.rankedPanel:recursiveGetChildById("bannerBg")
	if bannerBg then
		local bannerImagePath = "/images/game/ranked-queue/banners/" .. PrestigeRankData[self.playerBasicData.division].banner
		bannerBg:setImageSource(bannerImagePath)
	end

	self:onUpdateMatchCount()
end

function PrestigeBattle:onUpdateMatchCount()
	local matchCount = self.window:recursiveGetChildById("matches")
	matchCount:setText(string.format("%d / %d", self.currentMatchCount, self.dailyMatchCount))
end

function PrestigeBattle:processClosedEvent(label)
	self.timeUntilNextQueue = math.max(0, self.timeUntilNextQueue - 1)
	if TypingAnimation:hasEvent("prestigeBattle") then
		return true
	end

	local message = string.format(QueueStatusTexts[self.queueServerStatus], formatTimeBySecondsExtended(self.timeUntilNextQueue))
	label:setColorText(message)

	if self.timeUntilNextQueue <= 0 or not label:isVisible() then
		removeEvent(self.closedEvent)
		self.closedEvent = nil
	end
end

function PrestigeBattle:resetMatchFoundVariables()
	self.matchFoundWindow:setVisible(false)
	removeEvent(self.matchFoundCycleEvent)
	removeEvent(self.matchFoundProgressEvent)
	self.matchFoundCycleEvent = nil
	self.matchFoundProgressEvent = nil
	g_client.setInputLockWidget(self.window)

	if self.window:isVisible() and self.playerBasicData then
        scheduleEvent(function()
            self:restartQueueStatusAnimation()
        end, 10)
    end
end

---------------------
-- Queue Functions --
---------------------
function PrestigeBattle:onEnterQueue()
	if self.queueServerStatus ~= 0 or self.queueCycleEvent ~= nil then
		-- maybe display a pop-up warning about the queue
		return
	end

	TypingAnimation:stop("prestigeBattle")

	local queuePanel = self.rankedPanel:recursiveGetChildById("queuePanel")
	local searchPanel = self.rankedPanel:recursiveGetChildById("searchingQueue")

	self:onResourceBalance()

	queuePanel:setVisible(false)
	searchPanel:setVisible(true)
	self.minimizeButton:setVisible(true)
	self.prestigeWiki:setVisible(false)

	self.window:recursiveGetChildById("availableSearchText"):setText("00:00")

	self.queueWaitingTime = 0
	self.queuePlayerCount = 0
	self.queueCycleEvent = cycleEvent(function() self:processQueueEvent() end, 1000)

	local playerRank = searchPanel:recursiveGetChildById("playerRank")
	local currentDivision = searchPanel:recursiveGetChildById("currentDivisionLabel")
	local imageFolder = "/images/game/ranked-queue/ranks/"

	local divisionShader = PrestigeRankData[self.playerBasicData.division].shader or "text_staff"
	currentDivision:setImageShader(divisionShader)

	playerRank:setImageSource(imageFolder .. PrestigeRankData[self.playerBasicData.division].img)
	currentDivision:setText(PrestigeRankData[self.playerBasicData.division].name)

	-- Set searching queue background based on rank
	local background1 = searchPanel:recursiveGetChildById("background1")
	if background1 then
		local bgImagePath = "/images/game/ranked-queue/backgrounds/" .. PrestigeRankData[self.playerBasicData.division].bg1
		background1:setImageSource(bgImagePath)
	end

	local bannerBg1 = self.rankedPanel:recursiveGetChildById("bannerBg1")
	if bannerBg1 then
		local bannerImagePath = "/images/game/ranked-queue/banners/" .. PrestigeRankData[self.playerBasicData.division].banner
		bannerBg1:setImageSource(bannerImagePath)
	end

	local announceField = searchPanel:recursiveGetChildById("announceText")
	TypingAnimation:start("prestigeBattle", announceField, DefaultQueueText, 20)
end

function PrestigeBattle:manageOnLeaveQueue(closeWindow)
	if self.queueCycleEvent == nil then
		self:onCloseWindow()
		return
	end

	local wasMinimized = self.minimizedPanel:isVisible()
	self.window:hide()

	self.confirmLeaveQueue = g_ui.createWidget("ConfirmLeaveQueueWindow", g_ui.getRootWidget())
	self.confirmLeaveQueue:show(true)
	self.confirmLeaveQueue:raise()
	self.confirmLeaveQueue:focus()

	local confirmLabel = self.confirmLeaveQueue:recursiveGetChildById("confirmLabel")
	confirmLabel:setText(string.format("Are you sure you want to leave the queue?\nThe spent %s Gold Coins will not be refunded.", formatMoney(self.ticketPrice, ".")))

	local yesButton = self.confirmLeaveQueue:recursiveGetChildById("yesButton")
	local noButton = self.confirmLeaveQueue:recursiveGetChildById("noButton")

	g_client.setInputLockWidget(self.confirmLeaveQueue)

	local yesFunction = function()
		if closeWindow then
			g_game.sendClosePrestigeBattle()
			self:onCloseWindow()
		else
			g_game.sendManagePrestigeArenaQueue(true)
			if wasMinimized then
				g_client.setInputLockWidget(nil)
			else
				g_client.setInputLockWidget(self.window)
			end
			self.minimizeButton:setVisible(false)
			self.prestigeWiki:setVisible(true)
		end

		self.confirmLeaveQueue:destroy()
		self.confirmLeaveQueue = nil
	end

	local noFunction = function()
		if not wasMinimized then
			self.window:show(true)
			self.minimizeButton:setVisible(true)
			self.prestigeWiki:setVisible(false)
			g_client.setInputLockWidget(self.window)
		else
			g_client.setInputLockWidget(nil)
		end

		self.confirmLeaveQueue:destroy()
		self.confirmLeaveQueue = nil
	end

	yesButton.onClick = yesFunction
	noButton.onClick = noFunction

	self.confirmLeaveQueue.onEscape = noFunction
	self.confirmLeaveQueue.onEnter = yesFunction
end

function PrestigeBattle:onLeaveQueue()
	if g_game.isOnline() then
		self.rankedPanel:recursiveGetChildById("queuePanel"):setVisible(true)
		self.rankedPanel:recursiveGetChildById("searchingQueue"):setVisible(false)
		self.window:recursiveGetChildById("availableSearchText"):setText("00:00")
		self.minimizeButton:setVisible(false)
		self.minimizedPanel:setVisible(false)
		self.prestigeWiki:setVisible(true)

		scheduleEvent(function()
			self:restartQueueStatusAnimation()
		end, 10)
	end

	removeEvent(self.queueCycleEvent)
	self.queueCycleEvent = nil
	self.queueWaitingTime = 0
	self.queuePlayerCount = 0
end

function PrestigeBattle:processQueueEvent(externalTimer)
	if self.queueServerStatus ~= 0 or not g_game.isOnline() then
		g_game.sendManagePrestigeArenaQueue(true)
		return
	end

	self.queueWaitingTime = self.queueWaitingTime + 1

	local timerField = nil
	if externalTimer then
		timerField = self.minimizedPanel:recursiveGetChildById("availableSearchText")
	else
		timerField = self.window:recursiveGetChildById("availableSearchText")
	end

	timerField:setText(getTimeInShortWords(self.queueWaitingTime))

	if self.queueWaitingTime == self.queueMaxWaitingTime / 1000 then
		if not externalTimer then
			local searchPanel = self.rankedPanel:recursiveGetChildById("searchingQueue")
			local announceField = searchPanel:recursiveGetChildById("announceText")
			local message = "Since the queue has timed out, your matchmaking status has been updated.\nYou can now be matched with opponents up to [color=#ff9854]two divisions above or below your division[/color]."
			TypingAnimation:start("prestigeBattle", announceField, message, 20)
		else
			self:showQueueLimitNotification()
		end
	end
end

function PrestigeBattle:showQueueLimitNotification()
	if self.queueLimitPopup then
		self.queueLimitPopup:destroy()
	end

	self.queueLimitPopup = g_ui.createWidget("InfoWarningWindow", g_ui.getRootWidget())
	self.queueLimitPopup:show(true)
	self.queueLimitPopup:raise()
	self.queueLimitPopup:focus()

	local messageLabel = self.queueLimitPopup:recursiveGetChildById("messageLabel")
	if messageLabel then
		messageLabel:setColorText("Since the queue has timed out, your matchmaking status has been updated.\nYou can now be matched with opponents up to [color=#ff9854]two divisions above or below your division[/color].")
	end

	local okButton = self.queueLimitPopup:recursiveGetChildById("okButton")
	if okButton then
		okButton.onClick = function()
			self.queueLimitPopup:destroy()
			self.queueLimitPopup = nil
		end
	end

	self.queueLimitPopup.onEnter = function()
		self.queueLimitPopup:destroy()
		self.queueLimitPopup = nil
	end

	self.queueLimitPopup.onEscape = function()
		self.queueLimitPopup:destroy()
		self.queueLimitPopup = nil
	end

	g_window.flash()
	g_window.show()
end

function PrestigeBattle:onMatchFound()
	removeEvent(self.queueCycleEvent)
	self.queueCycleEvent = nil

	TypingAnimation:stop("prestigeBattle")

	if self.confirmLeaveQueue then
		self.confirmLeaveQueue:destroy()
		self.confirmLeaveQueue = nil
		g_client.setInputLockWidget(self.window)
	end

	if self.queueLimitPopup then
		self.queueLimitPopup:destroy()
		self.queueLimitPopup = nil
	end

	self.highScoresPanel:recursiveGetChildById("rankBox"):destroyCurrentMenu()
	self.highScoresPanel:recursiveGetChildById("vocationBox"):destroyCurrentMenu()
	self.highScoresPanel:recursiveGetChildById("worldBox"):destroyCurrentMenu()

	self.minimizeButton:setVisible(false)
	self.minimizedPanel:setVisible(false)
	self.prestigeWiki:setVisible(true)

    g_client.setInputLockWidget(self.matchFoundWindow)

	self.window:hide()
	self.matchFoundWindow:show(true)

	self.matchFoundTimer = 30
	self.matchFoundProgress = 30.0

	local timerLabel = self.matchFoundWindow:recursiveGetChildById("acceptMatchTimerText")
	local hourGlass = self.matchFoundWindow:recursiveGetChildById("hourglassIcon")
	local timerProgress = self.matchFoundWindow:recursiveGetChildById("acceptMatchTimerProgress")
	local acceptButton = self.matchFoundWindow:recursiveGetChildById("acceptButton")
	local cancelButton = self.matchFoundWindow:recursiveGetChildById("cancelButton")

	acceptButton:setText("Accept")
	acceptButton:setEnabled(true)
	cancelButton:setEnabled(true)

	timerLabel:setText("30 second(s) left")
	timerLabel:setColor("$var-text-cip-color")
	hourGlass:setImageSource("/images/game/battlepass/battlepass-hourglass")
	timerProgress:setPercent(100)

	self.matchFoundCycleEvent = cycleEvent(function() self:processMatchAcceptEvent(timerLabel, hourGlass) end, 1000)
	self.matchFoundProgressEvent = cycleEvent(function() self:updateMatchAcceptProgress(timerProgress) end, 100)

	g_window.flash()
	g_window.show()
end

function PrestigeBattle:processMatchAcceptEvent(timerLabel, hourGlass)
	if not self.matchFoundWindow:isVisible() or self.matchFoundTimer == 0 then
		return
	end

	self.matchFoundTimer = math.max(0, self.matchFoundTimer - 1)

	local imagePath = "/images/game/battlepass/"
	local textColor = self.matchFoundTimer > 10 and "$var-text-cip-color" or "$var-text-cip-store-red"
	local hourglassColor = self.matchFoundTimer > 10 and (imagePath .. "battlepass-hourglass") or (imagePath .. "battlepass-hourglass-red")

	timerLabel:setText(string.format("%d second(s) left", self.matchFoundTimer))
	timerLabel:setColor(textColor)
	hourGlass:setImageSource(hourglassColor)
end

function PrestigeBattle:updateMatchAcceptProgress(timerProgress)
	if not self.matchFoundWindow:isVisible() then
		return
	end

	self.matchFoundProgress = math.max(0, self.matchFoundProgress - 0.1)
	local percent = (self.matchFoundProgress / 30.0) * 100
	timerProgress:setPercent(percent)
end

function PrestigeBattle:onCloseWindow()
	g_game.sendClosePrestigeBattle()
	self:onLeaveQueue()
	g_client.setInputLockWidget(nil)
	hide()
end

function PrestigeBattle:onMinimizeWindow()
	self.window:hide()
	self.minimizedPanel:setVisible(true)
	g_ui.setInputLockWidget(nil)

	removeEvent(self.queueCycleEvent)

	local timerField = self.minimizedPanel:recursiveGetChildById("availableSearchText")
	timerField:setText(getTimeInShortWords(self.queueWaitingTime))

	self.queueCycleEvent = cycleEvent(function() self:processQueueEvent(true) end, 1000)

	local playerRank = self.minimizedPanel:recursiveGetChildById("playerRank")
	local currentDivision = self.minimizedPanel:recursiveGetChildById("currentDivisionLabel")
	local imageFolder = "/images/game/ranked-queue/ranks/"

	local divisionShader = PrestigeRankData[self.playerBasicData.division].shader or "text_staff"
	currentDivision:setImageShader(divisionShader)

	playerRank:setImageSource(imageFolder .. PrestigeRankData[self.playerBasicData.division].img)
	currentDivision:setText(PrestigeRankData[self.playerBasicData.division].name)

	local bannerBg1 = self.minimizedPanel:recursiveGetChildById("bannerBg1")
	local bannerImagePath = "/images/game/ranked-queue/banners/" .. PrestigeRankData[self.playerBasicData.division].banner
	bannerBg1:setImageSource(bannerImagePath)

end

function PrestigeBattle:closeMatchAcceptWindow(accepted)
	local acceptButton = self.matchFoundWindow:recursiveGetChildById("acceptButton")
	local cancelButton = self.matchFoundWindow:recursiveGetChildById("cancelButton")

	if accepted then
		acceptButton:setText("Accepted")
		acceptButton:setEnabled(false)
		cancelButton:setEnabled(false)
	else
		acceptButton:setEnabled(false)
		cancelButton:setEnabled(false)
	end

	g_game.sendAwnserMatchFound(accepted and 1 or 2)
end

function PrestigeBattle:configureLiveMatchFilters()
	local rankBox = self.castWindow:recursiveGetChildById("rankBox")
	rankBox:clearOptions()
	rankBox:addOption("All Ranks", nil, true)
	for _, data in ipairs(PrestigeRankData) do
		rankBox:addOption(data.name, nil, true)
	end

	local vocations = {"Druid", "Sorcerer", "Paladin", "Knight", "Monk"}
	local vocBox = self.castWindow:recursiveGetChildById("vocBox")
	vocBox:clearOptions()
	vocBox:addOption("All Vocations", nil, true)
	for i = 1, #vocations do
		vocBox:addOption(vocations[i], nil, true)
	end
end

function PrestigeBattle:checkFilters(liveData)
    local rankBox = self.castWindow:recursiveGetChildById("rankBox")
    local vocBox = self.castWindow:recursiveGetChildById("vocBox")

    local selectedRank = rankBox:getCurrentOption().text
    local selectedVocation = vocBox:getCurrentOption().text

	local rankMatch = false
	local vocationMatch = false

	if selectedRank == "All Ranks" then
		rankMatch = true
	else
		local player1Rank = PrestigeRankData[liveData.player1Division].name
		local player2Rank = PrestigeRankData[liveData.player2Division].name
		if player1Rank == selectedRank or player2Rank == selectedRank then
			rankMatch = true
		end
	end

	if selectedVocation == "All Vocations" then
		vocationMatch = true
	else
		local player1Vocation = g_game.getVocationNameBase(liveData.player1Vocation)
		local player2Vocation = g_game.getVocationNameBase(liveData.player2Vocation)

		if player1Vocation == selectedVocation or player2Vocation == selectedVocation then
			vocationMatch = true
		end
	end

	if not (rankMatch and vocationMatch) then
		return false
	end

	return true
end

function PrestigeBattle:displayLiveMatches()
	if not self.castWindow:isVisible() then
		self.castWindow:show(true)
		self.castWindow:focus()
	end

	g_ui.setInputLockWidget(self.castWindow)

	local castListWidget = self.castWindow:recursiveGetChildById("castList")
	castListWidget:destroyChildren()

	local watchButton = self.castWindow:recursiveGetChildById("watchButton")
	watchButton:setVisible(false)

	for _, liveData in pairs(self.liveMatchesMap) do
		if not self:checkFilters(liveData) then
			goto continue
		end

		local widget = g_ui.createWidget("CastWidget", castListWidget)

		widget:recursiveGetChildById("playerOutfit1"):setOutfit(liveData.player1Outfit)
		widget:recursiveGetChildById("playerOutfit2"):setOutfit(liveData.player2Outfit)

		widget:recursiveGetChildById("mapNameLabel"):setText(MapData[liveData.mapId].name)

		local bgImagePath = "/images/game/ranked-queue/cast/cast-bg-" .. MapData[liveData.mapId].img
		widget:setImageSource(bgImagePath)

		widget:recursiveGetChildById("playerRank1"):setImageSource("/images/game/ranked-queue/rank-icons/" .. PrestigeRankData[liveData.player1Division].img)
		widget:recursiveGetChildById("playerRank1"):setTooltip(PrestigeRankData[liveData.player1Division].name)
		
		widget:recursiveGetChildById("playerRank2"):setImageSource("/images/game/ranked-queue/rank-icons/" .. PrestigeRankData[liveData.player2Division].img)
		widget:recursiveGetChildById("playerRank2"):setTooltip(PrestigeRankData[liveData.player2Division].name)

		local baseText = "Name: %s\nLevel: %s\nVocation: %s\nDivision: %s\nPrestige Points: %s"
		local player1Tooltip = string.format(baseText, liveData.player1Name, liveData.player1Level, g_game.getVocationName(liveData.player1Vocation), PrestigeRankData[liveData.player1Division].name, liveData.player1PrestigePoints)
		widget:recursiveGetChildById("tooltipLabel1"):setTooltip(player1Tooltip)

		local player2Tooltip = string.format(baseText, liveData.player2Name, liveData.player2Level, g_game.getVocationName(liveData.player2Vocation), PrestigeRankData[liveData.player2Division].name, liveData.player2PrestigePoints)
		widget:recursiveGetChildById("tooltipLabel2"):setTooltip(player2Tooltip)
		widget.liveCache = liveData

		widget.onDoubleClick = function()
            if self.canWatchliveMatch then
                self.window:hide()
                g_game.sendWatchPrestigeArenaLiveMatch(widget.liveCache.instanceId)
            end
        end

	    ::continue::
	end

	castListWidget:focusChild(nil)
	castListWidget.onChildFocusChange = function(_, focused)
		if focused then
			if self.canWatchliveMatch then
				watchButton:setVisible(true)
			end

			watchButton.onClick = function()
				self.window:hide()
				g_game.sendWatchPrestigeArenaLiveMatch(focused.liveCache.instanceId)
			end
		else
			watchButton:setVisible(false)
		end
	end

	local noCastsLabel = self.castWindow:recursiveGetChildById("noCastsLabel")
	noCastsLabel:setVisible(castListWidget:getChildCount() == 0)
end

function PrestigeBattle:displayPlayerHistory()

	local historyList = self.playerHistory:recursiveGetChildById("playerHistoryContent")
	historyList:destroyChildren()

	for _, entry in pairs(self.playerHistoryEntries) do
		local widget = g_ui.createWidget("PlayerHistoryWidget", historyList)
		widget:setBackgroundColor((_ % 2 == 0) and "$var-textlist-even" or '$var-textlist-odd')

		local color = "$var-text-cip-color"
		if entry.state == 1 then
			color = "$var-text-cip-store-red"
		elseif entry.state == 2 then
			color = "$var-text-cip-color-green"
		end

		local dateLabel = widget:recursiveGetChildById("date")
		dateLabel:setText(os.date("%d/%m/%Y", entry.timestamp))
		dateLabel:setTooltip(os.date("%d/%m/%Y - %H:%M", entry.timestamp))

		local adversaryName = widget:recursiveGetChildById("adversaryName")
		adversaryName:setText(string.format("%s", entry.adversaryName))

		local winnerOrLooserColor = widget:recursiveGetChildById("winnerOrLooserColor")
		winnerOrLooserColor:setBackgroundColor(color)
		if entry.state == 0 then
			winnerOrLooserColor:setTooltip(tr("Draw"))
		elseif entry.state == 1 then
			winnerOrLooserColor:setTooltip(tr("Defeat"))
		else
			winnerOrLooserColor:setTooltip(tr("Victory"))
		end

		local adversaryPrestige = widget:recursiveGetChildById("adversaryPrestige")
		adversaryPrestige:setText(string.format("%s", (entry.adversaryPrestige)))

		local level = widget:recursiveGetChildById("level")
		level:setText(string.format("%d", entry.adversaryLevel))

		local voc = widget:recursiveGetChildById("voc")
		local vocationName = g_game.getVocationName(entry.adversaryVocation)
		voc:setText(vocationName)

		local mapLabel = widget:recursiveGetChildById("map")
		mapLabel:setText(MapData[entry.mapId].name)

		local resultLabel = widget:recursiveGetChildById("result")

		if entry.prestigePoints > 0 then
			local text = entry.prestigePoints
			if entry.state == 1 then
				text = "-" .. entry.prestigePoints
			else
				text = "+" .. entry.prestigePoints
			end

			resultLabel:setText(text)
			resultLabel:setColor(color)
		else
			resultLabel:setText(entry.prestigePoints)
		end
	end
end

function PrestigeBattle:sendPrestigeInspect()
	local textField = self.window:recursiveGetChildById("searchText")
	if not textField or #textField:getText() == 0 then
		return
	end

	g_game.sendRequestPrestigeInspect(textField:getText())
end

function PrestigeBattle:showPrestigeInspect(data, fromPrestigeWindow)
	if self.prestigeInspectWindow then
		self.prestigeInspectWindow:destroy()
	end

	if fromPrestigeWindow then
		local textField = self.window:recursiveGetChildById("searchText")
		textField:clearText()
		self.window:hide()
	end

	self.prestigeInspectWindow = g_ui.createWidget("PrestigePlayerInspect", m_interface.getRootPanel())
	self.prestigeInspectWindow:show(true)

	self.prestigeInspectWindow.fromPrestigeWindow = fromPrestigeWindow or false

	g_client.setInputLockWidget(self.prestigeInspectWindow)

	local closeButton = self.prestigeInspectWindow:recursiveGetChildById("close")
	if closeButton then
		closeButton.onClick = function()
			if self.prestigeInspectWindow.fromPrestigeWindow then
				self.window:show(true)
				g_client.setInputLockWidget(self.window)
			else
				g_client.setInputLockWidget(nil)
			end
			self.prestigeInspectWindow:destroy()
			self.prestigeInspectWindow = nil
		end
	end

	self.prestigeInspectWindow.onEscape = function()
		if self.prestigeInspectWindow.fromPrestigeWindow then
			self.window:show(true)
			g_client.setInputLockWidget(self.window)
		else
			g_client.setInputLockWidget(nil)
		end
		self.prestigeInspectWindow:destroy()
		self.prestigeInspectWindow = nil
	end

	-- General info
	local nameLabel = self.prestigeInspectWindow:recursiveGetChildById("characterName")
	local worldLabel = self.prestigeInspectWindow:recursiveGetChildById("worldName")
	local outfitWidget = self.prestigeInspectWindow:recursiveGetChildById("outfit")
	local prestigePointsLabel = self.prestigeInspectWindow:recursiveGetChildById("currentlyPrestigeText")
	local prestigeProgress = self.prestigeInspectWindow:recursiveGetChildById("prestigeProgress")
	local actualWinLabel = self.prestigeInspectWindow:recursiveGetChildById("actualWinStreak")
	local divisionLabel = self.prestigeInspectWindow:recursiveGetChildById("divisionRankLabel")

	nameLabel:setText(data.playerName)
	worldLabel:setText(data.worldName)
	outfitWidget:setOutfit(data.outfit)
	prestigePointsLabel:setText(data.record.prestigePoints)
	divisionLabel:setText(PrestigeRankData[data.record.division].name)
	actualWinLabel:setText(data.record.winStreak)
	prestigeProgress:setPercent(GetPrestigePercent(data.record.division, data.record.prestigePoints))

	-- Current best records in current seasson
	local bestMapLabel = self.prestigeInspectWindow:recursiveGetChildById("seasonBestMap")
	local bestStreakLabel = self.prestigeInspectWindow:recursiveGetChildById("seasonBestStreak")
	local bestDivisionLabel = self.prestigeInspectWindow:recursiveGetChildById("seasonBestDivision")
	local bestPrestigeLabel = self.prestigeInspectWindow:recursiveGetChildById("seasonBestPrestige")

	bestMapLabel:setText(MapData[data.record.bestMapId].name)
	bestStreakLabel:setText(string.format("%d Wins", data.record.bestStreak))
	bestDivisionLabel:setText(PrestigeRankData[data.record.bestDivision].name)
	bestPrestigeLabel:setText(data.record.bestPrestigePoints)

	-- All time seasson best records
	local allTimeMapLabel = self.prestigeInspectWindow:recursiveGetChildById("bestMap")
	local allTimeStreakLabel = self.prestigeInspectWindow:recursiveGetChildById("bestStreak")
	local allTimeDivisionLabel = self.prestigeInspectWindow:recursiveGetChildById("bestDivision")
	local allTimePrestigeLabel = self.prestigeInspectWindow:recursiveGetChildById("bestPrestige")

	-- allTimeMapLabel:setText(MapData[self.playerBasicData.allTimeMapId].name)
	-- allTimeStreakLabel:setText(string.format("%d Wins", self.playerBasicData.allTimeStreak))
	-- allTimeDivisionLabel:setText(PrestigeRankData[self.playerBasicData.allTimeDivision].name)
	-- allTimePrestigeLabel:setText(self.playerBasicData.allTimePrestigePoints)

	-- Until the next season
	allTimeMapLabel:setText(MapData[data.record.bestMapId].name)
	allTimeStreakLabel:setText(string.format("%d Wins", data.record.bestStreak))
	allTimeDivisionLabel:setText(PrestigeRankData[data.record.bestDivision].name)
	allTimePrestigeLabel:setText(data.record.bestPrestigePoints)

	local playerRank = self.prestigeInspectWindow:recursiveGetChildById("playerRank")
	local imageFolder = "/images/game/ranked-queue/ranks/"

	playerRank:setImageSource(imageFolder .. PrestigeRankData[data.record.division].img)
end

function PrestigeBattle:onResourceBalance()
    if not self.window or not self.window:isVisible() then
        return
    end

    -- Request the resources to ensure we have the latest values
    g_game.doThing(false)
    g_game.requestResource(ResourceBank)
    g_game.requestResource(ResourceInventary)
    g_game.doThing(true)

    local moneyTooltip = {}
    local player = g_game.getLocalPlayer()
    if not player then return end

    local playerBank = player:getResourceValue(ResourceBank)
    local playerInventory = player:getResourceValue(ResourceInventary)
	local goldCoinsLabel = self.window:recursiveGetChildById('goldCoins')

    setStringColor(moneyTooltip, "Cash: " .. comma_value(playerInventory), "#3f3f3f")
    setStringColor(moneyTooltip, " $", "#f7e6fe")
    setStringColor(moneyTooltip, "\nBank: " .. comma_value(playerBank), "#3f3f3f")
    setStringColor(moneyTooltip, " $", "#f7e6fe")

    goldCoinsLabel:setText(comma_value(playerBank + playerInventory))
    goldCoinsLabel:setTooltip(moneyTooltip)
end

function PrestigeBattle:restartQueueStatusAnimation()
    if not self.window:isVisible() or not self.playerBasicData then
        return
    end
    
    local announceTextLabel = self.rankedPanel:recursiveGetChildById("announceText")
    if not announceTextLabel then
        return
    end
    
    TypingAnimation:stop("prestigeBattle")
    
    local divisionName = PrestigeRankData[self.playerBasicData.division].name
    local message = ""
    if self.queueServerStatus == QueueOpen or self.queueServerStatus == QueueNoMoney then
        message = string.format(QueueStatusTexts[self.queueServerStatus], divisionName, formatMoney(self.ticketPrice, "."))
    elseif self.queueServerStatus == QueueClose then
        message = string.format(QueueStatusTexts[self.queueServerStatus], formatTimeBySecondsExtended(math.max(0, self.timeUntilNextQueue - 4)))
    elseif self.queueServerStatus == QueueLowLevel then
        message = string.format(QueueStatusTexts[self.queueServerStatus], self.minLevel)
    else
        message = QueueStatusTexts[self.queueServerStatus] or DefaultQueueText
    end
    
    TypingAnimation:start("prestigeBattle", announceTextLabel, message, 20)
end