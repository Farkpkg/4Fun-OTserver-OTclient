# PREY — API Reference (cliente + servidor)

## Cliente Lua/API exposta

### `g_game.preyAction(slot, actionType, index)`
- Origem: binding C++ (`Game::preyAction`)
- Parâmetros:
  - `slot: uint8`
  - `actionType: uint8`
  - `index: uint16` (usado como índice, option ou raceId conforme action)
- Retorno: void
- Dependências: conexão ativa + `ProtocolGame::sendPreyAction`
- Exemplo:
```lua
g_game.preyAction(0, PREY_ACTION_LISTREROLL, 0)
```

### `g_game.preyRequest()`
- Origem: binding C++ (`Game::preyRequest`)
- Uso: solicitar refresh ao abrir janela (cliente chama em `show()`)
- Retorno: void
- Exemplo:
```lua
g_game.preyRequest()
```

## Callback API recebida do protocolo
- `onPreyFreeRerolls(slot, timeLeft)`
- `onPreyTimeLeft(slot, timeLeft)`
- `onPreyRerollPrice(price, wildcardPrice, directSelectionPrice)`
- `onPreyLocked(slot, unlockState, nextFreeReroll, wildcards)`
- `onPreyInactive(slot, nextFreeReroll, wildcards)`
- `onPreyActive(slot, name, outfit, bonusType, bonusValue, bonusGrade, timeLeft, nextFreeReroll, wildcards, option)`
- `onPreySelection(slot, names, outfits, nextFreeReroll, wildcards)`
- `onPreySelectionChangeMonster(slot, names, outfits, bonusType, bonusValue, bonusGrade, nextFreeReroll, wildcards)`
- `onPreyListSelection(slot, races, nextFreeReroll, wildcards)`
- `onPreyWildcardSelection(slot, races, nextFreeReroll, wildcards)`

## Servidor C++

### `IOPrey::parsePreyAction(player, slotId, action, option, index, raceId)`
- Núcleo de regras do sistema.
- Valida estado do slot, custo (gold/wildcard), duplicidade de monster, etc.
- Atualiza slot e chama `player->reloadPreySlot(slotId)`.

### `IOPrey::checkPlayerPreys(player, amount)`
- Tick de redução de tempo.
- Gerencia expiração + auto-reroll/lock.

### `Player::initializePrey()`
- Cria slots faltantes e aplica estado inicial conforme premium/config.

### `Player::sendPreyData()` / `reloadPreySlot(slot)`
- Emissão incremental de estado ao cliente.

### `ProtocolGame::sendPreyData(slot)`
- Serializa payload de estado variável por slot.

## Lua servidor (integração)

### `player:removePreyStamina(amount)`
- Binding para `IOPrey::checkPlayerPreys`.

### `player:getPreyExperiencePercentage(raceId)`
- retorna `100 + bonus%` se slot ativo com bônus XP.

### `player:getPreyLootPercentage(raceId)`
- retorna `%` de loot prey aplicável.

### `player:isMonsterPrey(raceId)`
- true se criatura está ativa em algum slot do jogador.

## Dependências cruzadas
- Config (`PREY_*`)
- Bestiary (`getBestiaryList`, stars, raceId)
- Resource balance (gold/bank/wildcards)
- Task Hunting (payload compartilhado em preços/protocol)

## Pontos críticos / limitações / bugs potenciais
- `preyRequest()` no cliente aparenta não ter handler dedicado de refresh de prey no servidor atual.
- `sendPreyAction` reutiliza parâmetro `index` com semânticas diferentes por ação, aumentando risco de erro.

## Sugestões
- Introduzir payload tipado por ação (structs) em vez de multiplexar `index`.
