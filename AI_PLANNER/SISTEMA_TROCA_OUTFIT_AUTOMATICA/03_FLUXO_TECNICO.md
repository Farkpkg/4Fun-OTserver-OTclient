# 03_FLUXO_TECNICO

Jogador executa `!randomoutfit on`
   ↓
`randomOutfit.onSay(...)` valida parâmetro e marca `activePlayers[playerId] = true`
   ↓
`updateOutfit(playerId)` gera outfit aleatório
   ↓
`player:setOutfit(newOutfit)` aplica visual
   ↓
`addEvent(updateOutfit, 1000, playerId)` agenda próximo ciclo
   ↓
Jogador executa `!randomoutfit off`
   ↓
`activePlayers[playerId] = nil` e o loop não agenda novos ciclos.
