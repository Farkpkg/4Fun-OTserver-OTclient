# Métricas iniciais

## Totais
- **Arquivos**: 11.450
- **Pastas**: 1.023

## Linguagens detectadas (por extensão)
- Lua (`.lua`)
- C++ (`.cpp`, `.hpp`, `.h`)
- XML (`.xml`)
- OTUI (`.otui`)
- Markdown (`.md`)
- CMake (`.cmake`)
- Shaders (`.frag`)
- Shell (`.sh`)
- Assets (`.png`, `.jpg`, `.ttf`, `.otfont`, `.otbm`)

## Principais áreas do código
- **Servidor**: `crystalserver/src/` e `crystalserver/data/`.
- **Cliente**: `otclient/src/`, `otclient/modules/`, `otclient/data/`.
- **Documentação/apoio**: `docs/`, `ai/`, `codex-client-readmes/`.

## Sistemas críticos identificados
- **Rede e protocolos** (cliente/servidor).
- **Game loop** (servidor e cliente).
- **Scripts Lua e eventos** (servidor).
- **UI e módulos** (cliente).
- **Banco de dados e conta** (servidor).

## Relatório de qualidade da wiki
- **Páginas da wiki**: 30 arquivos Markdown.
- **Referências a arquivos/pastas do repositório**: 133.
- **Evolução da cobertura**:
  - snapshot anterior: 90 referências.
  - snapshot atual: 133 referências.

## Sistemas com risco documental
- **Crítico**: `crystalserver/src/enums/`, `crystalserver/src/utils/`.
- **Médio**: `crystalserver/data/scripts/globalevents/`, `talkactions/`.
- **Baixo**: `otclient/src/tools/`, assets adicionais.

## Áreas sensíveis a mudanças
- **Protocolos**: mudanças em opcodes exigem sincronização cliente ↔ servidor.
- **Scripts**: alterações em eventos exigem revisão de callbacks e XML.
- **Mapas/itens**: alterações em dados impactam UI e gameplay.
