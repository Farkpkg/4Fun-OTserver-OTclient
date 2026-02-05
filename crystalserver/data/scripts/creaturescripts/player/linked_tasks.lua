local linkedTaskLogin = CreatureEvent("LinkedTaskLogin")

function linkedTaskLogin.onLogin(player)
	LinkedTasks.ensurePlayerRows(player)
	player:registerEvent("LinkedTaskKill")
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

local linkedTaskKill = CreatureEvent("LinkedTaskKill")

function linkedTaskKill.onKill(player, target)
	if not player or not player:isPlayer() then
		return true
	end

	if not target or not target:isMonster() then
		return true
	end

	return LinkedTasks.onKill(player, target)
end

linkedTaskKill:register()

local linkedTaskExtendedOpcode = CreatureEvent("LinkedTaskExtendedOpcode")

function linkedTaskExtendedOpcode.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= LinkedTasks.opcode.request then
		return true
	end

	if buffer == "check" then
		LinkedTasks.checkActiveTask(player)
	else
		LinkedTasks.sendFullSync(player)
	end

	return true
end

linkedTaskExtendedOpcode:register()
