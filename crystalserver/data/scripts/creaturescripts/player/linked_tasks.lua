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
		return true
	end

	if buffer == "board" then
		LinkedTasks.sendTaskBoard(player)
		return true
	end

	if buffer:starts("board_start:") then
		local taskId = tonumber(buffer:split(":")[2])
		if not taskId then
			player:sendTextMessage(MESSAGE_FAILURE, "Task inválida.")
			return true
		end

		local ok, message = LinkedTasks.startTask(player, taskId)
		player:sendTextMessage(ok and MESSAGE_EVENT_ADVANCE or MESSAGE_FAILURE, message)
		LinkedTasks.sendTaskBoard(player)
		return true
	end

	LinkedTasks.sendFullSync(player)
	return true
end

linkedTaskExtendedOpcode:register()
