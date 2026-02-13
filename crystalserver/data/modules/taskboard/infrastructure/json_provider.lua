TaskBoardJsonProvider = TaskBoardJsonProvider or {}

local function isJsonModule(candidate)
    return type(candidate) == "table"
        and type(candidate.encode) == "function"
        and type(candidate.decode) == "function"
end

local function wrapCjson(candidate)
    if type(candidate) ~= "table" or type(candidate.encode) ~= "function" or type(candidate.decode) ~= "function" then
        return nil
    end

    return {
        encode = function(value)
            return candidate.encode(value)
        end,
        decode = function(payload)
            local decoded, err = candidate.decode(payload)
            if decoded == nil and err then
                error(err)
            end
            return decoded
        end,
    }
end

function TaskBoardJsonProvider.get()
    if isJsonModule(json) then
        return json
    end

    local okJson, jsonLib = pcall(require, "json")
    if okJson and isJsonModule(jsonLib) then
        return jsonLib
    end

    local okCjsonSafe, cjsonSafe = pcall(require, "cjson.safe")
    if okCjsonSafe then
        local wrappedSafe = wrapCjson(cjsonSafe)
        if wrappedSafe then
            return wrappedSafe
        end
    end

    local okCjson, cjson = pcall(require, "cjson")
    if okCjson then
        local wrapped = wrapCjson(cjson)
        if wrapped then
            return wrapped
        end
    end

    if not TaskBoardJsonProvider._bundledLoaded then
        local basePath = _G.TaskBoardBasePath or string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))
        local okBundled, bundled = pcall(dofile, basePath .. "/infrastructure/vendor_json.lua")
        if okBundled and isJsonModule(bundled) then
            TaskBoardJsonProvider._bundled = bundled
        end
        TaskBoardJsonProvider._bundledLoaded = true
    end

    return TaskBoardJsonProvider._bundled
end

return TaskBoardJsonProvider
