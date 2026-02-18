BestiaryProgressive = BestiaryProgressive or {}

BestiaryProgressive.config = {
	-- Keep this list aligned with your external TibiaForever registrar script.
	registerEvents = {
		"BestiaryProgressiveMonsterDeath",
		"REGISTER-NAME",
		"REGISTER-NAME-TWO",
	},
	blockedNames = {
		-- ["training monk"] = true,
	},
	-- If true, startup registration is skipped and external registrar should handle monster:event binding.
	useExternalRegistrar = true,
}

local BESTIARY_MESSAGE = MESSAGE_STATUS or MESSAGE_EVENT_ADVANCE or MESSAGE_LOGIN

local BOSSTIARY_FINAL_KILLS_BY_RARITY = {
	[0] = 300, -- Bane
	[1] = 60, -- Archfoe
	[2] = 5, -- Nemesis
}

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

local function getBestiaryKillGain()
	return math.max(configManager.getNumber(configKeys.BESTIARY_KILL_MULTIPLIER) or 1, 1)
end

local function getBosstiaryKillGain(monsterType)
	local kills = math.max(configManager.getNumber(configKeys.BOSSTIARY_KILL_MULTIPLIER) or 1, 1)
	local boostedBossName = Game.getBoostedBoss and Game.getBoostedBoss() or nil
	if boostedBossName and normalizeMonsterName(boostedBossName) == normalizeMonsterName(monsterType:getName()) then
		local bonus = math.max(configManager.getNumber(configKeys.BOOSTED_BOSS_KILL_BONUS) or 1, 1)
		kills = kills * bonus
	end
	return kills
end

local function getBestiaryStorageKey(raceId)
	return string.format("bestiary.progressive.official.%d", raceId)
end

local function getBosstiaryRequiredKills(monsterType)
	local rarity = monsterType:bossRaceId() or 0
	return BOSSTIARY_FINAL_KILLS_BY_RARITY[rarity]
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

	local raceId = monsterType:raceId()
	if not raceId or raceId <= 0 then
		return false
	end

	local monsterName = getMonsterDisplayName(monsterType)
	local isBossEntry = monsterType:bossRace() ~= nil

	if isBossEntry then
		local requiredKills = getBosstiaryRequiredKills(monsterType)
		if not requiredKills or requiredKills <= 0 then
			return false
		end

		local officialKills = player:getBosstiaryKills(monsterType:getName()) or 0
		local projectedKills = math.min(officialKills + getBosstiaryKillGain(monsterType), requiredKills)
		local remainingKills = math.max(requiredKills - projectedKills, 0)
		if remainingKills == 0 then
			if officialKills < requiredKills then
				player:sendTextMessage(BESTIARY_MESSAGE, string.format("Bosstiary completo: %s [%d/%d]!", monsterName, projectedKills, requiredKills))
			else
				player:sendTextMessage(BESTIARY_MESSAGE, string.format("Bosstiary: %s [%d/%d] — Completo.", monsterName, projectedKills, requiredKills))
			end
			return true
		end

		player:sendTextMessage(BESTIARY_MESSAGE, string.format("Bosstiary: %s [%d/%d] — Faltam %d.", monsterName, projectedKills, requiredKills, remainingKills))
		return true
	end

	local requiredKills = monsterType:BestiarytoKill() or 0
	if requiredKills <= 0 then
		return false
	end

	local storageKey = getBestiaryStorageKey(raceId)
	local currentKills = player:kv():get(storageKey)
	if not currentKills then
		currentKills = 0
	end

	local newKills = math.min(currentKills + getBestiaryKillGain(), requiredKills)
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
	if BestiaryProgressive.config.useExternalRegistrar then
		logger.info("[BestiaryProgressive] External registrar enabled. Skipping internal onDeath startup registration.")
		return
	end

	local eventName = BestiaryProgressive.config.registerEvents[1] or "BestiaryProgressiveMonsterDeath"
	local blockedNames = BestiaryProgressive.config.blockedNames or {}
	local monsterTypes = Game.getMonsterTypes and Game.getMonsterTypes() or {}

	for _, monsterType in pairs(monsterTypes) do
		if monsterType and monsterType:raceId() and monsterType:raceId() > 0 then
			local normalizedName = normalizeMonsterName(monsterType:getName())
			if not blockedNames[normalizedName] then
				monsterType:registerEvent(eventName)
			end
		end
	end
end
