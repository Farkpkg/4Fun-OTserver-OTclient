local internalNpcName = "Task Board"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "task board"

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 1

npcConfig.outfit = {
	lookType = 130,
	lookHead = 20,
	lookBody = 39,
	lookLegs = 57,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end


local function greetCallback(npc, creature)
	local player = Player(creature)
	if not player then
		return false
	end
	TaskBoard.open(player)
	npcHandler:say("Task Board opened.", npc, player)
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	if not player then
		return false
	end

	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	if MsgContains(message, "task") or MsgContains(message, "board") or MsgContains(message, "hunt") then
		TaskBoard.open(player)
		npcHandler:say("Task Board opened.", npc, player)
		return true
	end

	return false
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, |PLAYERNAME|. Say {task} to open your board.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good hunting.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good hunting.")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
