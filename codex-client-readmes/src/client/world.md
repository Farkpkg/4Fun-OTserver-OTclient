# Guia do Mundo (Map, Tile, Thing)

## Escopo

Este guia cobre a representacao do mundo: `Map`, `Tile`, `Thing` e derivados (Creature, Item, Effect, Missile).

## Visao geral

- `Map` organiza tiles por andar (z) e por blocos 8x8.
- `Tile` representa uma posicao e ordena `Thing` por prioridade de stack.
- `Thing` e a base polimorfica para tudo que aparece no mundo.

## Arquivos principais

- `src/client/map.*`
- `src/client/tile.*`
- `src/client/thing.*`
- `src/client/creature.*`
- `src/client/item.*`

## Hierarquia

- `Thing`
  - `Creature` -> `LocalPlayer`
  - `Item`
  - `Effect`
  - `Missile`

## Regras de stack (tile)

- Ground/ground borders -> bottom items -> on-top items -> creatures -> itens comuns.
- `Tile::addThing()` e `Tile::updateThingStackPos()` controlam a ordem.

## Map storage

- `Map` usa `m_floors[16]` e blocos 8x8 para localidade.
- Indice de bloco: `((x / 8) << 16) | ((y / 8) << 8) | z`.

## Dicas

- Sempre validar existencia de tile ao mover/add thing.
- Alteracoes de tile disparam update de render via `MapView`.
- Para movimento e animacao de criaturas, veja `src/client/creatures.md`.
