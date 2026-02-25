# 01_ANALISE

## Ideia solicitada
Criar um sistema para trocar outfit automaticamente a cada 1 segundo, de forma aleatória.

## Objetivo funcional
Permitir que o jogador ative/desative via comando um ciclo automático que altera o outfit com intervalo fixo de 1 segundo.

## Escopo
Server (Lua revscripts/talkaction).

## Base real encontrada
Já existe talkaction pronta para troca randômica em:
- `crystalserver/data/scripts/talkactions/player/randomoutfit.lua`

Ela usa:
- `TalkAction("!randomoutfit")`
- `addEvent(...)` para loop
- `player:setOutfit(...)`
- tabela de controle `activePlayers`
