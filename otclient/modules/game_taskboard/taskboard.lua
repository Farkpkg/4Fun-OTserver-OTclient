-- =============================================================
--  TASK BOARD — taskboard.lua
--  OTCRedemption (mehah/EDU) | Protocolo 15x | CrystalServer
--
--  OPCODES (servidor → cliente):
--    OPCODE_TASKBOARD_OPEN        = 50
--    OPCODE_TASKBOARD_BOUNTY_DATA = 51
--    OPCODE_TASKBOARD_WEEKLY_DATA = 52
--    OPCODE_TASKBOARD_SHOP_DATA   = 53
--    OPCODE_TASKBOARD_PREFERRED   = 54
--    OPCODE_TASKBOARD_TALISMAN    = 55
--    OPCODE_TASKBOARD_CURRENCIES  = 56
--    OPCODE_TASKBOARD_RESULT      = 57
--
--  OPCODES (cliente → servidor):
--    OPCODE_TASK_SELECT           = 60
--    OPCODE_TASK_REROLL           = 61
--    OPCODE_TASK_CLAIM_DAILY      = 62
--    OPCODE_TASK_PREFERRED_SET    = 63
--    OPCODE_TASK_PREFERRED_CLEAR  = 64
--    OPCODE_TASK_UNWANTED_CLEAR   = 65
--    OPCODE_TASK_EXTRA_SLOT       = 66
--    OPCODE_TALISMAN_UPGRADE      = 67
--    OPCODE_SHOP_BUY              = 68
--    OPCODE_WEEKLY_DIFFICULTY     = 69
--    OPCODE_WEEKLY_DELIVER        = 70
--    OPCODE_WEEKLY_UNLOCK_KILL    = 71
--    OPCODE_WEEKLY_UNLOCK_DELIVER = 72
-- =============================================================

-- ─────────────────────────────────────────────────────────────
--  OPCODES
-- ─────────────────────────────────────────────────────────────
local OPCODE = {
  -- recebidos do servidor
  OPEN         = 50,
  BOUNTY_DATA  = 51,
  WEEKLY_DATA  = 52,
  SHOP_DATA    = 53,
  PREFERRED    = 54,
  TALISMAN     = 55,
  CURRENCIES   = 56,
  RESULT       = 57,

  -- enviados ao servidor
  OPEN_REQUEST = 59,
  SELECT       = 60,
  REROLL       = 61,
  CLAIM_DAILY  = 62,
  PREF_SET     = 63,
  PREF_CLEAR   = 64,
  UNWANT_CLEAR = 65,
  EXTRA_SLOT   = 66,
  TALISM_UP    = 67,
  SHOP_BUY     = 68,
  WEEKLY_DIFF  = 69,
  DELIVER      = 70,
  UNLOCK_KILL  = 71,
  UNLOCK_DELIV = 72,
}

-- ─────────────────────────────────────────────────────────────
--  ESTADO LOCAL
-- ─────────────────────────────────────────────────────────────
local state = {
  -- moedas
  rerollTokens  = 0,
  bountyPoints  = 0,
  huntingPoints = 0,
  soulseals     = 0,

  -- bounty tasks (3 slots)
  bountyTasks   = {},   -- {name, creatureId, kills, maxKills, xp, bp, rt, tier}
  difficulty    = 'beginner',

  -- talisman
  talisman = {
    {name='Damage Against Creatures', current=2.50, next=3.00, cost=5},
    {name='Life Leech',               current=2.50, next=3.00, cost=5},
    {name='More Loot',                current=2.50, next=3.00, cost=5},
    {name='Double Bestiary Progress', current=5.00, next=6.00, cost=5},
  },

  -- preferred / unwanted
  preferred  = {},  -- [{name, creatureId}]
  unwanted   = {},  -- [{name, creatureId}]
  extraSlots = {false, false, false, false},  -- desbloqueados?

  -- weekly
  weeklyKillTasks     = {},  -- {name, creatureId, kills, maxKills}
  weeklyDelivTasks    = {},  -- {name, itemId, count, maxCount}
  weeklyRewardXP      = 0,
  weeklyCompleted     = 0,
  weeklyKillsTotal    = 6,
  weeklyDelivTotal    = 6,
  weeklyHTP           = 0,
  weeklySeals         = 0,
  killUnlocked        = false,
  delivUnlocked       = false,

  -- shop
  shopItems = {},  -- {name, desc, price, itemId}

  -- criatura selecionada na preferred list
  selectedCreature = nil,
  creatureList     = {},  -- lista completa recebida do servidor
}

-- ─────────────────────────────────────────────────────────────
--  REFERÊNCIAS DE WIDGETS
-- ─────────────────────────────────────────────────────────────
local ui = {}

-- ─────────────────────────────────────────────────────────────
--  MULTIPLICADORES WEEKLY
-- ─────────────────────────────────────────────────────────────
local MULTIPLIERS = {
  {tasks=0,  mult=1},
  {tasks=4,  mult=2},
  {tasks=8,  mult=3},
  {tasks=12, mult=5},
  {tasks=16, mult=8},
}

local EXTRA_SLOT_COSTS = {300, 600, 900, 1200}
local DIFFICULTY_TO_ID = {beginner = 0, adept = 1, expert = 2, master = 3}
local ID_TO_DIFFICULTY = {[0] = 'beginner', [1] = 'adept', [2] = 'expert', [3] = 'master'}
local bitLib = rawget(_G, 'bit32') or rawget(_G, 'bit')
local isUpdatingDifficulty = false
local taskBoardButton = nil
local sendOpcode


local function destroyTaskBoardButton()
  if taskBoardButton then
    taskBoardButton:destroy()
    taskBoardButton = nil
  end
end

local function toggleTaskBoardWindow()
  if not g_game.isOnline() then
    return
  end

  if ui.window and ui.window:isVisible() then
    hide()
    if taskBoardButton then
      taskBoardButton:setOn(false)
    end
    return
  end

  sendOpcode(OPCODE.OPEN_REQUEST)
end

local function checkTaskBoardButton()
  if not g_game.isOnline() then
    return
  end

  if not taskBoardButton then
    taskBoardButton = modules.game_mainpanel.addToggleButton('topMenuTaskBoardButton', tr('Task Board'), '/images/options/button_prey', toggleTaskBoardWindow)
    taskBoardButton:setOn(false)
  end
end

-- ─────────────────────────────────────────────────────────────
--  INIT / TERMINATE
-- ─────────────────────────────────────────────────────────────
function init()
  connect(g_game, { onGameStart = checkTaskBoardButton, onGameEnd = hide })

  g_ui.importStyle('taskboard_widgets')

  -- Carrega UI
  ui.window        = g_ui.loadUI('taskboard', GameInterface)
  ui.prefWindow    = g_ui.loadUI('preferredListWindow', GameInterface)
  ui.popupWindow   = g_ui.loadUI('weeklyProgressPopup', GameInterface)

  if not ui.window then
    g_logger.error('[game_taskboard] failed to load main UI: taskboard.otui')
    return
  end

  if not ui.prefWindow then
    g_logger.error('[game_taskboard] failed to load preferred UI: preferredListWindow.otui')
    return
  end

  if not ui.popupWindow then
    g_logger.error('[game_taskboard] failed to load popup UI: weeklyProgressPopup.otui')
    return
  end

  -- Registra opcodes do servidor
  ProtocolGame.registerOpcode(OPCODE.OPEN,        onServerOpen)
  ProtocolGame.registerOpcode(OPCODE.BOUNTY_DATA, onBountyData)
  ProtocolGame.registerOpcode(OPCODE.WEEKLY_DATA, onWeeklyData)
  ProtocolGame.registerOpcode(OPCODE.SHOP_DATA,   onShopData)
  ProtocolGame.registerOpcode(OPCODE.PREFERRED,   onPreferredData)
  ProtocolGame.registerOpcode(OPCODE.TALISMAN,    onTalismanData)
  ProtocolGame.registerOpcode(OPCODE.CURRENCIES,  onCurrenciesData)
  ProtocolGame.registerOpcode(OPCODE.RESULT,      onResultData)

  -- Preenche combo de dificuldade
  local combo = ui.window:recursiveGetChildById('comboDifficulty')
  if not combo then
    g_logger.error('[game_taskboard] comboDifficulty widget was not found in taskboard UI')
    return
  end
  combo:addOption('Beginner', 'beginner')
  combo:addOption('Adept',    'adept')
  combo:addOption('Expert',   'expert')
  combo:addOption('Master',   'master')
  combo.onOptionChange = function(_, opt)
    state.difficulty = opt
    if isUpdatingDifficulty then
      return
    end
    sendOpcode(OPCODE.WEEKLY_DIFF, function(msg)
      msg:addU8(DIFFICULTY_TO_ID[opt] or 0)
    end)
  end

  -- Conecta aba
  local tabBar = ui.window:recursiveGetChildById('taskBoardTabBar')
  if not tabBar then
    g_logger.error('[game_taskboard] taskBoardTabBar widget was not found in taskboard UI')
    return
  end
  tabBar.onTabChange = onTabChange

  if g_game.isOnline() then
    checkTaskBoardButton()
  end
end

function terminate()
  disconnect(g_game, { onGameStart = checkTaskBoardButton, onGameEnd = hide })
  destroyTaskBoardButton()

  ProtocolGame.unregisterOpcode(OPCODE.OPEN)
  ProtocolGame.unregisterOpcode(OPCODE.BOUNTY_DATA)
  ProtocolGame.unregisterOpcode(OPCODE.WEEKLY_DATA)
  ProtocolGame.unregisterOpcode(OPCODE.SHOP_DATA)
  ProtocolGame.unregisterOpcode(OPCODE.PREFERRED)
  ProtocolGame.unregisterOpcode(OPCODE.TALISMAN)
  ProtocolGame.unregisterOpcode(OPCODE.CURRENCIES)
  ProtocolGame.unregisterOpcode(OPCODE.RESULT)

  if ui.window then
    ui.window:destroy()
  end
  if ui.prefWindow then
    ui.prefWindow:destroy()
  end
  if ui.popupWindow then
    ui.popupWindow:destroy()
  end
end

-- ─────────────────────────────────────────────────────────────
--  SHOW / HIDE
-- ─────────────────────────────────────────────────────────────
function show()
  if ui.window then
    ui.window:show()
    ui.window:raise()
    ui.window:focus()
  end
end

function hide()
  if ui.window then
    ui.window:hide()
  end
  if taskBoardButton then
    taskBoardButton:setOn(false)
  end
end

-- ─────────────────────────────────────────────────────────────
--  TROCA DE ABAS
-- ─────────────────────────────────────────────────────────────
function onTabChange(tabBar, tab)
  local w = ui.window
  w:recursiveGetChildById('panelBounty'):setVisible(tab:getId() == 'tabBounty')
  w:recursiveGetChildById('panelWeekly'):setVisible(tab:getId() == 'tabWeekly')
  w:recursiveGetChildById('panelShop'):setVisible(tab:getId() == 'tabShop')
end

-- ─────────────────────────────────────────────────────────────
--  HELPERS — enviar pacote ao servidor
-- ─────────────────────────────────────────────────────────────
local function addU8(buffer, value)
  buffer[#buffer + 1] = string.char(value % 256)
end

local function addU16(buffer, value)
  buffer[#buffer + 1] = string.char(value % 256, math.floor(value / 256) % 256)
end

local function addU32(buffer, value)
  local b1 = value % 256
  local b2 = math.floor(value / 256) % 256
  local b3 = math.floor(value / 65536) % 256
  local b4 = math.floor(value / 16777216) % 256
  buffer[#buffer + 1] = string.char(b1, b2, b3, b4)
end

sendOpcode = function(opcode, writeCallback)
  local protocol = g_game.getProtocolGame()
  if not protocol then return end

  local payload = {}
  if writeCallback then
    writeCallback({
      addU8 = function(_, value) addU8(payload, value) end,
      addU16 = function(_, value) addU16(payload, value) end,
      addU32 = function(_, value) addU32(payload, value) end,
    })
  end

  protocol:sendExtendedOpcode(opcode, table.concat(payload))
end

-- ─────────────────────────────────────────────────────────────
--  HANDLERS: RECEBIDOS DO SERVIDOR
-- ─────────────────────────────────────────────────────────────

-- Abre a janela e solicita todos os dados
function onServerOpen(protocol, msg)
  show()
  if taskBoardButton then
    taskBoardButton:setOn(true)
  end
  -- O servidor pode já enviar os dados junto ou podemos pedir:
  -- (depende da implementação server-side; aqui apenas abrimos)
end

-- Dados das Bounty Tasks (3 tasks sorteadas)
-- Formato: uint8 difficulty | 3x { string name, uint32 creatureId,
--          uint32 kills, uint32 maxKills, uint64 xp,
--          uint16 bp, uint8 rt, uint8 tier (0=normal,1=silver,2=gold) }
function onBountyData(protocol, msg)
  local diff = msg:getU8()
  state.difficulty = ID_TO_DIFFICULTY[diff] or 'beginner'

  local combo = ui.window and ui.window:recursiveGetChildById('comboDifficulty')
  if combo then
    isUpdatingDifficulty = true
    combo:setCurrentOptionByData(state.difficulty, true)
    isUpdatingDifficulty = false
  end

  state.bountyTasks = {}

  for i = 1, 3 do
    local task = {
      name       = msg:getString(),
      creatureId = msg:getU32(),
      kills      = msg:getU32(),
      maxKills   = msg:getU32(),
      xp         = msg:getU64(),
      bp         = msg:getU16(),
      rt         = msg:getU8(),
      tier       = msg:getU8(),  -- 0=normal 1=silver 2=gold
    }
    state.bountyTasks[i] = task
  end

  refreshBountyCards()
end

-- Dados das Talisman
-- Formato: 4x { float current, float next, uint16 cost }
function onTalismanData(protocol, msg)
  for i = 1, 4 do
    state.talisman[i].current = msg:getFloat()
    state.talisman[i].next    = msg:getFloat()
    state.talisman[i].cost    = msg:getU16()
  end
  refreshTalisman()
end

-- Dados Weekly
-- Formato:
--   uint32 rewardXP
--   bool killUnlocked, bool delivUnlocked
--   uint8 completedTasks
--   uint32 weeklyHTP, uint32 weeklySeals
--   6x kill { string name, uint32 creatureId, uint32 kills, uint32 maxKills }
--   6x delivery { string name, uint32 itemId, uint32 count, uint32 maxCount }
function onWeeklyData(protocol, msg)
  state.weeklyRewardXP   = msg:getU32()
  state.killUnlocked     = msg:getU8() == 1
  state.delivUnlocked    = msg:getU8() == 1
  state.weeklyCompleted  = msg:getU8()
  state.weeklyHTP        = msg:getU32()
  state.weeklySeals      = msg:getU32()

  state.weeklyKillTasks = {}
  for i = 1, 6 do
    state.weeklyKillTasks[i] = {
      name       = msg:getString(),
      creatureId = msg:getU32(),
      kills      = msg:getU32(),
      maxKills   = msg:getU32(),
    }
  end

  state.weeklyDelivTasks = {}
  for i = 1, 6 do
    state.weeklyDelivTasks[i] = {
      name    = msg:getString(),
      itemId  = msg:getU32(),
      count   = msg:getU32(),
      maxCount= msg:getU32(),
    }
  end

  refreshWeekly()
end

-- Dados da Loja
-- Formato: uint16 count | count x { string name, string desc, uint32 price, uint32 itemId, uint8 mountOrOutfit }
function onShopData(protocol, msg)
  local count = msg:getU16()
  state.shopItems = {}
  for i = 1, count do
    state.shopItems[i] = {
      name         = msg:getString(),
      desc         = msg:getString(),
      price        = msg:getU32(),
      itemId       = msg:getU32(),
      mountOrOutfit= msg:getU8(),
    }
  end
  refreshShop()
end

-- Preferred/Unwanted list
-- Formato:
--   uint8 extraSlots (bitmask 4 bits)
--   uint8 prefCount | prefCount x { string name, uint32 creatureId }
--   uint8 unwantCount | unwantCount x { string name, uint32 creatureId }
--   uint16 creatureListCount | count x { string name, uint32 creatureId }
function onPreferredData(protocol, msg)
  local extraBits = msg:getU8()
  for i = 1, 4 do
    local mask = 2 ^ (i - 1)
    if bitLib and bitLib.band and bitLib.lshift then
      mask = bitLib.lshift(1, i - 1)
      state.extraSlots[i] = (bitLib.band(extraBits, mask) ~= 0)
    else
      state.extraSlots[i] = (math.floor(extraBits / mask) % 2 == 1)
    end
  end

  local prefCount = msg:getU8()
  state.preferred = {}
  for i = 1, prefCount do
    state.preferred[i] = {name=msg:getString(), creatureId=msg:getU32()}
  end

  local unwantCount = msg:getU8()
  state.unwanted = {}
  for i = 1, unwantCount do
    state.unwanted[i] = {name=msg:getString(), creatureId=msg:getU32()}
  end

  local listCount = msg:getU16()
  state.creatureList = {}
  for i = 1, listCount do
    state.creatureList[i] = {name=msg:getString(), creatureId=msg:getU32()}
  end

  refreshPreferredList()
end

-- Moedas atualizadas
-- Formato: uint16 rt, uint32 bp, uint32 htp, uint32 seals
function onCurrenciesData(protocol, msg)
  state.rerollTokens  = msg:getU16()
  state.bountyPoints  = msg:getU32()
  state.huntingPoints = msg:getU32()
  state.soulseals     = msg:getU32()
  refreshCurrencies()
end

-- Resultado de ação (feedback ao jogador)
-- Formato: uint8 ok (1=success), string message
function onResultData(protocol, msg)
  local ok  = msg:getU8() == 1
  local txt = msg:getString()
  if txt and #txt > 0 then
    if ok then
      displayInfoBox('Task Board', txt)
    else
      displayErrorBox('Task Board', txt)
    end
  end
end

-- ─────────────────────────────────────────────────────────────
--  REFRESH DE UI
-- ─────────────────────────────────────────────────────────────

local TIER_LABEL = {'', ' [SILVER 2x]', ' [GOLD 4x]'}
local TIER_COLOR = {'#f0c060', '#d0d0d0', '#f0c000'}

function refreshBountyCards()
  local w = ui.window
  for i = 1, 3 do
    local t    = state.bountyTasks[i]
    local card = w:recursiveGetChildById('taskCard'..i)
    if not card or not t then goto continue end

    -- Nome + tier badge
    local nameLabel = card:recursiveGetChildById('taskCard'..i..'Name')
    local tier      = t.tier or 0
    nameLabel:setText(t.name .. (TIER_LABEL[tier+1] or ''))
    nameLabel:setColor(TIER_COLOR[tier+1] or '#f0c060')

    -- Criatura
    local creature = card:recursiveGetChildById('taskCard'..i..'Creature')
    if creature and t.creatureId > 0 then
      creature:setOutfit({type=t.creatureId})
    end

    -- Kills
    local killsLabel = card:recursiveGetChildById('taskCard'..i..'Kills')
    killsLabel:setText(t.kills .. ' / ' .. t.maxKills .. ' kills')

    -- Recompensas
    local mult = (tier == 1) and 2 or (tier == 2) and 4 or 1
    local rewardLabel = card:recursiveGetChildById('taskCard'..i..'Reward')
    rewardLabel:setText(
      'Reward' .. (mult > 1 and ' ('..mult..'x)' or '') .. ':\n' ..
      '  ' .. formatNum(t.xp * mult) .. ' XP\n' ..
      '  ' .. (t.bp * mult) .. ' BP   ' ..
      (t.rt * mult) .. ' RT'
    )

    ::continue::
  end
end

function refreshTalisman()
  local w = ui.window
  local ids = {'talism1','talism2','talism3','talism4'}
  for i, id in ipairs(ids) do
    local t    = state.talisman[i]
    local panel = w:recursiveGetChildById(id)
    if not panel or not t then goto continue end

    panel:recursiveGetChildById(id..'Value'):setText(
      'Current: ' .. string.format('%.2f', t.current) .. '%'
    )
    panel:recursiveGetChildById(id..'Upgrade'):setText(
      'Upgrade to ' .. string.format('%.2f', t.next) .. '%'
    )
    panel:recursiveGetChildById(id..'Cost'):setText(t.cost .. ' BP')
    ::continue::
  end
end

function refreshCurrencies()
  local w = ui.window
  w:recursiveGetChildById('lblBottomRT'):setText(state.rerollTokens .. ' ◆')
  w:recursiveGetChildById('lblBottomBP'):setText(state.bountyPoints .. ' ●')
  w:recursiveGetChildById('lblBottomHTP'):setText(state.huntingPoints .. ' ▲')
  w:recursiveGetChildById('lblBottomSeal'):setText(state.soulseals .. ' ✦')

  -- Preferred list também atualiza
  if ui.prefWindow and ui.prefWindow:isVisible() then
    ui.prefWindow:recursiveGetChildById('prefLblRT'):setText(state.rerollTokens .. ' ◆')
    ui.prefWindow:recursiveGetChildById('prefLblBP'):setText(state.bountyPoints .. ' ●')
  end
end

function refreshWeekly()
  local w = ui.window

  -- XP banner
  w:recursiveGetChildById('lblWeeklyXP'):setText(
    'Each task rewards you with ' .. formatNum(state.weeklyRewardXP) .. ' XP.'
  )

  -- Barra de progresso
  local bar = w:recursiveGetChildById('weeklyProgressBar')
  bar:setValue(state.weeklyCompleted)

  -- Weekly rewards
  w:recursiveGetChildById('lblWeeklyHTP'):setText(state.weeklyHTP .. ' HTP')
  w:recursiveGetChildById('lblWeeklySeal'):setText(state.weeklySeals .. ' Soulseals')

  -- Kill cards
  local killGrid = w:recursiveGetChildById('killGrid')
  killGrid:destroyChildren()
  for _, task in ipairs(state.weeklyKillTasks) do
    local card = g_ui.createWidget('weeklyKillCard', killGrid)
    card:recursiveGetChildById('cardName'):setText(task.name)
    card:recursiveGetChildById('cardProgress'):setText(tostring(task.kills))
    card:recursiveGetChildById('cardTotal'):setText('of ' .. task.maxKills)
    if task.creatureId > 0 then
      card:recursiveGetChildById('cardCreature'):setOutfit({type=task.creatureId})
    end
    -- Cor do progresso
    local prog = card:recursiveGetChildById('cardProgress')
    if task.kills >= task.maxKills then
      prog:setColor('#60e060')
    elseif task.kills > 0 then
      prog:setColor('#c8a050')
    else
      prog:setColor('#e05050')
    end
  end

  -- Delivery cards
  local delivGrid = w:recursiveGetChildById('deliveryGrid')
  delivGrid:destroyChildren()
  for i, task in ipairs(state.weeklyDelivTasks) do
    local card = g_ui.createWidget('weeklyKillCard', delivGrid)
    card:recursiveGetChildById('cardName'):setText(task.name)
    card:recursiveGetChildById('cardProgress'):setText(tostring(task.count))
    card:recursiveGetChildById('cardTotal'):setText('of ' .. task.maxCount)
    -- Botão Deliver
    local delivBtn = g_ui.createWidget('Button', card)
    delivBtn:setText('Deliver')
    delivBtn:setHeight(16)
    delivBtn:setFont('verdana-11px-rounded')
    delivBtn.onClick = function()
      deliverItem(i)
    end
    card:addChild(delivBtn)
  end

  -- Unlock buttons
  local btnKill  = w:recursiveGetChildById('btnUnlockKill')
  local btnDeliv = w:recursiveGetChildById('btnUnlockDelivery')
  btnKill:setVisible(not state.killUnlocked)
  btnDeliv:setVisible(not state.delivUnlocked)
end

function refreshShop()
  local shopScroll = ui.window:recursiveGetChildById('shopScroll')
  shopScroll:destroyChildren()
  for i, item in ipairs(state.shopItems) do
    local card = g_ui.createWidget('shopItemCard', shopScroll)
    card:recursiveGetChildById('shopCardTitle'):setText(item.name)
    card:recursiveGetChildById('shopCardDesc'):setText(item.desc)
    card:recursiveGetChildById('shopCardPrice'):setText(formatNum(item.price) .. ' ▲')
    if item.itemId > 0 then
      card:recursiveGetChildById('shopCardItem'):setItemId(item.itemId)
    end
    local idx = i
    card:recursiveGetChildById('shopCardBuyBtn').onClick = function()
      buyShopItem(idx)
    end
  end
end

function refreshPreferredList()
  local w = ui.prefWindow

  -- Slot preferred
  local slot1 = w:recursiveGetChildById('prefSlot1')
  if state.preferred[1] then
    slot1:recursiveGetChildById('prefSlot1Name'):setText(state.preferred[1].name)
    if state.preferred[1].creatureId > 0 then
      slot1:recursiveGetChildById('prefSlot1Creature'):setOutfit({type=state.preferred[1].creatureId})
    end
  else
    slot1:recursiveGetChildById('prefSlot1Name'):setText('--- Empty ---')
  end

  -- Slot unwanted
  local uSlot1 = w:recursiveGetChildById('unwantedSlot1')
  if state.unwanted[1] then
    uSlot1:recursiveGetChildById('unwantedSlot1Name'):setText(state.unwanted[1].name)
    if state.unwanted[1].creatureId > 0 then
      uSlot1:recursiveGetChildById('unwantedSlot1Creature'):setOutfit({type=state.unwanted[1].creatureId})
    end
  else
    uSlot1:recursiveGetChildById('unwantedSlot1Name'):setText('--- Empty ---')
  end

  -- Extra slots
  for i = 1, 4 do
    local btn = w:recursiveGetChildById('extraSlot'..i..'Unlock')
    if btn then
      btn:setEnabled(not state.extraSlots[i])
      btn:setText(state.extraSlots[i] and 'Unlocked' or 'Unlock')
    end
  end

  -- Lista de criaturas
  populateCreatureList(state.creatureList)

  -- Moedas
  refreshCurrencies()
end

function populateCreatureList(list, filter)
  local scroll = ui.prefWindow:recursiveGetChildById('prefCreatureList')
  scroll:destroyChildren()

  for _, creature in ipairs(list) do
    local name = creature.name
    if filter and #filter > 0 then
      if not name:lower():find(filter:lower(), 1, true) then
        goto continue
      end
    end

    local item = g_ui.createWidget('creatureListItem', scroll)
    item:recursiveGetChildById('itemName'):setText(name)
    if creature.creatureId > 0 then
      item:recursiveGetChildById('itemCreature'):setOutfit({type=creature.creatureId})
    end
    local cap = creature  -- captura para o closure
    item.onClick = function()
      selectCreatureInList(cap)
    end

    ::continue::
  end
end

-- ─────────────────────────────────────────────────────────────
--  AÇÕES DO JOGADOR → SERVIDOR
-- ─────────────────────────────────────────────────────────────

-- Seleciona task slot (1, 2 ou 3)
function selectTask(slot)
  sendOpcode(OPCODE.SELECT, function(msg)
    msg:addU8(slot)
  end)
end

-- Reroll das 3 tasks
function rerollTasks()
  if state.rerollTokens <= 0 then
    displayErrorBox('Task Board', 'You have no Reroll Tokens available.')
    return
  end
  sendOpcode(OPCODE.REROLL)
end

-- Claim daily token
function claimDaily()
  sendOpcode(OPCODE.CLAIM_DAILY)
end

-- Upgrade de talisman (1-4)
function upgradeTalisman(slot)
  local t = state.talisman[slot]
  if not t then return end
  if state.bountyPoints < t.cost then
    displayErrorBox('Task Board', 'Not enough Bounty Points.')
    return
  end
  sendOpcode(OPCODE.TALISM_UP, function(msg)
    msg:addU8(slot)
  end)
end

-- Compra item da loja
function buyShopItem(index)
  local item = state.shopItems[index]
  if not item then return end
  if state.huntingPoints < item.price then
    displayErrorBox('Task Board', 'Not enough Hunting Task Points.')
    return
  end
  sendOpcode(OPCODE.SHOP_BUY, function(msg)
    msg:addU16(index)
  end)
end

-- Entrega item (weekly delivery)
function deliverItem(index)
  sendOpcode(OPCODE.DELIVER, function(msg)
    msg:addU8(index)
  end)
end

-- Unlock kill tasks permanentemente
function unlockKillTasks()
  sendOpcode(OPCODE.UNLOCK_KILL)
end

-- Unlock delivery tasks permanentemente
function unlockDeliveryTasks()
  sendOpcode(OPCODE.UNLOCK_DELIV)
end

-- Seleciona dificuldade no popup semanal
function selectDifficulty(diff)
  sendOpcode(OPCODE.WEEKLY_DIFF, function(msg)
    msg:addU8(DIFFICULTY_TO_ID[diff] or 0)
  end)
  closeWeeklyPopup()
end

-- ─────────────────────────────────────────────────────────────
--  PREFERRED LIST
-- ─────────────────────────────────────────────────────────────

function openPreferredList()
  if ui.prefWindow then
    ui.prefWindow:show()
    ui.prefWindow:raise()
    ui.prefWindow:focus()
    -- Solicita dados ao servidor
    sendOpcode(OPCODE.PREF_SET)
  end
end

function closePreferredList()
  if ui.prefWindow then
    ui.prefWindow:hide()
  end
end

function filterCreatureList(text)
  populateCreatureList(state.creatureList, text)
end

function clearCreatureSearch()
  local input = ui.prefWindow:recursiveGetChildById('prefSearchInput')
  if input then
    input:setText('')
    populateCreatureList(state.creatureList)
  end
end

function selectCreatureInList(creature)
  state.selectedCreature = creature
  -- Destaque visual (remove seleção anterior)
  local scroll = ui.prefWindow:recursiveGetChildById('prefCreatureList')
  for _, child in ipairs(scroll:getChildren()) do
    child:setStyleFromSelector('!selected')
  end
end

function clearPreferredSlot(slot)
  sendOpcode(OPCODE.PREF_CLEAR, function(msg)
    msg:addU8(slot)
  end)
end

function clearUnwantedSlot(slot)
  sendOpcode(OPCODE.UNWANT_CLEAR, function(msg)
    msg:addU8(slot)
  end)
end

function unlockExtraSlot(index)
  local cost = EXTRA_SLOT_COSTS[index]
  if state.bountyPoints < cost then
    displayErrorBox('Task Board', 'Not enough Bounty Points. Need ' .. cost .. ' BP.')
    return
  end
  sendOpcode(OPCODE.EXTRA_SLOT, function(msg)
    msg:addU8(index)
  end)
end

-- Clique direito em criatura da lista → adiciona como preferred/unwanted
function addToPreferred(slot)
  if not state.selectedCreature then
    displayErrorBox('Task Board', 'Select a creature from the list first.')
    return
  end
  sendOpcode(OPCODE.PREF_SET, function(msg)
    msg:addU8(slot)        -- 0=preferred, 1=unwanted
    msg:addU32(state.selectedCreature.creatureId)
  end)
end

-- ─────────────────────────────────────────────────────────────
--  WEEKLY PROGRESS POPUP
-- ─────────────────────────────────────────────────────────────

function openWeeklyPopup(killDone, killTotal, delivDone, delivTotal, htp, seals)
  if not ui.popupWindow then return end
  local pw = ui.popupWindow
  pw:recursiveGetChildById('popupKillInfo'):setText(
    'You have completed ' .. killDone .. ' / ' .. killTotal .. ' kill tasks.'
  )
  pw:recursiveGetChildById('popupDeliveryInfo'):setText(
    'You have completed ' .. delivDone .. ' / ' .. delivTotal .. ' delivery tasks.'
  )
  pw:recursiveGetChildById('popupEarned'):setText(
    'Total earned: ' .. htp .. ' HTP   ' .. seals .. ' Soulseals'
  )
  pw:show()
  pw:raise()
  pw:focus()
end

function closeWeeklyPopup()
  if ui.popupWindow then
    ui.popupWindow:hide()
  end
end

-- ─────────────────────────────────────────────────────────────
--  UTILITÁRIOS
-- ─────────────────────────────────────────────────────────────

function formatNum(n)
  local s = tostring(math.floor(n))
  local result = ''
  local len = #s
  for i = 1, len do
    if i > 1 and (len - i + 1) % 3 == 0 then
      result = result .. ','
    end
    result = result .. s:sub(i, i)
  end
  return result
end

function getCurrentMultiplier()
  local mult = 1
  for _, m in ipairs(MULTIPLIERS) do
    if state.weeklyCompleted >= m.tasks then
      mult = m.mult
    end
  end
  return mult
end
