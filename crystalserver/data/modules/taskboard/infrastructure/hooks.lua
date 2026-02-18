TaskBoardHooks = TaskBoardHooks or {}

local basePath = _G.TaskBoardBasePath or string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

if not TaskBoardService then
    dofile(basePath .. "/application/service.lua")
end
if not TaskBoardNetwork then
    dofile(basePath .. "/infrastructure/network.lua")
end
if not TaskBoardCache then
    dofile(basePath .. "/infrastructure/cache.lua")
end

if not TaskBoardGenerator then
    dofile(basePath .. "/application/generator.lua")
end

local function sendServiceResult(player, result)
    if type(result) ~= "table" then
        return
    end

    if result.sync then
        TaskBoardNetwork.sendSync(player, result.sync)
    end

    for _, delta in ipairs(result.deltas or {}) do
        TaskBoardNetwork.sendDelta(player, delta)
    end
end

local taskBoardLogin = CreatureEvent("TaskBoardLogin")

function taskBoardLogin.onLogin(player)
    player:registerEvent("TaskBoardExtendedOpcode")

    local weekKey = os.date("!%Y-W%V")
    local result = TaskBoardService.openBoard(player:getGuid(), weekKey)
    sendServiceResult(player, result)

    return true
end

taskBoardLogin:register()

local taskBoardLogout = CreatureEvent("TaskBoardLogout")

function taskBoardLogout.onLogout(player)
    TaskBoardCache.clear(player:getGuid())
    return true
end

taskBoardLogout:register()

local taskBoardKill = CreatureEvent("TaskBoardKill")

local function getPlayerFromKiller(killer)
    if not killer then
        return nil
    end

    if killer:isPlayer() then
        return killer
    end

    if killer:isMonster() and killer:getMaster() and killer:getMaster():isPlayer() then
        return killer:getMaster()
    end

    return nil
end

function taskBoardKill.onDeath(creature, _corpse, killer, mostDamageKiller, _lastHitUnjustified, _mostDamageUnjustified)
    if not creature or not creature:isMonster() then
        return true
    end

    if creature:hasBeenSummoned() then
        return true
    end

    local player = getPlayerFromKiller(killer) or getPlayerFromKiller(mostDamageKiller)
    if not player then
        return true
    end

    local result = TaskBoardService.onKill(player:getGuid(), creature:getName())
    sendServiceResult(player, result)

    return true
end

taskBoardKill:register()

local function registerTaskBoardMonsterDeathEvents()
    local names = {}
    local difficulties = { "Beginner", "Adept", "Expert", "Master" }

    for _, difficulty in ipairs(difficulties) do
        for _, bounty in ipairs(TaskBoardGenerator.generateBounties(difficulty, "register") or {}) do
            local dto = bounty.toDTO and bounty:toDTO() or bounty
            local monsterName = dto and dto.monsterName
            if type(monsterName) == "string" and monsterName ~= "" then
                names[monsterName:lower()] = monsterName
            end
        end

        for _, task in ipairs(TaskBoardGenerator.generateWeeklyTasks(difficulty, "register") or {}) do
            local dto = task.toDTO and task:toDTO() or task
            if dto and dto.subtype == "kill" and type(dto.targetName) == "string" and dto.targetName ~= "" then
                names[dto.targetName:lower()] = dto.targetName
            end
        end
    end

    local total = 0
    for _, monsterName in pairs(names) do
        local monsterType = MonsterType(monsterName)
        if monsterType then
            monsterType:registerEvent("TaskBoardKill")
            total = total + 1
        end
    end

    logger.info(string.format("[TaskBoard] Monster death events registered: %d", total))
end

local taskBoardStartup = GlobalEvent("TaskBoardStartup")

function taskBoardStartup.onStartup()
    local currentWeekKey = os.date("!%Y-W%V")
    registerTaskBoardMonsterDeathEvents()
    logger.info(string.format("[TaskBoard] Startup active week key: %s", currentWeekKey))
    return true
end

taskBoardStartup:register()

function TaskBoardHooks.init()
    return true
end

return TaskBoardHooks
