if not HuntConfig then
    HuntConfig = {
        data = {},
        levelList = {},
        lowestLevel = 10000,
        highestLevel = 0,
    }
    HuntConfig.__index = HuntConfig
end

local self = HuntConfig

-- Custom table.contains with case-insensitive option
local function tableContains(table, element, caseInsensitive)
    if not table then return false end
    for _, value in pairs(table) do
        if caseInsensitive then
            if type(value) == "string" and type(element) == "string" and value:lower() == element:lower() then
                return true
            end
        elseif value == element then
            return true
        end
    end
    return false
end

function HuntConfig:loadJson()
    self.data = {}
    local file = "/json/hunting_places.json"
    if g_resources.fileExists(file) then
        local status, result = pcall(function()
            return json.decode(g_resources.readFileContents(file))
        end)

        if not status then
            return g_logger.error("Error while reading characterdata file. Details: " .. result)
        end

        for i, data in pairs(result) do
            local hunt = Hunt:new(data)
            if not hunt then
                g_logger.debug(string.format("[HuntConfig] Failed to create hunt with index %d", i))
            end

            local level = hunt:getLevel()
            table.insert(self.data, hunt)
            table.uniqueInsert(self.levelList, level)

            if level > self.highestLevel then
                self.highestLevel = level
            elseif level < self.lowestLevel then
                self.lowestLevel = level
            end
        end
    else
        g_logger.error("Hunt config file not found: " .. file)
    end
end

function HuntConfig:getHuntByVocation(vocation, listClass)
    local display = {}
    for _, hunt in pairs(self.data) do
        local vocations = hunt:getVocations()
        if vocation == "All" or (vocations and #vocations > 0 and tableContains(vocations, vocation, true)) and listClass:canDrawHunt(hunt) then
            display[#display + 1] = hunt
        end
    end

    if HuntFinder.sortType == 1 then
        table.sort(display, function(a, b) return a:getLevel() < b:getLevel() end)
    elseif HuntFinder.sortType == 2 then
        table.sort(display, function(a, b)
            local stringA = a:getLootHour():gsub("+", "")
            local stringB = b:getLootHour():gsub("+", "")

            stringA = stringA:gsub("N/A", "0")
            stringB = stringB:gsub("N/A", "0")

            stringA = stringA:gsub("k", "000")
            stringB = stringB:gsub("k", "000")

            local aXp = tonumber(stringA) or 0
            local bXp = tonumber(stringB) or 0
            return aXp > bXp
        end)
    elseif HuntFinder.sortType == 3 then
        table.sort(display, function(a, b)
            local stringA = a:getXPHour():gsub("+", "")
            local stringB = b:getXPHour():gsub("+", "")

            stringA = stringA:gsub("k", "000")
            stringB = stringB:gsub("k", "000")

            local aXp = tonumber(stringA) or 0
            local bXp = tonumber(stringB) or 0
            return aXp > bXp
        end)
    end

    return display
end

function HuntConfig:getHuntsLevelList()
    return self.levelList
end

function HuntConfig:getPlayerFloorLevel(level)
    if level < self.lowestLevel then
        return self.lowestLevel
    end

    if level > self.highestLevel then
        return self.highestLevel
    end

    for i = #self.levelList, 1, -1 do
        local data = self.levelList[i]
        if data < level then
            return data
        end
    end
    return lowestLevel
end