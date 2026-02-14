# Achievements / Quests na Cyclopedia

## 1) Achievements

### Fonte principal
- `otclient/modules/game_cyclopedia/utils.lua` contém tabela global `ACHIEVEMENTS` (id -> name/grade/points/secret/description).

### Exibição
- `tab/character/character.lua` usa:
  - `Cyclopedia.loadCharacterAchievements()`
  - `Cyclopedia.achievementFilter(widget)`
  - `Cyclopedia.achievementSort(option)`

### Ordenações implementadas
- alfabética
- por grade
- por data (placeholder no fluxo de sort/filter; depende de dados reais de unlock)

### Estado atual
O módulo usa majoritariamente dataset estático local para renderizar achievements e descrição; não há parser dedicado de pacote "achievement unlock list" dentro de `protocolgameparse.cpp` para esta tela específica.

## 2) Quests

### Integração existente
- `game_questlog` é módulo separado (`game_questlog.lua`) com requests próprios:
  - `g_game.requestQuestLog()`
  - `g_game.requestQuestLine(questId)`

### Relação com Cyclopedia
- A Cyclopedia inclui sinalizadores/integrações auxiliares (ex.: tracker request `sendRequestTrackerQuestLog` no binding C++/Lua), mas não substitui a tela clássica de questlog.
- Em protobuf de aparências existe campo `currency_quest_flag_display_name` para dados de trade/NPC que podem refletir requisitos de quest em contexto de item.

## 3) Observações de arquitetura
- Achievements: forte componente client-side (lista estática), bom para customização de texto/grade.
- Quests: fonte autoritativa permanece no servidor via protocol de quest log.
- Há espaço para consolidar tudo em Cyclopedia com uma camada de sincronização por personagem.

## 4) Pontos de risco/limitação
- Divergência entre tabela estática local e conteúdo real do servidor (novos achievements).
- Ordenação "por unlock date" depende de dados não totalmente presentes na estrutura atual da lista estática.
