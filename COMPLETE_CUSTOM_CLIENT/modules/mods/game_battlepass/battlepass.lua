if not BattlePass then
    BattlePass = {}
    BattlePass.__index = BattlePass

    BattlePass.window = nil
    BattlePass.missionPanel = nil
    BattlePass.progressPanel = nil
    BattlePass.outfitWidget = nil
    BattlePass.scrollBarWidget = nil
    BattlePass.dailyRerollWindow = nil

    BattlePass.beginTime = 0
    BattlePass.endTime = 0
    BattlePass.progressPoints = 0
    BattlePass.dailyRerollPrice = 0
    BattlePass.premiumBattlepass = false
    BattlePass.currentRewardStep = 0
    BattlePass.nextStepPoints = 0
    BattlePass.currentReward = 0
    BattlePass.dailyMissionsBegin = 0
    BattlePass.dailyMissionsExpire = 0
    BattlePass.dailyMissions = {}
    BattlePass.seassonMissions = {}

    BattlePass.isAnimatingWalk = false
    BattlePass.lastRewardStep = 0
    BattlePass.lastCameraPosition = 0

    -- Common variables
    BattlePass.rewardMinMargin = 195
    BattlePass.rewardMaxMargin = 18045
end

local function getMissionIndex(index)
    return MissionsDisplacement[index]
end

local function getOrdenedMissions(missions)
    local bronzeMissions = {}
    local silverMissions = {}
    local goldMissions = {}
    local orderedWithIndex = {}

    for _, mission in ipairs(BattlePass.seassonMissions) do
        if mission.rewardPoints == 100 then
            table.insert(bronzeMissions, mission)
        elseif mission.rewardPoints == 200 then
            table.insert(silverMissions, mission)
        elseif mission.rewardPoints == 300 then
            table.insert(goldMissions, mission)
        end
    end

    local bronzeIndex = 1
    local silverIndex = 1
    local goldIndex = 1

    for i, missionType in ipairs(MissionTypesOrder) do
        local indexDestino = MissionsDisplacement[i]
        local mission = nil

        if missionType == "bronze" and bronzeMissions[bronzeIndex] then
            mission = bronzeMissions[bronzeIndex]
            bronzeIndex = bronzeIndex + 1
        elseif missionType == "silver" and silverMissions[silverIndex] then
            mission = silverMissions[silverIndex]
            silverIndex = silverIndex + 1
        elseif missionType == "gold" and goldMissions[goldIndex] then
            mission = goldMissions[goldIndex]
            goldIndex = goldIndex + 1
        end

        if mission then
            table.insert(orderedWithIndex, { data = mission, index = indexDestino })
        end
    end
    return orderedWithIndex
end

local function getFormatedTime(dailyEndTime)
    local timeLeft = dailyEndTime - os.time()
    if timeLeft <= 0 then
        return "Expired", "Expired"
    end

    local days = math.floor(timeLeft / 86400)
    local hours = math.floor((timeLeft % 86400) / 3600)
    local minutes = math.floor((timeLeft % 3600) / 60)
    local seconds = timeLeft % 60

    local function formatUnit(value, singular, plural)
        return value == 1 and string.format("%d %s", value, singular) or string.format("%02d %s", value, plural)
    end

    local shortFormat, longFormat
    if days > 0 then
        shortFormat = formatUnit(days, "Day left", "Days left")
        longFormat = formatUnit(days, "Day", "Days") .. string.format(" and %02d hours left", hours)
    elseif hours > 0 then
        shortFormat = formatUnit(hours, "Hour left", "Hours left")
        longFormat = formatUnit(hours, "Hour", "Hours") .. string.format(" and %02d minutes left", minutes)
    elseif minutes > 0 then
        shortFormat = formatUnit(minutes, "Minute left", "Minutes left")
        longFormat = formatUnit(minutes, "Minute", "Minutes") .. string.format(" and %02d seconds left", seconds)
    else
        shortFormat = string.format("%02d Seconds left", seconds)
        longFormat = shortFormat
    end
    return shortFormat, longFormat
end

local function getTimeUntil(timestamp)
    local timeLeft = timestamp - os.time()
    if timeLeft <= 0 then
        return "00:00:00:00"
    end

    local days = math.floor(timeLeft / 86400)
    local hours = math.floor((timeLeft % 86400) / 3600)
    local minutes = math.floor((timeLeft % 3600) / 60)
    local seconds = timeLeft % 60
    return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
end

local function timerEvent(widget, endTime)
	if not widget or not widget:isVisible() or os.time() > endTime then
		return
	end

	widget:setText(BattlePass:running() and (string.format("New missions available in: %s", getTimeUntil(endTime))) or "                              Expired")
	scheduleEvent(function()
		timerEvent(widget, endTime)
	end, 1000)
end

function redirectToStore()
    BattlePass.window:hide()
    g_client.setInputLockWidget(nil)
	g_game.openStore()
	g_game.requestStoreOffers(3, "", 20)
end

function init()
    BattlePass.window = g_ui.displayUI('battlepass')
    BattlePass.window:hide()

    BattlePass.missionPanel = BattlePass.window:recursiveGetChildById('missionPanel')
    BattlePass.progressPanel = BattlePass.window:recursiveGetChildById('progressPanel')
    BattlePass.outfitWidget = BattlePass.window:recursiveGetChildById('playerOutfit')
    BattlePass.scrollBarWidget = BattlePass.window:recursiveGetChildById('progressPanelScrollBar')

    BattlePass.scrollBarWidget.canChangeValue = function()
        return not BattlePass.isAnimatingWalk
    end

    local progressPanelContent = BattlePass.window:recursiveGetChildById('progressPanelContent')
    if progressPanelContent then
        progressPanelContent.onMousePress = function(widget, mousePos, button)
            if button == MouseLeftButton and not BattlePass.isAnimatingWalk then
                BattlePass.isDragging = true
                BattlePass.dragStartX = mousePos.x
                BattlePass.dragStartScrollValue = BattlePass.scrollBarWidget:getValue()
            end
        end

        progressPanelContent.onMouseMove = function(widget, mousePos)
            if BattlePass.isDragging and not BattlePass.isAnimatingWalk then
                local deltaX = mousePos.x - BattlePass.dragStartX
                local scrollChange = -deltaX * 1.5 -- Adjust the multiplier for sensitivity
                local newScrollValue = BattlePass.dragStartScrollValue + scrollChange
                newScrollValue = math.max(BattlePass.scrollBarWidget:getMinimum(), math.min(newScrollValue, BattlePass.scrollBarWidget:getMaximum()))
                BattlePass.scrollBarWidget:setValue(newScrollValue)
            end
        end

        progressPanelContent.onMouseRelease = function(widget, mousePos, button)
            if button == MouseLeftButton then
                BattlePass.isDragging = false
            end
        end
    end

    g_keyboard.bindKeyPress('Tab', toggleNextWindow, BattlePass.window)

    loadMenu('challengesMenu')
    onCreateRewardContainers()

    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onResourceBalance = onResourceBalance,
        onBattlePassMissions = BattlePass.onBattlePassMissions,
        onBattlePassRewards = BattlePass.onBattlePassRewards,
    })
end

function terminate()
    g_keyboard.unbindKeyPress('Tab', toggleNextWindow, BattlePass.window)

    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onResourceBalance = onResourceBalance,
        onBattlePassMissions = BattlePass.onBattlePassMissions,
        onBattlePassRewards = BattlePass.onBattlePassRewards
    })
end

function online()
    -- Load battlepass config
    BattlePass:loadConfigJson()
    BattlePass:loadPlayerPosition()

    -- Reset daily mission panel
    local dailyMissionsPanel = BattlePass.window:recursiveGetChildById('dailyMissionsBg')
    dailyMissionsPanel:destroyChildren()
    for i = 1, 2 do
        local widget = g_ui.createWidget('DailyMissionWidget', dailyMissionsPanel)
        local imageBackground = widget:recursiveGetChildById('dailyMissionIconImage')
        local image = i == 1 and 'daily-free-icon' or 'daily-vip-icon'
        imageBackground:setImageSource('/images/game/battlepass/' .. image)
    end

    -- Reset mission panel
    local missionsPanel = BattlePass.window:recursiveGetChildById('missionsBackground')
    missionsPanel:destroyChildren()
    for i = 1, 26 do
        g_ui.createWidget('MissionWidget', missionsPanel)
    end

    if BattlePassRewards.claimRewardWindow then
        BattlePassRewards.claimRewardWindow:destroy()
        BattlePassRewards.claimRewardWindow = nil
    end
end

function offline()
    hide()
    BattlePass.lastRewardStep = BattlePass.currentRewardStep
    BattlePass.lastCameraPosition = RewardPositions[BattlePass.currentRewardStep].scrollPosition
    BattlePass.outfitWidget:setMarginLeft(165)
    BattlePass:saveConfigJson()

    if BattlePassRewards.claimRewardWindow then
        BattlePassRewards.claimRewardWindow:destroy()
        BattlePassRewards.claimRewardWindow = nil
    end
end

function BattlePass:showBattlePass()
    BattlePass.window:show(true)
    BattlePass.window:raise()
    BattlePass.window:focus()
    g_client.setInputLockWidget(BattlePass.window)

    local moneyTooltip = {}
    local player = g_game.getLocalPlayer()
    local playerBank = player:getResourceValue(ResourceBank)
    local playerInventory = player:getResourceValue(ResourceInventary)
    local goldCoinsLabel = BattlePass.window:recursiveGetChildById('rCoins')

    setStringColor(moneyTooltip, "Cash: " .. comma_value(playerInventory), "#3f3f3f")
	setStringColor(moneyTooltip, " $", "#f7e6fe")
	setStringColor(moneyTooltip, "\nBank: " .. comma_value(playerBank), "#3f3f3f")
	setStringColor(moneyTooltip, " $", "#f7e6fe")

    goldCoinsLabel:setText(comma_value(playerBank + playerInventory))
    goldCoinsLabel:setTooltip(moneyTooltip)
end

function show()
    BattlePass.window:show(true)
    BattlePass.window:raise()
    BattlePass.window:focus()

    g_keyboard.bindKeyPress('Tab', toggleNextWindow, BattlePass.window)
    g_client.setInputLockWidget(BattlePass.window)
end

function hide()
    BattlePass.window:hide()
    g_client.setInputLockWidget(nil)
    g_keyboard.unbindKeyPress('Tab', toggleNextWindow, BattlePass.window)
end

function onCreateRewardContainers()
    local progressPanelContent = BattlePass.window:recursiveGetChildById('progressPanelContent')
    if not progressPanelContent then return end

    for i, data in ipairs(RewardPositions) do
        for rewardType, position in pairs(data.positions) do
            local rewardWidgetId = rewardType .. "RewardWidget" .. i
            local rewardWidget = g_ui.createWidget('RewardWidget', progressPanelContent)
            rewardWidget:setId(rewardWidgetId)
            rewardWidget:setMarginLeft(position.marginLeft)
            rewardWidget:setMarginTop(position.marginTop)
            rewardWidget:setVisible(false)

            local rewardBoxImage = rewardWidget:recursiveGetChildById("rewardBoxImage")
            if rewardType == "free" then
                rewardBoxImage:setImageSource("/images/game/battlepass/free-reward-chest")
                rewardBoxImage:setImageClip("30 32 29 31")
            else
                rewardBoxImage:setImageSource("/images/game/battlepass/vip-reward-chest")
                rewardBoxImage:setImageClip("30 32 29 31")
            end
            rewardBoxImage:setTooltip(string.format("Battle Pass %s Reward\nUnlocked at level %d", string.capitalize(rewardType), i))

            rewardWidget.rewardBox.onClick = function()
                BattlePass.scrollBarWidget:setValue(RewardPositions[i].scrollPosition)
                BattlePassRewards:onConfirmClaimReward(i, rewardType)
            end

            local blockedRewardId = rewardType .. "BlockedRewardWidget" .. i
            local blockedReward = g_ui.createWidget('BlockedRewardWidget', progressPanelContent)
            blockedReward:setId(blockedRewardId)
            blockedReward:setMarginLeft(position.marginLeft)
            blockedReward:setMarginTop(position.marginTop)
            blockedReward:setVisible(true)
            local lockedBoxImage = blockedReward:recursiveGetChildById("lockedBoxImage")
            if rewardType == "free" then
                lockedBoxImage:setImageSource("/images/game/battlepass/free-reward-chest")
            else
                lockedBoxImage:setImageSource("/images/game/battlepass/vip-reward-chest")
            end
            lockedBoxImage:setTooltip(string.format("Battle Pass %s Reward\nUnlock at level %d", string.capitalize(rewardType), i))
        end
    end
end

function loadMenu(menuId)
    local buttons = {
        challengesMenuButton = 'challengesMenu',
        rewardsMenuButton = 'rewardsMenu'
    }

    -- if menuId == 'challengesMenu' and not BattlePass:running() then
    --     menuId = 'rewardsMenu'
    -- end

    for buttonName, buttonId in pairs(buttons) do
        local button = BattlePass.window.mainPanel.optionsTabBar:getChildById(buttonId)
        if button then
            button:setChecked(false)
        end
    end

    local selectedButton = BattlePass.window.mainPanel.optionsTabBar:getChildById(menuId)
    if selectedButton then
        selectedButton:setChecked(true)
    end

    if menuId == 'challengesMenu' then
        BattlePass.missionPanel:show(true)
        if g_game.isOnline() and BattlePass.progressPanel:isVisible() then
            local nextUnlock = BattlePass.getNextResetWeek(BattlePass.calculateWeekNumber())
            local unlockInfo = BattlePass.window:recursiveGetChildById("unlockInfo")
            timerEvent(unlockInfo, nextUnlock)
        end

        BattlePass.progressPanel:hide()
        BattlePass.window:setHeight(595)
    elseif menuId == 'rewardsMenu' then
        BattlePass.scrollBarWidget:setValue(BattlePass.lastCameraPosition)
        BattlePass.outfitWidget:setDirection(BattlePass.currentRewardStep == 0 and East or North)
        g_game.requestBattlePass(1)

        scheduleEvent(function()
            BattlePass.missionPanel:hide()
            BattlePass.progressPanel:show(true)
            BattlePass.window:setHeight(515)
            BattlePass:updatePlayerPosition()
        end, 50)
    end

    g_client.setInputLockWidget(BattlePass.window)
end

function toggleNextWindow()
    local widgetList = {
      "challengesMenu",
      "rewardsMenu"
    }

    local selectedIndex = nil
    for i, widget in ipairs(widgetList) do
      if widget == menuId then
        selectedIndex = i
        break
      end
    end

    if not selectedIndex then
        selectedIndex = 1
    end

    local nextWidgetId = (selectedIndex == #widgetList and 1 or selectedIndex + 1)
    menuId = widgetList[nextWidgetId]
    loadMenu(menuId)
end

function BattlePass.onBattlePassMissions(playerOutfit, beginTime, endTime, points, rerollPrice, battlePassActive, currentRewardStep, nextStepPoints, dailyBeginTime, dailyEndTime, dailyMissions, generalMissions)
    BattlePass.outfitWidget:setOutfit(playerOutfit)
    BattlePass.beginTime = beginTime
    BattlePass.endTime = endTime
    BattlePass.progressPoints = points
    BattlePass.dailyRerollPrice = rerollPrice
    BattlePass.premiumBattlepass = battlePassActive
    BattlePass.currentRewardStep = currentRewardStep
    BattlePass.nextStepPoints = nextStepPoints
    BattlePass.dailyMissionsBegin = dailyBeginTime
    BattlePass.dailyMissionsExpire = dailyEndTime

    BattlePass.dailyMissions = dailyMissions
    BattlePass.seassonMissions = generalMissions

    local getVipPassTicketButton = BattlePass.window:recursiveGetChildById('getVipPassTicket')
    local getVipPassTicketBorder = BattlePass.window:recursiveGetChildById('getVipPassTicketBorder')
    if getVipPassTicketButton then
        getVipPassTicketButton:setVisible(not BattlePass.premiumBattlepass)
        getVipPassTicketBorder:setVisible(not BattlePass.premiumBattlepass)
    end

    BattlePass:configureMissionPanel()

    -- Reset player data in case of season ends
    if BattlePass.currentRewardStep == 0 then
        BattlePass.lastCameraPosition = 0
        BattlePass.lastRewardStep = 0
        BattlePass.outfitWidget:setMarginLeft(165)
        BattlePass.scrollBarWidget:setValue(0)
    end
end

function BattlePass.onBattlePassRewards(rewardSteps)
    BattlePass.rewardSteps = {}
    BattlePass.rewardSteps = rewardSteps
    BattlePass:configureRewardPanel()
end

function BattlePass.calculateWeekNumber()
    local targetTime = os.time()
    local begindate = os.time{year=os.date("*t", BattlePass.beginTime).year, month=os.date("*t", BattlePass.beginTime).month, day=os.date("*t", BattlePass.beginTime).day, hour=10, min=0, sec=0}
    local diffSeconds = os.difftime(targetTime, begindate)
    local diffDays = diffSeconds / 86400
    local weekNumber = diffDays / 7
    return math.ceil(weekNumber)
end

function BattlePass.getNextResetWeek(currentIndex)
    local nextDays = 7 * currentIndex
    local begindate = os.time{year=os.date("*t", BattlePass.beginTime).year, month=os.date("*t", BattlePass.beginTime).month, day=os.date("*t", BattlePass.beginTime).day, hour=10, min=0, sec=0}
    local nextResetTime = begindate + (nextDays * 86400)
    local tableDate = os.date("*t", nextResetTime)
    return os.time{year=tableDate.year, month=tableDate.month, day=tableDate.day, hour=10, min=0, sec=0}
end

function BattlePass:configureMissionPanel()
    if not BattlePass.window:isVisible() then
        BattlePass:showBattlePass(true)
    end

    -- Current reward points
    BattlePass.window:recursiveGetChildById("playerLevel"):setText(BattlePass.currentRewardStep)
    BattlePass.window:recursiveGetChildById("currentlyLevelText"):setText(string.format("%s/%s", BattlePass.progressPoints, BattlePass.nextStepPoints))
    BattlePass.window:recursiveGetChildById("levelProgress"):setPercent(BattlePass.progressPoints / BattlePass.nextStepPoints * 100)

    -- BattlePass end time
    local seasonTotalTime = BattlePass.endTime - BattlePass.beginTime
    local timeRemaining = BattlePass.endTime - os.time()
    local seasonPercent = (timeRemaining / seasonTotalTime) * 100
    local seasonTimeText, seasonTimeTooltip = getFormatedTime(BattlePass.endTime)
    BattlePass.window:recursiveGetChildById("seasonTimeText"):setText(seasonTimeText)
    BattlePass.window:recursiveGetChildById("seasonHourglassIcon"):setTooltip(seasonTimeTooltip)
    BattlePass.window:recursiveGetChildById("seasonTimeProgress"):setPercent(seasonPercent)

    -- Next unlocked missions
    local nextUnlock = BattlePass.getNextResetWeek(BattlePass.calculateWeekNumber())
    local unlockInfo = BattlePass.window:recursiveGetChildById("unlockInfo")
    unlockInfo:setText(string.format("New missions available in: %s", getTimeUntil(nextUnlock)))
    timerEvent(unlockInfo, nextUnlock)

    -- Daily end time
    local dailyTotalTime = BattlePass.dailyMissionsExpire - BattlePass.dailyMissionsBegin
    local dailyTimeRemaining = BattlePass.dailyMissionsExpire - os.time()
    local dailyPercent = (dailyTimeRemaining / dailyTotalTime) * 100
    local dailyTimeText, dailyTimeTooltip = getFormatedTime(BattlePass.dailyMissionsExpire)
    BattlePass.window:recursiveGetChildById("dailyTimeText"):setText(dailyTimeText)
    BattlePass.window:recursiveGetChildById("hourglassIcon"):setTooltip(dailyTimeTooltip)
    BattlePass.window:recursiveGetChildById("dailyTimeProgress"):setPercent(dailyPercent)

    -- Daily Missions
    local dailyMissionsPanel = BattlePass.window:recursiveGetChildById('dailyMissionsBg')

    for k, v in ipairs(BattlePass.dailyMissions) do
        if k > 2 then
            print(string.format("[WARNING] Daily mission count is higher than 2 missions. (%s)", #BattlePass.dailyMissions))
            break
        end

        local widget = dailyMissionsPanel:getChildByIndex(getMissionIndex(k))
        local completed = v.currentProgress == v.maxProgress

        widget:recursiveGetChildById("dailyMissionName"):setText(v.missionName)
        widget:recursiveGetChildById("dailyMissionPoints"):setText(v.rewardPoints)
        widget:recursiveGetChildById("dailyMissionProgress"):setPercent(v.currentProgress / v.maxProgress * 100)
        widget:recursiveGetChildById("dailyMissionProgressText"):setText(string.format("%s/%s", aggresiveNumberToStr(v.currentProgress), aggresiveNumberToStr(v.maxProgress)))
        widget:recursiveGetChildById("dailyMissionInformation"):setTooltip(v.missionDescription)
        widget:recursiveGetChildById("dailyBlockedMissionIcon"):setVisible(false)
        widget:recursiveGetChildById("dailyFreeIcon"):setVisible(false)
        widget:recursiveGetChildById("dailyRerollButton"):setVisible(not completed)
        widget:recursiveGetChildById("dailyRerollButton").onClick = function() if not BattlePass:running() then return true end BattlePass:rerollDailyMission(v) end

        local icon = (k == 1 and "daily-free-icon" or "daily-vip-icon")
        if completed then
            icon = "daily-icon-complete"
        end

        widget:recursiveGetChildById("dailyMissionIconImage"):setImageSource("/images/game/battlepass/" .. icon)
        widget:recursiveGetChildById("dailyProgressPanel"):setVisible(not completed)
        widget:recursiveGetChildById("dailyCompletedIcon"):setVisible(completed)

        if not BattlePass:running() then
            widget:setEnabled(false)
            widget:setVisible(false)
        end
    end

    -- General missions
    local missionsPanel = BattlePass.window:recursiveGetChildById('missionsBackground')
    local orderedWithIndex = getOrdenedMissions(BattlePass.seassonMissions)

    for k, v in ipairs(orderedWithIndex) do
        local data = v.data
        local widget = missionsPanel:getChildByIndex(v.index)
        if not widget then
            break
        end

        widget:recursiveGetChildById("missionName"):setText(data.missionName)
        widget:recursiveGetChildById("missionPoints"):setText(data.rewardPoints)
        widget:recursiveGetChildById("missionProgress"):setPercent(data.currentProgress / data.maxProgress * 100)
        widget:recursiveGetChildById("missionProgressText"):setText(string.format("%s/%s", aggresiveNumberToStr(data.currentProgress), aggresiveNumberToStr(data.maxProgress)))
        widget:recursiveGetChildById("missionInformation"):setTooltip(data.missionDescription)
        widget:recursiveGetChildById("blockedMissionIcon"):setVisible(false)

        local completed = data.currentProgress == data.maxProgress
        local missionIcon = completed and MissionRankIcons[data.rewardPoints] .. "-complete" or MissionRankIcons[data.rewardPoints]
        widget:recursiveGetChildById("missionIconImage"):setImageSource("/images/game/battlepass/" .. missionIcon)
        widget:recursiveGetChildById("progressPanel"):setVisible(not completed)
        widget:recursiveGetChildById("completedIcon"):setVisible(completed)
        if not BattlePass:running() then
            widget:setEnabled(false)
            widget:setVisible(false)
        end
    end
end

function BattlePass:configureRewardPanel()
    local rewardPanel = BattlePass.window:recursiveGetChildById('progressPanelContent')
    if not rewardPanel then
        return
    end

    for k, v in ipairs(BattlePass.rewardSteps) do
        for i, reward in ipairs(v.rewards) do
            local rewardType = reward.freeReward and "free" or "premium"
            local rewardWidget = rewardPanel:getChildById(rewardType .. "RewardWidget" .. v.stepId)
            local blockedReward = rewardPanel:getChildById(rewardType .. "BlockedRewardWidget" .. v.stepId)
            local availableReward = v.stepId <= BattlePass.currentRewardStep
            blockedReward:setVisible(not availableReward)
            rewardWidget:setVisible(availableReward)

            local enabled = not reward.hasClamedReward
            local text = reward.hasClamedReward and "Claimed" or "Claim Reward"
            if not availableReward then
                text = "Locked"
                enabled = false
            elseif not reward.freeReward and not BattlePass.premiumBattlepass and availableReward then
                text = "Deluxe"
                enabled = false
            end

            rewardWidget:recursiveGetChildById("collectRewardLabel"):setText(text)
            rewardWidget:recursiveGetChildById("rewardBox"):setEnabled(enabled)
            local rewardBoxImage = rewardWidget:recursiveGetChildById("rewardBoxImage")
            if reward.hasClamedReward then
                if rewardType == "free" then
                    rewardBoxImage:setImageSource("/images/game/battlepass/free-reward-chest-open")
                    rewardBoxImage:setImageClip("26 22 38 42")
                    rewardBoxImage:setSize("38 42")
                    rewardBoxImage:setMarginTop(-10)
                else
                    rewardBoxImage:setImageSource("/images/game/battlepass/vip-reward-chest-open")
                    rewardBoxImage:setImageClip("24 20 40 44")
                    rewardBoxImage:setSize("40 44")
                    rewardBoxImage:setMarginTop(-12)
                end
            else
                if rewardType == "free" then
                    rewardBoxImage:setImageSource("/images/game/battlepass/free-reward-chest")
                    rewardBoxImage:setImageClip("30 32 29 31")

                else
                    rewardBoxImage:setImageSource("/images/game/battlepass/vip-reward-chest")
                    rewardBoxImage:setImageClip("30 32 29 31")
                end
            end
            local rewardTypeText = reward.freeReward and "Free" or "Deluxe"
            rewardBoxImage:setTooltip(string.format("Battle Pass %s Reward\n%s at level %d", string.capitalize(rewardTypeText), (reward.hasClamedReward and "Claimed" or "Unlocked"), v.stepId))

            -- Set lockedBoxImage for blocked rewards (always closed chest)
            local lockedBoxImage = blockedReward:recursiveGetChildById("lockedBoxImage")
            if rewardType == "free" then
                lockedBoxImage:setImageSource("/images/game/battlepass/free-reward-chest")
            else
                lockedBoxImage:setImageSource("/images/game/battlepass/vip-reward-chest")
            end
            lockedBoxImage:setTooltip(string.format("Battle Pass %s Reward\nUnlock at level %d", string.capitalize(rewardTypeText), v.stepId))
        end
    end
end

function BattlePass:getStepsToReward(rewardStep)
    local stepsToReward = 0
    for i, data in ipairs(RewardPositions) do
        if i <= rewardStep then
            stepsToReward = stepsToReward + data.stepsTo
        end
    end
    return stepsToReward
end

function BattlePass:loadPlayerPosition()
    -- First execution
    local stepsToReward = BattlePass:getStepsToReward(BattlePass.lastRewardStep)
    if stepsToReward == 0 then
        return
    end

    local newProgress = BattlePass.rewardMinMargin + stepsToReward * 32
    local playerProgress = math.max(BattlePass.rewardMinMargin, math.min(newProgress, BattlePass.rewardMaxMargin))

    BattlePass.outfitWidget:setMarginLeft(playerProgress)
    BattlePass.scrollBarWidget:setValue(BattlePass.lastCameraPosition)
end

function BattlePass:updatePlayerPosition()
    local stepsToReward = BattlePass:getStepsToReward(BattlePass.currentRewardStep)
	local newProgress = BattlePass.rewardMinMargin + stepsToReward * 32
	local playerProgress = math.max(BattlePass.rewardMinMargin, math.min(newProgress, BattlePass.rewardMaxMargin))

    if playerProgress > 195 then
        BattlePass.lastCameraPosition = RewardPositions[BattlePass.lastRewardStep].scrollPosition
        BattlePass:doAnimatePlayerMove(playerProgress)
    end

    -- Force save data
    BattlePass:saveConfigJson()
end

function BattlePass:running()
    local timeLeft = BattlePass.endTime - os.time()
    if timeLeft <= 0 then
        return false
    end

    return true
end

function BattlePass:doAnimatePlayerMove(targetMargin)
    if targetMargin == BattlePass.outfitWidget:getMarginLeft() then
        return
    end

    local player = g_game.getLocalPlayer()
    BattlePass.outfitWidget:setDirection(East)
    BattlePass.outfitWidget:setAnimate(true)
    BattlePass.outfitWidget:setIdleAnimate(false)
    BattlePass.outfitWidget:setStaticWalking(true)

    BattlePass.isAnimatingWalk = true
    local currentMargin = BattlePass.outfitWidget:getMarginLeft()
    local scrollBar = BattlePass.scrollBarWidget

    local function finishAnimation()
        BattlePass.outfitWidget:setMarginLeft(targetMargin)
        BattlePass.outfitWidget:setAnimate(false)
        BattlePass.outfitWidget:setStaticWalking(false)
        BattlePass.outfitWidget:setIdleAnimate(true)
        BattlePass.isAnimatingWalk = false
        BattlePass.lastRewardStep = BattlePass.currentRewardStep
        BattlePass.lastCameraPosition = RewardPositions[BattlePass.currentRewardStep].scrollPosition

        -- Force save data
        BattlePass:saveConfigJson()

        scheduleEvent(function()
            BattlePass.outfitWidget:setDirection(North)
        end, 150)
    end

    local function animateStep()
        if not BattlePass.outfitWidget:isVisible() then
            finishAnimation()
            return true
        end

        if currentMargin < targetMargin then
            currentMargin = math.min(currentMargin + 3, targetMargin)
            BattlePass.outfitWidget:setMarginLeft(currentMargin)
            if currentMargin < targetMargin then
                scheduleEvent(animateStep, 25)
                if currentMargin >= 350 then
                    scrollBar:setValue(scrollBar:getValue() + 3)
                end
            else
                finishAnimation()
            end
        else
            finishAnimation()
        end
    end

    animateStep()
end

function BattlePass:loadConfigJson()
    if not LoadedPlayer:isLoaded() then return end

    local file = "/characterdata/" .. LoadedPlayer:getId() .. "/battlepass.json"
    if g_resources.fileExists(file) then
        local status, result = pcall(function()
            return json.decode(g_resources.readFileContents(file))
        end)

        if not status then
            return g_logger.error("Error while reading characterdata file. Details: " .. result)
        end

        BattlePass.lastRewardStep = result.currentRewardStep or 0
        BattlePass.lastCameraPosition = result.lastCameraPosition or 0
    else
        BattlePass.lastRewardStep = 0
        BattlePass.lastCameraPosition = 0
    end
end

function BattlePass:saveConfigJson()
	local config = { currentRewardStep = BattlePass.lastRewardStep, lastCameraPosition = BattlePass.lastCameraPosition }
	if not LoadedPlayer:isLoaded() then return end

	local file = "/characterdata/" .. LoadedPlayer:getId() .. "/battlepass.json"
	local status, result = pcall(function() return json.encode(config, 2) end)
	if not status then
		return g_logger.error("Error while saving profile Battlepass data. Data won't be saved. Details: " .. result)
	end

	if result:len() > 100 * 1024 * 1024 then
		return g_logger.error("Something went wrong, file is above 100MB, won't be saved")
	end
	g_resources.writeFileContents(file, result)
end

function BattlePass:rerollDailyMission(data)
    if BattlePass.dailyRerollWindow then
        BattlePass.dailyRerollWindow:destroy()
    end

    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    BattlePass.window:hide()

    local okButton = function()
        BattlePass.dailyRerollWindow:destroy()
        BattlePass.dailyRerollWindow = nil
        g_client.setInputLockWidget(nil)
        g_game.rerollBattlePassMission(data.missionId)
    end

    local cancelButton = function()
        BattlePass.dailyRerollWindow:destroy()
        BattlePass.dailyRerollWindow = nil
        BattlePass:showBattlePass()
        g_client.setInputLockWidget(BattlePass.window)
    end

    local message = {}
    setStringColor(message, string.format("Are you sure you want to reroll the mission %s for %s", data.missionName, comma_value(BattlePass.dailyRerollPrice * player:getLevel())), "#c0c0c0")
    setStringColor(message, " $", "#f7e6fe")
    setStringColor(message, " ?", "#c0c0c0")

    BattlePass.dailyRerollWindow = displayGeneralBox(tr('Confirm mission reroll'), message, {
        { text=tr('Ok'), callback = okButton },
        { text=tr('Cancel'), callback = cancelButton },
    }, okButton, cancelButton)

    BattlePass.dailyRerollWindow:recursiveGetChildById('messageBoxLabel'):setFont("Verdana Bold-11px-wheel")
    g_client.setInputLockWidget(BattlePass.dailyRerollWindow)
end

function onResourceBalance()
    if not BattlePass.window:isVisible() then
        return
    end

    local moneyTooltip = {}
    local player = g_game.getLocalPlayer()
    local playerBank = player:getResourceValue(ResourceBank)
    local playerInventory = player:getResourceValue(ResourceInventary)
    local goldCoinsLabel = BattlePass.window:recursiveGetChildById('rCoins')

    setStringColor(moneyTooltip, "Cash: " .. comma_value(playerInventory), "#3f3f3f")
	setStringColor(moneyTooltip, " $", "#f7e6fe")
	setStringColor(moneyTooltip, "\nBank: " .. comma_value(playerBank), "#3f3f3f")
	setStringColor(moneyTooltip, " $", "#f7e6fe")

    goldCoinsLabel:setText(comma_value(playerBank + playerInventory))
    goldCoinsLabel:setTooltip(moneyTooltip)
end
