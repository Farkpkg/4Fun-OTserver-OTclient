local OPCODE_LANGUAGE = 1

local TASKBOARD_OPCODE = {
	OPEN_REQUEST = 59,
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
	return opcode >= TASKBOARD_OPCODE.OPEN_REQUEST and opcode <= TASKBOARD_OPCODE.WEEKLY_UNLOCK_DELIVER
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

local function dispatchTaskBoardOpcode(player, opcode, payload)
	if type(TaskBoard) ~= "table" then
		logger.error("TaskBoard table is not available for extended opcode {}", opcode)
		return
	end

	local ok = false
	local message = "Ação inválida."

	if opcode == TASKBOARD_OPCODE.OPEN_REQUEST then
		TaskBoard.open(player)
		return
	elseif opcode == TASKBOARD_OPCODE.SELECT then
		if payload.slot == nil then
			logger.warn("TaskBoard SELECT opcode is missing slot payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Slot da task não informado.")
			end
			return
		end
		ok, message = TaskBoard.select(player, payload.slot)
	elseif opcode == TASKBOARD_OPCODE.REROLL then
		ok, message = TaskBoard.reroll(player)
	elseif opcode == TASKBOARD_OPCODE.CLAIM_DAILY then
		ok, message = TaskBoard.claimDaily(player)
	elseif opcode == TASKBOARD_OPCODE.PREF_SET then
		if payload.listType == nil or payload.creatureId == nil then
			if TaskBoard.result then
				TaskBoard.result(player, false, "Dados de preferred inválidos.")
			end
			return
		end
		ok, message = TaskBoard.preferred(player, "set", payload.listType, payload.creatureId, "")
	elseif opcode == TASKBOARD_OPCODE.PREF_CLEAR then
		if payload.slot == nil then
			logger.warn("TaskBoard PREF_CLEAR opcode is missing slot payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Slot preferred não informado.")
			end
			return
		end
		ok, message = TaskBoard.preferred(player, "clear", payload.slot)
	elseif opcode == TASKBOARD_OPCODE.UNWANTED_CLEAR then
		if payload.slot == nil then
			logger.warn("TaskBoard UNWANTED_CLEAR opcode is missing slot payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Slot unwanted não informado.")
			end
			return
		end
		ok, message = TaskBoard.preferred(player, "clear_unwanted", payload.slot)
	elseif opcode == TASKBOARD_OPCODE.EXTRA_SLOT then
		if payload.index == nil then
			logger.warn("TaskBoard EXTRA_SLOT opcode is missing index payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Índice de slot extra não informado.")
			end
			return
		end
		ok, message = TaskBoard.unlock(player, payload.index)
	elseif opcode == TASKBOARD_OPCODE.TALISMAN_UPGRADE then
		if payload.slot == nil then
			logger.warn("TaskBoard TALISMAN_UPGRADE opcode is missing slot payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Slot de talisman não informado.")
			end
			return
		end
		ok, message = TaskBoard.talisman(player, payload.slot)
	elseif opcode == TASKBOARD_OPCODE.SHOP_BUY then
		if payload.index == nil then
			logger.warn("TaskBoard SHOP_BUY opcode is missing index payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Índice da loja não informado.")
			end
			return
		end
		ok, message = TaskBoard.shop(player, payload.index)
	elseif opcode == TASKBOARD_OPCODE.WEEKLY_DIFFICULTY then
		if payload.difficulty == nil then
			logger.warn("TaskBoard WEEKLY_DIFFICULTY opcode is missing difficulty payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Dificuldade semanal não informada.")
			end
			return
		end
		ok, message = TaskBoard.weekly(player, "difficulty", payload.difficulty)
	elseif opcode == TASKBOARD_OPCODE.WEEKLY_DELIVER then
		if payload.index == nil then
			logger.warn("TaskBoard WEEKLY_DELIVER opcode is missing index payload")
			if TaskBoard.result then
				TaskBoard.result(player, false, "Índice de entrega não informado.")
			end
			return
		end
		ok, message = TaskBoard.weekly(player, "delivery", payload.index)
	elseif opcode == TASKBOARD_OPCODE.WEEKLY_UNLOCK_KILL then
		ok, message = TaskBoard.weekly(player, "unlock_kill")
	elseif opcode == TASKBOARD_OPCODE.WEEKLY_UNLOCK_DELIVER then
		ok, message = TaskBoard.weekly(player, "unlock_delivery")
	end

	if TaskBoard.result then
		TaskBoard.result(player, ok, message)
	end
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
		local payload = decodeTaskBoardPayload(opcode, buffer)
		if payload.remainingBytes ~= 0 then
			logger.warn(string.format("TaskBoard opcode %d has %d unread bytes", opcode, payload.remainingBytes))
		end
		dispatchTaskBoardOpcode(player, opcode, payload)
	else
		-- other opcodes can be ignored, and the server will just work fine...
	end
end

extendedOpcode:register()
