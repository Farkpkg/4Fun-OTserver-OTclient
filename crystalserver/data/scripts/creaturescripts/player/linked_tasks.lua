local linkedTasksLogin = CreatureEvent("LinkedTasksLogin")

function linkedTasksLogin.onLogin(player)
	LinkedTasks.ensureTable()
	LinkedTasks.ensurePlayerRows(player)
	player:registerEvent("LinkedTasksExtendedOpcode")
	addEvent(function(playerId)
		local onlinePlayer = Player(playerId)
		if onlinePlayer then
			LinkedTasks.sendFullSync(onlinePlayer)
		end
	end, 1000, player:getId())
	return true
end

linkedTasksLogin:register()

local linkedTasksExtendedOpcode = CreatureEvent("LinkedTasksExtendedOpcode")

function linkedTasksExtendedOpcode.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= LinkedTasks.opcode.request then
		return false
	end

	if type(buffer) ~= "string" or buffer == "" then
		return false
	end

	LinkedTasks.handleClientRequest(player, buffer)
	return true
end

linkedTasksExtendedOpcode:register()

local linkedTasksMonsterDeath = CreatureEvent("LinkedTasksMonsterDeath")

function linkedTasksMonsterDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	LinkedTasks.onMonsterDeath(creature, killer, mostDamageKiller)
	return true
end

linkedTasksMonsterDeath:register()

local linkedTasksStartup = GlobalEvent("LinkedTasksStartup")

function linkedTasksStartup.onStartup()
	LinkedTasks.ensureTable()
	LinkedTasks.registerMonsterDeathEvents()
	return true
end

linkedTasksStartup:register()
