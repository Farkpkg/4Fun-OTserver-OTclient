local taskCommand = TalkAction("!task")

local function parseTaskParam(param)
	local args = param:splitTrimmed(" ")
	local action = (args[1] or ""):lower()
	local value = tonumber(args[2])
	return action, value
end

function taskCommand.onSay(player, words, param)
	if not LinkedTasks then
		player:sendTextMessage(MESSAGE_FAILURE, "Sistema de tasks indisponível no momento.")
		return true
	end

	LinkedTasks.ensurePlayerRows(player)

	local action, value = parseTaskParam(param)
	if action == "start" then
		if not value then
			player:sendTextMessage(MESSAGE_FAILURE, "Uso: !task start <taskId>")
			return true
		end
		local ok, message = LinkedTasks.startTask(player, value)
		player:sendTextMessage(ok and MESSAGE_EVENT_ADVANCE or MESSAGE_FAILURE, message)
		return true
	end

	if action == "check" then
		local ok, message = LinkedTasks.checkActiveTask(player)
		player:sendTextMessage(ok and MESSAGE_EVENT_ADVANCE or MESSAGE_STATUS_WARNING, message)
		return true
	end

	if action == "clear" then
		local ok, message = LinkedTasks.clearActiveTask(player)
		player:sendTextMessage(ok and MESSAGE_EVENT_ADVANCE or MESSAGE_FAILURE, message)
		return true
	end

	if action == "bonus" then
		local ok, message = LinkedTasks.claimBonus(player)
		player:sendTextMessage(ok and MESSAGE_EVENT_ADVANCE or MESSAGE_STATUS_WARNING, message)
		return true
	end

	player:sendTextMessage(MESSAGE_INFO_DESCR, "Comandos: !task start <taskId>, !task check, !task clear, !task bonus")
	return true
end

taskCommand:setDescription("[Usage]: !task start <id> | !task check | !task clear | !task bonus")
taskCommand:groupType("normal")
taskCommand:register()
