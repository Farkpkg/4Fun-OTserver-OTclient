# Task Board — Módulo Client-Side
## OTCRedemption (mehah/EDU) + CrystalServer (Canary) | Protocolo 15x

---

## 📁 Estrutura de arquivos

```
modules/
└── game_taskboard/
    ├── taskboard.otmod   ← registro do módulo
    ├── taskboard.otui    ← layout de todas as janelas
    └── taskboard.lua     ← lógica client-side + opcodes
```

---

## 🚀 Instalação no Cliente

1. Copie a pasta `game_taskboard/` para `seu_cliente/modules/`
2. Abra `modules/game_taskboard/taskboard.otmod` e confirme o nome do módulo
3. No arquivo de módulos do cliente (`modules.otui` ou similar), adicione se necessário:
   ```
   Module
     name: game_taskboard
   ```
4. No script que abre a janela (ex: via NPC ou ação in-game), chame:
   ```lua
   modules.game_taskboard.show()
   ```

---

## 📡 Opcodes — Client ↔ Servidor

### Servidor → Cliente (recebidos)
| Opcode | Constante           | Descrição                              |
|--------|---------------------|----------------------------------------|
| 50     | OPEN                | Abre a janela                          |
| 51     | BOUNTY_DATA         | 3 tasks sorteadas + kills + recompensas|
| 52     | WEEKLY_DATA         | Kill/Delivery tasks + progresso        |
| 53     | SHOP_DATA           | Itens da loja com preços               |
| 54     | PREFERRED           | Lista preferred/unwanted + criaturas   |
| 55     | TALISMAN            | Estado atual dos 4 talismãs            |
| 56     | CURRENCIES          | RT, BP, HTP, Soulseals                 |
| 57     | RESULT              | Feedback de ação (ok/erro + mensagem)  |

### Cliente → Servidor (enviados)
| Opcode | Constante           | Payload                                |
|--------|---------------------|----------------------------------------|
| 60     | SELECT              | u8 slot (1-3)                         |
| 61     | REROLL              | —                                      |
| 62     | CLAIM_DAILY         | —                                      |
| 63     | PREF_SET            | u8 tipo (0=pref,1=unwant), u32 creatureId |
| 64     | PREF_CLEAR          | u8 slot                                |
| 65     | UNWANT_CLEAR        | u8 slot                                |
| 66     | EXTRA_SLOT          | u8 index (1-4)                         |
| 67     | TALISM_UP           | u8 slot (1-4)                          |
| 68     | SHOP_BUY            | u16 index                              |
| 69     | WEEKLY_DIFF         | u8 dificuldade (0-3)                   |
| 70     | DELIVER             | u8 index (1-6)                         |
| 71     | UNLOCK_KILL         | —                                      |
| 72     | UNLOCK_DELIV        | —                                      |

---

## 📦 Formato dos pacotes (servidor → cliente)

### BOUNTY_DATA (51)
```
u8  difficulty (0=beginner 1=adept 2=expert 3=master)
-- repete 3 vezes (3 task slots):
  string  name
  u32     creatureId
  u32     kills (progresso atual)
  u32     maxKills
  u64     xp
  u16     bountyPoints
  u8      rerollTokens
  u8      tier (0=normal 1=silver 2=gold)
```

### WEEKLY_DATA (52)
```
u32  rewardXP
u8   killUnlocked (0/1)
u8   delivUnlocked (0/1)
u8   completedTasks (0-18)
u32  weeklyHTP
u32  weeklySeals
-- 6x kill tasks:
  string  name
  u32     creatureId
  u32     kills
  u32     maxKills
-- 6x delivery tasks:
  string  name
  u32     itemId
  u32     count
  u32     maxCount
```

### SHOP_DATA (53)
```
u16  count
-- count x:
  string  name
  string  desc
  u32     price (HTP)
  u32     itemId
  u8      type (0=outfit_base 1=addon1 2=addon2 3=mount)
```

### PREFERRED (54)
```
u8   extraSlots (bitmask: bit0=slot1 bit1=slot2 bit2=slot3 bit3=slot4)
u8   preferredCount
-- preferredCount x:
  string  name
  u32     creatureId
u8   unwantedCount
-- unwantedCount x:
  string  name
  u32     creatureId
u16  creatureListCount
-- creatureListCount x:
  string  name
  u32     creatureId
```

### TALISMAN (55)
```
-- 4x (ordem: Damage, Life Leech, More Loot, Double Bestiary):
  float  current (%)
  float  next (%)
  u16    cost (BP)
```

### CURRENCIES (56)
```
u16  rerollTokens
u32  bountyPoints
u32  huntingPoints
u32  soulseals
```

### RESULT (57)
```
u8      ok (1=sucesso 0=erro)
string  message
```

---

## ⚙️ Próximo passo: Backend (Canary)

Após instalar o módulo client, implemente no servidor:

1. **`src/server/network/protocol/protocolgame.cpp`**
   - Registrar os opcodes 50-57 no handler de extended opcodes
   - Implementar os parsers para 60-72

2. **`data/scripts/task_board/`**
   - `taskboard_manager.lua` — lógica de negócio (sorteio, kills, rewards)
   - `taskboard_db.lua` — interface com o banco de dados

3. **Banco de dados (MySQL)**
   ```sql
   CREATE TABLE player_bounty_tasks (...)
   CREATE TABLE player_weekly_tasks (...)
   CREATE TABLE player_talisman (...)
   CREATE TABLE task_preferred_list (...)
   ```

---

## 💡 Como abrir a janela in-game

Via NPC (exemplo):
```lua
-- no script do NPC
npcHandler:addKeyword({'task', 'tasks', 'board'}, function(npc, creature)
  local player = Player(creature:getId())
  if player then
    -- envia opcode de abertura para o client
    local msg = NetworkMessage()
    msg:addByte(0x32)
    msg:addByte(50)  -- OPCODE OPEN
    player:sendNetworkMessage(msg)
    -- ... enviar também BOUNTY_DATA, CURRENCIES, etc.
  end
end)
```
