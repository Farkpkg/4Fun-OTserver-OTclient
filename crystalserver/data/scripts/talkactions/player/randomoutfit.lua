local randomOutfit = TalkAction("!randomoutfit")

local config = {
	changeInterval = 1000,
	showEffect = false,
	maxLookType = 1468,
}

local validValues = {
	"on",
	"off",
}

local activePlayers = {}
local ownedOutfitsByPlayer = {}

local function getRandomOwnedOutfit(playerId)
	local outfits = ownedOutfitsByPlayer[playerId]
	if not outfits or #outfits == 0 then
		return nil
	end

	local selectedOutfit = outfits[math.random(1, #outfits)]
	local selectedAddon = selectedOutfit.addons[math.random(1, #selectedOutfit.addons)]
	return selectedOutfit.lookType, selectedAddon
end

local function collectOwnedOutfits(player)
	local outfits = {}
	for lookType = 1, config.maxLookType do
		if player:hasOutfit(lookType) then
			local addons = { 0 }
			for addon = 1, 3 do
				if player:hasOutfit(lookType, addon) then
					table.insert(addons, addon)
				end
			end

			table.insert(outfits, {
				lookType = lookType,
				addons = addons,
			})
		end
	end
	return outfits
end

local function generateRandomOutfit(currentOutfit, randomLookType, randomAddon)
	currentOutfit.lookType = randomLookType
	currentOutfit.lookHead = math.random(0, 132)
	currentOutfit.lookBody = math.random(0, 132)
	currentOutfit.lookLegs = math.random(0, 132)
	currentOutfit.lookFeet = math.random(0, 132)
	currentOutfit.lookAddons = randomAddon
	return currentOutfit
end

local function updateOutfit(playerId)
	local player = Player(playerId)
	if not player then
		activePlayers[playerId] = nil
		ownedOutfitsByPlayer[playerId] = nil
		return
	end

	if activePlayers[playerId] then
		local randomLookType, randomAddon = getRandomOwnedOutfit(playerId)
		if randomLookType then
			local currentOutfit = player:getOutfit()
			local currentMount = currentOutfit.lookMount
			local newOutfit = generateRandomOutfit(currentOutfit, randomLookType, randomAddon)
			newOutfit.lookMount = currentMount
			player:setOutfit(newOutfit)
			if config.showEffect then
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			end
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
