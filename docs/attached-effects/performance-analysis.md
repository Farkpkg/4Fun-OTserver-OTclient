# Análise de performance

## Custos por frame
1. Iteração de vetor por dono (`attachedEffects`).
2. Atualização de fase de animação por efeito.
3. Ajustes de state no draw pool (shader/opacidade/scale/draw order).
4. Draw recursivo de subefeitos.

## Gargalos prováveis
- muitos efeitos simultâneos em criaturas numerosas;
- efeitos com shader único (quebra batching);
- texturas animadas externas em alta densidade;
- uso intenso de `pulse/fade` (trocas de opacity/scale frequentes).

## Custos de CPU
- `getCurrentAnimationPhase` chamado para cada efeito por frame;
- dispatch de eventos de detach por loop/duration em grande volume.

## Custos de memória
- protótipos ficam no manager + clones ativos por entidade;
- composições de efeito aumentam número de objetos e timers.

## Sinais positivos no código
- early-return por camada (`onTop`) e UI (`canDrawOnUI`);
- prevenção de vazamento de estado gráfico (comentários explícitos + resets);
- limpeza seletiva de temporários/permanentes.

## Riscos funcionais ligados a performance
- detach via `g_dispatcher.addEvent` quando loop zera pode atrasar remoção para frame seguinte;
- if de bug em `dirOffset` no Lua pode impedir configuração esperada e causar retrabalho/overdraw.

## Recomendações
- agregar efeitos por material (shader/texture) quando possível;
- limitar subefeitos recursivos por política;
- adicionar counters de telemetry (effects por frame, draw calls, state switches);
- validar config Lua em load (schema check + warnings).
