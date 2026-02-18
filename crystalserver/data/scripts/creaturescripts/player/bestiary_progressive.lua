local bestiaryProgressiveMonsterDeath = CreatureEvent("BestiaryProgressiveMonsterDeath")

function bestiaryProgressiveMonsterDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	BestiaryProgressive.onMonsterDeath(creature, killer, mostDamageKiller)
	return true
end

bestiaryProgressiveMonsterDeath:register()

local bestiaryProgressiveStartup = GlobalEvent("BestiaryProgressiveStartup")

function bestiaryProgressiveStartup.onStartup()
	BestiaryProgressive.registerMonsterDeathEvents()
	return true
end

bestiaryProgressiveStartup:register()
