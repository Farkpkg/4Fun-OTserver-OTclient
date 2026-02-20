TaskBoardDB = {}

local function tobool(value)
	return tonumber(value) == 1
end

function TaskBoardDB.loadCurrencies(playerId)
	local data = {
		rerollTokens = 0,
		bountyPoints = 0,
		huntingPoints = 0,
		soulseals = 0,
		lastDaily = "",
		weeklySeed = 0,
		bountySeed = 0,
	}

	local query = db.storeQuery("SELECT `reroll_tokens`, `bounty_points`, `hunting_points`, `soulseals`, `last_daily`, `weekly_seed`, `bounty_seed` FROM `player_task_currencies` WHERE `player_id` = " .. playerId)
	if not query then
		return data
	end

	data.rerollTokens = result.getNumber(query, "reroll_tokens")
	data.bountyPoints = result.getNumber(query, "bounty_points")
	data.huntingPoints = result.getNumber(query, "hunting_points")
	data.soulseals = result.getNumber(query, "soulseals")
	data.lastDaily = result.getString(query, "last_daily")
	data.weeklySeed = result.getNumber(query, "weekly_seed")
	data.bountySeed = result.getNumber(query, "bounty_seed")
	result.free(query)
	return data
end

function TaskBoardDB.saveCurrencies(playerId, data)
	local lastDaily = data.lastDaily
	if not lastDaily or lastDaily == "" then
		lastDaily = "NULL"
	else
		lastDaily = db.escapeString(lastDaily)
	end

	return db.query("INSERT INTO `player_task_currencies` (`player_id`, `reroll_tokens`, `bounty_points`, `hunting_points`, `soulseals`, `last_daily`, `weekly_seed`, `bounty_seed`) VALUES ("
		.. playerId
		.. ", "
		.. math.max(0, data.rerollTokens or 0)
		.. ", "
		.. math.max(0, data.bountyPoints or 0)
		.. ", "
		.. math.max(0, data.huntingPoints or 0)
		.. ", "
		.. math.max(0, data.soulseals or 0)
		.. ", "
		.. lastDaily
		.. ", "
		.. math.max(0, data.weeklySeed or 0)
		.. ", "
		.. math.max(0, data.bountySeed or 0)
		.. ") ON DUPLICATE KEY UPDATE `reroll_tokens` = VALUES(`reroll_tokens`), `bounty_points` = VALUES(`bounty_points`), `hunting_points` = VALUES(`hunting_points`), `soulseals` = VALUES(`soulseals`), `last_daily` = VALUES(`last_daily`), `weekly_seed` = VALUES(`weekly_seed`), `bounty_seed` = VALUES(`bounty_seed`)")
end

function TaskBoardDB.loadBountyTasks(playerId)
	local tasks = {}
	local query = db.storeQuery("SELECT `slot`, `creature_id`, `creature_name`, `kills`, `max_kills`, `xp_reward`, `bp_reward`, `rt_reward`, `tier`, `difficulty`, `completed` FROM `player_bounty_tasks` WHERE `player_id` = " .. playerId)
	if not query then
		return tasks
	end

	repeat
		local slot = result.getNumber(query, "slot")
		tasks[slot] = {
			slot = slot,
			creatureId = result.getNumber(query, "creature_id"),
			creatureName = result.getString(query, "creature_name"),
			kills = result.getNumber(query, "kills"),
			maxKills = result.getNumber(query, "max_kills"),
			xpReward = result.getNumber(query, "xp_reward"),
			bpReward = result.getNumber(query, "bp_reward"),
			rtReward = result.getNumber(query, "rt_reward"),
			tier = result.getNumber(query, "tier"),
			difficulty = result.getNumber(query, "difficulty"),
			completed = tobool(result.getNumber(query, "completed")),
		}
	until not result.next(query)

	result.free(query)
	return tasks
end

function TaskBoardDB.saveBountyTask(playerId, slot, task)
	return db.query("INSERT INTO `player_bounty_tasks` (`player_id`, `slot`, `creature_id`, `creature_name`, `kills`, `max_kills`, `xp_reward`, `bp_reward`, `rt_reward`, `tier`, `difficulty`, `completed`) VALUES ("
		.. playerId
		.. ", "
		.. slot
		.. ", "
		.. (task.creatureId or 0)
		.. ", "
		.. db.escapeString(task.creatureName or "")
		.. ", "
		.. (task.kills or 0)
		.. ", "
		.. (task.maxKills or 0)
		.. ", "
		.. (task.xpReward or 0)
		.. ", "
		.. (task.bpReward or 0)
		.. ", "
		.. (task.rtReward or 0)
		.. ", "
		.. (task.tier or 0)
		.. ", "
		.. (task.difficulty or 0)
		.. ", "
		.. (task.completed and 1 or 0)
		.. ") ON DUPLICATE KEY UPDATE `creature_id` = VALUES(`creature_id`), `creature_name` = VALUES(`creature_name`), `kills` = VALUES(`kills`), `max_kills` = VALUES(`max_kills`), `xp_reward` = VALUES(`xp_reward`), `bp_reward` = VALUES(`bp_reward`), `rt_reward` = VALUES(`rt_reward`), `tier` = VALUES(`tier`), `difficulty` = VALUES(`difficulty`), `completed` = VALUES(`completed`)")
end

function TaskBoardDB.loadWeeklyTasks(playerId)
	local weekly = { killTasks = {}, deliveryTasks = {} }
	local query = db.storeQuery("SELECT `task_type`, `slot`, `target_name`, `target_id`, `current_count`, `max_count`, `completed`, `week_number` FROM `player_weekly_tasks` WHERE `player_id` = " .. playerId)
	if not query then
		return weekly
	end

	repeat
		local taskType = result.getNumber(query, "task_type")
		local slot = result.getNumber(query, "slot")
		local row = {
			slot = slot,
			targetName = result.getString(query, "target_name"),
			targetId = result.getNumber(query, "target_id"),
			currentCount = result.getNumber(query, "current_count"),
			maxCount = result.getNumber(query, "max_count"),
			completed = tobool(result.getNumber(query, "completed")),
			weekNumber = result.getNumber(query, "week_number"),
		}

		if taskType == 0 then
			weekly.killTasks[slot] = row
		else
			weekly.deliveryTasks[slot] = row
		end
	until not result.next(query)

	result.free(query)
	return weekly
end

function TaskBoardDB.saveWeeklyTask(playerId, taskType, slot, task)
	return db.query("INSERT INTO `player_weekly_tasks` (`player_id`, `task_type`, `slot`, `target_name`, `target_id`, `current_count`, `max_count`, `completed`, `week_number`) VALUES ("
		.. playerId
		.. ", "
		.. taskType
		.. ", "
		.. slot
		.. ", "
		.. db.escapeString(task.targetName or "")
		.. ", "
		.. (task.targetId or 0)
		.. ", "
		.. (task.currentCount or 0)
		.. ", "
		.. (task.maxCount or 0)
		.. ", "
		.. (task.completed and 1 or 0)
		.. ", "
		.. (task.weekNumber or 0)
		.. ") ON DUPLICATE KEY UPDATE `target_name` = VALUES(`target_name`), `target_id` = VALUES(`target_id`), `current_count` = VALUES(`current_count`), `max_count` = VALUES(`max_count`), `completed` = VALUES(`completed`), `week_number` = VALUES(`week_number`)")
end

function TaskBoardDB.loadTalisman(playerId)
	local talisman = {}
	local query = db.storeQuery("SELECT `slot`, `level`, `current_pct` FROM `player_talisman` WHERE `player_id` = " .. playerId)
	if not query then
		return talisman
	end

	repeat
		local slot = result.getNumber(query, "slot")
		talisman[slot] = {
			level = result.getNumber(query, "level"),
			currentPct = result.getNumber(query, "current_pct"),
		}
	until not result.next(query)

	result.free(query)
	return talisman
end

function TaskBoardDB.saveTalisman(playerId, slot, data)
	return db.query("INSERT INTO `player_talisman` (`player_id`, `slot`, `level`, `current_pct`) VALUES ("
		.. playerId
		.. ", "
		.. slot
		.. ", "
		.. (data.level or 1)
		.. ", "
		.. (data.currentPct or 0)
		.. ") ON DUPLICATE KEY UPDATE `level` = VALUES(`level`), `current_pct` = VALUES(`current_pct`)")
end

function TaskBoardDB.loadPreferred(playerId)
	local data = {
		preferred = {},
		unwanted = {},
		extraSlots = TaskBoardDB.loadExtraSlots(playerId),
	}
	local query = db.storeQuery("SELECT `list_type`, `slot`, `creature_id`, `creature_name` FROM `player_task_preferred` WHERE `player_id` = " .. playerId)
	if not query then
		return data
	end

	repeat
		local listType = result.getNumber(query, "list_type")
		local slot = result.getNumber(query, "slot")
		local entry = {
			creatureId = result.getNumber(query, "creature_id"),
			creatureName = result.getString(query, "creature_name"),
		}

		if listType == 0 then
			data.preferred[slot] = entry
		else
			data.unwanted[slot] = entry
		end
	until not result.next(query)

	result.free(query)
	return data
end

function TaskBoardDB.savePreferred(playerId, listType, slot, creatureId, name)
	return db.query("INSERT INTO `player_task_preferred` (`player_id`, `list_type`, `slot`, `creature_id`, `creature_name`) VALUES ("
		.. playerId
		.. ", "
		.. listType
		.. ", "
		.. slot
		.. ", "
		.. (creatureId or 0)
		.. ", "
		.. db.escapeString(name or "")
		.. ") ON DUPLICATE KEY UPDATE `creature_id` = VALUES(`creature_id`), `creature_name` = VALUES(`creature_name`)")
end

function TaskBoardDB.clearPreferred(playerId, listType, slot)
	return db.query("DELETE FROM `player_task_preferred` WHERE `player_id` = " .. playerId .. " AND `list_type` = " .. listType .. " AND `slot` = " .. slot)
end

function TaskBoardDB.loadExtraSlots(playerId)
	local query = db.storeQuery("SELECT `extra_slots` FROM `player_task_extra_slots` WHERE `player_id` = " .. playerId)
	if not query then
		return 0
	end

	local bitmask = result.getNumber(query, "extra_slots")
	result.free(query)
	return bitmask
end

function TaskBoardDB.saveExtraSlots(playerId, bitmask)
	return db.query("INSERT INTO `player_task_extra_slots` (`player_id`, `extra_slots`) VALUES (" .. playerId .. ", " .. (bitmask or 0) .. ") ON DUPLICATE KEY UPDATE `extra_slots` = VALUES(`extra_slots`)")
end
