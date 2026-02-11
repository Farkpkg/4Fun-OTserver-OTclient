local weeklyTasksLogin = CreatureEvent("WeeklyTasksLogin")

function weeklyTasksLogin.onLogin(player)
    WeeklyTasks.ensureTables()
    WeeklyTasks.ensureCurrentWeek(player)
    player:registerEvent("WeeklyTasksExtendedOpcode")
    return true
end

weeklyTasksLogin:register()

local weeklyTasksExtendedOpcode = CreatureEvent("WeeklyTasksExtendedOpcode")

function weeklyTasksExtendedOpcode.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= WeeklyTasks.opcode.action then
        return false
    end

    if type(buffer) ~= "string" or buffer == "" then
        return false
    end

    WeeklyTasks.handleClientAction(player, buffer)
    return true
end

weeklyTasksExtendedOpcode:register()

local weeklyTasksMonsterDeath = CreatureEvent("WeeklyTasksMonsterDeath")

function weeklyTasksMonsterDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    WeeklyTasks.onMonsterDeath(creature, killer, mostDamageKiller)
    return true
end

weeklyTasksMonsterDeath:register()

local weeklyTasksStartup = GlobalEvent("WeeklyTasksStartup")

function weeklyTasksStartup.onStartup()
    WeeklyTasks.ensureTables()
    WeeklyTasks.registerMonsterDeathEvents()
    return true
end

weeklyTasksStartup:register()
