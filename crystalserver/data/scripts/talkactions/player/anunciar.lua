local config = {
    cost = 10000,
    interval = 5 * 1000, -- 5 segundos
    duration = 60 * 1000, -- 1 minuto
    effect = CONST_ME_MAGIC_GREEN,
    talkType = TALKTYPE_MONSTER_SAY,

    storageRunning = 92000 -- controla spam
}

-- Loop do anúncio
local function doAnnouncement(playerId, text, startTime)
    local player = Player(playerId)
    if not player then
        return
    end

    if os.time() * 1000 - startTime >= config.duration then
        -- libera o comando novamente
        player:setStorageValue(config.storageRunning, -1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Seu anúncio foi finalizado.")
        return
    end

    local pos = player:getPosition()
    pos:sendMagicEffect(config.effect)
    player:say(text, config.talkType, false, nil, pos)

    addEvent(doAnnouncement, config.interval, playerId, text, startTime)
end

-- Modal de confirmação
local function sendConfirmModal(player, text)
    local window = ModalWindow({
        title = "Confirmar Anúncio",
        message = string.format(
            "Texto:\n\"%s\"\n\nCusto: %d gold\n\nDeseja prosseguir?",
            text, config.cost
        )
    })

    window:addButton("Confirmar", function(player)
        if player:getMoney() < config.cost then
            player:sendCancelMessage("Você não possui gold suficiente.")
            return true
        end

        player:removeMoney(config.cost)
        player:setStorageValue(config.storageRunning, 1)

        doAnnouncement(player:getId(), text, os.time() * 1000)

        player:sendTextMessage(
            MESSAGE_EVENT_ADVANCE,
            "Anúncio iniciado."
        )
        return true
    end)

    window:addButton("Cancelar")
    window:setDefaultEnterButton(0)
    window:setDefaultEscapeButton(1)
    window:sendToPlayer(player)
end

-- Talkaction
local talk = TalkAction("!anunciar")

function talk.onSay(player, words, param)
    if param == "" then
        player:sendCancelMessage("Use: !anunciar texto")
        return true
    end

    -- Anti-spam
    if player:getStorageValue(config.storageRunning) == 1 then
        player:sendCancelMessage("Aguarde o término do seu anúncio atual.")
        return true
    end

    sendConfirmModal(player, param)
    return true
end

talk:separator(" ")
talk:groupType("normal")
talk:register()
