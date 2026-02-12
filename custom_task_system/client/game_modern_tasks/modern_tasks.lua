--[[
    Modern Task System (Client-Side)
    Author: Antigravity AI (Google DeepMind) for Ravendor
    Date: 2025
    
    Description:
    This module handles the UI for the task system. It communicates with the server via Extended Opcode 205.
    It supports:
    - Multiple Tabs (All, Daily, Story, Hardcore)
    - Dynamic Monster Previews (Outfits sent by server)
    - Real-time Progress Bars with Dynamic Colors
    - Cooldown Timers for Daily Tasks
    
    Configuration:
    - No configuration needed here. All logic is driven by the server payload.
    - To change styles, edit 'modern_tasks.otui'.
]]

local OPCODE = 205
local modernTaskWindow
local taskList
local taskButton

-- Helper Functions First

function create()
  if taskButton then return end
  
  if modules.client_topmenu then
    taskButton = modules.client_topmenu.addLeftGameButton('taskButton', 'Tasks', '/images/topbuttons/questlog', toggle)
  end
  
  if not modernTaskWindow then
      modernTaskWindow = g_ui.createWidget('ModernTaskWindow', rootWidget)
      modernTaskWindow:hide()
      taskList = modernTaskWindow:getChildById('taskList')
  end
end

function destroy()
  if modernTaskWindow then modernTaskWindow:destroy() modernTaskWindow = nil end
  if taskButton then taskButton:destroy() taskButton = nil end
end

function toggle()
  if not modernTaskWindow then return end
  if modernTaskWindow:isVisible() then hide() else show() end
end

function show()
  if not modernTaskWindow then return end
  modernTaskWindow:show()
  modernTaskWindow:raise()
  modernTaskWindow:focus()
  if taskButton then taskButton:setOn(true) end
  
  -- Request Data
  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode({action = "refresh"}))
end

function hide()
  if not modernTaskWindow then return end
  modernTaskWindow:hide()
  if taskButton then taskButton:setOn(false) end
end

function setBarState(widget, percent, color)
    local bar = widget:getChildById('progress')
    
    -- Limit percent
    percent = math.max(0, math.min(100, percent))
    
    -- Use Native ProgressBar logic
    bar:setPercent(percent)
    
    -- Change the color of the filled part (image)
    bar:setImageColor(color)
end

function sendAction(act, id)
    local payload = {action = act, id = id}
    g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode(payload))
end


local storedData = nil
local currentCategory = 'All'

function selectCategory(cat)
    currentCategory = cat
    -- Highlight tabs? (Optional/Advanced, skipping for simplicity)
    if storedData then refreshUI(storedData) end
end

function refreshUI(data)
  if not modernTaskWindow then return end
  if data then storedData = data end -- Cache data for filtering
  if not storedData then return end
  
  local d = storedData
  
  -- Update Points
  local lbl = modernTaskWindow:getChildById('pointsLabel')
  if d.points and lbl then
    lbl:setText("Points: " .. d.points)
  end
  
  -- Update List
  if taskList then
    taskList:destroyChildren()
    
    -- Sort
    table.sort(d.tasks, function(a,b) return a.id < b.id end)
    
    for _, t in ipairs(d.tasks) do
        -- Filter Category
        if currentCategory == 'All' or t.cat == currentCategory then
            
            local widget = g_ui.createWidget('ModernTaskWidget', taskList)
            widget:setId(t.id)
            widget:getChildById('title'):setText(t.name)
            widget:getChildById('desc'):setText(t.desc)
            
            -- Outfits (Dynamic Monster Support)
            local mobList = widget:getChildById('mobList')
            if mobList then
                mobList:destroyChildren()
                if t.outfits then
                    for _, outfit in ipairs(t.outfits) do
                        local creature = g_ui.createWidget('UICreature', mobList)
                        creature:setSize({width = 48, height = 48})
                        creature:setFixedCreatureSize(true)
                        creature:setOutfit(outfit)
                        creature:setPhantom(true)
                    end
                end
            end
            
            -- State & Colors
            local btn = widget:getChildById('actionButton')
            local p = 0
            local color = "#444444"
            local statusText = ""
            
            -- Reset Button State Defaults
            btn:setEnabled(true)
            btn:setColor("#FFFFFF") -- Text Color
            btn.onClick = nil
            
            if t.state == 0 then -- New
                btn:setText("Start")
                btn:setImageColor("green") -- Background Color
                btn.onClick = function() sendAction("start", t.id) end
                
                -- Cooldown Check
                if t.cooldown and t.cooldown > 0 then
                    local hours = math.floor(t.cooldown / 3600)
                    local mins = math.floor((t.cooldown % 3600) / 60)
                    local seconds = t.cooldown % 60
                     if hours > 0 then
                        btn:setText(string.format("Wait %dh%dm", hours, mins))
                    else
                        btn:setText(string.format("Wait %dm%ds", mins, seconds))
                    end
                    -- Keep enabled so text is visible, but set Start Color to Grey and remove click
                    btn:setImageColor("#333333")
                    btn:setColor("#CCCCCC") -- Slightly dimmed text
                    btn.onClick = nil
                end
                
                statusText = "0 / " .. t.target
                color = "#444444"
                
            elseif t.state == 1 then -- Active
                btn:setText("Cancel")
                btn:setImageColor("red")
                btn.onClick = function() sendAction("cancel", t.id) end
                
                p = math.floor((t.current / t.target) * 100)
                statusText = t.current .. " / " .. t.target
                
                -- Dynamic Colors
                if p < 50 then color = "#ff4444" -- Red
                elseif p < 100 then color = "#ffbb33" -- Yellow
                else color = "#00cc00" end -- Green
                
            elseif t.state == 2 then -- Claim
                btn:setText("CLAIM!")
                btn:setImageColor("#FFFF00")
                btn:setColor("#000000") -- Black text for yellow bg
                btn.onClick = function() sendAction("claim", t.id) end
                
                p = 100
                statusText = "Completed!"
                color = "#ffff00" -- Special color for Claim
                
            elseif t.state == 3 then -- Done
                btn:setText("Repeat")
                if t.repeatable then
                     btn:setImageColor("white")
                     btn:setColor("#000000")
                     btn.onClick = function() sendAction("start", t.id) end
                else
                     btn:setText("Done")
                     btn:setImageColor("#333333")
                     btn:setEnabled(false)
                end
                p = 100
                statusText = "Finished"
                color = "#444444"
            end
            
            setBarState(widget, p, color)
            widget:getChildById('progress'):getChildById('status'):setText(statusText)
            
            -- Rewards Label & Tooltip
            local rewardStr = "Rewards: "
            for i, r in ipairs(t.rewards) do
                if i > 1 then rewardStr = rewardStr .. ", " end
                if r.type == "exp" then rewardStr = rewardStr .. r.value .. " XP" end
                if r.type == "money" then rewardStr = rewardStr .. r.value .. " Gold" end
                if r.type == "item" then 
                    local name = r.name or ("Item " .. r.id)
                    rewardStr = rewardStr .. r.count .. "x " .. name 
                end
                if r.type == "points" then rewardStr = rewardStr .. r.value .. " Pts" end
            end
            widget:getChildById('rewards'):setText(rewardStr)
            widget:setTooltip(rewardStr)
        end
    end
  end
end

-- Callback Definition
function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE then return end
  local status, data = pcall(json.decode, buffer)
  if not status then return end
  
  if data.action == "open" then
      show()
      return
  end
  
  refreshUI(data)
end

-- onGameStart uses onExtendedOpcode, so define it here
function onGameStart()
  create()
  -- scheduleEvent(show, 500) -- Auto Open Disabled by request (Use !task)
end


-- Init and Terminate LAST
function init()
  g_ui.importStyle('modern_tasks.otui')
  
  -- Create Main Window
  -- handled in create() onGameStart
  
  -- Protocol
  ProtocolGame.registerExtendedOpcode(OPCODE, onExtendedOpcode)
  
  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = destroy
  })
  
  if g_game.isOnline() then
    onGameStart()
  end
end

function terminate()
  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = destroy
  })
  ProtocolGame.unregisterExtendedOpcode(OPCODE, onExtendedOpcode)
  destroy()
end
