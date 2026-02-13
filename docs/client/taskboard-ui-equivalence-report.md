<!-- REVIEW: Este documento referencia `COMPLETE_CUSTOM_CLIENT` (repositório externo não versionado neste projeto). Validar manualmente equivalência com `otclient/` atual antes de usar como fonte de verdade. -->

# TaskBoard UI Equivalence Report

## Objetivo
Verificar equivalência estrutural entre a UI do TaskBoard (`otclient/modules/game_taskboard`) e o padrão estrutural BattlePass/Tasks do `COMPLETE_CUSTOM_CLIENT`.

## Árvore estrutural (nível alto)

## Custom BattlePass
1. `battlePassWindow`
2. `mainPanel`
3. `optionsTabBar`
4. `contentPanel`
5. (`missionPanel` | `progressPanel`)

## TaskBoard adaptado
1. `taskBoardWindow`
2. `mainPanel`
3. `optionsTabBar`
4. `contentPanel`
5. (`missionPanel` | `progressPanel`)

**Status**: equivalente no backbone da árvore.

## Hierarquia interna

## missionPanel
- Custom: daily + missions + player progress.
- TaskBoard: bounty + weekly (com grids/track).

## progressPanel
- Custom: reward track.
- TaskBoard: shop grid.

**Status**: equivalente no padrão de composição (painéis especializados por seção), com domínio distinto.

## Navegação
- Custom: botões no optionsTabBar para alternar mission/progress.
- TaskBoard: botões no optionsTabBar (`bountyMenu`, `weeklyMenu`, `shopMenu`) alternando mission/progress e subpainéis.

**Status**: equivalente no mecanismo de navegação por botão + visibilidade.

## Render e binding
- Controller do TaskBoard resolve widgets por árvore (`findChild/recursiveGetChildById`) e aplica estado incremental por seção.
- Render distribuído por funções (`renderBounties`, `renderWeekly`, `renderShop`, `refreshSummary`).

**Status**: equivalente ao padrão de render do custom (estado -> widgets por painéis/templates).

## Resultado final
- A UI do `game_taskboard` está estruturalmente alinhada ao padrão BattlePass/Tasks do custom.
- Diferenças restantes são intencionais e restritas a:
  - domínio funcional (TaskBoard unificado)
  - protocolo/opcode (242 + sync/delta)
  - backend consolidado
