LinkedTasks = LinkedTasks or {}

LinkedTasks.opcode = {
	sync = 220,
	update = 221,
	request = 222,
}

LinkedTasks.status = {
	notStarted = 0,
	inProgress = 1,
	completed = 2,
}

LinkedTasks.activeStorage = 985200

LinkedTasks.config = {
	[1] = {
		name = "Rat Hunter",
		description = "Elimine ratos para treinar o sistema de tasks.",
		objectiveType = "kill",
		objectiveTarget = "rat",
		required = 25,
		rewardGold = 1000,
		rewardExperience = 2500,
		rewardItems = {},
	},
	[2] = {
		name = "Wolf Exterminator",
		description = "Mate lobos e receba uma recompensa maior.",
		objectiveType = "kill",
		objectiveTarget = "wolf",
		required = 20,
		rewardGold = 2500,
		rewardExperience = 6000,
		rewardItems = {
			{ itemId = 2666, count = 10 },
		},
	},
	[3] = {
		name = "Supply Collector",
		description = "Colete ham e reporte via !task check.",
		objectiveType = "collect",
		objectiveTarget = "2671",
		required = 15,
		rewardGold = 1500,
		rewardExperience = 3500,
		rewardItems = {},
	},
}

local function sanitizeField(value)
	local text = tostring(value or "")
	text = text:gsub("\r", " "):gsub("\n", " "):gsub("\t", " ")
	return text
end

local function rewardItemsToString(rewardItems)
	if not rewardItems or #rewardItems == 0 then
		return "none"
	end

	local out = {}
	for _, reward in ipairs(rewardItems) do
		if reward.itemId and reward.count and reward.count > 0 then
			table.insert(out, string.format("%d:%d", reward.itemId, reward.count))
		end
	end

	if #out == 0 then
		return "none"
	end

	return table.concat(out, ",")
end


local function getPlayerFromKiller(killer)
	if not killer then
		return nil
	end

	if killer:isPlayer() then
		return killer
	end

	if killer:isMonster() and killer:getMaster() and killer:getMaster():isPlayer() then
		return killer:getMaster()
	end

	return nil
end

function LinkedTasks.ensureTable()
	db.query([[
		CREATE TABLE IF NOT EXISTS `player_tasks` (
			`player_id` INT UNSIGNED NOT NULL,
			`task_id` SMALLINT UNSIGNED NOT NULL,
			`status` TINYINT UNSIGNED NOT NULL DEFAULT 0,
			`progress` INT UNSIGNED NOT NULL DEFAULT 0,
			`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			PRIMARY KEY (`player_id`, `task_id`),
			CONSTRAINT `fk_player_tasks_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])
end

function LinkedTasks.ensurePlayerRows(player)
	if not player then
		return
	end

	for taskId in pairs(LinkedTasks.config) do
		db.query(string.format(
			"INSERT IGNORE INTO `player_tasks` (`player_id`, `task_id`, `status`, `progress`) VALUES (%d, %d, %d, 0)",
			player:getGuid(),
			taskId,
			LinkedTasks.status.notStarted
		))
	end
end

function LinkedTasks.getPlayerTasks(player)
	local tasks = {}
	if not player then
		return tasks
	end

	local resultId = db.storeQuery(string.format(
		"SELECT `task_id`, `status`, `progress` FROM `player_tasks` WHERE `player_id` = %d",
		player:getGuid()
	))

	if not resultId then
		return tasks
	end

	repeat
		local taskId = Result.getNumber(resultId, "task_id")
		tasks[taskId] = {
			status = Result.getNumber(resultId, "status"),
			progress = Result.getNumber(resultId, "progress"),
		}
	until not Result.next(resultId)
	Result.free(resultId)

	return tasks
end

function LinkedTasks.getActiveTaskId(player)
	if not player then
		return 0
	end

	local activeTaskId = player:getStorageValue(LinkedTasks.activeStorage)
	if activeTaskId < 1 or not LinkedTasks.config[activeTaskId] then
		return 0
	end
	return activeTaskId
end

function LinkedTasks.setActiveTaskId(player, taskId)
	if not player then
		return
	end
	player:setStorageValue(LinkedTasks.activeStorage, taskId)
end

function LinkedTasks.saveTaskState(player, taskId, status, progress)
	if not player or not LinkedTasks.config[taskId] then
		return false
	end

	return db.query(string.format(
		"UPDATE `player_tasks` SET `status` = %d, `progress` = %d WHERE `player_id` = %d AND `task_id` = %d",
		status,
		progress,
		player:getGuid(),
		taskId
	))
end

function LinkedTasks.sendTaskUpdate(player, taskId, status, progress)
	if not player then
		return
	end

	local cfg = LinkedTasks.config[taskId]
	if not cfg then
		return
	end

	local payload = string.format("UPDATE\t%d\t%d\t%d\t%d", taskId, status, progress, cfg.required)
	player:sendExtendedOpcode(LinkedTasks.opcode.update, payload)
end

function LinkedTasks.sendFullSync(player)
	if not player then
		return
	end

	LinkedTasks.ensurePlayerRows(player)
	local tasks = LinkedTasks.getPlayerTasks(player)
	local activeTaskId = LinkedTasks.getActiveTaskId(player)

	local lines = { string.format("ACTIVE\t%d", activeTaskId) }
	for taskId, cfg in pairs(LinkedTasks.config) do
		local state = tasks[taskId] or { status = LinkedTasks.status.notStarted, progress = 0 }
		local rewardItems = rewardItemsToString(cfg.rewardItems)
		table.insert(lines, string.format(
			"TASK\t%d\t%d\t%d\t%d\t%s\t%s\t%s\t%s\t%d\t%d\t%s",
			taskId,
			state.status,
			state.progress,
			cfg.required,
			sanitizeField(cfg.name),
			sanitizeField(cfg.description),
			sanitizeField(cfg.objectiveType),
			sanitizeField(cfg.objectiveTarget),
			cfg.rewardGold,
			cfg.rewardExperience,
			rewardItems
		))
	end

	player:sendExtendedOpcode(LinkedTasks.opcode.sync, table.concat(lines, "\n"))
end

function LinkedTasks.startTask(player, taskId)
	local cfg = LinkedTasks.config[taskId]
	if not cfg then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Task inválida. Use !task list para ver os IDs.")
		return false
	end

	local activeTaskId = LinkedTasks.getActiveTaskId(player)
	if activeTaskId > 0 and activeTaskId ~= taskId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Você já possui uma task ativa. Use !task status.")
		return false
	end

	LinkedTasks.ensurePlayerRows(player)
	LinkedTasks.saveTaskState(player, taskId, LinkedTasks.status.inProgress, 0)
	LinkedTasks.setActiveTaskId(player, taskId)
	LinkedTasks.sendTaskUpdate(player, taskId, LinkedTasks.status.inProgress, 0)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Task iniciada: [%d] %s", taskId, cfg.name))
	return true
end

function LinkedTasks.finishTask(player, taskId, progress)
	local cfg = LinkedTasks.config[taskId]
	if not cfg then
		return false
	end

	LinkedTasks.saveTaskState(player, taskId, LinkedTasks.status.completed, progress)
	LinkedTasks.setActiveTaskId(player, 0)

	if cfg.rewardGold > 0 then
		player:setBankBalance(player:getBankBalance() + cfg.rewardGold)
	end
	if cfg.rewardExperience > 0 then
		player:addExperience(cfg.rewardExperience, true)
	end
	for _, reward in ipairs(cfg.rewardItems or {}) do
		player:addItem(reward.itemId, reward.count)
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Task concluída: %s", cfg.name))
	LinkedTasks.sendFullSync(player)
	return true
end

function LinkedTasks.checkCollectTask(player)
	local activeTaskId = LinkedTasks.getActiveTaskId(player)
	if activeTaskId == 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você não possui task ativa.")
		return false
	end

	local cfg = LinkedTasks.config[activeTaskId]
	if cfg.objectiveType ~= "collect" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "A task ativa não é de coleta.")
		return false
	end

	local itemId = tonumber(cfg.objectiveTarget)
	if not itemId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Configuração da task inválida (collect sem itemId).")
		return false
	end

	local currentCount = player:getItemCount(itemId)
	local progress = math.min(currentCount, cfg.required)
	LinkedTasks.saveTaskState(player, activeTaskId, LinkedTasks.status.inProgress, progress)
	LinkedTasks.sendTaskUpdate(player, activeTaskId, LinkedTasks.status.inProgress, progress)

	if progress >= cfg.required then
		return LinkedTasks.finishTask(player, activeTaskId, progress)
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Progresso atualizado: %d/%d", progress, cfg.required))
	return true
end

function LinkedTasks.onPlayerKill(player, target)
	if not player or not target or not target:isMonster() then
		return false
	end

	if target:hasBeenSummoned() then
		return false
	end

	local activeTaskId = LinkedTasks.getActiveTaskId(player)
	if activeTaskId == 0 then
		return false
	end

	local cfg = LinkedTasks.config[activeTaskId]
	if not cfg or cfg.objectiveType ~= "kill" then
		return false
	end

	if target:getName():lower() ~= cfg.objectiveTarget:lower() then
		return false
	end

	local tasks = LinkedTasks.getPlayerTasks(player)
	local state = tasks[activeTaskId] or { status = LinkedTasks.status.notStarted, progress = 0 }
	if state.status ~= LinkedTasks.status.inProgress then
		return false
	end

	local nextProgress = math.min(state.progress + 1, cfg.required)
	LinkedTasks.saveTaskState(player, activeTaskId, LinkedTasks.status.inProgress, nextProgress)
	LinkedTasks.sendTaskUpdate(player, activeTaskId, LinkedTasks.status.inProgress, nextProgress)

	if nextProgress >= cfg.required then
		LinkedTasks.finishTask(player, activeTaskId, nextProgress)
	end
	return true
end

function LinkedTasks.handleClientRequest(player, payload)
	if not player then
		return false
	end

	if payload == "sync" then
		LinkedTasks.sendFullSync(player)
		return true
	end

	if payload == "check" then
		LinkedTasks.checkCollectTask(player)
		return true
	end

	return false
end

function LinkedTasks.getListText()
	local lines = { "Linked Tasks disponíveis:" }
	for taskId, cfg in pairs(LinkedTasks.config) do
		table.insert(lines, string.format("[%d] %s - %s (%d)", taskId, cfg.name, cfg.objectiveType, cfg.required))
	end
	return table.concat(lines, "\n")
end


function LinkedTasks.onMonsterDeath(creature, killer, mostDamageKiller)
	if not creature or not creature:isMonster() then
		return false
	end

	if creature:hasBeenSummoned() then
		return false
	end

	local player = getPlayerFromKiller(killer) or getPlayerFromKiller(mostDamageKiller)
	if not player then
		return false
	end

	return LinkedTasks.onPlayerKill(player, creature)
end

function LinkedTasks.registerMonsterDeathEvents()
	for _, cfg in pairs(LinkedTasks.config) do
		if cfg.objectiveType == "kill" and cfg.objectiveTarget and cfg.objectiveTarget ~= "" then
			local mType = MonsterType(cfg.objectiveTarget)
			if mType then
				mType:registerEvent("LinkedTasksMonsterDeath")
			else
			end
		end
	end
end
