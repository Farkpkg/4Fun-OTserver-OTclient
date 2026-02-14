# Arquitetura Interna do PREY

## 1) Estrutura interna

### Slots
O sistema trabalha com 3 slots (`PreySlot_One..Three`).
- Slot 1: normalmente disponível.
- Slot 2: geralmente premium-gated.
- Slot 3: normalmente store-gated (pode ser liberado por config `preyFreeThirdSlot`).

### Estados de slot (`PreyDataState_t`)
- `Locked`
- `Inactive`
- `Active`
- `Selection`
- `SelectionChangeMonster`
- `ListSelection`
- `WildcardSelection` (suportado no cliente; no servidor clássico deste fork, fluxo principal cai em `ListSelection`)

### Tipos de bônus (`PreyBonus_t`)
- Dano
- Defesa
- Experiência
- Loot
- None (interno)

### Opções (`PreyOption_t`)
- `None`
- `AutomaticReroll`
- `Locked`

### Modelo de dados do slot
Campos essenciais de `PreySlot`:
- `id`
- `state`
- `option`
- `selectedRaceId`
- `bonus` + `bonusPercentage` + `bonusRarity`
- `bonusTimeLeft`
- `freeRerollTimeStamp`
- `raceIdList` (grid/lista atual de opções)

## 2) Fluxo funcional principal

```text
Login player
  -> loadPlayerPreyClass (DB -> runtime)
  -> initializePrey (normaliza slots e gera listas se necessário)
  -> ProtocolGame::sendPreyPrices
  -> Player::sendPreyData (slot por slot)

Cliente abre janela
  -> prey.lua::show()
  -> g_game.preyRequest()

Ação do usuário
  -> g_game.preyAction(slot, action, index/raceId/option)
  -> ProtocolGame::parsePreyAction (server)
  -> Game::playerPreyAction
  -> IOPrey::parsePreyAction
  -> Player::reloadPreySlot
  -> ProtocolGame::sendPreyData(slot atualizado)
```

## 3) Reroll e progressão de raridade
- `reloadBonusType()` sorteia novo tipo de bônus (evita repetir no rare cap 10).
- `reloadBonusValue()` aumenta estrela/raridade gradualmente (até 10) e recalcula `%` por tipo:
  - dano: `2*rarity + 5`
  - defesa: `2*rarity + 10`
  - xp/loot: `3*rarity + 10`

## 4) Tempo e expiração
- Cada slot ativo possui `bonusTimeLeft` (segundos).
- `checkPlayerPreys(player, amount)` decrementa timer por tick/evento de stamina.
- Ao expirar:
  - se `AutomaticReroll`: tenta consumir wildcard e renovar tipo+tempo.
  - se `Locked`: tenta consumir wildcard e renovar apenas tempo.
  - senão: limpa bônus e volta para seleção de criatura.

## 5) Regras de geração da lista de monstros
`reloadMonsterGrid(blackList, level)`:
- exige Prey habilitado e bestiary >= 36 entradas.
- monta 9 opções com distribuição por estrela de bestiary ajustada por faixa de level.
- filtra monsters inválidos (`experience == 0`, `!isPreyable`, `isPreyExclusive`).
- respeita blacklist global para reduzir duplicações entre slots.

## 6) Inconsistências relevantes
- Cliente possui estado/handler `WILDCARD_SELECTION`, mas o servidor neste fluxo principal envia até `LIST_SELECTION`.
- Cliente chama `preyRequest()` para “atualizar preys”, porém no servidor o opcode correspondente aparenta rotear para envio de resource balance (custom/protocol drift).

## Exemplo real (código)
```cpp
if (action == PreyAction_BonusReroll) {
  slot->reloadBonusType();
  slot->reloadBonusValue();
  slot->bonusTimeLeft = PREY_BONUS_TIME;
}
```

## Bugs potenciais
- Divergência de estado entre client/server em transições raras (ex.: seleção completa + troca de monster).

## Sugestões
- Modelar máquina de estados formal e validar transições com testes automatizados.
