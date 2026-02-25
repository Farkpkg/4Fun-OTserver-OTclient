# 02_ARQUITETURA

## Arquitetura proposta (baseada no que existe)
Reutilizar o talkaction existente `!randomoutfit` no server e evoluir o algoritmo:

1. Manter entrada `on/off`.
2. Manter loop com `addEvent`.
3. Trocar intervalo para 1000 ms.
4. Em cada tick, aplicar:
   - lookType aleatório dentro de uma lista segura de outfits configuráveis.
   - cores (head/body/legs/feet) aleatórias.
   - addon aleatório de 0 a 3.

## Comunicação server/client
Sem novo protocolo/opcode: a alteração usa `player:setOutfit` já existente no servidor, que sincroniza o visual ao cliente pelo fluxo padrão do engine.
