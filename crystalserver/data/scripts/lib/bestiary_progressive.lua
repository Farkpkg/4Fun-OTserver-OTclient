BestiaryProgressive = BestiaryProgressive or {}

BestiaryProgressive.config = {
	defaultRequiredKills = nil,
	goalsByRaceId = {
		-- [3] = 50, -- Bear
	},
	goalsByName = {
		bear = 50,
	},
}

local BESTIARY_MESSAGE = MESSAGE_STATUS or MESSAGE_EVENT_ADVANCE or MESSAGE_LOGIN

local function normalizeMonsterName(name)
	if not name then
		return ""
	end

	return name:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function getMonsterDisplayName(monsterType)
	local name = monsterType:getName() or ""
	if name == "" then
		return "Unknown"
	end

	return name:gsub("(%a)([%w_']*)", function(first, rest)
		return first:upper() .. rest:lower()
	end)
end

local function getPlayerFromKiller(killer)
	if not killer then
		return nil
	end

	if killer:isPlayer() then
		return killer
	end

	if killer:isMonster() then
		local master = killer:getMaster()
		if master and master:isPlayer() then
			return master
		end
	end

	return nil
end

function BestiaryProgressive.getRequiredKills(monsterType)
	if not monsterType then
		return nil
	end

	local raceId = monsterType:raceId()
	local byRaceId = BestiaryProgressive.config.goalsByRaceId[raceId]
	if byRaceId and byRaceId > 0 then
		return byRaceId
	end

	local byName = BestiaryProgressive.config.goalsByName[normalizeMonsterName(monsterType:getName())]
	if byName and byName > 0 then
		return byName
	end

	local defaultRequiredKills = BestiaryProgressive.config.defaultRequiredKills
	if defaultRequiredKills and defaultRequiredKills > 0 then
		return defaultRequiredKills
	end

	return nil
end

function BestiaryProgressive.getStorageKey(monsterType)
	local raceId = monsterType:raceId()
	if raceId and raceId > 0 then
		return string.format("bestiary.progressive.%d", raceId)
	end

	return "bestiary.progressive." .. normalizeMonsterName(monsterType:getName())
end

function BestiaryProgressive.onMonsterDeath(creature, killer, mostDamageKiller)
	if not creature or not creature:isMonster() or creature:hasBeenSummoned() then
		return false
	end

	local player = getPlayerFromKiller(killer) or getPlayerFromKiller(mostDamageKiller)
	if not player then
		return false
	end

	local monsterType = creature:getType()
	if not monsterType then
		return false
	end

	local requiredKills = BestiaryProgressive.getRequiredKills(monsterType)
	if not requiredKills then
		return false
	end

	local monsterName = getMonsterDisplayName(monsterType)
	local storageKey = BestiaryProgressive.getStorageKey(monsterType)
	local currentKills = player:kv():get(storageKey) or 0
	local newKills = math.min(currentKills + 1, requiredKills)

	player:kv():set(storageKey, newKills)

	local remainingKills = math.max(requiredKills - newKills, 0)
	if remainingKills == 0 then
		if currentKills < requiredKills then
			player:sendTextMessage(BESTIARY_MESSAGE, string.format("Bestiary completo: %s [%d/%d]!", monsterName, newKills, requiredKills))
		else
			player:sendTextMessage(BESTIARY_MESSAGE, string.format("Bestiary: %s [%d/%d] — Completo.", monsterName, newKills, requiredKills))
		end
		return true
	end

	player:sendTextMessage(BESTIARY_MESSAGE, string.format("Bestiary: %s [%d/%d] — Faltam %d.", monsterName, newKills, requiredKills, remainingKills))
	return true
end

function BestiaryProgressive.registerMonsterDeathEvents()
	local registeredNames = {}

	local function registerByName(monsterName)
		local normalized = normalizeMonsterName(monsterName)
		if normalized == "" or registeredNames[normalized] then
			return
		end

		local monsterType = MonsterType(monsterName)
		if not monsterType then
			return
		end

		monsterType:registerEvent("BestiaryProgressiveMonsterDeath")
		registeredNames[normalized] = true
	end

	local bestiaryList = Game.getBestiaryList and Game.getBestiaryList() or {}
	for raceId in pairs(BestiaryProgressive.config.goalsByRaceId) do
		registerByName(bestiaryList[raceId])
	end

	for monsterName in pairs(BestiaryProgressive.config.goalsByName) do
		registerByName(monsterName)
	end
end
