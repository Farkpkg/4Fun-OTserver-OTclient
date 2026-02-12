--[[
    Modern Task System (Server-Side)
    Built from scratch for ravendor Server.
    Protocol: 205
]]

--[[
    Modern Task System (Server-Side)
    Author: Julian Bernal #julianbernalv
    Date: 2025

    -- HOW TO ADD A NEW TASK --
    Add a new entry to the 'tasks' table below.
    [ID] = {
        name = "Task Name",
        category = "Category", -- Options: "Daily", "Story", "Hardcore", "All"
        mobs = {"monster1", "monster2"}, -- Exact names from monsters.xml
        count = 100, -- Kills required
        rewards = {
            {type = "exp", value = 1000},
            {type = "money", value = 500},
            {type = "points", value = 1},
            {type = "item", id = 2160, count = 1}
        },
        repeatable = true/false, -- Can repeat?
        cooldown = 20 * 3600, -- Only for Daily/Repeatable (Seconds). 20 * 3600 = 20 Hours.
        desc = "Description visible in UI."
    }
    
    -- HOW TO ADD COOLDOWNS --
    To add a cooldown, define the time in seconds.
    Example: 
       cooldown = 2 * 3600 -- 2 Hours
       cooldown = 30 * 60 -- 30 Minutes
    * Note: Cooldowns only work if 'repeatable = true'.

    -- HOW TO ADD CATEGORIES --
    1. Server: You can write ANY text in 'category', e.g., "Event", "VIP".
    2. Client: You MUST add a button in 'modern_tasks.otui' to filter by that name.
       Example Button in OTUI:
       Button
         id: tabEvent
         text: Event
         @onClick: modules.game_modern_tasks.selectCategory('Event')

    -- CONSIDERATIONS --
    1. Storage Ranges: This script uses storages from 84999 to 89999. Do not use these ranges in other scripts.
       - Points: 84999
       - Kills: 87000+
       - State: 88000+
       - Cooldown: 89000+
    2. Party Sharing: 
       - If a player is in a party with Shared XP enabled, kills count for all members within 30 sqms.
]]

local OPCODE = 205

-- Configuration
local config = {
    -- Storage Ranges
    killsStart = 87000,
    stateStart = 88000, -- 0=NotStarted, 1=Active, 2=Claimable, 3=Done
    cooldownStart = 89000, -- Timestamp for when task can be taken again
    points = 84999,
    
    tasks = {
        [1] = {
            name = "Rats Clean Up",
            category = "Daily",
            mobs = {"rat", "cave rat"},
            count = 50,
            rewards = {
                {type = "exp", value = 1000},
                {type = "points", value = 1},
                {type = "money", value = 500}
            },
            repeatable = true,
            cooldown = 20 * 3600, -- 20 Hours
            desc = "Clean the sewers."
        },
        [2] = {
            name = "Dragon Lord Hunt",
            category = "Story",
            mobs = {"dragon lord"},
            count = 100,
            rewards = {
                {type = "exp", value = 200000},
                {type = "points", value = 10},
                {type = "item", id = 2498, count = 1} -- Royal Helmet
            },
            repeatable = false,
            desc = "Prove your worth against the lords of dragons."
        },
         [3] = {
            name = "Demon Slayer",
            category = "Hardcore",
            mobs = {"demon"},
            count = 666,
            rewards = {
                {type = "exp", value = 666666},
                {type = "points", value = 50}
            },
            repeatable = true,
             desc = "The ultimate challenge."
        }
    }
}

-- Functions
local function getKills(player, id) return math.max(0, player:getStorageValue(config.killsStart + id)) end
local function setKills(player, id, v) player:setStorageValue(config.killsStart + id, v) end
local function getState(player, id) return math.max(0, player:getStorageValue(config.stateStart + id)) end -- 0 default
local function setState(player, id, v) player:setStorageValue(config.stateStart + id, v) end
local function getCooldown(player, id) return math.max(0, player:getStorageValue(config.cooldownStart + id)) end
local function setCooldown(player, id, v) player:setStorageValue(config.cooldownStart + id, v) end

local function sendData(player)
    local payload = {
        action = "sync",
        points = math.max(0, player:getStorageValue(config.points)),
        tasks = {}
    }
    
    for id, t in pairs(config.tasks) do
        local state = getState(player, id)
        local kills = getKills(player, id)
        local cd = getCooldown(player, id)
        local now = os.time()
        
        -- Generate Outfits dynamically
        local outfits = {}
        for _, mob in ipairs(t.mobs) do
            local mType = MonsterType(mob)
            if mType then
                local o = mType:getOutfit()
                table.insert(outfits, {
                    type = o.lookType,
                    head = o.lookHead,
                    body = o.lookBody,
                    legs = o.lookLegs,
                    feet = o.lookFeet,
                    addons = o.lookAddons,
                    mount = o.lookMount
                })
            end
        end

        -- Clone rewards to avoid modifying config permanently, and inject names
        local resolvedRewards = {}
        for _, r in ipairs(t.rewards) do
            local newR = {type = r.type, value = r.value, count = r.count, id = r.id}
            if r.type == "item" then
                newR.name = ItemType(r.id):getName()
            end
            table.insert(resolvedRewards, newR)
        end
        
        table.insert(payload.tasks, {
            id = id,
            name = t.name,
            cat = t.category,
            desc = t.desc,
            current = kills,
            target = t.count,
            state = state, -- 0=New, 1=Active, 2=Claim, 3=Done
            outfits = outfits, -- Send LIST of outfits
            rewards = resolvedRewards,
            repeatable = t.repeatable,
            cooldown = (state == 0 and cd > now) and (cd - now) or 0
        })
    end
    
    player:sendExtendedOpcode(OPCODE, json.encode(payload))
end

local function handleOpcode(player, opcode, buffer)
    if opcode ~= OPCODE then return end
    local status, data = pcall(json.decode, buffer)
    if not status then return end
    
    if data.action == "start" then
        local id = data.id
        local t = config.tasks[id]
        
        -- Check Cooldown
        local cd = getCooldown(player, id)
        if cd > os.time() then
            local remaining = cd - os.time()
            local hours = math.floor(remaining / 3600)
            local mins = math.floor((remaining % 3600) / 60)
            player:sendTextMessage(MESSAGE_STATUS_SMALL, string.format("Task is on cooldown. Wait %dh %dm.", hours, mins))
            return
        end

        if t and getState(player, id) == 0 then
            setState(player, id, 1) -- Active
            setKills(player, id, 0)
            sendData(player)
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Task started: " .. t.name)
        elseif t and t.repeatable and getState(player, id) == 3 then
             -- Restart explicitly needed? state 0 handles it better if we reset on claim.
             -- But kept for safety if manually forced to 3.
             setState(player, id, 1) 
             setKills(player, id, 0)
             sendData(player)
             player:sendTextMessage(MESSAGE_STATUS_SMALL, "Task restarted: " .. t.name)
        end
        
    elseif data.action == "claim" then
        local id = data.id
        local t = config.tasks[id]
        if t and getState(player, id) == 2 then -- Claimable
            -- Reward
            local rewardText = "Rewards: "
            for _, r in ipairs(t.rewards) do
                if r.type == "exp" then player:addExperience(r.value, true) rewardText = rewardText .. r.value .. " EXP "
                elseif r.type == "money" then player:setBankBalance(player:getBankBalance() + r.value) rewardText = rewardText .. r.value .. " Gold "
                elseif r.type == "points" then 
                    player:setStorageValue(config.points, math.max(0, player:getStorageValue(config.points)) + r.value)
                    rewardText = rewardText .. r.value .. " Pts "
                elseif r.type == "item" then player:addItem(r.id, r.count) rewardText = rewardText .. r.count .. "x Item "
                end
            end
            
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Task Completed! " .. rewardText)
            
            if t.repeatable then
                setState(player, id, 0) -- Reset to allow start (but with cooldown)
                if t.cooldown then
                    setCooldown(player, id, os.time() + t.cooldown)
                end
            else
                setState(player, id, 3) -- Done forever
            end
            sendData(player)
        end
    elseif data.action == "cancel" then
        local id = data.id
        if getState(player, id) == 1 then
            setState(player, id, 0)
            setKills(player, id, 0)
            sendData(player)
        end
    elseif data.action == "refresh" then
        sendData(player)
    end
end

-- Events
local ev = CreatureEvent("ModernTaskKill")
function ev.onKill(player, target)
    if not target:isMonster() then return true end
    local name = target:getName():lower()
    
    local function processKill(member, targetName)
        local updated = false
        -- Optimize: Could check only active tasks for performance
        for id, t in pairs(config.tasks) do
            if getState(member, id) == 1 then -- Active
                for _, m in ipairs(t.mobs) do
                    if m:lower() == targetName then
                        local k = getKills(member, id)
                        if k < t.count then
                            k = k + 1
                            setKills(member, id, k)
                            updated = true
                            if k >= t.count then
                                setState(member, id, 2) -- Claimable
                                member:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You finish task %s! Recolecta tu reward.", t.name))
                            else
                                member:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("[Task] %s: %d / %d", t.name, k, t.count))
                            end
                        end
                        break
                    end
                end
            end
        end
        if updated then sendData(member) end
    end

    -- Party Logic
    local party = player:getParty()
    if party and party:isSharedExperienceEnabled() then
        local members = party:getMembers()
        table.insert(members, party:getLeader())
        
        for _, member in ipairs(members) do
            if member:getPosition():getDistance(player:getPosition()) <= 30 then
                processKill(member, name)
            end
        end
    else
        processKill(player, name)
    end
    
    return true
end
ev:register()

local login = CreatureEvent("ModernTaskLogin")
function login.onLogin(player)
    player:registerEvent("ModernTaskKill")
    player:registerEvent("ModernTaskOpcode")
    return true
end
login:register()

local op = CreatureEvent("ModernTaskOpcode")
op.onExtendedOpcode = handleOpcode
op:type("extendedopcode")
op:register()

local cmd = TalkAction("!task")
function cmd.onSay(player, words, type)
    player:sendExtendedOpcode(OPCODE, json.encode({action = "open"}))
    return false
end
cmd:register()
