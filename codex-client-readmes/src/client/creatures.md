# Creature and Movement System

## Escopo

Este guia cobre criaturas e movimento no cliente: lifecycle, animacao, pre-walk e sincronizacao com o servidor.

## Hierarquia

- `Thing` -> `Creature` -> `Player` -> `LocalPlayer`.
- `Creature` e a base de entidades animadas (player, NPC, monstro).

## Lifecycle (alto nivel)

- Criacao via protocolo -> `Creature::onCreate()`.
- Registro no mapa -> `Map::m_knownCreatures`.
- `onAppear()` diferencia walk vs teleport.
- `onDisappear()` pode ser atrasado para evitar flicker.

## Movimento e animacao

- `Creature::walk()` inicializa estado de movimento.
- `m_walkOffset` suaviza a transicao entre tiles.
- `updateWalkingTile()` define a tile visual durante o passo.
- `updateWalkAnimation()` alterna fases com base na velocidade.

## Duracao do passo

- `getStepDuration()` combina speed, ground speed e diagonais.
- Formula nova depende de `GameNewSpeedLaw`.

## LocalPlayer (pre-walk)

- `preWalk()` antecipa o movimento no cliente.
- `canWalk()` valida lock, fila e sync com servidor.
- Server confirma ou corrige: limpa `m_preWalks` quando diverge.

## Render de criatura

- `Creature::draw()` desenha corpo e overlays.
- `internalDraw()` aplica outfit, addons e mount.
- `drawInformation()` desenha barras e nomes.
- Pipeline geral: ver `src/client/rendering.md` e `src/framework/graphics/AGENTS.md`.

## Arquivos principais

- `src/client/creature.*`
- `src/client/player.*`
- `src/client/localplayer.*`
- `src/client/outfit.*`
- `src/client/tile.*`
- `src/client/map.*`
