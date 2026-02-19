# Weekly Bounty System — Technical Documentation

## 1. Overview

O Weekly Bounty / Task Board é um sistema totalmente server-side, sem dependência de NPC, entregue ao cliente via protocolo de rede (board request/select/claim). O servidor controla toda a geração de ofertas, aceitação de tarefa, progresso por kill e claim de recompensa.

Características operacionais atuais:

- 100% server-side
- Sem NPC
- Board via protocol
- Determinístico por semana
- Retail-safe

---

## 2. Core Architecture

### 2.1 Main Classes

- **Player**
  - Classe central do sistema de bounty.
  - Mantém o estado semanal (`lastBountyWeekID`, `lastBountyClaimWeekID`, `weeklyBountyCompletions`), estado da tarefa ativa (`activeBountyTask`), ofertas em aberto (`bountyOffers`) e histórico anti-repetição (`lastBountyHistory`).

- **BountyDifficulty**
  - Enum de dificuldade utilizado no fluxo de geração de offers, cálculo de recompensa e serialização de task/offer.
  - Valores operacionais: Easy, Medium, Hard.

- **BountyTask**
  - Estrutura de tarefa ativa do jogador.
  - Campos operacionais: `creatureName`, `requiredKills`, `currentKills`, `completed`, `difficulty`.

- **BountyOffer**
  - Estrutura de oferta semanal enviada ao board.
  - Campos operacionais: `creatureName`, `requiredKills`, `difficulty`.

### 2.2 Main Methods

- **`generateBountyOffers()`**
  - Responsável por:
    - aplicar hard reset semanal defensivo;
    - bloquear geração se já houve claim na semana, se há task ativa ou offers já existentes;
    - montar pool elegível;
    - selecionar até 3 offers via peso + RNG deterministicamente seedado;
    - registrar histórico anti-repeat.

- **`claimBountyReward()`**
  - Responsável por:
    - validar semana corrente e invalidar estado cross-week;
    - garantir pré-condições de claim (task ativa e completada);
    - impedir claim duplicado na semana;
    - calcular EXP e task points;
    - aplicar recompensa e persistir estado final.

- **`addBountyTaskKill()`**
  - Responsável por:
    - validação defensiva de semana no kill path;
    - bloquear progresso cross-week;
    - validar criatura da task;
    - incrementar `currentKills` e marcar `completed` quando aplicável.

- **`calculateBountyExpReward()`**
  - Responsável por:
    - converter effort em EXP com multiplicador por dificuldade;
    - aplicar fator de normalização por level;
    - aplicar clamp final obrigatório da EXP no intervalo retail-safe.

- **`getCurrentWeekID()`**
  - Responsável por:
    - produzir o identificador semanal canônico usado por todo o fluxo de bounty.

---

## 3. Weekly Determinism

O determinismo semanal implementado funciona assim:

1. **WeekID canônico**
   - O fluxo de bounty usa `getCurrentWeekID()` para obter o week bucket corrente.

2. **Seed semanal por jogador**
   - Seed calculada via combinação de GUID do player e weekID:
   - `seed = getWeeklySeed(playerGUID, currentWeekID)`

3. **RNG determinístico**
   - O RNG de bounty usa gerador linear congruente (`seededUniform`) com seed local mutável no escopo da geração.
   - A seleção ponderada (`getWeightedRandomIndex`) também consome o mesmo RNG seedado.

4. **Sem RNG externo no fluxo de geração de offers**
   - Não existe consumo de RNG não-seedado dentro do pipeline de geração semanal.

5. **Sem influência do cliente no seed**
   - O cliente apenas solicita board, seleciona offer por nome e solicita claim.
   - Não envia weekID/seed nem parâmetros de randomização.

---

## 4. Weekly Reset Model

Modelo de reset semanal implementado:

- **`activeBountyTask` não atravessa semana**
  - Em mismatch de semana, o sistema invalida task ativa defensivamente.

- **Claim bloqueado cross-week**
  - `claimBountyReward()` valida semana antes de qualquer concessão.

- **Progresso bloqueado cross-week**
  - `addBountyTaskKill()` aborta progresso em mismatch semanal.

- **`weekly_bounty_completions` resetado corretamente**
  - Resetado para `0` em troca semanal nos caminhos defensivos.

- **`last_bounty_week` persistido em `players`**
  - Estado semanal principal fica persistido independentemente da existência de offers.

Pontos defensivos operacionais:

- reset semanal no momento de geração do board;
- reset semanal no kill path;
- reset semanal no claim path;
- atualização persistida de weekID ao invalidar estado por mismatch.

---

## 5. Persistence Layer

### Tabela `players`

Campos usados pelo sistema:

- `last_bounty_week`
- `last_bounty_claim_week`
- `weekly_bounty_completions`
- `last_bounty_history`
- `hunting_task_points`

### Tabelas auxiliares

- `player_bounty_task`
  - Persistência da task ativa (criatura, kills requeridos/atuais, completed, difficulty).

- `player_bounty_offers`
  - Persistência das offers correntes do board (slot, criatura, required_kills, difficulty, week).

### Load/Save Flow

**Load (login):**

1. Carrega estado base da tabela `players`, incluindo:
   - `last_bounty_week`
   - `last_bounty_claim_week`
   - `weekly_bounty_completions`
   - `last_bounty_history`
2. Carrega `player_bounty_task` e restaura `activeBountyTask`.
3. Carrega `player_bounty_offers` para reidratar ofertas existentes.

**Save:**

1. Salva estado base em `players`, incluindo week state e histórico.
2. Salva/limpa `player_bounty_task` conforme existência de task ativa.
3. Limpa e reinsere `player_bounty_offers` conforme offers atuais.

Resultado operacional: restauração de week state é independente de offers vazias.

---

## 6. Anti-Exploit Protections

Proteções implementadas:

- **Dupla contagem removida (claim único semanal)**
  - Gate por `last_bounty_claim_week == currentWeekID`.
  - Gate por `weekly_bounty_completions >= 1`.

- **Claim único por semana**
  - Ao claim com sucesso, atualiza claim week, incrementa weekly completions e limpa task ativa.

- **Clamp final de EXP**
  - Clamp obrigatório após cálculo completo: `100 .. 45,000,000`.

- **Overflow-safe em effort**
  - Multiplicação de effort promovida para `uint64_t` antes da operação.

- **Anti-repeat history**
  - Histórico de criaturas recentes exclui entradas repetidas na montagem do pool principal.

- **DB adulterado mitigado via clamp**
  - Mesmo com valores elevados de task input persistido, EXP final fica bounded pelo clamp máximo.

- **Seed não manipulável pelo cliente**
  - Seed e week logic são totalmente derivados no servidor.

---

## 7. Reward Model

Modelo atual de recompensa:

1. **Effort**
   - `effort = normalizedMonsterExp * requiredKills`
   - `normalizedMonsterExp` é clampado em `[20, 12000]`.

2. **Multiplicador por dificuldade**
   - Easy: `0.18`
   - Medium: `0.22`
   - Hard: `0.28`

3. **Normalização por nível**
   - fator discreto por faixa de level.

4. **Conversão e clamp final (obrigatório)**
   - promoção para `uint64_t` no effort;
   - reward final clampado:

```cpp
static constexpr uint64_t BOUNTY_EXP_MIN = 100;
static constexpr uint64_t BOUNTY_EXP_MAX = 45000000;
reward = std::clamp(reward, BOUNTY_EXP_MIN, BOUNTY_EXP_MAX);
```

5. **Determinismo mantido**
   - O cálculo de reward não depende do cliente e opera sobre estado server-side validado.

---

## 8. Edge Case Handling

Cobertura dos casos de borda implementados:

- **Relog sem offers**
  - `last_bounty_week` é carregado de `players`, então o estado semanal não depende de `player_bounty_offers` para restauração.

- **Task antiga no banco**
  - mismatch semanal nos caminhos defensivos invalida task antiga e ressincroniza week state.

- **Player offline na virada**
  - reset ocorre no primeiro acesso relevante (board/kill/claim) após retorno.

- **Kill path defensivo**
  - `addBountyTaskKill()` valida semana, criatura, status e limite de kills antes de progredir.

- **Claim path defensivo**
  - `claimBountyReward()` valida semana, task, completed state e gates anti-dup antes de conceder reward.

---

## 9. Stability Guarantees

Garantias operacionais do estado atual:

- Sistema determinístico
- Matemática blindada
- Persistência consistente
- Sem estado fantasma
- Retail-grade

---

## 10. Maintenance Notes

Locais técnicos para manutenção de parâmetros (sem alteração de arquitetura):

- **Alterar multiplicadores de reward por dificuldade**
  - `calculateBountyExpReward()` em `player.cpp`.

- **Alterar pesos de seleção**
  - `calculateBountyWeight()` em `player.cpp`.

- **Alterar clamp final de EXP**
  - constantes `BOUNTY_EXP_MIN` / `BOUNTY_EXP_MAX` em `calculateBountyExpReward()`.

- **Alterar kill range por effort/nível**
  - `getEffortBracket()` e `calculateKillRangeFromExp()` em `player.cpp`.

- **Alterar thresholds de dificuldade**
  - `resolveBountyDifficulty()` (constantes de HP/EXP) em `player.cpp`.

---

System Status: 100% Stable — Retail Safe
