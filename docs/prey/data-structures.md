# PREY — Estruturas de Dados

## Runtime (servidor)

## `PreySlot`
Campos:
- `PreySlot_t id`
- `PreyBonus_t bonus`
- `PreyDataState_t state`
- `PreyOption_t option`
- `std::vector<uint16_t> raceIdList`
- `uint8_t bonusRarity`
- `uint16_t selectedRaceId`
- `uint16_t bonusPercentage`
- `uint16_t bonusTimeLeft`
- `int64_t freeRerollTimeStamp`

Métodos relevantes:
- `isOccupied()`
- `canSelect()`
- `eraseBonus(maintainBonus)`
- `removeMonsterType(raceId)`
- `reloadBonusType()`
- `reloadBonusValue()`
- `reloadMonsterGrid(blackList, level)`

## Enumerações-chave
- `PreySlot_t`: 0..2
- `PreyDataState_t`: locked/inactive/active/selection/selectionChange/listSelection/wildcardSelection
- `PreyBonus_t`: damage/defense/experience/loot/none
- `PreyAction_t`: listReroll/bonusReroll/monsterSelection/listAllCards/listAllSelection/option
- `PreyOption_t`: none/automatic/locked

## Persistência SQL
Tabela `player_prey`:
- `player_id`
- `slot`
- `state`
- `raceid`
- `option`
- `bonus_type`
- `bonus_rarity`
- `bonus_percentage`
- `bonus_time`
- `free_reroll`
- `monster_list` (blob serializado)

## Serialização de lista (`monster_list`)
- No save: `PropWriteStream` serializa `uint16_t` raceIds.
- No load: `PropStream` desserializa e repopula `slot->raceIdList`.

## Dados no cliente

### `PreyMonster` (C++)
- `name`
- `outfit`

### Estruturas Lua (`prey.lua`)
- `preyDescription[slot]`: strings de tooltip
- `raceEntriesBySlot`
- `selectedRaceEntryBySlot`
- `selectedRaceWidgetBySlot`
- `raceSearchTextsBySlot`
- `pickSpecificPreyBonusBySlot`

## Mapeamento de estado (server -> client)
- Valores enuméricos são compatíveis entre `PreyDataState_t` (server) e `Otc::PreyState_t` (client).
- O mesmo vale para bônus (`PreyBonus_*`) e ações (`PreyAction_*`).

## Riscos de dados
1. `monster_list` inválido/desatualizado pode gerar raceIds órfãos; servidor tenta limpar se monsterType não existir no envio.
2. Duplicação de raceId entre slots é mitigada por blacklist e validações, mas depende de consistência durante load.
3. Compatibilidade de timestamp e unidade de tempo varia por protocolo antigo/novo.

## Exemplo real de serialização
```cpp
std::ranges::for_each(slot->raceIdList, [&propPreyStream](uint16_t raceId) {
  propPreyStream.write<uint16_t>(raceId);
});
```

## Diagrama textual
```text
player_prey row
  -> loadPlayerPreyClass
  -> PreySlot em memória
  -> sendPreyData
  -> parsePreyData client
```

## Sugestões
- Trocar blob binário por formato com versão explícita (ex.: protobuf/msgpack versionado) para facilitar evolução.
