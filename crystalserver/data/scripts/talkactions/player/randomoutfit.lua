local randomOutfit = TalkAction("!randomoutfit")

local config = {
	changeInterval = 1000,
	showEffect = false,
	outfitLookTypes = {
		128, -- citizen male
		129, -- hunter male
		130, -- mage male
		131, -- knight male
		136, -- citizen female
		137, -- hunter female
		138, -- mage female
		139, -- knight female
	},
}

local validValues = {
	"on",
	"off",
}

local activePlayers = {}
local ownedOutfitsByPlayer = {}

local function getRandomLookType()
	return config.outfitLookTypes[math.random(1, #config.outfitLookTypes)]
end

local function generateRandomOutfit(outfit)
	outfit.lookType = getRandomLookType()
	outfit.lookHead = math.random(0, 132)
	outfit.lookBody = math.random(0, 132)
	outfit.lookLegs = math.random(0, 132)
	outfit.lookFeet = math.random(0, 132)
	outfit.lookAddons = math.random(0, 3)
	return outfit
end

local function updateOutfit(playerId)
	local player = Player(playerId)
	if player and activePlayers[playerId] then
		local newOutfit = generateRandomOutfit(player:getOutfit())
		player:setOutfit(newOutfit)
		if config.showEffect then
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		end
		addEvent(updateOutfit, config.changeInterval, playerId)
	end
end

function randomOutfit.onSay(player, words, param)
	if not table.contains(validValues, param) then
		local validValuesStr = table.concat(validValues, "/")
		player:sendTextMessage(MESSAGE_FAILURE, "Invalid param specified. Usage: !randomoutfit [" .. validValuesStr .. "]")
		return true
	end

	local playerId = player:getId()

	if param == "on" then
		if activePlayers[playerId] then
			player:sendTextMessage(MESSAGE_FAILURE, "Random outfit is already active.")
			return true
		end

		local ownedOutfits = collectOwnedOutfits(player)
		if #ownedOutfits == 0 then
			player:sendTextMessage(MESSAGE_FAILURE, "You do not have any outfit unlocked for randomization.")
			return true
		end

		ownedOutfitsByPlayer[playerId] = ownedOutfits
		activePlayers[playerId] = true
		updateOutfit(playerId)
		player:sendTextMessage(MESSAGE_LOOK, "Random outfit is now enabled.")
	else
		activePlayers[playerId] = nil
		ownedOutfitsByPlayer[playerId] = nil
		player:sendTextMessage(MESSAGE_LOOK, "Random outfit is now disabled.")
	end

	return true
end

randomOutfit:separator(" ")
randomOutfit:groupType("normal")
randomOutfit:register()
