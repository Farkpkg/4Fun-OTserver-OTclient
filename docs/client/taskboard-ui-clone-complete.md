<!-- REVIEW: Este documento referencia `COMPLETE_CUSTOM_CLIENT` (repositório externo não versionado neste projeto). Validar manualmente equivalência com `otclient/` atual antes de usar como fonte de verdade. -->

# TaskBoard UI Clone Complete

## Fonte oficial usada
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/classes/rewards.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/*`
- `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/*`

## Árvore de widgets (comparativo resumido)

### Custom
- `battlePassWindow`
  - `mainPanel`
    - `optionsTabBar` (`challengesMenu`, `rewardsMenu`)
    - `contentPanel`
      - `missionPanel`
      - `progressPanel`

### OTCLIENT (game_taskboard)
- `taskBoardWindow`
  - `mainPanel`
    - `optionsTabBar` (`challengesMenu`, `rewardsMenu`)
    - `contentPanel`
      - `missionPanel`
      - `progressPanel`

## Equivalência aplicada (visual/funcional)
- Navegação de 2 abas mentais (`Challenges` / `Rewards`) replicada.
- `missionPanel` replica:
  - daily missions
  - progresso de nível (level/progress text/progressbar)
  - tarefas de caça/entrega com estados visuais.
- `progressPanel` replica:
  - reward track free/premium por steps
  - estados de reward (`locked`, `claim`, `claimed`)
  - fluxo de claim por step/lane.
- Shop mantida no painel de rewards como bloco adicional (suporte ao domínio consolidado).

## Ajustes de protocolo/backend (mantidos)
- Opcode: `242` (inalterado).
- Transporte: `sync/delta`.
- Ações extras para fidelidade de clone:
  - `claimReward`
- Payload de clone no sync:
  - `dailyMissions`
  - `rewardTrack`
  - `playerLevel`
  - `currentPoints`
  - `nextStepPoints`
  - `premiumEnabled`

## Checklist final
- [x] Hierarquia da janela equivalente ao custom.
- [x] Navegação equivalente ao custom.
- [x] Reward track free/premium presente.
- [x] Claim de reward por track presente.
- [x] Estados visuais locked/claim/claimed presentes.
- [x] Daily missions presentes.
- [x] Compatível com stack unificada e opcode 242.

## Observações
- Diferenças de backend são intencionais (stack consolidada TaskBoard + persistência nova).
- Diferenças de naming interno são permitidas quando não alteram experiência do jogador.
