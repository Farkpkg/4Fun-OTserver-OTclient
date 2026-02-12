-- @docclass Player

PlayerStates = {
  Hungry = -1,
  None = 0,
  Poison = 1,
  Burn = 2,
  Energy = 4,
  Drunk = 8,
  ManaShield = 16,
  Paralyze = 32,
  Haste = 64,
  Swords = 128,
  Drowning = 256,
  Freezing = 512,
  Dazzled = 1024,
  Cursed = 2048,
  PartyBuff = 4096,
  PzBlock = 8192,
  Pz = 16384,
  Bleeding = 32768,
  --Hungry = 65536,
  SufferringLesserHex = 65536,
  SufferringIntenserHex = 131072,
  SufferringGreaterHex = 262144,
  Rooted = 524288,
  Feared = 1048576,
  CurseI = 2097152,
  CurseII = 4194304,
  CurseIII = 8388608,
  CurseIV = 16777216,
  CurseV = 33554432,
  NewMagicShield = 67108864,
  Agony = 134217728,
  Powerless = 268435456,
  Mentored = 536870912,
}

TaintsDescriptions = {
  [1] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* 6% chance that a melee foe will switch positions with a nearby character.",
  [2] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* 6% chance that a melee foe will switch positions with a nearby character.\n* 6.25% chance that an even more powerful foe will rise from the corpse of a killed monster.",
  [3] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* 6% chance that a melee foe will switch positions with a nearby character.\n* 6.25% chance that an even more powerful foe will rise from the corpse of a killed monster.\n* Monsters gain additional abilities.",
  [4] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* 6% chance that a melee foe will switch positions with a nearby character.\n* 6.25% chance that an even more powerful foe will rise from the corpse of a killed monster.\n* Monsters gain additional abilities.\n* Total damage taken by characters is increased by 14%.",
  [5] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* Due to the influence of Bakragore, all penalties are increased, but in return, the loot is improved.",
  [6] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* Due to the influence of Bakragore, all penalties are increased, but in return, the loot is improved.\n* 9% chance that a melee foe will switch positions with a nearby character.",
  [7] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* Due to the influence of Bakragore, all penalties are increased, but in return, the loot is improved.\n* 9% chance that a melee foe will switch positions with a nearby character.\n* 9.375% chance that an even more powerful foe will rise from the corpse of a killed monster.",
  [8] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* Due to the influence of Bakragore, all penalties are increased, but in return, the loot is improved.\n* 9% chance that a melee foe will switch positions with a nearby character.\n* 9.375% chance that an even more powerful foe will rise from the corpse of a killed monster.\n* Monsters gain additional abilities.",
  [9] = "Since you are in Bakragore's lairs, you are suffering from the following penalties:\n* Due to the influence of Bakragore, all penalties are increased, but in return, the loot is improved.\n* 9% chance that a melee foe will switch positions with a nearby character.\n* 9.375% chance that an even more powerful foe will rise from the corpse of a killed monster.\n* Monsters gain additional abilities.\n* Total damage taken by characters is increased by 21%.",
}

Icons = {}
Icons[PlayerStates.Poison] = { tooltip = tr('You are poisoned'), path = '/images/game/states/poisoned', id = 'condition_poisoned' }
Icons[PlayerStates.Burn] = { tooltip = tr('You are burning'), path = '/images/game/states/burning', id = 'condition_burning' }
Icons[PlayerStates.Energy] = { tooltip = tr('You are electrified'), path = '/images/game/states/electrified', id = 'condition_electrified' }
Icons[PlayerStates.Drunk] = { tooltip = tr('You are drunk'), path = '/images/game/states/drunk', id = 'condition_drunk' }
Icons[PlayerStates.ManaShield] = { tooltip = tr('You are protected by a magic shield'), path = '/images/game/states/magic_shield', id = 'condition_magic_shield' }
Icons[PlayerStates.Paralyze] = { tooltip = tr('You are paralysed'), path = '/images/game/states/slowed', id = 'condition_slowed' }
Icons[PlayerStates.Haste] = { tooltip = tr('You are hasted'), path = '/images/game/states/haste', id = 'condition_haste' }
Icons[PlayerStates.Swords] = { tooltip = tr('You may not logout during a fight'), path = '/images/game/states/logout_block', id = 'condition_logout_block' }
Icons[PlayerStates.Drowning] = { tooltip = tr('You are drowning'), path = '/images/game/states/drowning', id = 'condition_drowning' }
Icons[PlayerStates.Freezing] = { tooltip = tr('You are freezing'), path = '/images/game/states/freezing', id = 'condition_freezing' }
Icons[PlayerStates.Dazzled] = { tooltip = tr('You are dazzled'), path = '/images/game/states/dazzled', id = 'condition_dazzled' }
Icons[PlayerStates.Cursed] = { tooltip = tr('You are cursed'), path = '/images/game/states/cursed', id = 'condition_cursed' }
Icons[PlayerStates.PartyBuff] = { tooltip = tr('You are strengthened'), path = '/images/game/states/strengthened', id = 'condition_strengthened' }
Icons[PlayerStates.PzBlock] = { tooltip = tr('You may not logout or enter a protection zone'), path = '/images/game/states/protection_zone_block', id = 'condition_protection_zone_block' }
Icons[PlayerStates.Pz] = { tooltip = tr('You are within a protection zone'), path = '/images/game/states/protection_zone', id = 'condition_protection_zone' }
Icons[PlayerStates.Bleeding] = { tooltip = tr('You are bleeding'), path = '/images/game/states/bleeding', id = 'condition_bleeding' }
Icons[PlayerStates.Hungry] = { tooltip = tr('You are hungry'), path = '/images/game/states/hungry', id = 'condition_hungry' }
Icons[PlayerStates.SufferringLesserHex] = { tooltip = tr('You are sufferring lesser hex'), path = '/images/game/states/sufferringlesserhex', id = 'condition_sufferringlesserhex' }
Icons[PlayerStates.SufferringIntenserHex] = { tooltip = tr('You are sufferring intenser hex'), path = '/images/game/states/sufferringintenserhex', id = 'condition_sufferringintenserhex' }
Icons[PlayerStates.SufferringGreaterHex] = { tooltip = tr('You are sufferring greater hex'), path = '/images/game/states/sufferringgreaterhex', id = 'condition_sufferringgreaterhex' }
Icons[PlayerStates.Rooted] = { tooltip = tr('You are rooted'), path = '/images/game/states/rooted', id = 'condition_rooted' }
Icons[PlayerStates.Feared] = { tooltip = tr('You are feared'), path = '/images/game/states/feared', id = 'condition_feared' }
Icons[PlayerStates.CurseI] = { tooltip = tr('If you are in Goshnar\'s lairs, you are sufferring from the following penalty:\n- 10%% chance that a creature teleports near you'), path = '/images/game/states/cursei', id = 'condition_cursei' }
Icons[PlayerStates.CurseII] = { tooltip = tr('If you are in Goshnar\'s lairs, you are sufferring from the following penalty:\n- 10%% chance that a creature teleports near you\n 0.5%% chance that a new creature spawns near you if you hit another creature'), path = '/images/game/states/curseii', id = 'condition_curseii' }
Icons[PlayerStates.CurseIII] = { tooltip = tr('If you are in Goshnar\'s lairs, you are sufferring from the following penalty:\n- 10%% chance that a creature teleports near you\n 0.5%% chance that a new creature spawns near you if you hit another creature\n- received damage increased by 15%%'), path = '/images/game/states/curseiii', id = 'condition_curseiii' }
Icons[PlayerStates.CurseIV] = { tooltip = tr('If you are in Goshnar\'s lairs, you are sufferring from the following penalty:\n- 10%% chance that a creature teleports near you\n 0.5%% chance that a new creature spawns near you if you hit another creature\n- received damage increased by 15%%\n - 10%% chance that a creature will fully heal itself instead of dying'), path = '/images/game/states/curseiv', id = 'condition_curseiv' }
Icons[PlayerStates.CurseV] = { tooltip = tr('If you are in Goshnar\'s lairs, you are sufferring from the following penalty:\n- 10%% chance that a creature teleports near you\n 0.5%% chance that a new creature spawns near you if you hit another creature\n- received damage increased by 15%% \n - 10%% chance that a creature will fully heal itself instead of dying\n- loss of 10%% of your hit points and your mana every 10 seconds'), path = '/images/game/states/cursev', id = 'condition_cursev' }
Icons[PlayerStates.NewMagicShield] = { tooltip = tr('You are protected by a magic shield'), path = '/images/game/states/magic_shield', id = 'condition_new_magic_shield' }
Icons[PlayerStates.Agony] = { tooltip = tr('You are in agony'), path = '/images/game/states/agony', id = 'condition_agony' }
Icons[PlayerStates.Powerless] = { tooltip = tr('You are Powerless'), path = '/images/game/states/sufferringpowerless', id = 'condition_powerless' }
Icons[PlayerStates.Mentored] = { tooltip = tr('You are empowered by Mentor Other'), path = '/images/game/states/mentored', id = 'condition_mentored' }

SkullIcons = {}
SkullIcons[SkullGreen] = { tooltip = tr('You are a member of a party'), path = '/images/game/states/skullgreen', id = 'skullIcon' }
SkullIcons[SkullWhite] = { tooltip = tr('You have attacked an unmarked player'), path = '/images/game/states/skullwhite', id = 'skullIcon' }
SkullIcons[SkullRed] = { tooltip = tr('You have killed too many unmarked players'), path = '/images/game/states/skullred', id = 'skullIcon' }
SkullIcons[SkullOrange] = { tooltip = tr('You may suffer revenge from your former victim'), path = '/images/game/states/skullorange', id = 'skullIcon' }

InventorySlotOther = 0
InventorySlotHead = 1
InventorySlotNeck = 2
InventorySlotBack = 3
InventorySlotBody = 4
InventorySlotRight = 5
InventorySlotLeft = 6
InventorySlotLeg = 7
InventorySlotFeet = 8
InventorySlotFinger = 9
InventorySlotAmmo = 10
InventorySlotPurse = 11
InventorySlotBattlePass = 12

InventorySlotFirst = 1
InventorySlotLast = 10

function Player:isPartyLeader()
  local shield = self:getShield()
  return (shield == ShieldYellow or
          shield == ShieldYellowSharedExp or
          shield == ShieldYellowNoSharedExpBlink or
          shield == ShieldYellowNoSharedExp)
end

function Player:isPartyMember()
  local shield = self:getShield()
  return (shield == ShieldYellow or
          shield == ShieldYellowSharedExp or
          shield == ShieldYellowNoSharedExpBlink or
          shield == ShieldYellowNoSharedExp or
          shield == ShieldBlueSharedExp or
          shield == ShieldBlueNoSharedExpBlink or
          shield == ShieldBlueNoSharedExp or
          shield == ShieldBlue)
end

function Player:isInSameParty(name)
  local partyData = g_minimap.getPartyMembersData()
  if table.empty(partyData) then
    return false
  end

  for _, data in pairs(partyData) do
    if data.name == name then
      return true
    end
  end
end

function Player:getPartyCreatureId(name)
  local partyData = g_minimap.getPartyMembersData()
  if table.empty(partyData) then
    return 0
  end

  for _, data in pairs(partyData) do
    if data.name == name then
      return data.id
    end
  end
end

function Player:isPartySharedExperienceActive()
  local shield = self:getShield()
  return (shield == ShieldYellowSharedExp or
          shield == ShieldYellowNoSharedExpBlink or
          shield == ShieldYellowNoSharedExp or
          shield == ShieldBlueSharedExp or
          shield == ShieldBlueNoSharedExpBlink or
          shield == ShieldBlueNoSharedExp)
end

function Player:hasVip(creatureName)
  for id, vip in pairs(g_game.getVips()) do
    if (vip[1] == creatureName) then return true end
  end
  return false
end

function Player:isMounted()
  local outfit = self:getOutfit()
  return outfit.mount ~= nil and outfit.mount > 0
end

function Player:toggleMount()
  if g_game.getFeature(GamePlayerMounts) then
    g_game.mount(not self:isMounted())
  end
end

function Player:mount()
  if g_game.getFeature(GamePlayerMounts) then
    g_game.mount(true)
  end
end

function Player:dismount()
  if g_game.getFeature(GamePlayerMounts) then
    g_game.mount(false)
  end
end

function Player:getItem(itemId, subType)
  return g_game.findPlayerItem(itemId, subType or -1)
end

function Player:getItems(itemId, subType)
  local items = {}
  local result, _ = tryCatch(g_game.findItems, itemId, subType or -1)
  if result then
      items = result
  end
  return items
end

function Player:getItemsCount(itemId)
  local items, count = self:getItems(itemId), 0
  for i=1,#items do
    count = count + items[i]:getCount()
  end
  return count
end

function Player:hasState(state, states)
  if not states then
    states = self:getStates()
  end

  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > states then break end

    local states = bit32.band(states, pow)
    if states == state then
      return true
    end
  end
  return false
end

if not Analyzer then
    Analyzer = {}
end

if not Analyzer.analyzers then
  Analyzer.analyzers = {
    trackedLoot = {},
    customPrices = {},
    lootChannel = true,
    rarityFrames = true
  }
end
