if not TaskBoard then
  local configuredBasePath = string.format('%s/modules/taskboard', configManager.getString(configKeys.DATA_DIRECTORY))
  local fallbackBasePath = 'data/modules/taskboard'

  local function fileExists(path)
    local file = io.open(path, 'r')
    if not file then
      return false
    end

    file:close()
    return true
  end

  local initPath = configuredBasePath .. '/init.lua'
  _G.TaskBoardBasePath = configuredBasePath

  if not fileExists(initPath) then
    local fallbackInitPath = fallbackBasePath .. '/init.lua'
    if fileExists(fallbackInitPath) then
      _G.TaskBoardBasePath = fallbackBasePath
      initPath = fallbackInitPath
      logger.warn(string.format('[TaskBoard] Module not found in %s, using %s instead.', configuredBasePath, fallbackBasePath))
    else
      logger.warn(string.format('[TaskBoard] Module not found in %s or %s, skipping bootstrap.', configuredBasePath, fallbackBasePath))
      return
    end
  end

  dofile(initPath)
end
