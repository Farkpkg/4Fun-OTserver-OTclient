<!-- REVIEW: Este documento referencia `COMPLETE_CUSTOM_CLIENT` (repositório externo não versionado neste projeto). Validar manualmente equivalência com `otclient/` atual antes de usar como fonte de verdade. -->

# TaskBoard UX Equivalence Report

## Objetivo
Este relatório valida a **equivalência de experiência (UX)** entre o padrão BattlePass/Task Board do `COMPLETE_CUSTOM_CLIENT` e o `game_taskboard` atual, **sem exigir clone estrutural pixel-perfect**.

## Princípio adotado
- **Mantido:** arquitetura consolidada do TaskBoard (`taskBoardWindow`, `mainPanel`, `optionsTabBar`, `missionPanel`, `progressPanel`).
- **Mantido:** transporte por opcode `242` e modelo `sync/delta`.
- **Permitido:** diferenças de estrutura interna de widgets/layout para adequação da stack consolidada.
- **Obrigatório:** mesma experiência mental do jogador.

---

## Tradução de conceitos (Custom -> TaskBoard)

### 1) Aba Challenges
**Custom (conceito):** Daily missions + progresso de nível + lista de missões/tarefas.

**TaskBoard (implementação):**
- `dailyMissionsBg` com slots de missão (`TaskBoardMissionWidget`).
- `playerProgressPanel` com `playerLevel`, `levelProgress`, `currentlyLevelText`.
- Área de tarefas com Bounty + Weekly (kill/delivery), incluindo dificuldade e ações (`reroll`, `claimDaily`).

**Equivalência UX:** o jogador vê tarefas ativas, progresso e estados de conclusão/claim no mesmo fluxo mental da aba de desafios.

### 2) Aba Rewards
**Custom (conceito):** trilha de recompensa por nível com faixas Free/Premium e estados de desbloqueio/claim.

**TaskBoard (implementação):**
- `freeTrack` + `premiumTrack`.
- Slots (`TaskBoardTrackRewardSlot`) por step, com estados:
  - `Locked`
  - `Claim`
  - `Claimed`
- Ação `claimReward` por `stepId` e `lane`.

**Equivalência UX:** progressão por step e coleta de recompensa por faixa reproduzida mentalmente.

### 3) Estados visuais e feedback
**Custom (conceito):** estados de tarefa/recompensa e bloqueios visuais claros.

**TaskBoard (implementação):**
- Missões/tarefas: `in progress`, `claimable`, `claimed/completed`.
- Recompensas: `locked`, `claim`, `claimed`.
- Premium: bloqueio explícito quando `premiumEnabled` não está ativo.

**Equivalência UX:** feedback imediato de status e ação disponível/indisponível.

### 4) Navegação
**Custom (conceito):** navegação por tabs principais (Challenges/Rewards).

**TaskBoard (implementação):**
- `challengesMenu` e `rewardsMenu` no `optionsTabBar`.
- alternância de `missionPanel` e `progressPanel`.

**Equivalência UX:** duas áreas mentais claras e previsíveis para o jogador.

---

## Diferenças estruturais intencionais

1. **Sem clone pixel-perfect de OTUI custom**
   - Não há cópia literal de todos os templates/containers do `battlepass.otui`.
   - Razão: reduzir acoplamento e preservar manutenção da stack consolidada.

2. **Sem MapFragment/track contínua gigante**
   - A trilha usa containers de slots (horizontalBox/grid), não painel contínuo com fragmentos.
   - Razão: simplicidade operacional e melhor previsibilidade de render no contexto atual.

3. **Domínio consolidado no mesmo fluxo**
   - Rewards tab inclui trilha + bloco de shop integrado ao modelo TaskBoard atual.
   - Razão: manter unificação Weekly/Bounty/Rewards com backend único.

4. **Estruturas de widget próprias do módulo**
   - Uso de classes atuais (`TaskBoardMissionWidget`, `TaskBoardTrackRewardSlot`, `RectangleProgressBar`).
   - Razão: consistência interna do módulo e menor custo de evolução.

---

## Adequação técnica à stack consolidada

- Protocolo: `242` + `sync/delta`.
- Backend: TaskBoard unificado (persistência + validações de ação/parâmetro).
- Atualização de UI: state/store incremental (sem rebuild completo de janela).

Esta decisão entrega equivalência de experiência sem herdar complexidades estruturais desnecessárias do custom.

---

## Conclusão
A UI atual do `game_taskboard` deve ser tratada como **UX-equivalente** ao custom, e não como clone estrutural.

Critério atendido:
- jogador mantém o mesmo mapa mental de uso (Challenges/Rewards, progresso, claim, premium lock, tarefas semanais/bounty).
- arquitetura permanece compatível com o backend unificado e sustentável para evolução.
