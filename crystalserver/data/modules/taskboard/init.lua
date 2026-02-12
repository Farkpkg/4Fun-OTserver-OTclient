TaskBoard = TaskBoard or {}

local basePath = string.format("%s/modules/taskboard", configManager.getString(configKeys.DATA_DIRECTORY))

dofile(basePath .. "/constants.lua")
dofile(basePath .. "/infrastructure/serializer.lua")
dofile(basePath .. "/infrastructure/repository.lua")
dofile(basePath .. "/infrastructure/cache.lua")
dofile(basePath .. "/infrastructure/network.lua")
dofile(basePath .. "/infrastructure/hooks.lua")

function TaskBoard.init()
    TaskBoardHooks.init()
    logger.info("[TaskBoard] Bootstrap complete (FASE 1)")
    return true
end

TaskBoard.init()

return TaskBoard
