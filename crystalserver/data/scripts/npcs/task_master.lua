local internalNpcName = "Task Master"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {
	name = internalNpcName,
	description = internalNpcName,
	health = 100,
	maxHealth = 100,
	walkInterval = 2000,
	walkRadius = 2,
	outfit = {
		lookType = 133,
		lookHead = 95,
		lookBody = 94,
		lookLegs = 96,
		lookFeet = 95,
		lookAddons = 0,
	},
	flags = {
		floorchange = false,
	},
}

local function sendBoardToPlayer(player)
	if not LinkedTasks then
		player:sendTextMessage(MESSAGE_FAILURE, "Sistema de tasks indisponível no momento.")
		return
	end

	LinkedTasks.ensurePlayerRows(player)
	LinkedTasks.sendTaskBoard(player)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Task Board aberto. Selecione uma task AVAILABLE para iniciar.")
end

function npcType.onSay(npc, creature, type, message)
	local player = Player(creature)
	if not player then
		return false
	end

	local text = message:lower()
	if MsgContains(text, "task") or MsgContains(text, "board") or MsgContains(text, "job") then
		npc:say("Aqui está o Task Board. Veja suas tasks e inicie uma disponível.", TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())
		sendBoardToPlayer(player)
		return true
	end

	if MsgContains(text, "hi") then
		npc:say("Saudações! Diga {task} ou {board} para abrir o Task Board.", TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())
		return true
	end

	return false
end

npcType:register(npcConfig)
