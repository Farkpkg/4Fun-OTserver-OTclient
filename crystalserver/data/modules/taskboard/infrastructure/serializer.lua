TaskBoardSerializer = TaskBoardSerializer or {}

local function getJsonLib()
    if type(json) == "table" and type(json.encode) == "function" and type(json.decode) == "function" then
        return json
    end

    local ok, jsonLib = pcall(require, "json")
    if ok and type(jsonLib) == "table" and type(jsonLib.encode) == "function" and type(jsonLib.decode) == "function" then
        return jsonLib
    end

    return nil
end

function TaskBoardSerializer.attachSchemaVersion(payload)
    local data = payload or {}
    data.schemaVersion = TaskBoardConstants.SCHEMA_VERSION
    return data
end

function TaskBoardSerializer.encode(payload)
    local jsonLib = getJsonLib()
    if not jsonLib then
        logger.error("[TaskBoard] Serializer.encode failed: JSON library not available")
        return nil
    end

    local withVersion = TaskBoardSerializer.attachSchemaVersion(payload)
    return jsonLib.encode(withVersion)
end

function TaskBoardSerializer.decode(payload)
    if type(payload) ~= "string" or payload == "" then
        return nil
    end

    local jsonLib = getJsonLib()
    if not jsonLib then
        logger.error("[TaskBoard] Serializer.decode failed: JSON library not available")
        return nil
    end

    local ok, data = pcall(jsonLib.decode, payload)
    if not ok then
        logger.error(string.format("[TaskBoard] Serializer.decode invalid payload: %s", tostring(data)))
        return nil
    end

    if type(data) ~= "table" then
        return nil
    end

    return data
end

return TaskBoardSerializer
