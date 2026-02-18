PvpLeaderboard = {
    rankings = {},
    currentWorld = nil,
    lastUpdateTime = nil,
    availableWorlds = {},
    currentPage = 1,
    totalPages = 1,
    ranking = 0,
    vocation = 0xFFFFFFFF,
    vocations = {}
}

local function getHours(seconds)
  return math.floor((seconds/60)/60)
end

local function getMinutes(seconds)
  return math.floor(seconds/60)
end

local function getSeconds(seconds)
  return seconds%60
end

local function getTimeinWords(secs)
  local hours, minutes, seconds = getHours(secs), getMinutes(secs), getSeconds(secs)
  if (minutes > 59) then
    minutes = minutes-hours*60
  end

  local timeStr = ''

  if hours > 0 then
    timeStr = timeStr .. ' hours '
  end

  if minutes > 0 then
    timeStr = timeStr .. minutes .. ' minutes'
  elseif seconds > 0 then
    timeStr =  seconds .. ' seconds'
  end

  return timeStr
end


function PvpLeaderboard:init(currentWorld, lastUpdateTime, availableWorlds, currentPage, totalPages, rankings, ranking, vocations, vocation)
    self.currentWorld = currentWorld
    self.lastUpdateTime = lastUpdateTime
    self.availableWorlds = availableWorlds
    self.currentPage = currentPage
    self.totalPages = totalPages
    self.rankings = rankings
    self.ranking = ranking
    self.vocation = vocation
    self.vocations = vocations

    local vocationBox = PrestigeBattle.highScoresPanel:recursiveGetChildById('vocationBox')
    vocationBox:clearOptions()
    for id, vocation in pairs(self.vocations) do
        vocationBox:addOption(vocation, {vocationId = id})
        if id == self.vocation then
            vocationBox:setCurrentOption(vocation, false)
        end
    end

    local selectedId = 1
    local worldBox = PrestigeBattle.highScoresPanel:recursiveGetChildById('worldBox')
    worldBox:clearOptions()
    
    local sortedWorlds = {}
    for id, world in pairs(self.availableWorlds) do
        table.insert(sortedWorlds, {id = id, world = world})
    end
    
    table.sort(sortedWorlds, function(a, b)
        return a.world:lower() < b.world:lower()
    end)
    
    for _, worldData in ipairs(sortedWorlds) do
        worldBox:addOption(worldData.world, {worldId = worldData.id})
        if worldData.world:lower() == self.currentWorld:lower() then
            selectedId = worldData.id
            worldBox:setCurrentOption(self.currentWorld, false)
        end
    end

    local rankBox = PrestigeBattle.highScoresPanel:recursiveGetChildById('rankBox')
    rankBox:clearOptions()
    rankBox:addOption("All", {rank = 0})
    for i, rank in ipairs(PrestigeRankData) do
        rankBox:addOption(rank.name, {rank = i})
        if i == self.ranking then
            rankBox:setCurrentOption(rank.name, false)
        end
    end

    local showOwnRankButton = PrestigeBattle.highScoresPanel:recursiveGetChildById('showOwnRank')
    showOwnRankButton.onClick = function()
        local currentRank = rankBox:getCurrentOption().data.rank
        local currentVocation = vocationBox:getCurrentOption().data.vocationId

        g_game.sendPrestigeArenaLeaderboard(selectedId, 1, true, currentRank, currentVocation)
    end

    local submitButton = PrestigeBattle.highScoresPanel:recursiveGetChildById('submitButton')
    submitButton.onClick = function()
        local currentRank = rankBox:getCurrentOption().data.rank
        local currentVocation = vocationBox:getCurrentOption().data.vocationId

        g_game.sendPrestigeArenaLeaderboard(worldBox:getCurrentOption().data.worldId, 1, false, currentRank, currentVocation)
    end

    local pageLabel = PrestigeBattle.highScoresPanel:recursiveGetChildById('page')
    pageLabel:setText(("%d/%d"):format(self.currentPage, self.totalPages))

    local firstButton = PrestigeBattle.highScoresPanel:recursiveGetChildById('first')
    firstButton.onClick = function()
        local currentRank = rankBox:getCurrentOption().data.rank
        local currentVocation = vocationBox:getCurrentOption().data.vocationId

        g_game.sendPrestigeArenaLeaderboard(selectedId, 1, false, currentRank, currentVocation)
    end

    local prevButton = PrestigeBattle.highScoresPanel:recursiveGetChildById('prevButton')
    prevButton.onClick = function()
        local currentRank = rankBox:getCurrentOption().data.rank
        local currentVocation = vocationBox:getCurrentOption().data.vocationId

        g_game.sendPrestigeArenaLeaderboard(selectedId, math.max(1, self.currentPage - 1), false, currentRank, currentVocation)
    end

    local nextButton = PrestigeBattle.highScoresPanel:recursiveGetChildById('nextButton')
    nextButton.onClick = function()
        local currentRank = rankBox:getCurrentOption().data.rank
        local currentVocation = vocationBox:getCurrentOption().data.vocationId

        g_game.sendPrestigeArenaLeaderboard(selectedId, math.min(self.totalPages, self.currentPage + 1), false, currentRank, currentVocation)
    end

    local lastButton = PrestigeBattle.highScoresPanel:recursiveGetChildById('last')
    lastButton.onClick = function()
        local currentRank = rankBox:getCurrentOption().data.rank
        local currentVocation = vocationBox:getCurrentOption().data.vocationId

        g_game.sendPrestigeArenaLeaderboard(selectedId, self.totalPages, false, currentRank, currentVocation)
    end

    local rankList = PrestigeBattle.highScoresPanel:recursiveGetChildById('rankList')
    rankList:destroyChildren()

    for i, ranking in pairs(self.rankings) do
        local rankWidget = g_ui.createWidget('PlayerRankWidget', rankList)
        rankWidget:setId('rankWidget' .. i)

        local rankingDiff = ranking[2] - ranking[1]
        if ranking[2] ~= 1001 and rankingDiff ~= 0 then
            rankWidget.rankPoints:setColorText("[color=" .. (rankingDiff > 0 and "$var-text-cip-color-green" or "$var-text-cip-store-red") .. "](" .. (rankingDiff > 0 and "+ " or "- ") .. math.abs(rankingDiff) .. ")[/color]")

            local baseImageSource = "/images/game/ranked-queue/"
            if rankingDiff > 0 then
                rankWidget.infoIcon:setImageSource(baseImageSource .. "icon-arrow-up")
            else
                rankWidget.infoIcon:setImageSource(baseImageSource .. "icon-arrow-down")
            end
        else
            rankWidget.rankPoints:setColorText("")
            rankWidget.infoIcon:setImageSource("/images/game/ranked-queue/icon-none")
        end

        rankWidget.rankPosition:setText(ranking[1])
        rankWidget.name:setText(ranking[4])
        if ranking[3] then
            rankWidget.name:setColor('$var-text-cip-color-green')
            rankWidget.vocation:setColor('$var-text-cip-color-green')
            rankWidget.rankPosition:setColor('$var-text-cip-color-green')
            rankWidget.score:setColor('$var-text-cip-color-green')
            rankWidget.division:setColor('$var-text-cip-color-green')
        end
        rankWidget.vocation:setText(ranking[5])
        rankWidget.world:setText(ranking[8])
        rankWidget.world:setTooltip(ranking[8])
        rankWidget.score:setText(ranking[6])
        rankWidget.division:setText(ranking[7])
        rankWidget:setBackgroundColor((i % 2 == 0) and "$var-textlist-even" or '$var-textlist-odd')
    end

    local lastUpdateLabel = PrestigeBattle.highScoresPanel:recursiveGetChildById('lastUpdate')
    lastUpdateLabel:setText("Last Update: " .. getTimeinWords(os.time() - self.lastUpdateTime) .. " ago")
end
