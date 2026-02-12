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
    player:registerEvent("TaskBoardKill")

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

function taskBoardKill.onKill(creature, target)
    if not creature or not creature:isPlayer() then
        return true
    end

    if not target or not target:isMonster() then
        return true
    end

    local result = TaskBoardService.onKill(creature:getGuid(), target:getName())
    sendServiceResult(creature, result)

    return true
end

taskBoardKill:register()

local taskBoardStartup = GlobalEvent("TaskBoardStartup")

function taskBoardStartup.onStartup()
    local currentWeekKey = os.date("!%Y-W%V")
    logger.info(string.format("[TaskBoard] Startup active week key: %s", currentWeekKey))
    return true
end

taskBoardStartup:register()

function TaskBoardHooks.init()
    return true
end

return TaskBoardHooks
