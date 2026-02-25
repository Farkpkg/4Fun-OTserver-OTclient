# 10_REGRAS_DE_NEGOCIO_FORMAL

## 1) Escopo e premissas
Este documento formaliza as regras de negócio do sistema de **Hunting Task** (task hunting), cobrindo:
- geração de tasks por dificuldade,
- fórmula de recompensa (Bounty / Weekly / Shop),
- custos de reroll, cancelamento, upgrades e preferred slots,
- limites/caps diários e semanais,
- regras de desempate/randomização com seed e intervalos,
- exemplos numéricos completos,
- tabela de constantes com origem (arquivo/feature flag).

> **Nota de aderência ao core atual:** as fórmulas de geração, raridade e custos refletem o comportamento existente no servidor. Para componentes “Weekly” e “Shop” que não possuem cap nativo no core, este documento define uma formalização compatível e extensível por feature flags.

---

## 2) Fórmula de geração de tasks por dificuldade

### 2.1 Classificação da dificuldade
A dificuldade da criatura é determinada por estrelas de bestiary:
- **Easy**: `bestiaryStars <= 1`
- **Medium**: `2 <= bestiaryStars <= 3`
- **Hard**: `bestiaryStars >= 4`

### 2.2 Geração de opções-base (kills/reward) por dificuldade e raridade
Constantes base:
- `killStage = 25`
- `limitOfStars = 5` (raridade 1..5)
- dificuldades indexadas como: `Easy=1`, `Medium=2`, `Hard=3`

Para cada dificuldade `d`:
1. `killsBase(d) = 25 * 4^(d-1)`
2. `rewardBase(d, star=1) = round((10 * killsBase(d)) / 25)`
3. Para cada `star` de 1 a 5:
   - `firstKills(d,star) = killsBase(d)`
   - `secondKills(d,star) = 2 * killsBase(d)`
   - `firstReward(d,star) = reward(d,star)`
   - `secondReward(d,star) = 2 * reward(d,star)`
   - Próximo reward:
     - `reward(d,star+1) = round(reward(d,star) * growth(d))`
     - `growth(d) = (115 + 5*d) / 100`
       - Easy (`d=1`) => `1.20`
       - Medium (`d=2`) => `1.25`
       - Hard (`d=3`) => `1.30`

### 2.3 Tabela derivada (core)
| Dificuldade | Star | First Kills | First Reward | Second Kills | Second Reward |
|---|---:|---:|---:|---:|---:|
| Easy | 1 | 25 | 10 | 50 | 20 |
| Easy | 2 | 25 | 12 | 50 | 24 |
| Easy | 3 | 25 | 14 | 50 | 28 |
| Easy | 4 | 25 | 17 | 50 | 34 |
| Easy | 5 | 25 | 20 | 50 | 40 |
| Medium | 1 | 100 | 40 | 200 | 80 |
| Medium | 2 | 100 | 50 | 200 | 100 |
| Medium | 3 | 100 | 63 | 200 | 126 |
| Medium | 4 | 100 | 79 | 200 | 158 |
| Medium | 5 | 100 | 99 | 200 | 198 |
| Hard | 1 | 400 | 160 | 800 | 320 |
| Hard | 2 | 400 | 208 | 800 | 416 |
| Hard | 3 | 400 | 270 | 800 | 540 |
| Hard | 4 | 400 | 351 | 800 | 702 |
| Hard | 5 | 400 | 456 | 800 | 912 |

---

## 3) Fórmula de recompensa (Bounty / Weekly / Shop)

## 3.1 Bounty (pontuação da task individual)
1. Defina `baseReward`:
   - se task com upgrade concluída em `secondKills`: `baseReward = secondReward(d,star)`
   - senão: `baseReward = firstReward(d,star)`
2. Sorteie multiplicador de bônus (`boostFactor`) conforme regra de claim:
   - padrão: `boostFactor = 10`
   - se `rarity >= 4` e roll em faixa especial: pode virar `15` (50%) ou `20` (100%)
3. Recompensa final de bounty:

`BountyPoints = ceil(baseReward * boostFactor / 10)`

Exemplos de multiplicador:
- `boostFactor=10` => 1.0x
- `boostFactor=15` => 1.5x
- `boostFactor=20` => 2.0x

## 3.2 Weekly (agregação semanal)
Formalização recomendada (compatível com core):

`WeeklyPoints(player, week) = sum(BountyPoints de claims da semana)`

Com cap opcional por feature flag:

`WeeklyPointsCapped = min(WeeklyPoints, WEEKLY_CAP_POINTS)`

> Sem a flag de cap, o comportamento atual é “sem teto semanal de pontos”, limitado apenas por tempo de slot e capacidade de completar tasks.

## 3.3 Shop (gasto de pontos)
No core atual, compras com task points são controladas por consumo direto de saldo:

`TaskPointsAfterPurchase = TaskPointsBefore - ShopCostPoints`

Regra de autorização:

`TaskPointsBefore >= ShopCostPoints`

Formalização opcional para loja semanal (feature flag):
- `ShopWeeklySpent <= SHOP_WEEKLY_SPEND_CAP`
- `ShopCostDynamic = BaseCost * ShopPriceMultiplier`

---

## 4) Custos: reroll, cancel, upgrades e preferred slots

## 4.1 Reroll de lista (task)
- Se **fora da janela free reroll**:
  - `TaskRerollCostGold = PlayerLevel * taskHuntingRerollPricePerLevel`
- Se **dentro da janela free reroll expirada**:
  - custo 0 e reinicia `freeRerollTimeStamp`

## 4.2 Reroll de recompensa (raridade)
- Custo em prey cards:

`RewardRerollCostCards = taskHuntingBonusRerollPrice`

## 4.3 Cancelar task ativa
- Custo em gold (sempre pago):

`CancelCostGold = PlayerLevel * taskHuntingRerollPricePerLevel`

## 4.4 Upgrade da task
- Não há custo monetário direto no core.
- Regra de elegibilidade:

`UpgradeAllowed = player.isCreatureUnlockedOnTaskHunting(creature)`

Se verdadeiro e jogador marcar upgrade, task passa a exigir `secondKills` e pagar `secondReward`.

## 4.5 Preferred slots / seleção preferencial de criatura
- Seleção manual da lista completa (ListAll) custa:

`PreferredSelectionCostCards = taskHuntingSelectListPrice`

- Slots extras:
  - Slot 2 depende de status premium (quando aplicável).
  - Slot 3 depende de `taskHuntingFreeThirdSlot` ou compra de slot permanente no Store.

---

## 5) Limites e caps (diário/semanal)

## 5.1 Cooldown por slot após claim
Após claim válido:

`slot.disabledUntil = now + taskHuntingLimitedTasksExhaust`

Com default de 20h, o slot fica bloqueado para nova seleção até expirar.

## 5.2 Cap diário efetivo (operacional)
Sem cap explícito no core, o teto efetivo por slot é temporal:

`DailyClaimsPerSlotMax = floor(24h / taskHuntingLimitedTasksExhaust)`

`DailyClaimsAllSlotsMax = ActiveSlots * DailyClaimsPerSlotMax`

Com 20h:
- `DailyClaimsPerSlotMax = floor(24/20)=1`
- com 2 slots ativos => até 2 claims/dia (teórico)

## 5.3 Cap semanal efetivo (operacional)

`WeeklyClaimsPerSlotMax = floor(168h / taskHuntingLimitedTasksExhaust)`

`WeeklyClaimsAllSlotsMax = ActiveSlots * WeeklyClaimsPerSlotMax`

Com 20h:
- `WeeklyClaimsPerSlotMax = floor(168/20)=8`
- com 2 slots ativos => até 16 claims/semana (teórico)

## 5.4 Caps lógicos opcionais (feature flags)
Se o produto quiser cap econômico explícito:
- `FEATURE_TASK_WEEKLY_CAP_ENABLED=true`
- `WEEKLY_CAP_POINTS=<valor>`
- `FEATURE_TASK_DAILY_CAP_ENABLED=true`
- `DAILY_CAP_POINTS=<valor>`

Aplicação:
- `GrantedPoints = min(BountyPoints, RemainingCap)`

---

## 6) Regras de desempate e randomização (seed/intervalos)

## 6.1 Seed e engine de aleatoriedade
- PRNG: `std::mt19937`
- Seed: `std::random_device` no start do processo.
- Distribuição: `uniform_int_distribution<int32_t>` com intervalo **inclusivo** `[min,max]`.

## 6.2 Randomização da raridade ao rerollar recompensa
Dado `rarity atual`:
- `rarity >= 4` => força `rarity = 5`
- caso contrário, sorteia `chance` em faixa:
  - r0 => `[0,100]`
  - r1 => `[0,70]`
  - r2 => `[0,45]`
  - r3 => `[0,20]`

Mapeamento da chance para nova raridade:
- `chance <= 5` => r5
- `6..20` => r4
- `21..45` => r3
- `46..70` => r2
- `>70` => r1

## 6.3 Randomização do bônus no claim
Sorteio `boostRoll` em `[0,100]`:
- se `rarity >= 4` e `boostRoll <= 5` => `boostFactor=20`
- senão, se `rarity >= 4` e `boostRoll <= 10` => `boostFactor=15`
- senão => `boostFactor=10`

## 6.4 Randomização da lista de monstros por slot
- Seleção aleatória de até 9 criaturas com blacklist para evitar duplicidade.
- Composição por faixa de level (cotas por estrelas de bestiary):
  - Level 0..99: `3/3/2/1` (1★,2★,3★,4★+)
  - Level 100..299: `1/3/3/2`
  - Level 300..499: `1/2/3/3`
  - Level 500+: `1/1/3/4`
- Fallback: após 10 tentativas sem encaixe em cota, aceita criatura válida para destravar geração.

---

## 7) Exemplos numéricos completos

## Exemplo A — Custo de reroll/cancel/preferred (player level 250)
Parâmetros padrão:
- `taskHuntingRerollPricePerLevel = 200`
- `taskHuntingSelectListPrice = 5`

Cálculos:
1. **Reroll pago**:
   - `250 * 200 = 50.000 gold`
2. **Cancelamento**:
   - `250 * 200 = 50.000 gold`
3. **Preferred selection (ListAll)**:
   - `5 prey cards`

Resultado:
- reroll e cancel custam **50.000 gold** cada,
- seleção preferencial custa **5 cards**.

## Exemplo B — Claim de task Medium, star 3, sem upgrade
Da tabela:
- Medium star 3 => `firstKills=100`, `firstReward=63`

Supondo task concluída e claim com bônus padrão (`boostFactor=10`):

`BountyPoints = ceil(63 * 10 / 10) = 63`

Se cair bônus 50% (`boostFactor=15`):

`BountyPoints = ceil(63 * 15 / 10) = ceil(94,5) = 95`

## Exemplo C — Claim de task Hard, star 4, com upgrade
Da tabela:
- Hard star 4 => `secondKills=800`, `secondReward=702`

Cenários:
1. bônus padrão (1.0x):
   - `ceil(702 * 10 / 10) = 702`
2. bônus 50% (1.5x):
   - `ceil(702 * 15 / 10) = ceil(1053) = 1053`
3. bônus 100% (2.0x):
   - `ceil(702 * 20 / 10) = 1404`

## Exemplo D — Cap semanal efetivo por tempo
Parâmetros:
- cooldown = 20h
- slots ativos = 2

`WeeklyClaimsPerSlotMax = floor(168/20)=8`

`WeeklyClaimsAllSlotsMax = 2*8=16 claims/semana`

Se média de 500 pontos por claim:
- teto operacional aproximado = `16*500 = 8.000 pontos/semana`
(sem cap lógico adicional).

---

## 8) Tabela de constantes e origem de configuração

| Constante / Chave | Tipo | Padrão | Origem (arquivo) | Feature flag / controle |
|---|---|---:|---|---|
| `taskHuntingSystemEnabled` | bool | `true` | `config.lua.dist` | Liga/desliga sistema de task hunting |
| `taskHuntingFreeThirdSlot` | bool | `false` | `config.lua.dist` | Define se 3º slot é gratuito |
| `taskHuntingLimitedTasksExhaust` | int (s) | `72000` | `config.lua.dist` | Cooldown pós-claim por slot |
| `taskHuntingRerollPricePerLevel` | int | `200` | `config.lua.dist` | Multiplicador de custo de reroll/cancel |
| `taskHuntingSelectListPrice` | int (cards) | `5` | `config.lua.dist` | Custo de seleção preferencial |
| `taskHuntingBonusRerollPrice` | int (cards) | `1` | `config.lua.dist` | Custo de reroll de raridade |
| `taskHuntingFreeRerollTime` | int (s) | `72000` | `config.lua.dist` | Janela para reroll gratuito |
| `killStage` | int | `25` | hardcoded em `ioprey.cpp` | Recomendado externalizar por flag/config |
| `limitOfStars` | int | `5` | hardcoded em `ioprey.cpp` | Alinhado ao cliente atual |
| `Store Permanent Hunting Task Slot` | preço TC | `900` | `data/modules/scripts/gamestore/gamestore.lua` | Compra slot permanente |

### Flags recomendadas para evolução (não nativas no core)
| Flag proposta | Objetivo | Valor sugerido |
|---|---|---|
| `FEATURE_TASK_WEEKLY_CAP_ENABLED` | Habilitar cap semanal de pontos | `false` |
| `WEEKLY_CAP_POINTS` | Teto semanal de pontos | `10000` |
| `FEATURE_TASK_DAILY_CAP_ENABLED` | Habilitar cap diário de pontos | `false` |
| `DAILY_CAP_POINTS` | Teto diário de pontos | `2000` |
| `FEATURE_TASK_SHOP_WEEKLY_SPEND_CAP_ENABLED` | Limitar gasto semanal em shop | `false` |
| `SHOP_WEEKLY_SPEND_CAP` | Teto de gasto semanal | `5000` |

---

## 9) Regras de conformidade e auditoria
- Toda concessão de pontos deve registrar: `playerId`, `slotId`, `difficulty`, `rarity`, `upgrade`, `kills`, `boostFactor`, `grantedPoints`, `timestamp`.
- Toda dedução (reroll/cancel/shop) deve registrar: `currencyType`, `amount`, `balanceBefore`, `balanceAfter`, `reason`.
- Para troubleshooting de RNG, logar também o `roll` bruto (ex.: `boostRoll`) sem expor seed.

---

## 10) Resumo executivo
- A economia atual de task hunting já tem fórmulas determinísticas para geração e reward base.
- Custos principais são lineares por nível (`level * rerollPricePerLevel`) + custos fixos em cards.
- O “cap” real hoje é majoritariamente temporal (cooldown por slot), não um cap lógico de pontos.
- Caso o produto precise equilíbrio mais rígido, ativar caps diários/semanais por feature flag conforme tabela.
