MapPhase = { 
	CONFIG = {
		TIMER_DURATION = 30,
		FADE_IN_DURATION = 300,
		FADE_OUT_DURATION = 1000,
		CLEANUP_DELAY = 1100,
		MAP_FADE_DELAY = 500,
		MAP_FADE_IN_DURATION = 500,
		MAP_DISPLAY_END = 0,
		PROGRESS_UPDATE_INTERVAL = 100,
		TIMER_UPDATE_INTERVAL = 1000,
		BLINK_CYCLES = 6,
		INITIAL_BLINK_DELAY = 200,
		BLINK_STEP_INCREMENT = 20,
		TIMER_WARNING_THRESHOLD = 10,
		BORDER_WIDTH = 2,
		WINNER_BORDER_WIDTH = 2,
		WINNER_BLINK_DURATION = 2000,
		WINNER_BLINK_INTERVAL = 200,
	},

	COLORS = {
		TIMER_NORMAL = "$var-text-cip-color",
		TIMER_WARNING = "$var-text-cip-store-red",
		BORDER_HIGHLIGHT = "#FFFFFF",
		BORDER_WINNER = "#00d924",
		TEXT_PLAYER_TURN = "#0ce211",
		TEXT_OPPONENT_TURN = "#f72828"
	},

	TEXTS = {
		DEFAULT_ANNOUNCE = "Here, you will select a map to ban for the upcoming battle...\nYour opponent will also ban a map, so be ready to adapt to their choice\nand adjust your strategy accordingly.",
		PLAYER_TURN = " It's your turn to ban a map.",
		OPPONENT_TURN = " Your opponent is banning a map.",
		SELECTING_MAP = "Selecting Map...",
		WINNER_MAP_PREFIX = "Winner Map: ",
		TIMER_FORMAT = "%d second(s) left"
	},

	PATHS = {
		MAP_IMAGES = "/images/game/ranked-queue/map-images/",
		BATTLEPASS_IMAGES = "/images/game/battlepass/"
	},

	mapWindow = nil,
	timerLabel = nil,
	timerProgress = nil,
	announceText = nil,
	hourglassIcon = nil,
	prestigeMaps = {},
	availableMaps = {},

	winnerMapIndex = 0,
	winnerMap = 0,
	canBanMap = false,

	banMapCycleEvent = nil,
	banMapProgressEvent = nil,

	blinkIndex = 0,
	blinkLastWidget = nil,
	blinkWinnerIndex = 0,
	blinkSteps = {},
	blinkStepIndex = 1,

	banMapTimer = 30,
	banMapProgress = 30.0
}

function MapPhase:init()
	self.banMapTimer = self.CONFIG.TIMER_DURATION
	self.banMapProgress = self.CONFIG.TIMER_DURATION
end

function MapPhase:displayMaps(prestigeMaps, canBanMap)
	MapPhase:init()
	if not self.mapWindow then
		self.mapWindow = g_ui.createWidget("BanMapWindow", g_ui.getRootWidget())
		self.timerLabel = self.mapWindow:recursiveGetChildById("banMapTimerText")
		self.timerProgress = self.mapWindow:recursiveGetChildById("banMapTimerProgress")
		self.announceText = self.mapWindow:recursiveGetChildById("announceText")
		self.hourglassIcon = self.mapWindow:recursiveGetChildById("hourglassIcon")
	end
	
	g_client.setInputLockWidget(self.mapWindow)

	self.canBanMap = canBanMap
	self.prestigeMaps = prestigeMaps
	PrestigeBattle.matchFoundWindow:hide()
	
	local mapGrid = self.mapWindow:recursiveGetChildById("mapsGrid")
	local panelEmpty = #mapGrid:getChildren() == 0

	if panelEmpty then
		g_effects.fadeIn(self.mapWindow, self.CONFIG.FADE_IN_DURATION)
	end

	local totalDelayTime = 0
	local bannedCount = 0
	for i, map in pairs(prestigeMaps) do
		local timer = panelEmpty and (self.CONFIG.MAP_FADE_DELAY * i) or 0
		if timer >= totalDelayTime then
			totalDelayTime = timer
		end

		if map.banned then
			bannedCount = bannedCount + 1
		end

		scheduleEvent(function()
			local widget = mapGrid:getChildById("map_" .. map.id)
			if not widget then
				widget = g_ui.createWidget('MapBackground', mapGrid, "map_" .. map.id)
			end

			local imgName = MapData[map.id].img
            if map.banned then
                imgName = imgName .. "-banned"
            end
            widget.mapImage:setImageSource(self.PATHS.MAP_IMAGES .. imgName)
			widget.mapName:setText(MapData[map.id].name)
			widget.mapData = map
			widget.onClick = function() self:onBanMap(widget) end

			if panelEmpty then
				g_effects.fadeIn(widget, self.CONFIG.MAP_FADE_IN_DURATION)
			end

		end, timer)
	end

	removeEvent(self.banMapCycleEvent)
	removeEvent(self.banMapProgressEvent)

	if bannedCount >= 2 then
		-- Already reached the ban limit
		self.canBanMap = false
		self.timerLabel:setText(self.TEXTS.SELECTING_MAP)
		self.timerLabel:setColor(self.COLORS.TIMER_NORMAL)
		self.announceText:setText(self.TEXTS.DEFAULT_ANNOUNCE)
		self.timerProgress:setPercent(0)
		self.hourglassIcon:setVisible(false)
		return
	end

	self.CONFIG.MAP_DISPLAY_END = g_clock.millis() + (totalDelayTime + self.CONFIG.MAP_FADE_IN_DURATION)

	scheduleEvent(function()
		self.banMapTimer = self.CONFIG.TIMER_DURATION
		self.banMapProgress = self.CONFIG.TIMER_DURATION

		self.timerLabel:setText(string.format(self.TEXTS.TIMER_FORMAT, self.CONFIG.TIMER_DURATION))
		self.timerProgress:setPercent(100)

		self.banMapCycleEvent = cycleEvent(function() self:processBanMapEvent() end, self.CONFIG.TIMER_UPDATE_INTERVAL)
		self.banMapProgressEvent = cycleEvent(function() self:updateBanMapProgress() end, self.CONFIG.PROGRESS_UPDATE_INTERVAL)

		self:updateAnnounceText()
	end, (totalDelayTime + self.CONFIG.MAP_FADE_IN_DURATION))
end

function MapPhase:updateAnnounceText()
	local baseText = self.TEXTS.DEFAULT_ANNOUNCE
	local statusText = ""
	local statusColor = ""

	if self.canBanMap then
		statusText = self.TEXTS.PLAYER_TURN
		statusColor = self.COLORS.TEXT_PLAYER_TURN
	else
		statusText = self.TEXTS.OPPONENT_TURN
		statusColor = self.COLORS.TEXT_OPPONENT_TURN
	end

	self.announceText:setColorText(baseText .. "[color=" .. statusColor .. "]" .. statusText .. "[/color]")
end

function MapPhase:onBanMap(mapWidget)
	if g_clock.millis() < self.CONFIG.MAP_DISPLAY_END then
		return
	end

	if mapWidget.mapData.banned or not self.canBanMap then
		return
	end

	g_game.sendBanPrestigeArenaMap(mapWidget.mapData.id)
end

function MapPhase:displayWinnerMap(winnerId)
	removeEvent(self.banMapCycleEvent)
	removeEvent(self.banMapProgressEvent)
	self.banMapCycleEvent = nil
	self.banMapProgressEvent = nil

	self.timerLabel:setText(self.TEXTS.SELECTING_MAP)
	self.timerLabel:setColor(self.COLORS.TIMER_NORMAL)
	self.timerProgress:setPercent(0)
	self.hourglassIcon:setVisible(false)

	self.availableMaps = {}
	self.winnerMapIndex = 0

	local mapGrid = self.mapWindow:recursiveGetChildById("mapsGrid")

	for i, widget in pairs(mapGrid:getChildren()) do
		if not widget.mapData.banned then
			table.insert(self.availableMaps, widget)
		end
	end

	for i, widget in pairs(self.availableMaps) do
		if widget.mapData.id == winnerId then
			self.winnerMapIndex = i
			break
		end
	end

	self.winnerMap = winnerId
	self:getRandomMap()
end

function MapPhase:getRandomMap()
	local maps = self.availableMaps
	local total = #maps

	self.blinkIndex = 0
	self.blinkLastWidget = nil
	self.blinkWinnerIndex = self.winnerMapIndex

	local totalCycles = self.CONFIG.BLINK_CYCLES * total
	local stopAt = (self.winnerMapIndex - 1 + total) % total

	local totalSteps = totalCycles + stopAt + 1
	self.blinkSteps = {}
	self.blinkStepIndex = 1

	local delay = self.CONFIG.INITIAL_BLINK_DELAY

	for i = 1, totalSteps do
		table.insert(self.blinkSteps, delay)
		delay = delay + self.CONFIG.BLINK_STEP_INCREMENT
	end

	self:runBlinkStep()
end

function MapPhase:runBlinkStep()
	local maps = self.availableMaps
	local total = #maps

	if self.blinkLastWidget then
		self.blinkLastWidget:setBorderWidth(0)
	end

	self.blinkIndex = self.blinkIndex + 1
	if self.blinkIndex > total then
		self.blinkIndex = 1
	end

	local currentWidget = maps[self.blinkIndex]
	currentWidget:setBorderColor(self.COLORS.BORDER_HIGHLIGHT)
	currentWidget:setBorderWidth(self.CONFIG.BORDER_WIDTH)
	self.blinkLastWidget = currentWidget

	if self.blinkStepIndex < #self.blinkSteps then
		local nextDelay = self.blinkSteps[self.blinkStepIndex]
		self.blinkStepIndex = self.blinkStepIndex + 1

		scheduleEvent(function()
			self:runBlinkStep()
		end, nextDelay)
	else
		scheduleEvent(function() 
			self:displayWinner(maps)	
		end, 500)
	end
end

function MapPhase:displayWinner(maps)
    for i, map in pairs(maps) do
        if i == self.winnerMapIndex then
            map:getParent():moveChildToIndex(map, 3)
            map:setBorderColor(self.COLORS.BORDER_WINNER)
            g_effects.startBorderBlink(map, self.CONFIG.WINNER_BLINK_DURATION, self.CONFIG.WINNER_BLINK_INTERVAL, self.CONFIG.WINNER_BORDER_WIDTH)
            self.timerLabel:setText(self.TEXTS.WINNER_MAP_PREFIX .. MapData[self.winnerMap].name)
            map.mapImage:setImageSource(self.PATHS.MAP_IMAGES .. MapData[self.winnerMap].img)
        else
            local imgName = MapData[map.mapData.id].img .. "-banned"
            map.mapImage:setImageSource(self.PATHS.MAP_IMAGES .. imgName)
        end
    end
end

function MapPhase:processBanMapEvent()
	if not self.mapWindow:isVisible() or self.banMapTimer == 0 then
		return
	end

	self.banMapTimer = math.max(0, self.banMapTimer - 1)

	local textColor = self.banMapTimer > self.CONFIG.TIMER_WARNING_THRESHOLD and self.COLORS.TIMER_NORMAL or self.COLORS.TIMER_WARNING

	self.timerLabel:setText(string.format(self.TEXTS.TIMER_FORMAT, self.banMapTimer))
	self.timerLabel:setColor(textColor)
end

function MapPhase:updateBanMapProgress()
	if not self.mapWindow:isVisible() then
		return
	end

	self.banMapProgress = math.max(0, self.banMapProgress - 0.1)
	local percent = (self.banMapProgress / self.CONFIG.TIMER_DURATION) * 100
	self.timerProgress:setPercent(percent)
end

function MapPhase:offline()
	if self.mapWindow then
		self.mapWindow:destroy()
	end

	removeEvent(self.banMapCycleEvent)
	removeEvent(self.banMapProgressEvent)

	self.mapWindow = nil
	self.timerLabel = nil
	self.timerProgress = nil
	self.announceText = nil
	self.hourglassIcon = nil
	self.prestigeMaps = {}
	self.availableMaps = {}
	self.winnerMapIndex = 0
	self.winnerMap = 0
	self.canBanMap = false
	self.banMapCycleEvent = nil
	self.banMapProgressEvent = nil
	self.blinkIndex = 0
	self.blinkLastWidget = nil
	self.blinkWinnerIndex = 0
	self.blinkSteps = {}
	self.blinkStepIndex = 1
	self.banMapTimer = self.CONFIG.TIMER_DURATION
	self.banMapProgress = self.CONFIG.TIMER_DURATION

	g_client.setInputLockWidget(nil)
end

function MapPhase:reset()
	if self.mapWindow then
		g_effects.fadeOut(self.mapWindow, self.CONFIG.FADE_OUT_DURATION)
	end

	removeEvent(self.banMapCycleEvent)
	removeEvent(self.banMapProgressEvent)

	scheduleEvent(function()
		if self.mapWindow then
			self.mapWindow:destroy()
		end

		self.mapWindow = nil
		self.timerLabel = nil
		self.timerProgress = nil
		self.announceText = nil
		self.hourglassIcon = nil
		self.prestigeMaps = {}
		self.availableMaps = {}
		self.winnerMapIndex = 0
		self.winnerMap = 0
		self.canBanMap = false
		self.banMapCycleEvent = nil
		self.banMapProgressEvent = nil
		self.blinkIndex = 0
		self.blinkLastWidget = nil
		self.blinkWinnerIndex = 0
		self.blinkSteps = {}
		self.blinkStepIndex = 1
		self.banMapTimer = self.CONFIG.TIMER_DURATION
		self.banMapProgress = self.CONFIG.TIMER_DURATION

		g_client.setInputLockWidget(nil)
	end, self.CONFIG.CLEANUP_DELAY)
end
