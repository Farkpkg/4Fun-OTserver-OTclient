local function handleBestiaryProgressiveDeath(creature, killer, mostDamageKiller)
	BestiaryProgressive.onMonsterDeath(creature, killer, mostDamageKiller)
	return true
end

local eventNames = BestiaryProgressive and BestiaryProgressive.config and BestiaryProgressive.config.registerEvents or {
	"BestiaryProgressiveMonsterDeath",
}

local registered = {}
for _, eventName in ipairs(eventNames) do
	if type(eventName) == "string" and eventName ~= "" and not registered[eventName] then
		local event = CreatureEvent(eventName)
		function event.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
			return handleBestiaryProgressiveDeath(creature, killer, mostDamageKiller)
		end
		event:register()
		registered[eventName] = true
	end
end

local bestiaryProgressiveStartup = GlobalEvent("BestiaryProgressiveStartup")

function bestiaryProgressiveStartup.onStartup()
	BestiaryProgressive.registerMonsterDeathEvents()
	return true
end

bestiaryProgressiveStartup:register()
