local taskBoardKill = CreatureEvent("TaskBoardKill")

function taskBoardKill.onKill(player, target)
	if not player or not player:isPlayer() or not target or not target:isMonster() then
		return true
	end

	local monsterType = target:getType()
	if not monsterType then
		return true
	end

	TaskBoard.onCreatureKill(player, monsterType:getName())
	return true
end

taskBoardKill:register()
