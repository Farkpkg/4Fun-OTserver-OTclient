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
	local b1 = number % 256
	local b2 = math.floor(number / 256) % 256
	local b3 = math.floor(number / 65536) % 256
	local b4 = math.floor(number / 16777216) % 256
	buffer[#buffer + 1] = string.char(b1, b2, b3, b4)
end

local function addU64(buffer, value)
	local number = math.max(0, math.floor(value or 0))
	local low = number % 4294967296
	local high = math.floor(number / 4294967296)
	addU32(buffer, low)
	addU32(buffer, high)
end

local function addFloat(buffer, value)
	buffer[#buffer + 1] = string.pack("<f", tonumber(value) or 0)
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

local function getTodayUtc()
	return os.date("!%Y-%m-%d")
end

local function getCurrentWeekUtc()
	return tonumber(os.date("!%W")) + 1
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
		selectedBountySlot = 0,
		selectedDifficulty = 0,
		lastBountyWeek = getCurrentWeekUtc(),
		weeklyCompletions = 0,
	}

	if data.currencies.weeklySeed == 0 then
		data.currencies.weeklySeed = os.time()
	end
	if data.currencies.bountySeed == 0 then
		data.currencies.bountySeed = playerId * 131 + os.time()
	end
	TaskBoardDB.saveCurrencies(playerId, data.currencies)

	for slot = 1, 4 do
		if not data.talisman[slot] then
			local config = TaskBoardConfig.talisman[slot]
			data.talisman[slot] = { level = 1, currentPct = config.levels[1] }
			TaskBoardDB.saveTalisman(playerId, slot, data.talisman[slot])
		end
	end

	if not next(data.bountyTasks) then
		for slot = 1, 3 do
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
				difficulty = 0,
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
			local task = data.bountyTasks[slot] or {}
			addString(buffer, task.creatureName or "")
			addU32(buffer, task.creatureId or 0)
			addU32(buffer, task.kills or 0)
			addU32(buffer, task.maxKills or 0)
			addU64(buffer, task.xpReward or 0)
			addU16(buffer, task.bpReward or 0)
			addU8(buffer, task.rtReward or 0)
			addU8(buffer, task.tier or 0)
		end
	end)
end

local function sendWeeklyData(player)
	local data = ensureData(player)
	local killUnlocked = data.killUnlocked and 1 or 0
	local delivUnlocked = data.deliveryUnlocked and 1 or 0
	local weeklyHTP = data.weeklyHuntingPoints or 0
	local weeklySeals = data.weeklySoulseals or 0
	local completedTasks = data.weeklyCompletions or 0

	sendOpcode(player, OPCODE.WEEKLY_DATA, function(buffer)
		addU32(buffer, data.weeklyRewardXP or 0)
		addU8(buffer, killUnlocked)
		addU8(buffer, delivUnlocked)
		addU8(buffer, completedTasks)
		addU32(buffer, weeklyHTP)
		addU32(buffer, weeklySeals)

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

local function sendPreferredData(player)
	local data = ensureData(player)
	local preferredList = {}
	local unwantedList = {}
	for slot = 1, 5 do
		local preferred = data.preferred.preferred[slot]
		if preferred then
			preferredList[#preferredList + 1] = preferred
		end
		local unwanted = data.preferred.unwanted[slot]
		if unwanted then
			unwantedList[#unwantedList + 1] = unwanted
		end
	end

	local catalog = buildCreatureCatalog()
	sendOpcode(player, OPCODE.PREFERRED, function(buffer)
		addU8(buffer, data.extraSlots or 0)
		addU8(buffer, #preferredList)
		for _, entry in ipairs(preferredList) do
			addString(buffer, entry.creatureName)
			addU32(buffer, entry.creatureId)
		end

		addU8(buffer, #unwantedList)
		for _, entry in ipairs(unwantedList) do
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
			local talismanData = data.talisman[slot] or { level = 1, currentPct = 0 }
			local config = TaskBoardConfig.talisman[slot]
			local nextPct = config.levels[math.min(talismanData.level + 1, #config.levels)]
			local cost = config.costs[talismanData.level] or 0
			addFloat(buffer, talismanData.currentPct)
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
	local data = ensureData(player)
	TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
	sendCurrencies(player)
end

local function saveBountyTask(player, slot)
	local playerId = player:getGuid()
	local data = ensureData(player)
	TaskBoardDB.saveBountyTask(playerId, slot, data.bountyTasks[slot])
end

local function saveWeeklyTask(player, taskType, slot, task)
	TaskBoardDB.saveWeeklyTask(player:getGuid(), taskType, slot, task)
end

local function addBountyTaskReward(data, task)
	data.currencies.bountyPoints = data.currencies.bountyPoints + task.bpReward
	data.currencies.rerollTokens = math.min(TaskBoardConfig.rerollTokenMax, data.currencies.rerollTokens + task.rtReward)
end

local function rollTier()
	local roll = math.random(1, 100)
	if roll <= 5 then
		return 2, 4
	end
	if roll <= 25 then
		return 1, 2
	end
	return 0, 1
end

local function pickDifficulty(diff)
	local name = TaskBoardConfig.difficultyById[diff] or "beginner"
	return TaskBoardConfig.difficulties[name], diff
end

local function rerollBountyTasks(player)
	local data = ensureData(player)
	local difficultyConfig, difficulty = pickDifficulty(data.selectedDifficulty)
	local creaturePool = difficultyConfig.creatures
	for slot = 1, 3 do
		local pick = creaturePool[math.random(1, #creaturePool)]
		local maxKills = math.random(difficultyConfig.maxKills[1], difficultyConfig.maxKills[2])
		local tier, mult = rollTier()

		data.bountyTasks[slot] = {
			slot = slot,
			creatureId = pick.id,
			creatureName = pick.name,
			kills = 0,
			maxKills = maxKills,
			xpReward = maxKills * 100 * mult,
			bpReward = difficultyConfig.bountyPoints * mult,
			rtReward = mult > 1 and 1 or 0,
			tier = tier,
			difficulty = difficulty,
			completed = false,
		}
		saveBountyTask(player, slot)
	end
end

function TaskBoard.open(player)
	ensureData(player)
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
	local data = ensureData(player)
	data.selectedBountySlot = slot
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
	local today = getTodayUtc()
	if data.currencies.lastDaily == today then
		return false, "Recompensa diária já coletada."
	end

	if data.currencies.rerollTokens >= TaskBoardConfig.rerollTokenMax then
		data.currencies.lastDaily = today
		saveCurrenciesAndSend(player)
		return false, "Você já atingiu o máximo de reroll tokens."
	end

	data.currencies.lastDaily = today
	data.currencies.rerollTokens = math.min(TaskBoardConfig.rerollTokenMax, data.currencies.rerollTokens + 1)
	saveCurrenciesAndSend(player)
	return true, "+1 reroll token recebido."
end

function TaskBoard.onCreatureKill(player, creatureName)
	local data = ensureData(player)
	for slot = 1, 3 do
		local task = data.bountyTasks[slot]
		if task and not task.completed and task.creatureName:lower() == creatureName:lower() then
			task.kills = math.min(task.maxKills, task.kills + 1)
			if task.kills >= task.maxKills then
				task.completed = true
				addBountyTaskReward(data, task)
				saveCurrenciesAndSend(player)
			end
			saveBountyTask(player, slot)
			sendBountyData(player)
		end
	end
	return true
end

function TaskBoard.claimSelected(player)
	local data = ensureData(player)
	local slot = data.selectedBountySlot
	if slot == 0 then
		return false, "Nenhuma task selecionada."
	end
	local task = data.bountyTasks[slot]
	if not task or not task.completed then
		return false, "Task não concluída."
	end

	data.currencies.huntingPoints = data.currencies.huntingPoints + TaskBoardConfig.difficulties[TaskBoardConfig.difficultyById[task.difficulty]].killTaskHuntingPoints
	data.currencies.soulseals = data.currencies.soulseals + 1
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
		difficulty = task.difficulty,
		completed = false,
	}
	saveCurrenciesAndSend(player)
	saveBountyTask(player, slot)
	sendBountyData(player)
	return true, "Task resgatada."
end

function TaskBoard.selectWeeklyDifficulty(player, diff)
	if diff < 0 or diff > 3 then
		return false, "Dificuldade inválida."
	end

	local data = ensureData(player)
	data.selectedDifficulty = diff
	rerollBountyTasks(player)
	sendBountyData(player)
	return true, "Dificuldade semanal alterada."
end

function TaskBoard.upgradeTalisman(player, slot)
	local data = ensureData(player)
	local talismanData = data.talisman[slot]
	local config = TaskBoardConfig.talisman[slot]
	if not talismanData or not config then
		return false, "Talisman inválido."
	end

	if talismanData.level >= #config.levels then
		return false, "Este talisman já está no nível máximo."
	end

	local cost = config.costs[talismanData.level]
	if data.currencies.bountyPoints < cost then
		return false, "Bounty points insuficientes."
	end

	data.currencies.bountyPoints = data.currencies.bountyPoints - cost
	talismanData.level = talismanData.level + 1
	talismanData.currentPct = config.levels[talismanData.level]
	saveCurrenciesAndSend(player)
	TaskBoardDB.saveTalisman(player:getGuid(), slot, talismanData)
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

function TaskBoard.setPreferred(player, listType, creatureId, creatureName)
	local data = ensureData(player)
	local list = listType == 1 and data.preferred.unwanted or data.preferred.preferred
	for slot = 1, 5 do
		if not list[slot] then
			list[slot] = { creatureId = creatureId, creatureName = creatureName }
			TaskBoardDB.savePreferred(player:getGuid(), listType == 1 and 1 or 0, slot, creatureId, creatureName)
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
	saveCurrenciesAndSend(player)
	TaskBoardDB.saveExtraSlots(player:getGuid(), data.extraSlots)
	sendPreferredData(player)
	return true, "Slot extra desbloqueado."
end

function TaskBoard.unlockWeeklyKill(player)
	return true, "Tarefas de caça desbloqueadas."
end

function TaskBoard.unlockWeeklyDelivery(player)
	return true, "Tarefas de entrega desbloqueadas."
end

function TaskBoard.getData(player)
	local data = ensureData(player)
	sendPreferredData(player)
	return data
end

function TaskBoard.result(player, ok, message)
	return sendResult(player, ok, message)
end


function TaskBoard.select(player, slot)
	return TaskBoard.selectTask(player, slot)
end

function TaskBoard.reroll(player)
	return TaskBoard.rerollTasks(player)
end

function TaskBoard.claim(player)
	return TaskBoard.claimSelected(player)
end


function TaskBoard.deliverWeekly(player, index)
	if index == nil then
		return false, "Índice semanal inválido."
	end

	-- TODO: ligar entrega semanal ao backend de itens quando o fluxo estiver disponível.
	return false, "Entrega semanal ainda não implementada."
end

function TaskBoard.weekly(player, action, value)
	if action == "difficulty" then
		return TaskBoard.selectWeeklyDifficulty(player, value)
	end
	if action == "delivery" or action == "deliver" then
		return TaskBoard.deliverWeekly(player, value)
	end
	if action == "unlock_kill" then
		return TaskBoard.unlockWeeklyKill(player)
	end
	if action == "unlock_delivery" then
		return TaskBoard.unlockWeeklyDelivery(player)
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
	end
	if action == "clear" then
		return TaskBoard.clearPreferred(player, ...)
	end
	if action == "clear_unwanted" then
		return TaskBoard.clearUnwanted(player, ...)
	end
	return false, "Ação de preferred inválida."
end

function TaskBoard.unlock(player, index)
	return TaskBoard.unlockExtraSlot(player, index)
end
