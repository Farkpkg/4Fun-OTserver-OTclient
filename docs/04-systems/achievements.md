# Sistema de Achievements

## Descrição
O sistema de achievements é implementado no CrystalServer com registro central de conquistas, consulta via API Lua e envio para Cyclopedia. A interface no OTClient consome a listagem para exibição na aba de personagem.

## Localização no Projeto
- client/
  - `otclient/modules/game_cyclopedia/`
- server/
  - `crystalserver/data/scripts/lib/register_achievements.lua`
  - `crystalserver/src/creatures/players/achievement/`
  - `crystalserver/src/lua/functions/core/game/game_functions.cpp`
  - `crystalserver/src/lua/functions/creatures/player/player_functions.cpp`

## Arquivos Envolvidos
- `crystalserver/data/scripts/lib/register_achievements.lua`
- `crystalserver/src/io/functions/iologindata_load_player.cpp`
- `crystalserver/src/lua/functions/core/game/game_functions.cpp`
- `crystalserver/src/lua/functions/creatures/player/player_functions.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/creatures/players/player.cpp`
- `crystalserver/data/scripts/actions/items/usable_outfit_items.lua`
- `otclient/modules/game_cyclopedia/tab/character/character.lua`
- `otclient/modules/game_cyclopedia/utils.lua`

## Fluxo de Execução
1. No boot do servidor, `register_achievements.lua` define a tabela `ACHIEVEMENTS` e registra cada conquista via `Game.registerAchievement`.
2. No login, o jogador carrega conquistas desbloqueadas com `player->achiev()->loadUnlockedAchievements()`.
3. Scripts e sistemas concedem conquistas por `player:addAchievement(...)` ou progresso por `player:addAchievementProgress(...)`.
4. A API Lua de jogo expõe consultas como `Game.getAchievementInfoById`, `Game.getPublicAchievements` e `Game.getSecretAchievements`.
5. O servidor envia dados para Cyclopedia em `sendCyclopediaCharacterAchievements` (pontos, secretos desbloqueados e lista de conquistas).
6. O OTClient abre a aba de achievements da Cyclopedia e monta/ordena a lista exibida na UI.

## Dependências
- Tabela global `ACHIEVEMENTS` e registro por `Game.registerAchievement`.
- Componente de jogador `player->achiev()` no servidor.
- Bindings Lua de Game/Player para consultar, adicionar e remover conquistas.
- Pacote Cyclopedia `0xDA` com tipo `CYCLOPEDIA_CHARACTERINFO_ACHIEVEMENTS`.
- Dados de achievements no client (`ACHIEVEMENTS`) usados pela UI da Cyclopedia.

## Pontos de Extensão
- Adicionar novas conquistas em `register_achievements.lua` mantendo `id`, `name` e `description` válidos.
- Integrar novas regras de concessão em scripts de actions/events usando `player:addAchievement` ou `player:addAchievementProgress`.
- Ajustar ordenação e filtro da visualização em `game_cyclopedia/tab/character/character.lua`.
