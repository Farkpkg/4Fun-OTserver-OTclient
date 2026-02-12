if not TaskBoard then
  local dataDirectory = configManager.getString(configKeys.DATA_DIRECTORY)
  local configuredPath = string.format('%s/modules/taskboard/init.lua', dataDirectory)

  local loadedConfigured = pcall(dofile, configuredPath)
  if not loadedConfigured then
    dofile('data/modules/taskboard/init.lua')
  end
end
