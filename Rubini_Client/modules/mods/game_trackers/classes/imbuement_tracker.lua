---------------------------
-- Lua code author: R1ck --
-- Company: VICTOR HUGO PERENHA - JOGOS ON LINE --
---------------------------

ImbuementTracker = {}
ImbuementTracker.__index = ImbuementTracker

local imbuementData = nil
local sortOptions = {}
local characterConfig = {}

local sortTypes = {
	LESS_THAN_ONE = 1,
	LAST_BETWEEN = 2,
	MORE_THAN_THREE = 3,
	NO_ACTIVE = 4,
}

function ImbuementTracker.onReceiveData(items)
  imbuementData = items
  ImbuementTracker.showTrackerData()
end

function ImbuementTracker.showTrackerData()
	if not imbuementData or not g_game.isOnline() then
		return
	end

	local sortedData = {}
	imbuementTrackerWindow.contentsPanel:destroyChildren()

	for _, data in pairs(imbuementData) do
		local canShow = true
		local emptySlots = 0
		for k, v in pairs(data.slots) do
			if v.imbuementId == 0 then
				emptySlots = emptySlots + 1
				goto continue
			end

			canShow = true
			local hours = math.floor(v.time / 3600)
			local minutes = math.floor((v.time % 3600) / 60)
			if v.imbuementId ~= 0 then
				if not sortOptions[sortTypes.LESS_THAN_ONE] and hours < 1 and emptySlots < k then
					canShow = false
				end

				if not sortOptions[sortTypes.LAST_BETWEEN] and (hours >= 1 and hours <= 3) and emptySlots < k then
					canShow = false
				end

				if not sortOptions[sortTypes.MORE_THAN_THREE] and hours > 3 and emptySlots < k then
					canShow = false
				end
			end

			:: continue ::
		end

		if not sortOptions[sortTypes.NO_ACTIVE] and emptySlots == #data.slots then
			canShow = false
		end

		if canShow then
			table.insert(sortedData, data)
		end
	end

	for _, data in pairs(sortedData) do
		local widget = g_ui.createWidget('ImbuePanel', imbuementTrackerWindow.contentsPanel)
		widget.itemSlot:setItem(data.item)

		local position = {x = 65535, y = data.slotPosition, z = 0}
		local item = widget.itemSlot:getItem()
		item:setPosition(position)
		item:setStaticThing(true)
		if item:isContainer() then
			updateFlags(item, widget.itemSlot)
		end

		for k, v in pairs(data.slots) do
			local hours = math.floor(v.time / 3600)
			local minutes = math.floor((v.time % 3600) / 60)

			local panel = widget:recursiveGetChildById("panel" .. k)
			local source = widget:recursiveGetChildById("imbueContainer" .. k)
			source:setVisible(true)
			panel:setVisible(true)

			if v.imbuementId ~= 0 then
				local total_seconds = v.time
				local hours = math.floor(total_seconds / 3600)
				local minutes = math.floor((total_seconds % 3600) / 60)
				local seconds = total_seconds % 60

				local formatted_minutes = string.format("%02d", minutes)
				local formatted_seconds = string.format("%02d", seconds)

				source:setImageSource("/images/game/imbuing/imbuement-icons-64")
        		source:setImageClip(getFramePosition(v.imbuementId, 64, 64, 21) .. " 64 64")
				source:setTooltip(tr("%s\n\nTime remaining: %sh %smin", v.description, hours, minutes))

				if hours >= 10 then
					source:setText(hours .. "h")
				elseif hours < 10 and hours >= 1 then
					source:setText(hours .. "h" .. formatted_minutes)
				elseif hours < 1 and minutes >= 10 then
					source:setText(formatted_minutes .. "m")
				elseif minutes < 10 and minutes >= 1 then
					source:setText(minutes .. "m" .. formatted_seconds)
					source:setTooltip(tr("%s\n\nTime remaining: %sm %sseconds", v.description, minutes, seconds))
				else
					source:setText(formatted_seconds .. "s")
					source:setTooltip(tr("%s\n\nTime remaining: %s seconds", v.description, seconds))
				end

				if hours < 3 then
					source:setColor("#f8db38")
				elseif hours < 1 then
					source:setColor("#d33c3c")
				end
			end
		end
	end
end

function ImbuementTracker.initSortFields()
	sortOptions[sortTypes.LESS_THAN_ONE] = characterConfig["showAlmostGone"]
	sortOptions[sortTypes.LAST_BETWEEN] = characterConfig["showUsed"]
	sortOptions[sortTypes.MORE_THAN_THREE] = characterConfig["showAlmostNew"]
	sortOptions[sortTypes.NO_ACTIVE] = characterConfig["showEmptySlots"]
end

function ImbuementTracker.onSortButton()
	local sortMenu = g_ui.createWidget('PopupMenu')
    sortMenu:setGameMenu(true)
	sortMenu:addCheckBoxOption(tr('Show imbuements that last less than 1h'), function() ImbuementTracker.sortFilterCheck(sortTypes.LESS_THAN_ONE) end, "", sortOptions[sortTypes.LESS_THAN_ONE])
    sortMenu:addCheckBoxOption(tr('Show imbuements that last between 1h and 3h'), function() ImbuementTracker.sortFilterCheck(sortTypes.LAST_BETWEEN) end, "", sortOptions[sortTypes.LAST_BETWEEN])
    sortMenu:addCheckBoxOption(tr('Show imbuements that last more than 3h'), function() ImbuementTracker.sortFilterCheck(sortTypes.MORE_THAN_THREE) end, "", sortOptions[sortTypes.MORE_THAN_THREE])
    sortMenu:addCheckBoxOption(tr('Show items with no active imbuement'), function() ImbuementTracker.sortFilterCheck(sortTypes.NO_ACTIVE) end, "", sortOptions[sortTypes.NO_ACTIVE])
    sortMenu:display(g_window.getMousePosition())
end

function ImbuementTracker.sortFilterCheck(type)
	sortOptions[type] = not sortOptions[type]
	if type == sortTypes.LESS_THAN_ONE then
		characterConfig["showAlmostGone"] = sortOptions[type]
	elseif type == sortTypes.LAST_BETWEEN then
		characterConfig["showUsed"] = sortOptions[type]
	elseif type == sortTypes.MORE_THAN_THREE then
		characterConfig["showAlmostNew"] = sortOptions[type]
	else
		characterConfig["showEmptySlots"] = sortOptions[type]
	end
	ImbuementTracker.showTrackerData()
end

function ImbuementTracker.online()
	characterConfig = modules.game_sidebars.getImbuementTrackerConfig()
	if table.empty(characterConfig) then
		characterConfig = {
			["contentHeight"] = 0,
			["contentMaximized"] =  true,
			["showAlmostGone"] =  true,
			["showAlmostNew"] =  true,
			["showEmptySlots"] =  true,
			["showUsed"] =  true
		}
	end
end

function ImbuementTracker.offline()
	modules.game_sidebars.registerImbuementTrackerConfig(characterConfig)
end