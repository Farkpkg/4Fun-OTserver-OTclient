local taskBoardKill = CreatureEvent("TaskBoardKill")

function taskBoardKill.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	local player = Player(killer)
	if not player then
		return true
	end

	if not creature or not creature:isMonster() then
		return true
	end

	local monsterType = creature:getType()
	if not monsterType then
		return true
	end

	TaskBoard.onCreatureKill(player, monsterType:getName())
	return true
end

taskBoardKill:register()
