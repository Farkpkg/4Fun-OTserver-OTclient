local OPCODE_LANGUAGE = 1

local TASKBOARD_OPCODE = {
	SELECT = 60,
	REROLL = 61,
	CLAIM_DAILY = 62,
	PREF_SET = 63,
	PREF_CLEAR = 64,
	UNWANTED_CLEAR = 65,
	EXTRA_SLOT = 66,
	TALISMAN_UPGRADE = 67,
	SHOP_BUY = 68,
	WEEKLY_DIFFICULTY = 69,
	WEEKLY_DELIVER = 70,
	WEEKLY_UNLOCK_KILL = 71,
	WEEKLY_UNLOCK_DELIVER = 72,
}

local function isTaskBoardOpcode(opcode)
	return opcode >= TASKBOARD_OPCODE.SELECT and opcode <= TASKBOARD_OPCODE.WEEKLY_UNLOCK_DELIVER
end

local function newReader(buffer)
	return { buffer = buffer or "", pos = 1 }
end

local function readU8(reader)
	local value = string.byte(reader.buffer, reader.pos)
	if not value then
		return nil
	end
	reader.pos = reader.pos + 1
	return value
end

local function readU16(reader)
	local b1 = readU8(reader)
	local b2 = readU8(reader)
	if not b1 or not b2 then
		return nil
	end
	return b1 + b2 * 256
end

local function readU32(reader)
	local b1 = readU8(reader)
	local b2 = readU8(reader)
	local b3 = readU8(reader)
	local b4 = readU8(reader)
	if not b1 or not b2 or not b3 or not b4 then
		return nil
	end
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

local function decodeTaskBoardPayload(opcode, buffer)
	local reader = newReader(buffer)
	local payload = {}

	if opcode == TASKBOARD_OPCODE.SELECT then
		payload.slot = readU8(reader)
	elseif opcode == TASKBOARD_OPCODE.PREF_SET then
		if #buffer >= 5 then
			payload.listType = readU8(reader)
			payload.creatureId = readU32(reader)
		end
	elseif opcode == TASKBOARD_OPCODE.PREF_CLEAR or opcode == TASKBOARD_OPCODE.UNWANTED_CLEAR then
		payload.slot = readU8(reader)
	elseif opcode == TASKBOARD_OPCODE.EXTRA_SLOT then
		payload.index = readU8(reader)
	elseif opcode == TASKBOARD_OPCODE.TALISMAN_UPGRADE then
		payload.slot = readU8(reader)
	elseif opcode == TASKBOARD_OPCODE.SHOP_BUY then
		payload.index = readU16(reader)
	elseif opcode == TASKBOARD_OPCODE.WEEKLY_DIFFICULTY then
		payload.difficulty = readU8(reader)
	elseif opcode == TASKBOARD_OPCODE.WEEKLY_DELIVER then
		payload.index = readU8(reader)
	end

	if reader.pos <= #reader.buffer + 1 then
		payload.remainingBytes = (#reader.buffer - reader.pos) + 1
	else
		payload.remainingBytes = 0
	end

	return payload
end

local extendedOpcode = CreatureEvent("ExtendedOpcode")

function extendedOpcode.onExtendedOpcode(player, opcode, buffer)
	if opcode == OPCODE_LANGUAGE then
		-- otclient language
		if buffer == "en" or buffer == "pt" then
			-- example, setting player language, because otclient is multi-language...
			-- player:setStorageValue(SOME_STORAGE_ID, SOME_VALUE)
		end
	elseif isTaskBoardOpcode(opcode) then
		-- Task Board payload decode (opcodes 60-72)
		-- This keeps server parsing aligned with client binary-string payload format.
		local payload = decodeTaskBoardPayload(opcode, buffer)
		if payload.remainingBytes ~= 0 then
			logger.warn(string.format("TaskBoard opcode %d has %d unread bytes", opcode, payload.remainingBytes))
		end
		-- Integrate real handlers here (example):
		-- TaskBoard.onExtendedOpcode(player, opcode, payload)
	else
		-- other opcodes can be ignored, and the server will just work fine...
	end
end

extendedOpcode:register()
