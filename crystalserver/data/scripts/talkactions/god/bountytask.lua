local bountyTask = TalkAction("/bountytask")

function bountyTask.onSay(player, words, param)
	local split = param:split(",")
	if #split ~= 3 then
		player:sendCancelMessage("Insufficient parameters. Usage: /bountytask <playerName>, <creatureName>, <requiredKills>")
		return true
	end

	local playerName = split[1]:trimSpace()
	local targetPlayer = Player(playerName)
	if not targetPlayer then
		player:sendCancelMessage("Player " .. playerName .. " not found.")
		return true
	end

	local creatureName = split[2]:trimSpace()
	if creatureName == "" then
		player:sendCancelMessage("<creatureName> is required.")
		return true
	end

	local requiredKills = tonumber(split[3]:trimSpace())
	if not requiredKills or requiredKills < 1 then
		player:sendCancelMessage("<requiredKills> must be a number greater than 0.")
		return true
	end

	if not targetPlayer:assignBountyTask(creatureName, requiredKills) then
		player:sendCancelMessage("Failed to assign bounty task. Player may already have an active unfinished task or creature does not exist.")
		return true
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Bounty task assigned to " .. targetPlayer:getName() .. ": " .. creatureName .. " (" .. requiredKills .. " kills).")
	return true
end

bountyTask:separator(" ")
bountyTask:groupType("god")
bountyTask:register()
