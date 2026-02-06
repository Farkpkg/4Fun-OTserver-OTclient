---
alwaysApply: true
---
# Guia de Tests (GTest)

## Escopo

Este guia cobre os testes em `tests/` e como habilitar o build de testes.

## Estrutura

- `tests/CMakeLists.txt` agrega suites.
- `tests/map/` contem testes de mapa.

## Build e execucao

- Build controlado por `OTCLIENT_BUILD_TESTS` no CMake.
- Ver `tools/build.md` para comandos de build.

## Onde editar

- Adicionar novos testes em subpastas de `tests/`.
- Registrar no `tests/CMakeLists.txt` correspondente.

## Relacionados

- `tools/build.md` (flags de build e ctest).
