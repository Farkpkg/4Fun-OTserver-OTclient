local taskCommand = TalkAction("!task")

local TASK_MESSAGE_STATUS = MESSAGE_STATUS or MESSAGE_EVENT_ADVANCE or MESSAGE_LOGIN
local TASK_MESSAGE_INFO = MESSAGE_EVENT_ADVANCE or MESSAGE_STATUS or MESSAGE_LOGIN
local TASK_MESSAGE_ERROR = MESSAGE_FAILURE or MESSAGE_STATUS or MESSAGE_EVENT_ADVANCE

local function sendTaskMessage(player, messageType, text)
	if not player then
		return
	end

	if messageType then
		player:sendTextMessage(messageType, text)
	else
		player:sendCancelMessage(text)
	end
end

local function sendUsage(player)
	sendTaskMessage(player, TASK_MESSAGE_STATUS, "Uso: !task list | !task start <id> | !task status | !task check | !task sync")
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
			sendTaskMessage(player, TASK_MESSAGE_ERROR, "Informe o ID. Ex: !task start 1")
			return false
		end

		LinkedTasks.startTask(player, taskId)
		return false
	end

	if action == "status" then
		local activeTaskId = LinkedTasks.getActiveTaskId(player)
		if activeTaskId == 0 then
			sendTaskMessage(player, TASK_MESSAGE_STATUS, "Nenhuma task ativa.")
			return false
		end

		local cfg = LinkedTasks.config[activeTaskId]
		local states = LinkedTasks.getPlayerTasks(player)
		local state = states[activeTaskId] or { progress = 0 }
		sendTaskMessage(player, TASK_MESSAGE_STATUS, string.format("Task ativa [%d] %s: %d/%d", activeTaskId, cfg.name, state.progress, cfg.required))
		return false
	end

	if action == "check" then
		LinkedTasks.checkCollectTask(player)
		return false
	end

	if action == "sync" then
		LinkedTasks.sendFullSync(player)
		sendTaskMessage(player, TASK_MESSAGE_INFO, "Sincronização enviada ao client.")
		return false
	end

	sendUsage(player)
	return false
end

taskCommand:separator(" ")
taskCommand:groupType("normal")
taskCommand:register()
