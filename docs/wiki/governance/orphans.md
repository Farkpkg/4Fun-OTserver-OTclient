[Wiki](../README.md) > [Governança](README.md) > Órfãos

# Relatório de órfãos (snapshot)

## Metodologia
- Foi feita a varredura das referências em backticks dentro da wiki.
- Pastas relevantes do código foram comparadas com as referências.
- O objetivo é indicar **áreas não citadas** na wiki atual.

> **Nota**: este relatório não substitui uma análise semântica do conteúdo, apenas indica ausência de links.

## Órfãos detectados (por área)

### CrystalServer (`crystalserver/src`)
- **Crítico**
  - `crystalserver/src/enums/` — sugerir link em `docs/wiki/server/README.md` (seção de estrutura).
  - `crystalserver/src/utils/` — sugerir link em `docs/wiki/server/README.md`.
- **Legado/apoio**
  - `crystalserver/src/lib/` — sugerir link em `docs/wiki/server/README.md`.
  - `crystalserver/src/kv/` — sugerir link em `docs/wiki/server/README.md`.

### OTClient (`otclient/src`)
- **Apoio**
  - `otclient/src/tools/` — sugerir link em `docs/wiki/client/README.md` ou `docs/wiki/tools/README.md`.

### Scripts (`crystalserver/data/scripts`)
- **Scripts**
  - `crystalserver/data/scripts/globalevents/` — sugerir link em `docs/wiki/scripts/README.md` ou `docs/wiki/game-systems/eventos/README.md`.
  - `crystalserver/data/scripts/lib/` — sugerir link em `docs/wiki/scripts/README.md`.
  - `crystalserver/data/scripts/systems/` — sugerir link em `docs/wiki/scripts/README.md`.
  - `crystalserver/data/scripts/talkactions/` — sugerir link em `docs/wiki/scripts/README.md`.

### Assets (`otclient/data`)
- **Assets**
  - `otclient/data/cursors/` — sugerir link em `docs/wiki/assets/README.md`.
  - `otclient/data/fonts/` — sugerir link em `docs/wiki/assets/README.md`.
  - `otclient/data/images/` — sugerir link em `docs/wiki/assets/README.md`.
  - `otclient/data/locales/` — sugerir link em `docs/wiki/assets/README.md` ou `docs/wiki/client/README.md`.
  - `otclient/data/particles/` — sugerir link em `docs/wiki/assets/README.md`.
  - `otclient/data/sounds/` — sugerir link em `docs/wiki/assets/README.md`.

## Próximas ações
- Incluir os caminhos órfãos nas seções de estrutura apropriadas.
- Confirmar se algum caminho é **intencionalmente omitido** (legado ou em desuso).
