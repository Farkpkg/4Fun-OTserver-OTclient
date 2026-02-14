# PREY — Dependency Map

## Mapa textual de dependências

```text
[config.lua / configmanager]
    -> PREY_ENABLED, PREY_*_PRICE, PREY_BONUS_TIME, PREY_FREE_REROLL_TIME

[IOLoginDataLoad/Save]
    <-> [player_prey SQL]
    -> [Player::preys runtime]

[Player]
    -> initializePrey / sendPreyData / reloadPreySlot
    -> getPreyWithMonster / getPreyBlackList / getPreyCards

[IOPrey]
    -> parsePreyAction
    -> checkPlayerPreys
    -> PreySlot::reloadMonsterGrid/reloadBonus*

[ProtocolGame server]
    -> parsePreyAction (client->server)
    -> sendPreyData/sendPreyTimeLeft/sendPreyPrices (server->client)

[ProtocolGame client]
    -> parsePrey*
    -> g_game.onPrey* callbacks

[Lua module game_prey]
    -> render UI OTUI + estados locais
    -> chama g_game.preyAction / g_game.preyRequest

[Combat/Events Lua]
    -> dano/defesa (combat.cpp)
    -> xp (player.lua)
    -> loot (ondroploot_prey.lua)
```

## Dependências transversais
- **Bestiary**: prey depende da base de monstros (raceId, stars, flags).
- **Premium/Store**: desbloqueio de slots.
- **Economia**: gold + prey wildcards.
- **Party/Loot**: prey loot pode considerar participantes.

## Acoplamentos fortes
1. `IOPrey` e `Player` têm acoplamento bidirecional via slot classes.
2. `ProtocolGame` serializa estados com layout implicitamente compartilhado com parser cliente.
3. `prey.lua` codifica vários ids/paths de asset fixos.

## Acoplamentos fracos
- Eventos Lua de XP/loot usam API abstrata (`getPreyExperiencePercentage`, `getPreyLootPercentage`), sem conhecer estrutura interna do slot.

## Exemplo real de encadeamento (código)
```cpp
// crystalserver/src/game/game.cpp
void Game::playerPreyAction(uint32_t playerId, uint8_t slot, uint8_t action, uint8_t option, int8_t index, uint16_t raceId) {
  g_ioprey().parsePreyAction(player, static_cast<PreySlot_t>(slot), ...);
}
```

## Pontos críticos / limitações / bugs potenciais
- Mudanças no payload de `sendPreyData` exigem atualização sincronizada no parser OTClient.
- Acoplamento por enum numérico entre cliente e servidor pode quebrar silenciosamente se divergir.

## Sugestões
- Introduzir testes de contrato de protocolo com fixtures de payload.
