# Referências obrigatórias — UI, widgets e padrões existentes

## Objetivo
Tornar explícito **com quais arquivos existentes** a implementação deve se alinhar para manter padrão visual, estrutural e de codificação do projeto.

## 1) Base de estilos OTUI (obrigatório consultar)
- `otclient/data/styles/10-windows.otui`
- `otclient/data/styles/10-buttons.otui`
- `otclient/data/styles/10-checkboxes.otui`
- `otclient/data/styles/10-progressbars.otui`
- `otclient/data/styles/10-separators.otui`
- `otclient/data/styles/20-tabbars.otui`
- `otclient/data/styles/30-miniwindow.otui`
- `otclient/data/styles/30-messageboxes.otui`
- `otclient/data/styles/30-inputboxes.otui`

## 2) Módulos com padrões úteis de UI/estado
- `otclient/modules/game_rewardwall/styles/style.otui`
- `otclient/modules/game_rewardwall/styles/pickreward.otui`
- `otclient/modules/game_rewardwall/game_rewardwall.lua`
- `otclient/modules/game_interface/gameinterface.otui`
- `otclient/modules/game_interface/gameinterface.lua`

> Observação: pode usar esses módulos como referência de layout/UX, mas **sem copiar domínio de negócio**.

## 3) Pipeline client (C++ -> Lua -> OTUI)
- Parse: `otclient/src/client/protocolgameparse.cpp`
- Send: `otclient/src/client/protocolgamesend.cpp`
- API game: `otclient/src/client/game.cpp` e `otclient/src/client/game.h`
- Códigos de protocolo: `otclient/src/client/protocolcodes.h`

## 4) Pipeline server (autoritativo)
- Parser de mensagens: `crystalserver/src/server/network/protocol/protocolgame.cpp`
- Regras de jogo: `crystalserver/src/game/game.cpp`
- Entidade jogador: `crystalserver/src/creatures/players/player.cpp`
- Persistência e IO: `crystalserver/src/io/*` e migrations em `crystalserver/data/migrations/*`

## 5) Regras de codificação e governança (obrigatório)
- `new_docs/UI_CANONICAL_RULES.md`
- `new_docs/SYSTEM_INVARIANTS.md`
- `new_docs/CHANGE_IMPACT_PROTOCOL.md`
- `new_docs/CHANGE_GATE_CHECKLIST.md`
- `new_docs/AUTOMATED_STRUCTURAL_CHECKS_SPEC.md`

## 6) Checklist de aderência rápida para PR de implementação
- [ ] Nenhum widget custom recria algo já existente em `otclient/data/styles` sem justificativa.
- [ ] Convenções de naming de arquivos `.otui/.lua` mantidas (minúsculo predominante).
- [ ] Estado visual de componentes interativos completo (`normal/hover/pressed/disabled`).
- [ ] Server mantém autoridade total de estado/recompensa.
- [ ] Qualquer desvio de padrão documentado via ADR/justificativa formal.
