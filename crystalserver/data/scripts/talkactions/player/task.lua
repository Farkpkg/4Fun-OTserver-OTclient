local taskCommand = TalkAction("!task")

local function sendUsage(player)
	player:sendTextMessage(MESSAGE_STATUS, "Uso: !task list | !task start <id> | !task status | !task check | !task sync")
end

function taskCommand.onSay(player, words, param)
	LinkedTasks.ensureTable()
	LinkedTasks.ensurePlayerRows(player)

	local args = {}
	for token in string.gmatch(param or "", "%S+") do
		table.insert(args, token)
	end
	local action = (args[1] or ""):lower()

	if action == "" then
		sendUsage(player)
		return false
	end

	if action == "list" then
		player:showTextDialog(1950, LinkedTasks.getListText())
		return false
	end

	if action == "start" then
		local taskId = tonumber(args[2])
		if not taskId then
			player:sendTextMessage(MESSAGE_FAILURE, "Informe o ID. Ex: !task start 1")
			return false
		end

		LinkedTasks.startTask(player, taskId)
		return false
	end

	if action == "status" then
		local activeTaskId = LinkedTasks.getActiveTaskId(player)
		if activeTaskId == 0 then
			player:sendTextMessage(MESSAGE_STATUS, "Nenhuma task ativa.")
			return false
		end

		local cfg = LinkedTasks.config[activeTaskId]
		local states = LinkedTasks.getPlayerTasks(player)
		local state = states[activeTaskId] or { progress = 0 }
		player:sendTextMessage(MESSAGE_STATUS, string.format("Task ativa [%d] %s: %d/%d", activeTaskId, cfg.name, state.progress, cfg.required))
		return false
	end

	if action == "check" then
		LinkedTasks.checkCollectTask(player)
		return false
	end

	if action == "sync" then
		LinkedTasks.sendFullSync(player)
		player:sendTextMessage(MESSAGE_STATUS, "Sincronização enviada ao client.")
		return false
	end

	sendUsage(player)
	return false
end

taskCommand:separator(" ")
taskCommand:groupType("normal")
taskCommand:register()
