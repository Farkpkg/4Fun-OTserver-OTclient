if not TaskBoard then
  local dataDirectory = configManager.getString(configKeys.DATA_DIRECTORY)
  local modulePath = string.format('%s/modules/taskboard/init.lua', dataDirectory)

  local file = io.open(modulePath, 'r')
  if file then
    file:close()
  else
    modulePath = 'data/modules/taskboard/init.lua'
  end

  dofile(modulePath)
end
