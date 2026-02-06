local taskCommand = TalkAction("!task")

local function parseTaskParam(param)
	local args = param:splitTrimmed(" ")
	local action = (args[1] or ""):lower()
	local value = tonumber(args[2])
	return action, value
end

local function msg(player, text, type)
	player:sendTextMessage(type or MESSAGE_INFO_DESCR, text)
end

function taskCommand.onSay(player, words, param)
	if not player or not player:isPlayer() then
		return true
	end

	if not LinkedTasks then
		msg(player, "Sistema de tasks indisponível no momento.", MESSAGE_FAILURE)
		return true
	end

	LinkedTasks.ensurePlayerRows(player)

	local action, value = parseTaskParam(param)

	if action == "start" then
		if not value then
			msg(player, "Uso correto: !task start <taskId>", MESSAGE_FAILURE)
			return true
		end

		local ok, message = LinkedTasks.startTask(player, value)
		msg(player, message, ok and MESSAGE_EVENT_ADVANCE or MESSAGE_FAILURE)
		return true
	end

	if action == "check" then
		local ok, message = LinkedTasks.checkActiveTask(player)
		msg(player, message, ok and MESSAGE_EVENT_ADVANCE or MESSAGE_INFO_DESCR)
		return true
	end

	if action == "clear" then
		local ok, message = LinkedTasks.clearActiveTask(player)
		msg(player, message, ok and MESSAGE_EVENT_ADVANCE or MESSAGE_FAILURE)
		return true
	end

	if action == "bonus" then
		local ok, message = LinkedTasks.claimBonus(player)
		msg(player, message, ok and MESSAGE_EVENT_ADVANCE or MESSAGE_INFO_DESCR)
		return true
	end

	msg(
		player,
		"Comandos disponíveis:\n!task start <id>\n!task check\n!task clear\n!task bonus",
		MESSAGE_INFO_DESCR
	)

	return true
end

taskCommand:setDescription("[Usage]: !task start <id> | !task check | !task clear | !task bonus")
taskCommand:groupType("normal")
taskCommand:register()
