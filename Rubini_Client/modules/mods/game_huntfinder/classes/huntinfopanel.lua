if not HuntInfo then
    HuntInfo = {
        monsters = {},
        widget = nil,
        radioSelected = nil,
        lastMonsterWidget = nil,
        trackerKillsWidget = nil, -- show kills for the tracked hunt
        trackedHunt = nil, -- Store the currently tracked hunt
        showingCharms = false
    }
    HuntInfo.__index = HuntInfo
end

local self = HuntInfo

local charmNameToId = {
    ["wound"] = {id = 0, name = "Wound", description = "Your attacks have a %d%% chance to deal physical damage equal to 5%% of the target's initial hit points.", bonus = 5},
    ["enflame"] = {id = 1, name = "Enflame", description = "Your attacks have a %d%% chance to deal fire damage equal to 5%% of the target's initial hit points.", bonus = 5},
    ["poison"] = {id = 2, name = "Poison", description = "Your attacks have a %d%% chance to deal earth damage equal to 5%% of the target's initial hit points.", bonus = 5},
    ["freeze"] = {id = 3, name = "Freeze", description = "Your attacks have a %d%% chance to deal ice damage equal to 5%% of the target's initial hit points.", bonus = 5},
    ["zap"] = {id = 4, name = "Zap", description = "Your attacks have a %d%% chance to deal energy damage equal to 5%% of the target's initial hit points.", bonus = 5},
    ["curse"] = {id = 5, name = "Curse", description = "Your attacks have a %d%% chance to deal death damage equal to 5%% of the target's initial hit points.", bonus = 5},
    ["parry"] = {id = 7, name = "Parry", description = "Each time you take damage, you have a %d%% chance to reflect it back to the aggressor.", bonus = 5},
    ["dodge"] = {id = 8, name = "Dodge", description = "Grants a %d%% chance to dodge an attack.", bonus = 5},
    ["low blow"] = {id = 15, name = "Low Blow", description = "Adds %d%% critical hit chance to attacks with critical hit weapons.", bonus = 4},
    ["divine wrath"] = {id = 16, name = "Divine Wrath", description = "Your attacks have a %d%% chance to deal holy damage equal to 5%% of the target's initial hit points.", bonus = 5},
    ["savage blow"] = {id = 19, name = "Savage Blow", description = "Adds %d%% critical extra damage to attacks with critical hit weapons.", bonus = 20},
    ["carnage"] = {id = 22, name = "Carnage", description = "Killing a monster has %d%% chance to deal physical damage equal to 15%% of its maximum health to all monsters in small radius.", bonus = 10},
    ["overpower"] = {id = 23, name = "Overpower", description = "Your attacks have a %d%% chance to deal damage equal to 5%% of your maximum health.", bonus = 5},
    ["overflux"] = {id = 24, name = "Overflux", description = "Your attacks have a %d%% chance to deal damage equal to 2.5%% of your maximum mana.", bonus = 5},
    ["cripple"] = {id = 6, name = "Cripple", description = "Your attacks have a %d%% chance to paralyse the target for 10 seconds.", bonus = 6},
    ["adrenaline burst"] = {id = 9, name = "Adrenaline Burst", description = "Each time you're hit you have a %d%% chance to trigger a burst of adrenaline, boosting your speed by 150%% for 10 seconds.", bonus = 6},
    ["numb"] = {id = 10, name = "Numb", description = "After being attacked, you have a %d%% chance to paralyse the aggressor for 10 seconds.", bonus = 6},
    ["cleanse"] = {id = 11, name = "Cleanse", description = "Each time you're hit, you have a %d%% chance to cleanse one random negative status effect and gain temporary immunity to it for 11 seconds.", bonus = 6},
    ["bless"] = {id = 12, name = "Bless", description = "Blesses you, reducing skill and experience loss by %d%% when killed by the chosen creature.", bonus = 6},
    ["scavenge"] = {id = 13, name = "Scavenge", description = "Increases your chance of successfully skinning/dusting a skinnable/dustable creature by %d%%.", bonus = 60},
    ["gut"] = {id = 14, name = "Gut", description = "Gutting the creature yields %d%% more creature products.", bonus = 6},
    ["vampiric embrace"] = {id = 17, name = "Vampiric Embrace", description = "Increases your current life leech by %.1f%%.", bonus = 1.6},
    ["void's call"] = {id = 18, name = "Void's Call", description = "Increases your current mana leech by %.1f%%.", bonus = 0.8},
    ["fatal hold"] = {id = 20, name = "Fatal Hold", description = "Your attacks have a %d%% chance to prevent creatures from fleeing due to low health for 30 seconds.", bonus = 30},
    ["void inversion"] = {id = 21, name = "Void Inversion", description = "%d%% chance to gain mana instead of losing it when taking mana drain damage.", bonus = 20},
}

local imbuementTypes = {
    ["epiphany"] = 66,
    ["void"] = 51,
    ["vampirism"] = 48,
    ["dragon hide"] = 36,
    ["cloud fabric"] = 33,
    ["snake skin"] = 30,
    ["lich shroud"] = 27,
    ["reap"] = 24,
    ["quara scale"] = 42,
    ["demon presence"] = 39,
}

function HuntInfo.init()
    self.widget = HuntFinder.widget:recursiveGetChildById('huntInfoPanel')
    self.radioSelected = UIRadioGroup.create()
    self.statsPanel = self.widget:recursiveGetChildById('statsPanel')
    self.creatureCharmPanel = self.widget:recursiveGetChildById('creatureCharmPanel')
    self.creatureInfoButton = self.widget:recursiveGetChildById('creatureInfoButton')
    self.charmImage = self.widget:recursiveGetChildById('charmImage')
    self.charmOpacity = self.widget:recursiveGetChildById('charmOpacity')
    self.trackerKillsWidget = self.widget:recursiveGetChildById('trackerKills')
    self.floorUp = self.widget:recursiveGetChildById('floorUp')
    self.floorDown = self.widget:recursiveGetChildById('floorDown')
    
    self.floorUp.onClick = function()
        local minimap = self.widget:recursiveGetChildById('minimap')
        if minimap then
            minimap:floorUp(1)
        end
    end

    self.floorDown.onClick = function()
        local minimap = self.widget:recursiveGetChildById('minimap')
        if minimap then
            minimap:floorDown(1)
        end
    end
    
    connect(self.radioSelected, { onSelectionChange = onSelectionChange })

    self.showingCharms = false
    self:updateButtonState()
    self.creatureInfoButton.onClick = function()
        self.showingCharms = not self.showingCharms
        self:updatePanels()
        self:updateButtonState()
        if self.showingCharms and self.radioSelected:getSelectedWidget() then
            onSelectionChange(nil, self.radioSelected:getSelectedWidget())
        end
    end
end

function HuntInfo:clear()
    if self.widget then
        self.widget:destroyChildren()
        self.widget = nil
    end

    if self.radioSelected then
        disconnect(self.radioSelected, { onSelectionChange = onSelectionChange })
        self.radioSelected:destroy()
        self.radioSelected = nil
    end

    if self.lastMonsterWidget then
        self.lastMonsterWidget = nil
    end
    self.trackedHunt = nil
    self.showingCharms = false

    self.trackerKillsWidget = nil
end

function HuntInfo:updatePanels()
    self.statsPanel:setVisible(not self.showingCharms)
    self.creatureCharmPanel:setVisible(self.showingCharms)
end

function HuntInfo:updateButtonState()
    if self.showingCharms then
        self.creatureInfoButton:setImageSource("/images/game/wiki/hunt-finder/health-info-button")
        self.creatureInfoButton:setTooltip("Click to show monster stats and hide charm")
    else
        self.creatureInfoButton:setImageSource("/images/game/wiki/hunt-finder/charm-info-button")
        self.creatureInfoButton:setTooltip("Click to show charm and hide monster stats")
    end
end

function HuntInfo:displayHunt(hunt)
    self.currentHunt = hunt -- Store the current hunt
    MapFinder:setHuntPosition(hunt:getPosition())
    local huntName = self.widget:getChildById('huntName')
    local huntLevel = self.widget:recursiveGetChildById('huntLevel')
    local huntXpHour = self.widget:recursiveGetChildById('huntXpHour')
    local huntLootHour = self.widget:recursiveGetChildById('huntLootHour')
    local huntLocation = self.widget:recursiveGetChildById('huntLocation')
    local trackHuntOnMap = self.widget:recursiveGetChildById('trackHuntOnMap')

    huntName:setText(hunt:getName())
    huntLevel:setText(hunt:getLevel() .. " +")
    huntXpHour:setText(hunt:getXPHour())
    huntLootHour:setText(hunt:getLootHour())
    huntLocation:setText(hunt:getLocation())
    trackHuntOnMap:setChecked(self.trackedHunt == hunt)

    local creaturesInfo = self.widget:recursiveGetChildById('creaturesInfo')
    creaturesInfo:destroyChildren()

    self.radioSelected:destroy()
    self.lastMonsterWidget = nil
    for _, monster in ipairs(hunt:getMonsters()) do
        local widget = g_ui.createWidget('UIWidget', creaturesInfo)
        widget:setText(monster.Name)
        widget:setId(monster.Name)
        widget:setTooltip(monster.Name)
        widget:setFont("$var-cip-font")
        widget:setColor("$var-text-cip-color")
        widget:setTextOverflowLength(13)
        local monsterData = g_things.getMonsterByName(monster.Name)
        widget:setActionId(monsterData.id)
        widget:setTextAlign(AlignLeft)
        self.radioSelected:addWidget(widget)
    end

    self.radioSelected:selectWidget(self.radioSelected:getFirstWidget())

    local imbuiContentPanel = self.widget:recursiveGetChildById('imbuiContentPanel')
    local imbues = hunt:getRecommendedImbuesByVocation(HuntFinder.vocation)
    for i = 1, 3 do
        local widget = imbuiContentPanel:getChildById('slot' .. i - 1)
        local activeSlot = imbues[i]
        widget:setImageSource("/images/game/imbuing/imbuement-icons-64")
        if not activeSlot then
            widget:setImageClip("0 0 64 64")
            widget:setTooltip('')
        else
            local imageId = imbuementTypes[activeSlot:lower()] or 3
            widget:setImageClip(getFramePosition(imageId, 64, 64, 21) .. " 64 64")
            widget:setTooltip(activeSlot)
        end
    end

    local suppliesContentPanel = self.widget:recursiveGetChildById('suppliesContentPanel')
    local supplies = hunt:getRecommendedSuppliesByVocation(HuntFinder.vocation)
    for i, widget in ipairs(suppliesContentPanel:getChildren()) do
        local itemName = supplies[i]
        if not itemName then
            widget:setItemId(0)
            widget:setTooltip('')
        else
            local itemId = g_things.getItemByName(itemName)
            if itemId then
                widget:setItemId(itemId)
                widget:setTooltip(itemName)
                
                widget.onMouseRelease = function(widget, mousePos, mouseButton)
                    if mouseButton == MouseRightButton then
                        local menu = g_ui.createWidget('PopupMenu')
                        menu:setGameMenu(true)
                        menu:addOption(tr('Cyclopedia Info'), function() 
                            modules.game_cyclopedia.CyclopediaItems.onRedirect(itemId) 
                        end)
                        menu:display(mousePos)
                    end
                end
            else
                widget:setItemId(0)
                widget:setTooltip('')
            end
        end
    end

    local lootContentPanel = self.widget:recursiveGetChildById('lootContentPanel')
    local valuableDrops = hunt:getValuableDrops()
    for i, widget in ipairs(lootContentPanel:getChildren()) do
        local itemName = valuableDrops[i]
        if not itemName then
            widget:setItemId(0)
        else
            local itemId = g_things.getItemByName(itemName)
            if itemId then
                widget:setItemId(itemId)
                widget:setTooltip(itemName)

                widget.onMouseRelease = function(widget, mousePos, mouseButton)
                    if mouseButton == MouseRightButton then
                        local menu = g_ui.createWidget('PopupMenu')
                        menu:setGameMenu(true)
                        menu:addOption(tr('Cyclopedia Info'), function() modules.game_cyclopedia.CyclopediaItems.onRedirect(itemId) end)
                        local buttonText = modules.game_quickloot.inWhiteList(itemId) and 'Remove from Loot List' or 'Add to Loot List'
                        menu:addOption(tr(buttonText), function() self:onAddToLootList(itemId) end)
                        menu:display(mousePos)
                    end
                end
            end
        end
    end

    MapFinder:setRoutePath(hunt:getRouteCoordinates())
    local howToGetButton = self.widget:recursiveGetChildById('howToGetButton')
    local isHowToGetState = true
    howToGetButton.onClick = function()
        if isHowToGetState then
            MapFinder:setPath(hunt:getCoordinates())
            MapFinder:setHuntPosition(hunt:getTemplePosition())
            howToGetButton:setText("Show Route")
        else
            MapFinder:setPath(hunt:getPosition())
            MapFinder:setHuntPosition(hunt:getPosition())
            howToGetButton:setText("How To Get Here")
        end
        isHowToGetState = not isHowToGetState
    end

    trackHuntOnMap.onCheckChange = function(widget, checked)
        if checked then
            self.trackedHunt = hunt
            modules.game_minimap.setPath(hunt:getCoordinates())
            modules.game_minimap.setRoutePath(hunt:getRouteCoordinates())
        else
            self.trackedHunt = nil
            modules.game_minimap.clearPath()
            modules.game_minimap.clearRoutePath()
        end
        ListPanel:displayHunts()
    end

    local equipmentsImageSource = {
        ["neck"] = "/images/game/slots/neck",
        ["head"] = "/images/game/slots/head",
        ["backpack"] = "/images/game/slots/back",
        ["body"] = "/images/game/slots/body",
        ["leftHand"] = "/images/game/slots/left-hand",
        ["rightHand"] = "/images/game/slots/right-hand",
        ["leg"] = "/images/game/slots/legs",
        ["feet"] = "/images/game/slots/feet",
        ["finger"] = "/images/game/slots/finger",
        ["ammo"] = "/images/game/slots/ammo",
    }

    local equipmentsPanel = self.widget:recursiveGetChildById('equipmentsPanel')
    local recomented = hunt:getEquipmentsByVocation(HuntFinder.vocation)
    for i, widget in ipairs(equipmentsPanel:getChildren()) do
        local equipment = recomented[widget:getId()]
        if not equipment or equipment == "" then
            widget:setItemId(0)
            widget:setImageSource(equipmentsImageSource[widget:getId()])
        else
            local itemId = g_things.getItemByName(equipment)
            if itemId then
                widget:setItemId(itemId)
                widget:setTooltip(string.capitalize(equipment))
                widget:setImageSource('/images/ui/item')

                widget.onMouseRelease = function(widget, mousePos, mouseButton)
                    if mouseButton == MouseRightButton then
                        local menu = g_ui.createWidget('PopupMenu')
                        menu:setGameMenu(true)
                        menu:addOption(tr('Cyclopedia Info'), function() 
                            modules.game_cyclopedia.CyclopediaItems.onRedirect(itemId) 
                        end)
                        menu:display(mousePos)
                    end
                end
            end
        end
    end

    local ammoWidget = equipmentsPanel:getChildById('ammo')
    local trinketWidget = self.widget:recursiveGetChildById('trinketItem')
    if ammoWidget and trinketWidget then
        trinketWidget:setItemId(ammoWidget:getItemId())
        trinketWidget:setTooltip(ammoWidget:getTooltip())
    end

    self:updatePanels()
end

local elementName = {
    [0] = "physical",
    [1] = "fire",
    [2] = "earth",
    [3] = "energy",
    [4] = "ice",
    [5] = "holy",
    [6] = "death",
    [7] = "healing"
}

function onSelectionChange(widget, selectedWidget)
    if self.lastMonsterWidget then
        self.lastMonsterWidget:setBackgroundColor("#363636")
        self.lastMonsterWidget:setColor("$var-text-cip-color")
    end

    self.trackerKillsWidget.onCheckChange = function(seldWidget) end
    if selectedWidget then
        local serverInfo = self.monsters[selectedWidget:getActionId()]
        local monsterData = g_things.getMonsterByName(selectedWidget:getText())

        if not serverInfo then
            return
        end

        local planeCreature = self.widget:recursiveGetChildById('creatureInfoOutfit')
        if monsterData and monsterData.id > 0 then
            planeCreature:setOutfit({type = monsterData.type, auxType = monsterData.auxType, head = monsterData.head, body = monsterData.body, legs = monsterData.legs, feet = monsterData.feet, addons = monsterData.addons})
        else
            planeCreature:setOutfit({auxType = 13})
        end

        -- self.trackerKillsWidget
        if monsterData and monsterData.id > 0 then
            self.trackerKillsWidget:setChecked(modules.game_cyclopedia.Bestiary.monsterInTracker(monsterData.id))
            self.trackerKillsWidget:setEnabled(true)
            self.trackerKillsWidget.onCheckChange = function(seldWidget)
                modules.game_cyclopedia.Bestiary.onTrackMonster(seldWidget:isChecked(), monsterData.id)
            end
        else
            self.trackerKillsWidget:setChecked(false)
            self.trackerKillsWidget:setEnabled(false)
        end

        local monsterName = self.widget:recursiveGetChildById('creatureName')
        local health = self.widget:recursiveGetChildById('health')
        local experience = self.widget:recursiveGetChildById('experience')
        local speed = self.widget:recursiveGetChildById('speed')
        local armor = self.widget:recursiveGetChildById('armor')
        local mitigation = self.widget:recursiveGetChildById('mitigation')

        monsterName:setText(selectedWidget:getText())
        health:setText(serverInfo[1])
        experience:setText(serverInfo[2])
        speed:setText(serverInfo[3])
        armor:setText(serverInfo[4])
        mitigation:setText(serverInfo[5])

        local elements = self.widget:recursiveGetChildById('elements')
        elements:destroyChildren()
        for elementId, percent in pairs(serverInfo[6]) do
            local widgetElement = g_ui.createWidget('ElementInfo', elements)
            widgetElement.progress:setBackgroundColor('white')
            widgetElement:setId(elementId)
            widgetElement:setActionId(elementId)
            local name = elementName[elementId]
            widgetElement.icon:setImageSource('/images/game/cyclopedia/icons/monster-icon-'.. name ..'-resist')
            widgetElement.icon:setTooltip(string.capitalize(name))

            widgetElement.progress:setValue(percent, 0, 150)
            widgetElement.progress:setTooltip(tr('Sensitive to %s: %d%% (neutral)', name, percent))
            if percent < 50 then
                widgetElement.progress:setBackgroundColor('red')
                widgetElement.progress:setTooltip(tr('Sensitive to %s: %d%% (strong)', name, percent))
            elseif percent < 100 then
                widgetElement.progress:setBackgroundColor('#e4c00a')
                widgetElement.progress:setTooltip(tr('Sensitive to %s: %d%% (strong)', name, percent))
            elseif percent > 100 then
                widgetElement.progress:setBackgroundColor('#18ce18')
                widgetElement.progress:setTooltip(tr('Sensitive to %s: %d%% (weak)', name, percent))
            end
        end

        if self.showingCharms then
            local monsterName = selectedWidget:getText()
            local hunt = self.currentHunt or self.trackedHunt
            local charmName = nil
            if hunt then
                local monsters = hunt:getMonsters()
                for _, monster in ipairs(monsters) do
                    if monster.Name == monsterName then
                        charmName = monster.Charm
                        break
                    end
                end
            end

            local charmData = charmName and charmNameToId[charmName:lower()] or nil
            if charmData then
                self.charmOpacity:setVisible(false)
                self.charmImage:setImageSource(string.format("/images/game/cyclopedia/monster-bonus-effects/monster-bonus-effects-%d", charmData.id))
                self.charmImage:setTooltip(string.todivide(charmData.name .. ": " .. string.format(charmData.description, charmData.bonus), 10))
            else
                self.charmOpacity:setVisible(true)
                self.charmImage:setImageSource('')
                self.charmImage:setTooltip('')
            end
        end

        selectedWidget:setBackgroundColor("#585858")
        selectedWidget:setColor("$var-text-cip-color-orange")
    end

    self.lastMonsterWidget = selectedWidget
end

function HuntInfo:setMonsters(monsters)
    self.monsters = monsters
end

function HuntInfo:onAddToLootList(itemId)
    if not modules.game_quickloot.inWhiteList(itemId) then
		modules.game_quickloot.addToQuickLoot(itemId)
	else
		modules.game_quickloot.removeItemInList(itemId)
	end
end

