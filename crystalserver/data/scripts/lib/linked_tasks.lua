LinkedTasks = {
	status = {
		notStarted = 0,
		inProgress = 1,
		completed = 2,
	},
	opcode = {
		sync = 220,
		update = 221,
		request = 222,
	},
	storage = {
		activeTask = 92100,
		bonusClaims = 92101,
	},
	bonus = {
		requiredCompletions = 3,
		rewardGold = 5000,
		rewardExperience = 2500,
		rewardItems = {
			{ id = 3031, count = 20 },
		},
	},
	tasks = {
		[1] = {
			id = 1,
			name = "Slime Extermination",
			description = "Elimine 30 Slimes para liberar a segunda task.",
			objective = {
				type = "kill",
				targetName = "slime",
				required = 30,
			},
			rewards = {
				gold = 1000,
				experience = 2500,
				items = {
					{ id = 2148, count = 100 },
				},
			},
			unlock = nil,
		},
		[2] = {
			id = 2,
			name = "Rotworm Control",
			description = "Elimine 20 Rotworms para desbloquear a task de coleta.",
			objective = {
				type = "kill",
				targetName = "rotworm",
				required = 20,
			},
			rewards = {
				gold = 2500,
				experience = 5500,
				items = {
					{ id = 2152, count = 2 },
				},
			},
			unlock = 1,
		},
		[3] = {
			id = 3,
			name = "Collect Healing Supplies",
			description = "Colete 10 Health Potions para completar a cadeia.",
			objective = {
				type = "collect",
				itemId = 266,
				required = 10,
			},
			rewards = {
				gold = 4500,
				experience = 9000,
				items = {
					{ id = 7618, count = 5 },
				},
			},
			unlock = 2,
		},
	},
}

function LinkedTasks.getTask(taskId)
	return LinkedTasks.tasks[taskId]
end

function LinkedTasks.getPlayerId(player)
	return player:getGuid()
end

function LinkedTasks.getActiveTaskId(player)
	local taskId = player:getStorageValue(LinkedTasks.storage.activeTask)
	if taskId < 1 then
		return nil
	end
	if not LinkedTasks.tasks[taskId] then
		return nil
	end
	return taskId
end

function LinkedTasks.setActiveTaskId(player, taskId)
	player:setStorageValue(LinkedTasks.storage.activeTask, taskId or -1)
end

function LinkedTasks.ensurePlayerRows(player)
	local playerId = LinkedTasks.getPlayerId(player)
	for taskId, _ in pairs(LinkedTasks.tasks) do
		db.query(string.format("INSERT IGNORE INTO `player_tasks` (`player_id`, `task_id`, `progress`, `status`) VALUES (%d, %d, 0, %d)", playerId, taskId, LinkedTasks.status.notStarted))
	end
end

function LinkedTasks.getTaskState(player, taskId)
	local playerId = LinkedTasks.getPlayerId(player)
	local resultId = db.storeQuery(string.format("SELECT `progress`, `status` FROM `player_tasks` WHERE `player_id` = %d AND `task_id` = %d", playerId, taskId))
	if not resultId then
		return {
			progress = 0,
			status = LinkedTasks.status.notStarted,
		}
	end

	local state = {
		progress = Result.getNumber(resultId, "progress"),
		status = Result.getNumber(resultId, "status"),
	}
	Result.free(resultId)
	return state
end

function LinkedTasks.updateTaskState(player, taskId, progress, status)
	local playerId = LinkedTasks.getPlayerId(player)
	db.query(string.format(
		"UPDATE `player_tasks` SET `progress` = %d, `status` = %d WHERE `player_id` = %d AND `task_id` = %d",
		progress,
		status,
		playerId,
		taskId
	))
end

function LinkedTasks.hasCompleted(player, taskId)
	local state = LinkedTasks.getTaskState(player, taskId)
	return state.status == LinkedTasks.status.completed
end

function LinkedTasks.canStartTask(player, taskId)
	local task = LinkedTasks.getTask(taskId)
	if not task then
		return false, "Task inválida."
	end

	if LinkedTasks.getActiveTaskId(player) then
		return false, "Você já possui uma task ativa. Use !task check ou !task clear."
	end

	local state = LinkedTasks.getTaskState(player, taskId)
	if state.status == LinkedTasks.status.completed then
		return false, "Essa task já foi concluída neste ciclo."
	end

	if task.unlock and not LinkedTasks.hasCompleted(player, task.unlock) then
		return false, string.format("Você precisa concluir a task %d antes.", task.unlock)
	end

	return true, nil
end

function LinkedTasks.rewardPlayer(player, task)
	if task.rewards.gold > 0 then
		player:setBankBalance(player:getBankBalance() + task.rewards.gold)
	end

	if task.rewards.experience > 0 then
		player:addExperience(task.rewards.experience, true)
	end

	for _, rewardItem in ipairs(task.rewards.items or {}) do
		player:addItem(rewardItem.id, rewardItem.count)
	end
end

function LinkedTasks.startTask(player, taskId)
	local canStart, message = LinkedTasks.canStartTask(player, taskId)
	if not canStart then
		return false, message
	end

	LinkedTasks.updateTaskState(player, taskId, 0, LinkedTasks.status.inProgress)
	LinkedTasks.setActiveTaskId(player, taskId)
	return true, string.format("Task %d iniciada: %s.", taskId, LinkedTasks.tasks[taskId].name)
end

function LinkedTasks.clearActiveTask(player)
	local activeTaskId = LinkedTasks.getActiveTaskId(player)
	if not activeTaskId then
		return false, "Você não possui task ativa para limpar."
	end

	LinkedTasks.updateTaskState(player, activeTaskId, 0, LinkedTasks.status.notStarted)
	LinkedTasks.setActiveTaskId(player, nil)
	return true, "Task ativa limpa com sucesso."
end

function LinkedTasks.checkCollectObjective(player, task, state)
	if task.objective.type ~= "collect" then
		return false
	end

	local itemCount = player:getItemCount(task.objective.itemId)
	local progress = math.min(itemCount, task.objective.required)
	if progress == state.progress then
		return false
	end

	local status = LinkedTasks.status.inProgress
	if progress >= task.objective.required then
		status = LinkedTasks.status.completed
	end
	LinkedTasks.updateTaskState(player, task.id, progress, status)
	LinkedTasks.sendTaskUpdate(player, task.id, status, progress, task.objective.required)
	if status == LinkedTasks.status.completed then
		LinkedTasks.finishActiveTask(player, task)
	end
	return true
end

function LinkedTasks.finishActiveTask(player, task)
	LinkedTasks.rewardPlayer(player, task)
	LinkedTasks.setActiveTaskId(player, nil)
	LinkedTasks.updateTaskState(player, task.id, task.objective.required, LinkedTasks.status.completed)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Task concluída: %s.", task.name))
end

function LinkedTasks.checkActiveTask(player)
	local activeTaskId = LinkedTasks.getActiveTaskId(player)
	if not activeTaskId then
		return false, "Nenhuma task ativa no momento."
	end

	local task = LinkedTasks.getTask(activeTaskId)
	local state = LinkedTasks.getTaskState(player, activeTaskId)
	if task.objective.type == "collect" then
		LinkedTasks.checkCollectObjective(player, task, state)
		state = LinkedTasks.getTaskState(player, activeTaskId)
	end

	local progressText = string.format("%d/%d", state.progress, task.objective.required)
	return true, string.format("Task ativa: [%d] %s (%s).", task.id, task.name, progressText)
end

function LinkedTasks.getActiveTaskSummary(player)
	local activeTaskId = LinkedTasks.getActiveTaskId(player)
	if not activeTaskId then
		return false, "Nenhuma task ativa no momento."
	end

	local task = LinkedTasks.getTask(activeTaskId)
	local state = LinkedTasks.getTaskState(player, activeTaskId)
	local progress = state.progress
	if task.objective.type == "collect" then
		local itemCount = player:getItemCount(task.objective.itemId)
		progress = math.min(itemCount, task.objective.required)
	end

	local progressText = string.format("%d/%d", progress, task.objective.required)
	return true, string.format("Task ativa: [%d] %s (%s).", task.id, task.name, progressText)
end

function LinkedTasks.getCompletedCount(player)
	local playerId = LinkedTasks.getPlayerId(player)
	local resultId = db.storeQuery(string.format("SELECT COUNT(*) AS `total` FROM `player_tasks` WHERE `player_id` = %d AND `status` = %d", playerId, LinkedTasks.status.completed))
	if not resultId then
		return 0
	end
	local completed = Result.getNumber(resultId, "total")
	Result.free(resultId)
	return completed
end

function LinkedTasks.resetCycle(player)
	local playerId = LinkedTasks.getPlayerId(player)
	db.query(string.format("UPDATE `player_tasks` SET `progress` = 0, `status` = %d WHERE `player_id` = %d", LinkedTasks.status.notStarted, playerId))
	LinkedTasks.setActiveTaskId(player, nil)
end

function LinkedTasks.claimBonus(player)
	local completedCount = LinkedTasks.getCompletedCount(player)
	local totalTasks = 0
	for _ in pairs(LinkedTasks.tasks) do
		totalTasks = totalTasks + 1
	end

	if completedCount < totalTasks then
		return false, string.format("Bônus indisponível. Conclua todas as tasks (%d/%d).", completedCount, totalTasks)
	end

	local currentClaims = math.max(0, player:getStorageValue(LinkedTasks.storage.bonusClaims))
	player:setStorageValue(LinkedTasks.storage.bonusClaims, currentClaims + 1)
	player:setBankBalance(player:getBankBalance() + LinkedTasks.bonus.rewardGold)
	player:addExperience(LinkedTasks.bonus.rewardExperience, true)
	for _, rewardItem in ipairs(LinkedTasks.bonus.rewardItems) do
		player:addItem(rewardItem.id, rewardItem.count)
	end

	LinkedTasks.resetCycle(player)
	return true, "Bônus do ciclo recebido. As tasks foram reiniciadas para um novo ciclo."
end

local function resolveKillerPlayer(killer)
	if not killer then
		return nil
	end
	if killer:isPlayer() then
		return killer
	end
	local master = killer:getMaster()
	if master and master:isPlayer() then
		return master
	end
	return nil
end

function LinkedTasks.onDeath(creature, killer, mostDamageKiller)
	if not creature then
		return true
	end

	local targetMonster = creature:getMonster()
	if not targetMonster or targetMonster:getMaster() then
		return true
	end

	local player = resolveKillerPlayer(killer) or resolveKillerPlayer(mostDamageKiller)
	if not player then
		return true
	end

	local activeTaskId = LinkedTasks.getActiveTaskId(player)
	if not activeTaskId then
		return true
	end

	local task = LinkedTasks.getTask(activeTaskId)
	if not task or task.objective.type ~= "kill" then
		return true
	end

	if targetMonster:getName():lower() ~= task.objective.targetName:lower() then
		return true
	end

	local state = LinkedTasks.getTaskState(player, activeTaskId)
	if state.status ~= LinkedTasks.status.inProgress then
		return true
	end

	local progress = math.min(state.progress + 1, task.objective.required)
	local status = LinkedTasks.status.inProgress
	if progress >= task.objective.required then
		status = LinkedTasks.status.completed
	end

	LinkedTasks.updateTaskState(player, task.id, progress, status)
	LinkedTasks.sendTaskUpdate(player, task.id, status, progress, task.objective.required)

	if status == LinkedTasks.status.completed then
		LinkedTasks.finishActiveTask(player, task)
	end
	return true
end

local function sanitize(value)
	local text = tostring(value or "")
	-- Remove payload delimiters/control characters to keep the client parser safe.
	text = text:gsub("[\n\r\t]", " "):gsub("|", "/"):gsub("\\", "/")
	return text
end

local function encodeItems(items)
	if not items or #items == 0 then
		return "none"
	end

	local serialized = {}
	for _, item in ipairs(items) do
		table.insert(serialized, string.format("%d:%d", item.id, item.count))
	end
	return table.concat(serialized, ",")
end

function LinkedTasks.sendFullSync(player)
	if not player or not player:isUsingOtClient() then
		return true
	end

	LinkedTasks.ensurePlayerRows(player)
	local activeTaskId = LinkedTasks.getActiveTaskId(player) or 0
	local lines = {
		string.format("ACTIVE\t%d", activeTaskId),
	}

	for taskId, task in pairs(LinkedTasks.tasks) do
		local state = LinkedTasks.getTaskState(player, taskId)
		table.insert(lines, string.format(
			"TASK\t%d\t%d\t%d\t%d\t%s\t%s\t%s\t%s\t%d\t%d\t%s",
			task.id,
			state.status,
			state.progress,
			task.objective.required,
			sanitize(task.name),
			sanitize(task.description),
			sanitize(task.objective.type),
			sanitize(task.objective.targetName or task.objective.itemId or ""),
			task.rewards.gold,
			task.rewards.experience,
			encodeItems(task.rewards.items)
		))
	end

	player:sendExtendedOpcode(LinkedTasks.opcode.sync, table.concat(lines, "\n"))
	return true
end

function LinkedTasks.sendTaskBoard(player)
	return LinkedTasks.sendFullSync(player)
end

function LinkedTasks.sendTaskUpdate(player, taskId, status, progress, required)
	if not player or not player:isUsingOtClient() then
		return true
	end

	local payload = string.format("UPDATE\t%d\t%d\t%d\t%d", taskId, status, progress, required)
	player:sendExtendedOpcode(LinkedTasks.opcode.update, payload)
	return true
end
