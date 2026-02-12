if not TaskBoard then
  local basePath = string.format('%s/modules/taskboard', configManager.getString(configKeys.DATA_DIRECTORY))
  dofile(basePath .. '/init.lua')
end
