local registerEvents = {
    -- Exemplo: "WeeklyTasksMonsterDeath", "LinkedTasksMonsterDeath"
    -- Remova placeholders e preencha com eventos CreatureEvent válidos do seu datapack.
    "REGISTER-NAME",
    "REGISTER-NAME-TWO",
}

local blockedNames = {
    "...",
}

local tibiaForeverOnDeathStartup = GlobalEvent("TibiaForever-OnDeath-Startup")

local function isPlaceholderEventName(eventName)
    local normalized = tostring(eventName or ""):upper()
    return normalized:find("REGISTER-NAME", 1, true) ~= nil
end

local function getValidRegisterEvents()
    local valid = {}
    for _, eventName in ipairs(registerEvents) do
        if type(eventName) == "string" and eventName ~= "" and not isPlaceholderEventName(eventName) then
            valid[#valid + 1] = eventName
        end
    end
    return valid
end

local function isWindowsOS()
    return package.config:sub(1, 1) == "\\"
end

local function listFilesRecursively(dir)
    local files = {}
    local command

    if isWindowsOS() then
        command = string.format('dir "%s" /b /s', dir)
    else
        command = string.format('find "%s" -type f', dir)
    end

    local process = io.popen(command)
    if not process then
        logger.error(string.format("[TibiaForever OnDeath Register] Error opening directory: %s", dir))
        return files
    end

    for file in process:lines() do
        if file:match("%.lua$") then
            files[#files + 1] = file
        end
    end

    process:close()
    return files
end

local function readMonsterNameFromFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        logger.error(string.format("[TibiaForever OnDeath Register] Error opening file: %s", filePath))
        return nil
    end

    local content = file:read("*all")
    file:close()

    return content:match('Game%.createMonsterType%("%s*(.-)%s*"%)')
end

local function loadMonsterList(dataDirectory)
    local monsters = {}
    local seen = {}

    local files = listFilesRecursively(dataDirectory)
    for _, filePath in ipairs(files) do
        local monsterName = readMonsterNameFromFile(filePath)
        if monsterName and not seen[monsterName] then
            seen[monsterName] = true
            monsters[#monsters + 1] = monsterName
        end
    end

    logger.info(string.format("[TibiaForever OnDeath Register] Monsters valid: %d", #monsters))
    return monsters
end

function tibiaForeverOnDeathStartup.onStartup()
    local validEvents = getValidRegisterEvents()
    if #validEvents == 0 then
        logger.warn("[TibiaForever OnDeath Register] No valid event names configured in registerEvents. Placeholder names were ignored.")
        return true
    end

    local selectedDataPack = configManager.getString(configKeys.DATA_DIRECTORY)
    local monsters = loadMonsterList(selectedDataPack)

    if #monsters == 0 then
        logger.error("[TibiaForever OnDeath Register] No monsters found.")
        return
    end

    for _, monster in ipairs(monsters) do
        if not table.contains(blockedNames, monster) then
            local monsterType = MonsterType(monster)
            if not monsterType then
                logger.error(string.format("[TibiaForever OnDeath Register] Monster with name %s is not a valid MonsterType.", monster))
            else
                for _, eventName in ipairs(validEvents) do
                    monsterType:registerEvent(eventName)
                end
            end
        end
    end

    logger.info(string.format("[TibiaForever OnDeath Register] Events registered: %s", table.concat(validEvents, ", ")))
    return true
end

tibiaForeverOnDeathStartup:register()
