TaskBoard = TaskBoard or {}

local cache = {}

local OPCODE = {
	OPEN = 50,
	BOUNTY_DATA = 51,
	WEEKLY_DATA = 52,
	SHOP_DATA = 53,
	PREFERRED = 54,
	TALISMAN = 55,
	CURRENCIES = 56,
	RESULT = 57,
}

local function newBuffer()
	return {}
end

local function addU8(buffer, value)
	buffer[#buffer + 1] = string.char((value or 0) % 256)
end

local function addU16(buffer, value)
	local number = math.max(0, math.floor(value or 0))
	buffer[#buffer + 1] = string.char(number % 256, math.floor(number / 256) % 256)
end

local function addU32(buffer, value)
	local number = math.max(0, math.floor(value or 0))
	buffer[#buffer + 1] = string.char(number % 256, math.floor(number / 256) % 256, math.floor(number / 65536) % 256, math.floor(number / 16777216) % 256)
end

local function addU64(buffer, value)
	local number = math.max(0, math.floor(value or 0))
	addU32(buffer, number % 4294967296)
	addU32(buffer, math.floor(number / 4294967296))
end

local function encodeFloat32LE(value)
	if string.pack then
		return string.pack("<f", value)
	end

	if value == 0 then
		return string.char(0, 0, 0, 0)
	end

	local sign = 0
	if value < 0 then
		sign = 1
		value = -value
	end

	local mantissa, exponent = math.frexp(value)
	exponent = exponent + 126
	mantissa = math.floor((mantissa * 2 - 1) * 8388608)

	local bits = sign * 2147483648 + exponent * 8388608 + mantissa
	local b1 = bits % 256
	local b2 = math.floor(bits / 256) % 256
	local b3 = math.floor(bits / 65536) % 256
	local b4 = math.floor(bits / 16777216) % 256
	return string.char(b1, b2, b3, b4)
end

local function addFloat(buffer, value)
	buffer[#buffer + 1] = encodeFloat32LE(tonumber(value) or 0)
end

local function addString(buffer, value)
	local text = tostring(value or "")
	addU16(buffer, #text)
	buffer[#buffer + 1] = text
end

local function sendOpcode(player, opcode, write)
	local payload = newBuffer()
	if write then
		write(payload)
	end
	player:sendExtendedOpcode(opcode, table.concat(payload))
end

local function sendResult(player, ok, message)
	sendOpcode(player, OPCODE.RESULT, function(buffer)
		addU8(buffer, ok and 1 or 0)
		addString(buffer, message or "")
	end)
	return ok, message
end

local function getCurrentWeekToken()
	return tonumber(os.date("!%Y%W"))
end

local function getWeeklyXpMultiplier(completed)
	if completed >= 16 then
		return 8
	elseif completed >= 12 then
		return 5
	elseif completed >= 8 then
		return 3
	elseif completed >= 4 then
		return 2
	end
	return 1
end

local function buildCreatureCatalog()
	local creatures = {}
	for _, difficultyName in pairs(TaskBoardConfig.difficultyById) do
		local difficulty = TaskBoardConfig.difficulties[difficultyName]
		for _, creature in ipairs(difficulty.creatures) do
			if not creatures[creature.id] then
				creatures[creature.id] = { creatureId = creature.id, creatureName = creature.name }
			end
		end
	end

	local ordered = {}
	for _, creature in pairs(creatures) do
		ordered[#ordered + 1] = creature
	end
	table.sort(ordered, function(a, b)
		return a.creatureName < b.creatureName
	end)
	return ordered
end

local function ensureData(player)
	local playerId = player:getGuid()
	if cache[playerId] then
		return cache[playerId]
	end

	local data = {
		currencies = TaskBoardDB.loadCurrencies(playerId),
		bountyTasks = TaskBoardDB.loadBountyTasks(playerId),
		weeklyTasks = TaskBoardDB.loadWeeklyTasks(playerId),
		talisman = TaskBoardDB.loadTalisman(playerId),
		preferred = TaskBoardDB.loadPreferred(playerId),
		extraSlots = TaskBoardDB.loadExtraSlots(playerId),
		selectedDifficulty = 0,
		selectedBountySlot = 0,
		killUnlocked = false,
		deliveryUnlocked = false,
		weeklyCompletions = 0,
		weeklyHuntingPoints = 0,
		weeklySoulseals = 0,
		weeklyRewardXP = 0,
		weeklyToken = getCurrentWeekToken(),
	}

	-- Hotfix mínimo: preservar dificuldade semanal baseada no estado persistido,
	-- evitando reset para beginner após relog quando já existe weekly ativa.
	local function inferSelectedDifficultyFromWeeklyState()
		local sampledDifficulty = nil

		for slot = 1, 3 do
			local bountyTask = data.bountyTasks[slot]
			if bountyTask and bountyTask.difficulty ~= nil and TaskBoardConfig.difficultyById[bountyTask.difficulty] then
				sampledDifficulty = bountyTask.difficulty
				break
			end
		end

		if sampledDifficulty == nil then
			return
		end

		local weeklyReference = data.weeklyTasks.killTasks[1] or data.weeklyTasks.deliveryTasks[1]
		if weeklyReference and weeklyReference.weekNumber == getCurrentWeekToken() then
			data.selectedDifficulty = sampledDifficulty
		end
	end

	inferSelectedDifficultyFromWeeklyState()

	for slot = 1, 4 do
		if not data.talisman[slot] then
			local config = TaskBoardConfig.talisman[slot]
			data.talisman[slot] = { level = 1, currentPct = config.levels[1] }
			TaskBoardDB.saveTalisman(playerId, slot, data.talisman[slot])
		end
	end

	for slot = 1, 3 do
		if not data.bountyTasks[slot] then
			data.bountyTasks[slot] = {
				slot = slot,
				creatureId = 0,
				creatureName = "",
				kills = 0,
				maxKills = 0,
				xpReward = 0,
				bpReward = 0,
				rtReward = 0,
				tier = 0,
				difficulty = data.selectedDifficulty,
				completed = false,
			}
			TaskBoardDB.saveBountyTask(playerId, slot, data.bountyTasks[slot])
		end
	end

	cache[playerId] = data
	return data
end

local function sendBountyData(player)
	local data = ensureData(player)
	sendOpcode(player, OPCODE.BOUNTY_DATA, function(buffer)
		addU8(buffer, data.selectedDifficulty)
		for slot = 1, 3 do
			local task = data.bountyTasks[slot]
			addString(buffer, task.creatureName)
			addU32(buffer, task.creatureId)
			addU32(buffer, task.kills)
			addU32(buffer, task.maxKills)
			addU64(buffer, task.xpReward)
			addU16(buffer, task.bpReward)
			addU8(buffer, task.rtReward)
			addU8(buffer, task.tier)
		end
	end)
end

local function sendWeeklyData(player)
	local data = ensureData(player)
	sendOpcode(player, OPCODE.WEEKLY_DATA, function(buffer)
		addU32(buffer, data.weeklyRewardXP)
		addU8(buffer, data.killUnlocked and 1 or 0)
		addU8(buffer, data.deliveryUnlocked and 1 or 0)
		addU8(buffer, data.weeklyCompletions)
		addU32(buffer, data.weeklyHuntingPoints)
		addU32(buffer, data.weeklySoulseals)

		for slot = 1, 6 do
			local task = data.weeklyTasks.killTasks[slot] or {}
			addString(buffer, task.targetName or "")
			addU32(buffer, task.targetId or 0)
			addU32(buffer, task.currentCount or 0)
			addU32(buffer, task.maxCount or 0)
		end

		for slot = 1, 6 do
			local task = data.weeklyTasks.deliveryTasks[slot] or {}
			addString(buffer, task.targetName or "")
			addU32(buffer, task.targetId or 0)
			addU32(buffer, task.currentCount or 0)
			addU32(buffer, task.maxCount or 0)
		end
	end)
end

local function sendShopData(player)
	sendOpcode(player, OPCODE.SHOP_DATA, function(buffer)
		addU16(buffer, #TaskBoardConfig.shopItems)
		for _, item in ipairs(TaskBoardConfig.shopItems) do
			addString(buffer, item.name)
			addString(buffer, item.desc)
			addU32(buffer, item.price)
			addU32(buffer, item.itemId)
			addU8(buffer, item.type)
		end
	end)
end

local function sendPreferredData(player)
	local data = ensureData(player)
	local preferred = {}
	local unwanted = {}

	for slot = 1, 5 do
		if data.preferred.preferred[slot] then
			preferred[#preferred + 1] = data.preferred.preferred[slot]
		end
		if data.preferred.unwanted[slot] then
			unwanted[#unwanted + 1] = data.preferred.unwanted[slot]
		end
	end

	local catalog = buildCreatureCatalog()
	sendOpcode(player, OPCODE.PREFERRED, function(buffer)
		addU8(buffer, data.extraSlots)
		addU8(buffer, #preferred)
		for _, entry in ipairs(preferred) do
			addString(buffer, entry.creatureName)
			addU32(buffer, entry.creatureId)
		end
		addU8(buffer, #unwanted)
		for _, entry in ipairs(unwanted) do
			addString(buffer, entry.creatureName)
			addU32(buffer, entry.creatureId)
		end
		addU16(buffer, #catalog)
		for _, creature in ipairs(catalog) do
			addString(buffer, creature.creatureName)
			addU32(buffer, creature.creatureId)
		end
	end)
end

local function sendTalismanData(player)
	local data = ensureData(player)
	sendOpcode(player, OPCODE.TALISMAN, function(buffer)
		for slot = 1, 4 do
			local state = data.talisman[slot]
			local config = TaskBoardConfig.talisman[slot]
			local nextPct = config.levels[math.min(state.level + 1, #config.levels)]
			local cost = config.costs[state.level] or 0
			addFloat(buffer, state.currentPct)
			addFloat(buffer, nextPct)
			addU16(buffer, cost)
		end
	end)
end

local function sendCurrencies(player)
	local data = ensureData(player)
	sendOpcode(player, OPCODE.CURRENCIES, function(buffer)
		addU16(buffer, data.currencies.rerollTokens)
		addU32(buffer, data.currencies.bountyPoints)
		addU32(buffer, data.currencies.huntingPoints)
		addU32(buffer, data.currencies.soulseals)
	end)
end

local function saveCurrenciesAndSend(player)
	TaskBoardDB.saveCurrencies(player:getGuid(), ensureData(player).currencies)
	sendCurrencies(player)
end

local function saveBountyTask(player, slot)
	local data = ensureData(player)
	TaskBoardDB.saveBountyTask(player:getGuid(), slot, data.bountyTasks[slot])
end

local function saveWeeklyTask(player, taskType, slot)
	local data = ensureData(player)
	local task = taskType == 0 and data.weeklyTasks.killTasks[slot] or data.weeklyTasks.deliveryTasks[slot]
	TaskBoardDB.saveWeeklyTask(player:getGuid(), taskType, slot, task)
end

local function clearWeeklyProgress(data)
	data.weeklyCompletions = 0
	data.weeklyHuntingPoints = 0
	data.weeklySoulseals = 0
	data.weeklyRewardXP = 0
	data.killUnlocked = false
	data.deliveryUnlocked = false
end

local function rollTier()
	local roll = math.random(1, 100)
	if roll <= 5 then
		return 2, 4
	elseif roll <= 25 then
		return 1, 2
	end
	return 0, 1
end

local function pickWeightedCreature(pool, preferredById, unwantedById)
	local weighted = {}
	for _, creature in ipairs(pool) do
		if not unwantedById[creature.id] then
			local weight = 1
			if preferredById[creature.id] then
				weight = weight + TaskBoardConfig.preferredWeightBonus
			end
			weighted[#weighted + 1] = { creature = creature, weight = weight }
		end
	end
	if #weighted == 0 then
		for _, creature in ipairs(pool) do
			weighted[#weighted + 1] = { creature = creature, weight = 1 }
		end
	end

	local total = 0
	for _, entry in ipairs(weighted) do
		total = total + entry.weight
	end
	local roll = math.random() * total
	local acc = 0
	for _, entry in ipairs(weighted) do
		acc = acc + entry.weight
		if roll <= acc then
			return entry.creature
		end
	end
	return weighted[#weighted].creature
end

local function rerollBountyTasks(player)
	local data = ensureData(player)
	local diffName = TaskBoardConfig.difficultyById[data.selectedDifficulty] or "beginner"
	local config = TaskBoardConfig.difficulties[diffName]
	local preferredById = {}
	local unwantedById = {}
	for _, entry in pairs(data.preferred.preferred) do
		preferredById[entry.creatureId] = true
	end
	for _, entry in pairs(data.preferred.unwanted) do
		unwantedById[entry.creatureId] = true
	end

	for slot = 1, 3 do
		local creature = pickWeightedCreature(config.creatures, preferredById, unwantedById)
		local maxKills = math.random(config.maxKills[1], config.maxKills[2])
		local tier, mult = rollTier()
		data.bountyTasks[slot] = {
			slot = slot,
			creatureId = creature.id,
			creatureName = creature.name,
			kills = 0,
			maxKills = maxKills,
			xpReward = maxKills * 100 * mult,
			bpReward = config.bountyPoints * mult,
			rtReward = mult > 1 and 1 or 0,
			tier = tier,
			difficulty = data.selectedDifficulty,
			completed = false,
		}
		saveBountyTask(player, slot)
	end
end

local function rebuildWeeklyTasks(player)
	local data = ensureData(player)
	local weekToken = getCurrentWeekToken()
	local diffName = TaskBoardConfig.difficultyById[data.selectedDifficulty] or "beginner"
	local diffConfig = TaskBoardConfig.difficulties[diffName]
	local killRange = TaskBoardConfig.weeklyKillRange[diffName]
	data.weeklyToken = weekToken
	clearWeeklyProgress(data)
	data.weeklyTasks = { killTasks = {}, deliveryTasks = {} }

	for slot = 1, 6 do
		local creature = diffConfig.creatures[((slot - 1) % #diffConfig.creatures) + 1]
		data.weeklyTasks.killTasks[slot] = {
			slot = slot,
			targetName = creature.name,
			targetId = creature.id,
			currentCount = 0,
			maxCount = math.random(killRange[1], killRange[2]),
			completed = false,
			weekNumber = weekToken,
		}
		TaskBoardDB.saveWeeklyTask(player:getGuid(), 0, slot, data.weeklyTasks.killTasks[slot])
	end

	for slot = 1, 6 do
		local item = TaskBoardConfig.weeklyDeliveryItems[((slot - 1) % #TaskBoardConfig.weeklyDeliveryItems) + 1]
		data.weeklyTasks.deliveryTasks[slot] = {
			slot = slot,
			targetName = item.name,
			targetId = item.id,
			currentCount = 0,
			maxCount = math.random(item.min, item.max),
			completed = false,
			weekNumber = weekToken,
		}
		TaskBoardDB.saveWeeklyTask(player:getGuid(), 1, slot, data.weeklyTasks.deliveryTasks[slot])
	end
end

local function ensureWeeklyState(player)
	local data = ensureData(player)
	local weekToken = getCurrentWeekToken()
	local first = data.weeklyTasks.killTasks[1] or data.weeklyTasks.deliveryTasks[1]
	if not first or first.weekNumber ~= weekToken then
		rebuildWeeklyTasks(player)
	end
end

local function rewardWeeklyCompletion(player, huntingPoints)
	local data = ensureData(player)
	data.currencies.huntingPoints = data.currencies.huntingPoints + huntingPoints
	data.currencies.soulseals = data.currencies.soulseals + 1
	data.weeklyHuntingPoints = data.weeklyHuntingPoints + huntingPoints
	data.weeklySoulseals = data.weeklySoulseals + 1
	data.weeklyCompletions = math.min(18, data.weeklyCompletions + 1)
	data.weeklyRewardXP = 10000 * getWeeklyXpMultiplier(data.weeklyCompletions)
	saveCurrenciesAndSend(player)
	sendWeeklyData(player)
end

function TaskBoard.open(player)
	ensureData(player)
	ensureWeeklyState(player)
	sendOpcode(player, OPCODE.OPEN)
	sendBountyData(player)
	sendWeeklyData(player)
	sendShopData(player)
	sendTalismanData(player)
	sendCurrencies(player)
	return true
end

function TaskBoard.selectTask(player, slot)
	if slot < 1 or slot > 3 then
		return false, "Slot inválido."
	end
	ensureData(player).selectedBountySlot = slot
	sendBountyData(player)
	return true, "Task selecionada."
end

function TaskBoard.rerollTasks(player)
	local data = ensureData(player)
	if data.currencies.rerollTokens <= 0 then
		return false, "Você não possui reroll tokens."
	end
	data.currencies.rerollTokens = data.currencies.rerollTokens - 1
	rerollBountyTasks(player)
	saveCurrenciesAndSend(player)
	sendBountyData(player)
	return true, "Tasks sorteadas novamente."
end

function TaskBoard.claimDaily(player)
	local data = ensureData(player)
	local today = os.date("!%Y-%m-%d")
	if data.currencies.lastDaily == today then
		return false, "Recompensa diária já coletada."
	end
	data.currencies.lastDaily = today
	if data.currencies.rerollTokens < TaskBoardConfig.rerollTokenMax then
		data.currencies.rerollTokens = math.min(TaskBoardConfig.rerollTokenMax, data.currencies.rerollTokens + 1)
		saveCurrenciesAndSend(player)
		return true, "+1 reroll token recebido."
	end
	saveCurrenciesAndSend(player)
	return false, "Você já atingiu o máximo de reroll tokens."
end

function TaskBoard.onCreatureKill(player, creatureName)
	local data = ensureData(player)
	ensureWeeklyState(player)
	local lowered = creatureName:lower()
	for slot = 1, 3 do
		local task = data.bountyTasks[slot]
		if not task.completed and task.creatureName:lower() == lowered then
			task.kills = math.min(task.maxKills, task.kills + 1)
			if task.kills >= task.maxKills then
				task.completed = true
				data.currencies.bountyPoints = data.currencies.bountyPoints + task.bpReward
				data.currencies.rerollTokens = math.min(TaskBoardConfig.rerollTokenMax, data.currencies.rerollTokens + task.rtReward)
				saveCurrenciesAndSend(player)
			end
			saveBountyTask(player, slot)
		end
	end

	for slot = 1, 6 do
		local task = data.weeklyTasks.killTasks[slot]
		if task and not task.completed and task.targetName:lower() == lowered then
			task.currentCount = math.min(task.maxCount, task.currentCount + 1)
			if task.currentCount >= task.maxCount then
				task.completed = true
				rewardWeeklyCompletion(player, TaskBoardConfig.difficulties[TaskBoardConfig.difficultyById[data.selectedDifficulty]].killTaskHuntingPoints)
			end
			saveWeeklyTask(player, 0, slot)
		end
	end

	sendBountyData(player)
	sendWeeklyData(player)
	return true
end

function TaskBoard.onItemDeliver(player, index)
	if index < 1 or index > 6 then
		return false, "Índice semanal inválido."
	end
	local data = ensureData(player)
	ensureWeeklyState(player)
	local task = data.weeklyTasks.deliveryTasks[index]
	if not task or task.completed then
		return false, "Task de entrega inválida."
	end
	local need = task.maxCount - task.currentCount
	if need <= 0 then
		return false, "Task já concluída."
	end
	local removed = player:removeItem(task.targetId, need)
	if not removed then
		return false, "Itens insuficientes para entrega."
	end
	task.currentCount = task.maxCount
	task.completed = true
	saveWeeklyTask(player, 1, index)
	rewardWeeklyCompletion(player, TaskBoardConfig.weeklyDeliveryHuntingPoints)
	return true, "Entrega concluída."
end

function TaskBoard.upgradeTalisman(player, slot)
	local data = ensureData(player)
	local talisman = data.talisman[slot]
	local config = TaskBoardConfig.talisman[slot]
	if not talisman or not config then
		return false, "Talisman inválido."
	end
	if talisman.level >= #config.levels then
		return false, "Este talisman já está no nível máximo."
	end
	local cost = config.costs[talisman.level]
	if data.currencies.bountyPoints < cost then
		return false, "Bounty points insuficientes."
	end
	data.currencies.bountyPoints = data.currencies.bountyPoints - cost
	talisman.level = talisman.level + 1
	talisman.currentPct = config.levels[talisman.level]
	TaskBoardDB.saveTalisman(player:getGuid(), slot, talisman)
	saveCurrenciesAndSend(player)
	sendTalismanData(player)
	return true, "Talisman aprimorado."
end

function TaskBoard.buyShopItem(player, index)
	local item = TaskBoardConfig.shopItems[index]
	if not item then
		return false, "Item inválido."
	end
	local data = ensureData(player)
	if data.currencies.huntingPoints < item.price then
		return false, "Hunting task points insuficientes."
	end
	data.currencies.huntingPoints = data.currencies.huntingPoints - item.price
	saveCurrenciesAndSend(player)
	return true, "Compra realizada com sucesso."
end

function TaskBoard.setPreferred(player, tipo, creatureId)
	local data = ensureData(player)
	local list = tipo == 1 and data.preferred.unwanted or data.preferred.preferred
	for _, entry in pairs(list) do
		if entry.creatureId == creatureId then
			return false, "Criatura já está na lista."
		end
	end
	local catalog = buildCreatureCatalog()
	local creatureName = nil
	for _, entry in ipairs(catalog) do
		if entry.creatureId == creatureId then
			creatureName = entry.creatureName
			break
		end
	end
	if not creatureName then
		return false, "Criatura inválida."
	end
	for slot = 1, 5 do
		if not list[slot] then
			list[slot] = { creatureId = creatureId, creatureName = creatureName }
			TaskBoardDB.savePreferred(player:getGuid(), tipo == 1 and 1 or 0, slot, creatureId, creatureName)
			sendPreferredData(player)
			return true, "Criatura adicionada à lista."
		end
	end
	return false, "Sem slots livres na lista."
end

function TaskBoard.clearPreferred(player, slot)
	local data = ensureData(player)
	data.preferred.preferred[slot] = nil
	TaskBoardDB.clearPreferred(player:getGuid(), 0, slot)
	sendPreferredData(player)
	return true, "Preferred removido."
end

function TaskBoard.clearUnwanted(player, slot)
	local data = ensureData(player)
	data.preferred.unwanted[slot] = nil
	TaskBoardDB.clearPreferred(player:getGuid(), 1, slot)
	sendPreferredData(player)
	return true, "Unwanted removido."
end

function TaskBoard.unlockExtraSlot(player, index)
	if index < 1 or index > #TaskBoardConfig.extraSlotCosts then
		return false, "Índice inválido."
	end
	local data = ensureData(player)
	local mask = bit.lshift(1, index - 1)
	if bit.band(data.extraSlots, mask) ~= 0 then
		return false, "Slot extra já desbloqueado."
	end
	local cost = TaskBoardConfig.extraSlotCosts[index]
	if data.currencies.bountyPoints < cost then
		return false, "Bounty points insuficientes."
	end
	data.currencies.bountyPoints = data.currencies.bountyPoints - cost
	data.extraSlots = bit.bor(data.extraSlots, mask)
	TaskBoardDB.saveExtraSlots(player:getGuid(), data.extraSlots)
	saveCurrenciesAndSend(player)
	sendPreferredData(player)
	return true, "Slot extra desbloqueado."
end

function TaskBoard.selectWeeklyDifficulty(player, diff)
	if diff < 0 or diff > 3 then
		return false, "Dificuldade inválida."
	end
	local data = ensureData(player)
	data.selectedDifficulty = diff
	rerollBountyTasks(player)
	rebuildWeeklyTasks(player)
	sendBountyData(player)
	sendWeeklyData(player)
	return true, "Dificuldade semanal alterada."
end

function TaskBoard.unlockKillTasks(player)
	ensureData(player).killUnlocked = true
	sendWeeklyData(player)
	return true, "Tarefas de caça desbloqueadas."
end

function TaskBoard.unlockDeliveryTasks(player)
	ensureData(player).deliveryUnlocked = true
	sendWeeklyData(player)
	return true, "Tarefas de entrega desbloqueadas."
end

function TaskBoard.openPreferredList(player)
	sendPreferredData(player)
	return true, "Lista carregada."
end

function TaskBoard.result(player, ok, message)
	return sendResult(player, ok, message)
end

function TaskBoard.resetWeeklyForAll()
	db.query("TRUNCATE TABLE `player_weekly_tasks`")
	for playerId, data in pairs(cache) do
		data.weeklyTasks = { killTasks = {}, deliveryTasks = {} }
		data.weeklyToken = getCurrentWeekToken()
		clearWeeklyProgress(data)
		local player = Player(playerId)
		if player then
			rebuildWeeklyTasks(player)
			sendWeeklyData(player)
		end
	end
end

function TaskBoard.select(player, slot)
	return TaskBoard.selectTask(player, slot)
end

function TaskBoard.reroll(player)
	return TaskBoard.rerollTasks(player)
end

function TaskBoard.claim(player)
	return false, "Use o botão de claim daily ou complete as weekly tasks."
end

function TaskBoard.weekly(player, action, value)
	if action == "difficulty" then
		return TaskBoard.selectWeeklyDifficulty(player, value)
	elseif action == "delivery" then
		return TaskBoard.onItemDeliver(player, value)
	elseif action == "unlock_kill" then
		return TaskBoard.unlockKillTasks(player)
	elseif action == "unlock_delivery" then
		return TaskBoard.unlockDeliveryTasks(player)
	end
	return false, "Ação semanal inválida."
end

function TaskBoard.talisman(player, slot)
	return TaskBoard.upgradeTalisman(player, slot)
end

function TaskBoard.shop(player, index)
	return TaskBoard.buyShopItem(player, index)
end

function TaskBoard.preferred(player, action, ...)
	if action == "set" then
		return TaskBoard.setPreferred(player, ...)
	elseif action == "clear" then
		return TaskBoard.clearPreferred(player, ...)
	elseif action == "clear_unwanted" then
		return TaskBoard.clearUnwanted(player, ...)
	end
	return false, "Ação de preferred inválida."
end

function TaskBoard.unlock(player, index)
	return TaskBoard.unlockExtraSlot(player, index)
end
