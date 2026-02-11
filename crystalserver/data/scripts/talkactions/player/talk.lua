local talk = TalkAction("!talk")

function talk.onSay(player, words, param)
	if param == "" then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Usage: !talk <message>")
		return false
	end

	player:say(param, TALKTYPE_SAY)
	player:sendTextMessage(MESSAGE_STATUS, "Message sent with TALKTYPE_SAY.")
	return false
end

talk:setDescription("[Usage]: !talk <message>")
talk:groupType("normal")
talk:register()
