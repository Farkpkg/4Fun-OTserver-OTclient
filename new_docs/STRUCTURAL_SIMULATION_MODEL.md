# STRUCTURAL SIMULATION MODEL

## 1) Objetivo

Definir um modelo de simulação estrutural **pré-mudança** para estimar, antes da execução real:

- impacto em estabilidade arquitetural (AIS);
- impacto em drift e budget de governança;
- impacto em risco estrutural preditivo;
- probabilidade de regressão por classe de intervenção.

A simulação é obrigatória para mudanças classificadas como `architecture_relevant_change`.

---

## 2) Escopo de simulação

Cada simulação opera sobre uma **Structural Unit (SU)** (sistema, subsistema ou aresta crítica) e um tipo de intervenção:

1. redução de acoplamento;
2. extração de módulo;
3. introdução de novo sistema;
4. migração de persistência;
5. alteração de protocolo.

---

## 3) Variáveis estruturais afetadas

Entradas mínimas por cenário:

- `CHS`, `CLS`, `CDS`, `RCS`, `ECS`, `DCS` (baseline atual);
- `critical_dependency_density`;
- `global_coupling`;
- `drift_accum_k` e `drift_budget_k`;
- `exceptions_open` e `exceptions_expired`;
- `risk_probability` por SU.

Variáveis derivadas da intervenção:

- `delta_cross_edges`
- `delta_internal_cohesion`
- `delta_contract_break_risk`
- `delta_data_migration_complexity`
- `delta_observability_gap`
- `delta_change_frequency`

---

## 4) Modelo conceitual de impacto

## 4.1 Delta de métricas componentes

Para cada métrica `M`:

`M_sim = clamp(0, 100, M_base + delta_M_intervention + delta_M_context)`

Exemplos de sinais esperados por intervenção:

- redução de acoplamento: `delta_CLS > 0`, `delta_CDS >= 0`, `delta_DCS` depende do rollout;
- extração de módulo: `delta_CHS > 0`, possível `delta_RCS < 0` no curto prazo se observabilidade for baixa;
- novo sistema: `delta_CDS` pode cair inicialmente por novas arestas críticas;
- migração de persistência: pressão em `RCS` e `DCS` durante janela de coexistência;
- alteração de protocolo: maior sensibilidade em `CDS` e `RCS`.

## 4.2 Delta de AIS simulado

`AIS_sim = 0.22*CHS_sim + 0.18*CLS_sim + 0.16*CDS_sim + 0.18*RCS_sim + 0.12*ECS_sim + 0.14*DCS_sim`

`delta_AIS_sim = AIS_sim - AIS_base`

## 4.3 Delta de drift simulado

`drift_sim_k = drift_accum_k + drift_expected_change - drift_remediation_expected`

`drift_consumption_ratio_sim = drift_sim_k / drift_budget_k`

## 4.4 Delta de risco preditivo

`risk_probability_sim = calibrate(sigmoid(alpha*base_risk_score_sim + beta*volatility + gamma*criticality))`

`delta_risk = risk_probability_sim - risk_probability_base`

---

## 5) Simulações obrigatórias por tipo

## 5.1 Redução de acoplamento

Avaliar:

- queda de `global_coupling` e `critical_dependency_density`;
- aumento de fronteiras contratuais explícitas;
- risco de duplicação temporária de fluxo.

Critério mínimo de aceite simulado:

- `delta_AIS_sim >= +2` **ou** `delta_CLS >= +5` sem queda de `RCS > 3`.

## 5.2 Extração de módulo

Avaliar:

- ganho de coesão local (`CHS`);
- criação de novos contratos;
- risco de regressão por mudanças de integração.

Critério mínimo:

- `CHS_sim >= 70` na SU afetada;
- `CDS_sim` não entra em faixa crítica.

## 5.3 Introdução de novo sistema

Avaliar:

- incremento de arestas críticas;
- necessidade de observabilidade mínima;
- impacto em cadeia de deploy e rollback.

Critério mínimo:

- `risk_probability_sim < 0.60` no go-live inicial;
- `drift_consumption_ratio_sim <= 0.85`.

## 5.4 Migração de persistência

Avaliar:

- risco de inconsistência de dados;
- janela dual-write/dual-read;
- reversibilidade operacional.

Critério mínimo:

- `RCS_sim >= 60`;
- plano de rollback reduz `delta_risk` para classe <= Moderado.

## 5.5 Alteração de protocolo

Avaliar:

- compatibilidade backward;
- divergência client/server;
- propagação de quebra por opcode/payload.

Critério mínimo:

- `CDS_sim >= 55` e `risk_divergence_cs_sim < 0.35`;
- cenário de fallback validado.

---

## 6) Saídas do simulador (artefato)

Gerar `structural_simulation_report.json` com:

- `scenario_id`, `change_type`, `owner`, `timestamp`;
- `baseline_metrics` e `simulated_metrics`;
- `delta_AIS_sim`, `delta_drift_sim`, `delta_risk`;
- `confidence_interval` da predição;
- `recommended_action` (seguir, fatiar, mitigar, bloquear);
- `required_controls` (testes de contrato, rollout gradual, freeze parcial).

---

## 7) Regra operacional

**Nenhuma mudança estrutural crítica deve entrar em execução real sem simulação aprovada** pelo motor de decisão e pela camada de governança.
