# PROMPT — Codex: Implementação do Task Board (CrystalServer / Canary)

---

## 🎯 OBJETIVO

Implementar o sistema **Task Board** completo no servidor **CrystalServer** (baseado no
Canary — C++/Lua), integrando-o com o módulo client-side já existente em
`modules/game_taskboard/` (arquivos `taskboard.otmod`, `taskboard.otui`,
`taskboard.lua`).

O módulo client está **100% pronto** — ele já define todos os opcodes, parsers de
pacotes e lógica de UI. Sua tarefa é implementar **apenas o lado servidor**, garantindo
que cada pacote enviado pelo servidor siga **exatamente** o formato especificado abaixo.

---

## ⚠️ REGRA PRINCIPAL — CONFORMIDADE COM O PROJETO

**Antes de criar qualquer arquivo**, faça o seguinte:

1. Leia `src/server/network/protocol/protocolgame.cpp` e entenda como outros sistemas
   enviam extended opcodes (procure por `0x32`, `sendExtendedOpcode`,
   `parseExtendedOpcode` ou similar).

2. Leia `src/server/network/protocol/protocolgame.h` e localize onde novos opcodes e
   handlers devem ser declarados.

3. Leia pelo menos **2 sistemas similares já existentes** no projeto (ex: bestiary,
   imbuements, cyclopedia, forge) para entender:
   - Como o C++ lê pacotes do cliente (`NetworkMessage& msg`, `msg.getByte()` etc.)
   - Como o C++ escreve pacotes para o cliente (`NetworkMessage msg`, `msg.addByte()` etc.)
   - Como os scripts Lua do servidor enviam pacotes (`NetworkMessage`, `player:sendNetworkMessage`)
   - Como as tabelas MySQL são criadas (veja `schema.sql` ou migrations existentes)
   - Como os dados são lidos/escritos via Lua (`db.query`, `db.storeQuery`, `Result`)
   - O padrão de nomenclatura de funções, variáveis e arquivos usado no projeto

4. **Somente após essa análise**, crie os arquivos seguindo estritamente os padrões
   encontrados. Não invente padrões — replique o que já existe.

---

## 📡 OPCODES

### Servidor → Cliente
| Opcode | Nome             | Quando enviar                                      |
|--------|------------------|----------------------------------------------------|
| 50     | OPEN             | Jogador interage com NPC/objeto Task Board         |
| 51     | BOUNTY_DATA      | Após OPEN, reroll, seleção de task                 |
| 52     | WEEKLY_DATA      | Após OPEN, kill/delivery completada               |
| 53     | SHOP_DATA        | Após OPEN (uma vez por sessão ou sempre)           |
| 54     | PREFERRED        | Ao abrir Preferred List                            |
| 55     | TALISMAN         | Após OPEN, após upgrade                            |
| 56     | CURRENCIES       | Após OPEN e após qualquer alteração de moeda       |
| 57     | RESULT           | Resposta de qualquer ação do jogador               |

### Cliente → Servidor
| Opcode | Nome             | Payload (bytes, em ordem)                          |
|--------|------------------|----------------------------------------------------|
| 60     | SELECT           | u8 slot (1–3)                                     |
| 61     | REROLL           | — (sem payload)                                    |
| 62     | CLAIM_DAILY      | — (sem payload)                                    |
| 63     | PREF_SET         | u8 tipo (0=preferred / 1=unwanted), u32 creatureId |
| 64     | PREF_CLEAR       | u8 slot                                            |
| 65     | UNWANT_CLEAR     | u8 slot                                            |
| 66     | EXTRA_SLOT       | u8 index (1–4)                                     |
| 67     | TALISM_UP        | u8 slot (1–4)                                      |
| 68     | SHOP_BUY         | u16 index                                          |
| 69     | WEEKLY_DIFF      | u8 dificuldade (0=beginner 1=adept 2=expert 3=master) |
| 70     | DELIVER          | u8 index (1–6)                                     |
| 71     | UNLOCK_KILL      | — (sem payload)                                    |
| 72     | UNLOCK_DELIV     | — (sem payload)                                    |

---

## 📦 FORMATO EXATO DOS PACOTES (Servidor → Cliente)

O client Lua lê os bytes **nesta ordem exata**. Qualquer desvio causa crash ou dados
corrompidos na UI.

### OPCODE 50 — OPEN
```
(sem payload — apenas abre a janela, depois envie 51+52+53+55+56)
```

### OPCODE 51 — BOUNTY_DATA
```
u8   difficulty        (0=beginner 1=adept 2=expert 3=master)
--- repete 3 vezes (slots 1, 2, 3): ---
  string  name         (nome da criatura)
  u32     creatureId   (id para renderizar sprite no client)
  u32     kills        (progresso atual do jogador)
  u32     maxKills     (total necessário)
  u64     xp           (recompensa base de XP)
  u16     bountyPoints (recompensa base em Bounty Points)
  u8      rerollTokens (recompensa base em Reroll Tokens)
  u8      tier         (0=normal 1=silver[2x] 2=gold[4x])
```

### OPCODE 52 — WEEKLY_DATA
```
u32  rewardXP          (XP por task completada)
u8   killUnlocked      (0=locked 1=permanently unlocked)
u8   delivUnlocked     (0=locked 1=permanently unlocked)
u8   completedTasks    (0–18, usado na barra de progresso)
u32  weeklyHTP         (HTP acumulado esta semana)
u32  weeklySeals       (Soulseals acumulados esta semana)
--- repete 6 vezes (kill tasks): ---
  string  name
  u32     creatureId
  u32     kills        (progresso atual)
  u32     maxKills
--- repete 6 vezes (delivery tasks): ---
  string  name
  u32     itemId
  u32     count        (quantidade entregue)
  u32     maxCount     (quantidade necessária)
```

### OPCODE 53 — SHOP_DATA
```
u16  count             (total de itens na loja)
--- repete 'count' vezes: ---
  string  name
  string  desc
  u32     price        (custo em Hunting Task Points)
  u32     itemId       (id do item para sprite)
  u8      type         (0=outfit_base 1=addon1 2=addon2 3=mount)
```

### OPCODE 54 — PREFERRED
```
u8   extraSlots        (bitmask 4 bits: bit0=slot1 desbloqueado, bit1=slot2, ...)
u8   preferredCount    (0–5)
--- repete 'preferredCount' vezes: ---
  string  name
  u32     creatureId
u8   unwantedCount     (0–5)
--- repete 'unwantedCount' vezes: ---
  string  name
  u32     creatureId
u16  creatureListCount (total de criaturas disponíveis para escolha)
--- repete 'creatureListCount' vezes: ---
  string  name
  u32     creatureId
```

### OPCODE 55 — TALISMAN
```
--- repete 4 vezes (ordem fixa: Damage, Life Leech, More Loot, Double Bestiary): ---
  float   current      (valor atual em %, ex: 2.50)
  float   next         (próximo nível, ex: 3.00)
  u16     cost         (custo em Bounty Points)
```

### OPCODE 56 — CURRENCIES
```
u16  rerollTokens
u32  bountyPoints
u32  huntingPoints     (Hunting Task Points)
u32  soulseals
```

### OPCODE 57 — RESULT
```
u8      ok             (1=sucesso 0=erro)
string  message        (mensagem exibida ao jogador)
```

---

## 🗄️ BANCO DE DADOS (MySQL)

Crie as tabelas seguindo o padrão de nomenclatura e tipos já usados no projeto
(verifique `schema.sql` ou tabelas existentes como `player_storage`, `player_items`).

```sql
-- Bounty Tasks ativas do jogador
CREATE TABLE IF NOT EXISTS `player_bounty_tasks` (
  `player_id`    INT UNSIGNED NOT NULL,
  `slot`         TINYINT NOT NULL DEFAULT 1,   -- 1, 2 ou 3
  `creature_id`  INT UNSIGNED NOT NULL DEFAULT 0,
  `creature_name` VARCHAR(64) NOT NULL DEFAULT '',
  `kills`        INT UNSIGNED NOT NULL DEFAULT 0,
  `max_kills`    INT UNSIGNED NOT NULL DEFAULT 0,
  `xp_reward`    BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `bp_reward`    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `rt_reward`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `tier`         TINYINT UNSIGNED NOT NULL DEFAULT 0, -- 0=normal 1=silver 2=gold
  `difficulty`   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `completed`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `slot`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Weekly Tasks do jogador
CREATE TABLE IF NOT EXISTS `player_weekly_tasks` (
  `player_id`      INT UNSIGNED NOT NULL,
  `task_type`      TINYINT NOT NULL DEFAULT 0, -- 0=kill 1=delivery
  `slot`           TINYINT NOT NULL DEFAULT 1, -- 1–6
  `target_name`    VARCHAR(64) NOT NULL DEFAULT '',
  `target_id`      INT UNSIGNED NOT NULL DEFAULT 0,
  `current_count`  INT UNSIGNED NOT NULL DEFAULT 0,
  `max_count`      INT UNSIGNED NOT NULL DEFAULT 0,
  `completed`      TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `week_number`    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `task_type`, `slot`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Talisman do jogador (4 slots fixos)
CREATE TABLE IF NOT EXISTS `player_talisman` (
  `player_id`   INT UNSIGNED NOT NULL,
  `slot`        TINYINT NOT NULL DEFAULT 1, -- 1=Damage 2=LifeLeech 3=MoreLoot 4=DoubleBestiary
  `level`       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `current_pct` FLOAT NOT NULL DEFAULT 2.50,
  PRIMARY KEY (`player_id`, `slot`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Lista Preferred/Unwanted + extra slots
CREATE TABLE IF NOT EXISTS `player_task_preferred` (
  `player_id`    INT UNSIGNED NOT NULL,
  `list_type`    TINYINT NOT NULL DEFAULT 0,  -- 0=preferred 1=unwanted
  `slot`         TINYINT NOT NULL DEFAULT 1,
  `creature_id`  INT UNSIGNED NOT NULL DEFAULT 0,
  `creature_name` VARCHAR(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`player_id`, `list_type`, `slot`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Slots extras desbloqueados (bitmask)
CREATE TABLE IF NOT EXISTS `player_task_extra_slots` (
  `player_id`    INT UNSIGNED NOT NULL,
  `extra_slots`  TINYINT UNSIGNED NOT NULL DEFAULT 0, -- bitmask
  PRIMARY KEY (`player_id`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Moedas do Task Board
CREATE TABLE IF NOT EXISTS `player_task_currencies` (
  `player_id`      INT UNSIGNED NOT NULL,
  `reroll_tokens`  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `bounty_points`  INT UNSIGNED NOT NULL DEFAULT 0,
  `hunting_points` INT UNSIGNED NOT NULL DEFAULT 0,
  `soulseals`      INT UNSIGNED NOT NULL DEFAULT 0,
  `last_daily`     DATE DEFAULT NULL,
  PRIMARY KEY (`player_id`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

---

## 📁 ARQUIVOS A CRIAR NO SERVIDOR

### 1. C++ — Registro de opcodes
**Arquivo:** `src/server/network/protocol/protocolgame.cpp`

Localize onde outros extended opcodes são registrados (procure por `0x32` ou
`parseExtendedOpcode`). Adicione os handlers para os opcodes 60–72 **seguindo
exatamente o mesmo padrão** dos outros handlers existentes. Declare os métodos
correspondentes em `protocolgame.h`.

Cada handler deve:
- Ler o payload na ordem especificada acima
- Chamar a função Lua equivalente via `g_luaEnvironment.callFunction` ou pelo
  método já usado no projeto
- Enviar RESULT (opcode 57) em caso de erro de validação C++

### 2. Lua — Gerenciador principal
**Arquivo:** `data/scripts/task_board/taskboard_manager.lua`

Implemente as funções chamadas pelo C++:

```lua
-- Funções obrigatórias (nomes exatos):
TaskBoard.open(player)               -- envia opcodes 51+52+53+55+56 ao abrir
TaskBoard.selectTask(player, slot)   -- seleciona uma das 3 tasks
TaskBoard.rerollTasks(player)        -- resorteio (consome 1 Reroll Token)
TaskBoard.claimDaily(player)         -- +1 Reroll Token (1x por dia)
TaskBoard.onCreatureKill(player, creatureName) -- chamado pelo evento onKill
TaskBoard.onItemDeliver(player, index)         -- entrega item weekly
TaskBoard.upgradeTalisman(player, slot)        -- consome BP, upgrade talisman
TaskBoard.buyShopItem(player, index)           -- consome HTP, dá outfit/mount
TaskBoard.setPreferred(player, tipo, creatureId)
TaskBoard.clearPreferred(player, slot)
TaskBoard.clearUnwanted(player, slot)
TaskBoard.unlockExtraSlot(player, index)       -- consome BP
TaskBoard.selectWeeklyDifficulty(player, diff)
TaskBoard.unlockKillTasks(player)
TaskBoard.unlockDeliveryTasks(player)
TaskBoard.openPreferredList(player)            -- envia opcode 54
```

**Regras de negócio obrigatórias:**
- **Reroll Token**: máximo 10 por personagem. Claim Daily dá +1, máximo 1 por dia UTC.
- **Silver Task**: 20% de chance ao sortear. Recompensas x2.
- **Gold Task**: 5% de chance ao sortear. Recompensas x4.
- **Bounty Points por dificuldade**: Beginner=3, Adept=7, Expert=16, Master=54.
- **Hunting Task Points por kill task**: Beginner=25, Adept=50, Expert=100, Master=110.
- **Hunting Task Points por delivery task**: sempre 75.
- **Soulseal**: 1 por task completada (kill ou delivery).
- **Multiplicador semanal de XP**: completedTasks 0–3=x1, 4–7=x2, 8–11=x3, 12–15=x5, 16+=x8.
- **Reset semanal**: segunda-feira às 00:00 UTC. Use scheduler do Canary.
- **Talisman slots** (valores e custos):
  - Damage Against Creatures: 2.50% → 3.00% → 3.50% → 4.00% (custo: 5→8→12 BP)
  - Life Leech: 2.50% → 3.00% → 3.50% → 4.00% (custo: 5→8→12 BP)
  - More Loot: 2.50% → 3.00% → 3.50% → 4.00% (custo: 5→8→12 BP)
  - Double Bestiary: 5.00% → 6.00% → 7.00% → 8.00% (custo: 5→8→12 BP)
- **Extra slots**: custam 300 → 600 → 900 → 1200 BP (desbloqueio permanente).
- **Preferred List**: ao sortear Bounty Tasks, criaturas preferred têm +50% de chance.
  Criaturas unwanted nunca aparecem.

### 3. Lua — Banco de dados
**Arquivo:** `data/scripts/task_board/taskboard_db.lua`

Implemente funções de leitura/escrita para cada tabela, seguindo exatamente o padrão
já usado no projeto para `db.query`, `db.storeQuery` e `Result`. Exemplo de funções:

```lua
TaskBoardDB.loadCurrencies(playerId)    → {rerollTokens, bountyPoints, ...}
TaskBoardDB.saveCurrencies(playerId, data)
TaskBoardDB.loadBountyTasks(playerId)   → array de tasks
TaskBoardDB.saveBountyTask(playerId, slot, task)
TaskBoardDB.loadWeeklyTasks(playerId)   → {killTasks, delivTasks}
TaskBoardDB.loadTalisman(playerId)      → array de 4 slots
TaskBoardDB.saveTalisman(playerId, slot, data)
TaskBoardDB.loadPreferred(playerId)     → {preferred, unwanted, extraSlots}
TaskBoardDB.savePreferred(playerId, tipo, slot, creatureId, name)
TaskBoardDB.clearPreferred(playerId, tipo, slot)
TaskBoardDB.loadExtraSlots(playerId)    → bitmask (u8)
TaskBoardDB.saveExtraSlots(playerId, bitmask)
```

### 4. Lua — Configuração de criaturas e loja
**Arquivo:** `data/scripts/task_board/taskboard_config.lua`

```lua
-- Lista de criaturas por dificuldade (adicione conforme o bestiary do servidor)
TaskBoardConfig = {
  difficulties = {
    beginner = { maxKills = {50, 100}, creatures = { ... } },
    adept    = { maxKills = {100, 200}, creatures = { ... } },
    expert   = { maxKills = {200, 400}, creatures = { ... } },
    master   = { maxKills = {400, 600}, creatures = { ... } },
  },

  -- Itens da loja (Hunting Task Shop)
  shopItems = {
    {name='Feral Trapper (Base Outfit)', desc='The newest fashion from Walter Jaeger.',
     price=120000, itemId=0, type=0},
    {name='Feral Trapper (Addon 1)', desc='Spice up your outfit for long hunts.',
     price=50000, itemId=0, type=1},
    {name='Feral Trapper (Addon 2)', desc='Spice up your outfit for long hunts.',
     price=50000, itemId=0, type=2},
    {name='Falconer (Base Outfit)', desc='Show off your hunting skills.',
     price=100000, itemId=0, type=0},
    {name='Falconer (Addon 1)', desc='Boar-ed running around without a helmet?',
     price=35000, itemId=0, type=1},
    {name='Falconer (Addon 2)', desc='Pro: Fal Con: None',
     price=35000, itemId=0, type=2},
    {name='Tidal Seawater Predator', desc='Swim through a sea of prey.',
     price=180000, itemId=0, type=3},
    {name='Ashen Coast Predator', desc='Swim through a sea of prey.',
     price=180000, itemId=0, type=3},
    {name='Crimson Bay Predator', desc='Swim through a sea of prey.',
     price=180000, itemId=0, type=3},
  },

  -- Talisman (4 slots, valores por nível)
  talisman = {
    {name='Damage Against Creatures', levels={2.50,3.00,3.50,4.00}, costs={5,8,12}},
    {name='Life Leech',               levels={2.50,3.00,3.50,4.00}, costs={5,8,12}},
    {name='More Loot',                levels={2.50,3.00,3.50,4.00}, costs={5,8,12}},
    {name='Double Bestiary Progress', levels={5.00,6.00,7.00,8.00}, costs={5,8,12}},
  },

  -- Extra slots (custo em BP)
  extraSlotCosts = {300, 600, 900, 1200},

  -- Weekly tasks: quantas kills/itens por dificuldade
  weeklyKillRange = {
    beginner = {50, 150},
    adept    = {150, 300},
    expert   = {300, 600},
    master   = {600, 1000},
  },
}
```

### 5. Lua — Evento de kill
**Arquivo:** `data/scripts/task_board/taskboard_events.lua`
(ou adicione ao evento onKill existente, seguindo o padrão do projeto)

```lua
-- Conectar ao evento global de kill do Canary:
-- Verifique como outros sistemas (bestiary, prey) escutam kills e replique.
-- A função deve chamar: TaskBoard.onCreatureKill(player, creatureName)
```

### 6. NPC — Task Board
**Arquivo:** `data/world/npcs/task_board_npc.lua` (ou local equivalente no projeto)

Crie um NPC simples chamado **"Task Board"** que ao ser clicado/cumprimentado:
- Verifica se o jogador está próximo
- Chama `TaskBoard.open(player)`

Siga o padrão de NPCs já existentes no projeto.

### 7. SQL — Migration
**Arquivo:** `schema.sql` ou migration separada (siga o padrão do projeto)

Adicione os `CREATE TABLE IF NOT EXISTS` das 6 tabelas listadas na seção Banco de
Dados acima.

---

## ✅ CHECKLIST DE VALIDAÇÃO

Após implementar, verifique cada item:

- [ ] `protocolgame.cpp` registra os opcodes 60–72 sem conflito com opcodes existentes
- [ ] Cada opcode do cliente chama a função Lua correspondente com os parâmetros corretos
- [ ] Opcode 51 (BOUNTY_DATA) envia **exatamente** 3 tasks com todos os campos na ordem certa
- [ ] Opcode 52 (WEEKLY_DATA) envia **exatamente** 6 kill tasks + 6 delivery tasks
- [ ] Opcode 56 (CURRENCIES) é enviado **sempre** que qualquer moeda muda
- [ ] Opcode 57 (RESULT) é enviado para **toda** ação do jogador (sucesso ou erro)
- [ ] Reset semanal funciona via scheduler (segunda-feira 00:00 UTC)
- [ ] Reroll Token: máx 10, Claim Daily: máx 1/dia
- [ ] Silver/Gold task: chances corretas (20% / 5%)
- [ ] Preferred list: influencia o sorteio (criaturas preferred +50%, unwanted excluídas)
- [ ] Talisman: valores e custos por nível corretos
- [ ] Extra slots: custos progressivos (300/600/900/1200 BP)
- [ ] Multiplicador XP semanal: x1/x2/x3/x5/x8 nos thresholds corretos (0/4/8/12/16)
- [ ] Todas as tabelas criadas com chave estrangeira para `players.id`
- [ ] Nenhum nome de função, tabela ou variável conflita com o projeto existente

---

## 📎 ARQUIVOS DE REFERÊNCIA DO CLIENT (já prontos, NÃO modificar)

```
modules/game_taskboard/taskboard.otmod   ← definição do módulo
modules/game_taskboard/taskboard.otui    ← layout UI completo
modules/game_taskboard/taskboard.lua     ← lógica client + parsers de pacotes
```

O client espera receber os pacotes **exatamente** como especificado neste prompt. Se
o servidor enviar bytes na ordem errada, a UI quebrará silenciosamente.

---

## 🔁 ORDEM DE IMPLEMENTAÇÃO SUGERIDA

1. `schema.sql` — criar tabelas
2. `taskboard_config.lua` — configurar criaturas e loja
3. `taskboard_db.lua` — funções de banco
4. `taskboard_manager.lua` — lógica de negócio
5. `taskboard_events.lua` — hook no evento onKill
6. `protocolgame.cpp` / `.h` — opcodes C++
7. NPC Task Board
8. Teste: abrir o cliente, interagir com o NPC, verificar que a janela abre e exibe dados

---

## 💬 NOTAS FINAIS

- Os opcodes 50–72 foram escolhidos para **não conflitar** com o protocolo Tibia 15x
  padrão. Verifique se o projeto já usa algum desses números antes de confirmar.
  Se houver conflito, ajuste os números tanto no servidor quanto no arquivo
  `modules/game_taskboard/taskboard.lua` (variável `OPCODE` no topo do arquivo).

- O client usa `0x32` como byte de header para extended opcodes (padrão OTCRedemption).
  Confirme que o servidor também usa `0x32` para extended opcodes verificando outros
  sistemas existentes.

- Não crie sistemas de "storage" via `player:setStorageValue` para dados persistentes
  do Task Board — use exclusivamente as tabelas MySQL criadas acima para evitar
  poluição do sistema de storage e facilitar queries futuras.
