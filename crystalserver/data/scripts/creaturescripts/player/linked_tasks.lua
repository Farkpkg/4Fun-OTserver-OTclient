local linkedTaskLogin = CreatureEvent("LinkedTaskLogin")

function linkedTaskLogin.onLogin(player)
	if not LinkedTasks then
		return true
	end

	LinkedTasks.ensurePlayerRows(player)
	player:registerEvent("LinkedTaskDeath")
	player:registerEvent("LinkedTaskExtendedOpcode")
	addEvent(function(playerId)
		local onlinePlayer = Player(playerId)
		if onlinePlayer then
			LinkedTasks.sendFullSync(onlinePlayer)
		end
	end, 1000, player:getId())
	return true
end

linkedTaskLogin:register()

local linkedTaskDeath = CreatureEvent("LinkedTaskDeath")

function linkedTaskDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if not LinkedTasks then
		return true
	end

	return LinkedTasks.onDeath(creature, killer, mostDamageKiller)
end

linkedTaskDeath:register()

local linkedTaskExtendedOpcode = CreatureEvent("LinkedTaskExtendedOpcode")

function linkedTaskExtendedOpcode.onExtendedOpcode(player, opcode, buffer)
	if not LinkedTasks then
		return true
	end

	if opcode ~= LinkedTasks.opcode.request then
		return true
	end

	if type(buffer) ~= "string" or buffer == "" then
		return true
	end

	if buffer == "check" then
		LinkedTasks.checkActiveTask(player)
	elseif buffer == "sync" then
		LinkedTasks.sendFullSync(player)
	end

	return true
end

linkedTaskExtendedOpcode:register()
