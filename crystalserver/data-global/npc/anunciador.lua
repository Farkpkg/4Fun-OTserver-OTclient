local internalNpcName = "Anunciador"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = 100
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 0

npcConfig.outfit = {
    lookType = 130,
    lookHead = 114,
    lookBody = 114,
    lookLegs = 114,
    lookFeet = 114
}

npcConfig.flags = {
    floorchange = false
}

-- ===============================
-- NPC HANDLER
-- ===============================
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

-- ===============================
-- CONFIG
-- ===============================
local ANNOUNCE_COST = 20000
local COOLDOWN_SECONDS = 60
local STORAGE_COOLDOWN = 93000

local announceText = {}

-- ===============================
-- NPC TYPE CALLBACKS
-- ===============================
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

-- ===============================
-- CONVERSA
-- ===============================
local function creatureSayCallback(npc, creature, type, message)
    local player = Player(creature)
    local playerId = player:getId()

    if not npcHandler:checkInteraction(npc, creature) then
        return false
    end

    local msg = message:lower()
    npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) or 0)

    -- INÍCIO
    if npcHandler:getTopic(playerId) == 0 then
        if msg == "anunciar" or msg == "anuncio" or msg == "anúncio" then
            if player:getStorageValue(STORAGE_COOLDOWN) > os.time() then
                npcHandler:say("Aguarde antes de fazer outro anúncio.", npc, creature)
                return true
            end

            npcHandler:say(
                "Digite o texto do anúncio global.\nCusto: " ..
                ANNOUNCE_COST .. " gold.",
                npc, creature
            )
            npcHandler:setTopic(playerId, 1)
        end

    -- TEXTO
    elseif npcHandler:getTopic(playerId) == 1 then
        if player:getMoney() < ANNOUNCE_COST then
            npcHandler:say("Você não possui gold suficiente.", npc, creature)
            npcHandler:setTopic(playerId, 0)
            return true
        end

        announceText[playerId] = message
        npcHandler:say(
            "Confirma o anúncio:\n\"" .. message .. "\"\n" ..
            "Custo: " .. ANNOUNCE_COST .. " gold?\n{sim} / {não}",
            npc, creature
        )
        npcHandler:setTopic(playerId, 2)

    -- CONFIRMAÇÃO
    elseif npcHandler:getTopic(playerId) == 2 then
        if msg == "sim" then
            local text = announceText[playerId]
            if not text then
                npcHandler:setTopic(playerId, 0)
                return true
            end

            if not player:removeMoney(ANNOUNCE_COST) then
                npcHandler:say("Você não possui gold suficiente.", npc, creature)
                npcHandler:setTopic(playerId, 0)
                return true
            end

            player:setStorageValue(STORAGE_COOLDOWN, os.time() + COOLDOWN_SECONDS)

            Game.broadcastMessage(
                "[ANÚNCIO] " .. text,
                MESSAGE_GAME_HIGHLIGHT
            )

            npcHandler:say("Anúncio enviado com sucesso.", npc, creature)

            announceText[playerId] = nil
            npcHandler:setTopic(playerId, 0)

        elseif msg == "não" or msg == "nao" then
            npcHandler:say("Anúncio cancelado.", npc, creature)
            announceText[playerId] = nil
            npcHandler:setTopic(playerId, 0)
        end
    end

    return true
end

npcHandler:setMessage(MESSAGE_GREET, "Olá, |PLAYERNAME|. Posso fazer um {anúncio} global para você.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Até logo.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Volte quando quiser anunciar.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- ===============================
-- REGISTRO FINAL
-- ===============================
npcType:register(npcConfig)
