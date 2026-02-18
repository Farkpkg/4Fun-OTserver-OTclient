---
alwaysApply: true
---
# Guia de Protobuf (Assets e Static Data)

## Escopo

Este guia cobre os schemas protobuf usados pelo cliente para assets e dados estaticos. Eles sao usados no parsing moderno (10.98+).

## Arquivos principais

- `src/protobuf/appearances.proto`: sprites/appearances.
- `src/protobuf/staticdata.proto`: dados estaticos.
- `src/protobuf/sounds.proto`: definicoes de audio.

## Uso no client

- `ThingType::unserializeAppearance()` consome appearances.
- Para fluxo de assets, veja `src/client/assets.md`.
