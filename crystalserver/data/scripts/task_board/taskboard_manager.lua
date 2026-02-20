TaskBoard = TaskBoard or {}

local cache = {}

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
	return true
end

function TaskBoard.selectTask(player, slot)
	if slot < 1 or slot > 3 then
		return false, "Slot inválido."
	end
	local data = ensureData(player)
	data.selectedBountySlot = slot
	return true, "Task selecionada."
end

function TaskBoard.rerollTasks(player)
	local data = ensureData(player)
	if data.currencies.rerollTokens <= 0 then
		return false, "Você não possui reroll tokens."
	end

	data.currencies.rerollTokens = data.currencies.rerollTokens - 1
	rerollBountyTasks(player)
	TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
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
		TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
		return false, "Você já atingiu o máximo de reroll tokens."
	end

	data.currencies.lastDaily = today
	data.currencies.rerollTokens = math.min(TaskBoardConfig.rerollTokenMax, data.currencies.rerollTokens + 1)
	TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
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
				TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
			end
			saveBountyTask(player, slot)
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
	TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
	saveBountyTask(player, slot)
	return true, "Task resgatada."
end

function TaskBoard.selectWeeklyDifficulty(player, diff)
	if diff < 0 or diff > 3 then
		return false, "Dificuldade inválida."
	end

	local data = ensureData(player)
	data.selectedDifficulty = diff
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
	TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
	TaskBoardDB.saveTalisman(player:getGuid(), slot, talismanData)
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
	TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
	return true, "Compra realizada com sucesso."
end

function TaskBoard.setPreferred(player, listType, creatureId, creatureName)
	local data = ensureData(player)
	local list = listType == 1 and data.preferred.unwanted or data.preferred.preferred
	for slot = 1, 5 do
		if not list[slot] then
			list[slot] = { creatureId = creatureId, creatureName = creatureName }
			TaskBoardDB.savePreferred(player:getGuid(), listType == 1 and 1 or 0, slot, creatureId, creatureName)
			return true, "Criatura adicionada à lista."
		end
	end
	return false, "Sem slots livres na lista."
end

function TaskBoard.clearPreferred(player, slot)
	local data = ensureData(player)
	data.preferred.preferred[slot] = nil
	TaskBoardDB.clearPreferred(player:getGuid(), 0, slot)
	return true, "Preferred removido."
end

function TaskBoard.clearUnwanted(player, slot)
	local data = ensureData(player)
	data.preferred.unwanted[slot] = nil
	TaskBoardDB.clearPreferred(player:getGuid(), 1, slot)
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
	TaskBoardDB.saveCurrencies(player:getGuid(), data.currencies)
	TaskBoardDB.saveExtraSlots(player:getGuid(), data.extraSlots)
	return true, "Slot extra desbloqueado."
end

function TaskBoard.unlockWeeklyKill(player)
	return true, "Tarefas de caça desbloqueadas."
end

function TaskBoard.unlockWeeklyDelivery(player)
	return true, "Tarefas de entrega desbloqueadas."
end

function TaskBoard.getData(player)
	return ensureData(player)
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
