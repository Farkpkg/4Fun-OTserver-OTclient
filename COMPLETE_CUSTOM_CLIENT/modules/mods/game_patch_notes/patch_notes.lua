patchNotes = nil

local PatchNotes = nil
local PatchNotesServer = nil
local backgroundPanel = nil

local noteData = {
  title = "",
  patchNote = "1.0",
  notes = {}
}

local noteDataServer = {
  title = "",
  patchNote = "1.0",
  notes = {}
}

function init()
  patchNotes = g_ui.displayUI('patch_notes')
  createBackgroundPanel()
  backgroundPanel:hide()
  loadPatchNotes()
  loadPatchNotesServer()
  hide()
end

function terminate()
  if PatchNotes then
    removeEvent(PatchNotes)
    PatchNotes = nil
  end
  if PatchNotesServer then
    removeEvent(PatchNotesServer)
    PatchNotesServer = nil
  end
  if patchNotes then
    patchNotes:destroy()
    patchNotes = nil
  end
end

function show()
  backgroundPanel:show()
  patchNotes:show()
  patchNotes:focus()
  patchNotes:lock()

  local closeButton = patchNotes:recursiveGetChildById('closeButton')
  if closeButton then
    closeButton:setEnabled(false)
    buttonCountdown(closeButton, 5)
  end

  if EnterGame then
    modules.client_background.hideIcon()
    modules.client_entergame.EnterGame.hide()
  end
end

function hide()
  backgroundPanel:hide()
  patchNotes:unlock()
  patchNotes:hide()
end

function close()
  if noteData.patchNote then
    g_settings.set('patchNote', noteData.patchNote)
  end
  
  local closeButton = patchNotes:recursiveGetChildById('closeButton')
  if closeButton:isEnabled() then
    patchNotes:hide()
    patchNotes:unlock()
    backgroundPanel:hide()
    closeButton:setEnabled(false)
    modules.client_background.showIcon()
    modules.client_entergame.EnterGame.show()
  end
end

function loadPatchNotes()
  HTTP.postJSON("https://rubinot.com.br/webservices/patchnotes.php", { ["type"] = '0' }, onDownloadClientJsonfunction)
end

function loadPatchNotesServer()
  HTTP.postJSON("https://rubinot.com.br/webservices/patchnotes.php", { ["type"] = '1' }, onDownloadServerJsonfunction)
end

function hasSeenPatchNote()
  local currentPatchNote = g_settings.get('patchNote', "")
  local newPatchNote = noteData and noteData.patchNote or ""
  local hasSeen = currentPatchNote == newPatchNote

  return hasSeen
end

function onDownloadClientJsonfunction(data, err)
  if g_game.isOnline() then
    return
  end
  if err then
    PatchNotes = scheduleEvent(loadPatchNotes, 60000)
    return
  end

  if not data then
    return
  end

  noteData = data

  local patchList = patchNotes:recursiveGetChildById('patchList')

  local titleWidget = g_ui.createWidget('Title', patchList)
  local title = noteData.title:utf8_to_latin1()
  title = string.gsub(title, "&#10;", "\n")
  titleWidget:recursiveGetChildById('date'):setText(title)

  local backgroundColorToggle = true
  for _, note in ipairs(noteData.notes) do
    local noteWidget = g_ui.createWidget('Note', patchList)
    local text = note.text:utf8_to_latin1()
    text = string.gsub(text, "&#10;", "\n")
    noteWidget:recursiveGetChildById('noteText'):setText(text)

    noteWidget:recursiveGetChildById('noteIcon'):setImageSource("/images/store/icon-rtc")

    if backgroundColorToggle then
      noteWidget:setBackgroundColor('#484848')
    else
      noteWidget:setBackgroundColor('#363636')
    end
    backgroundColorToggle = not backgroundColorToggle
  end
end

function onDownloadServerJsonfunction(data, err)
  if g_game.isOnline() then
    return
  end
  if err then
    PatchNotesServer = scheduleEvent(loadPatchNotesServer, 60000)
    return
  end

  if not data then
    return
  end

  noteDataServer = data

  local patchList = patchNotes:recursiveGetChildById('svPatchList')

  local titleWidget = g_ui.createWidget('Title', patchList)
  local title = noteDataServer.title:utf8_to_latin1()
  title = string.gsub(title, "&#10;", "\n")
  titleWidget:recursiveGetChildById('date'):setText(title)

  local backgroundColorToggle = true
  for _, note in ipairs(noteDataServer.notes) do
    local noteWidget = g_ui.createWidget('Note', patchList)
    local text = note.text:utf8_to_latin1()
    text = string.gsub(text, "&#10;", "\n")
    noteWidget:recursiveGetChildById('noteText'):setText(text)

    if backgroundColorToggle then
      noteWidget:setBackgroundColor('#484848')
    else
      noteWidget:setBackgroundColor('#363636')
    end
    backgroundColorToggle = not backgroundColorToggle
  end
end

function buttonCountdown(closeButton, seconds)
  if seconds > 0 then
    closeButton:setText( seconds .. "s")
    closeButton:setColor("$var-text-cip-color-yellow")
    scheduleEvent(function()
      buttonCountdown(closeButton, seconds - 1)
    end, 1000)
  else
    closeButton:setEnabled(true)
    closeButton:setColor("$var-text-cip-color")
    closeButton:setText("Close")
  end
end

function createBackgroundPanel()
  if not backgroundPanel then
    backgroundPanel = g_ui.createWidget('Panel', rootWidget)
    backgroundPanel:setId('blackBackground')
    backgroundPanel:setBackgroundColor('#000000')
    backgroundPanel:setOpacity(0.9)
    backgroundPanel:fill('parent')
    backgroundPanel:hide()
  end
end