# EVOLUTION DECISION ENGINE
Status operacional: TARGET_STATE | deprecated_documental
Nota: Documento redundante no estado atual, mantido só como referência teórica.

## 1) Objetivo

Definir um mecanismo formal de decisão arquitetural que transforma métricas, tendência, risco e custo estrutural em ação governada.

Decisões possíveis:

- `MANTER`
- `MELHORAR`
- `REFATORAR`
- `MODULARIZAR`
- `BLOQUEAR`

---

## 2) Entradas obrigatórias

- `AIS_base` e componentes (`CHS`, `CLS`, `CDS`, `RCS`, `ECS`, `DCS`);
- tendência de `AIS` e componentes (janela k releases);
- `drift_consumption_ratio`;
- `risk_probability` e `risk_class` por SU;
- `structural_simulation_report` (delta previsto);
- `structural_cost_index` (esforço + blast radius + complexidade de reversão);
- garantias estruturais G1–G5 (violada / íntegra).

---

## 3) Índices de decisão

## 3.1 Índice de pressão evolutiva (EPI)

`EPI = w1*degradation_trend + w2*risk_pressure + w3*drift_pressure + w4*hotspot_recurrence`

Interpretação: quão urgente é evoluir para evitar degradação.

## 3.2 Índice de viabilidade estrutural (SVI)

`SVI = v1*delta_AIS_sim + v2*risk_reduction_sim + v3*governance_readiness - v4*execution_complexity`

Interpretação: quão viável é executar a mudança com segurança.

## 3.3 Índice de custo estrutural (SCI)

`SCI = c1*change_surface + c2*critical_dependencies_touched + c3*rollback_difficulty + c4*operational_load`

Interpretação: custo sistêmico da intervenção.

---

## 4) Algoritmo conceitual

```text
INPUT: metrics_base, trends, risk, simulation, governance, cost

IF any structural guarantee violated (G1..G5) AND no approved mitigation:
    DECISION = BLOQUEAR
    EXIT

Compute EPI, SVI, SCI

IF risk_class == CRITICO AND SVI < threshold_min:
    DECISION = BLOQUEAR
ELSE IF EPI < low AND AIS_base >= 80 AND trends stable:
    DECISION = MANTER
ELSE IF EPI in medium range AND SVI positive AND SCI low:
    DECISION = MELHORAR
ELSE IF EPI high AND coupling hotspot concentrated:
    DECISION = MODULARIZAR
ELSE IF EPI high AND legacy complexity dominates:
    DECISION = REFATORAR
ELSE:
    DECISION = MELHORAR (incremental slices + guardrails)

Attach governance controls and acceptance gates
OUTPUT decision package
```

---

## 5) Matriz de decisão operacional

- **MANTER**
  - condição: estabilidade alta, risco baixo, tendência saudável;
  - ação: preservar baseline, monitorar contínuo.

- **MELHORAR**
  - condição: risco moderado e ganho incremental previsível;
  - ação: micro-ajustes com baixo custo estrutural.

- **REFATORAR**
  - condição: dívida técnica concentrada sem fronteira clara de módulo;
  - ação: reorganizar internamente mantendo contratos externos.

- **MODULARIZAR**
  - condição: acoplamento transversal e hotspots recorrentes;
  - ação: separar fronteiras, contratos explícitos, ownership.

- **BLOQUEAR**
  - condição: risco crítico sem mitigação, quebra de garantia, ou simulação negativa grave;
  - ação: impedir merge/release, abrir plano corretivo obrigatório.

---

## 6) Guardrails de decisão

- Nunca autorizar mudança com `delta_AIS_sim < -5` sem exceção formal.
- Nunca autorizar quando `drift_consumption_ratio_sim > 1.0`.
- Nunca autorizar risco `Crítico` sem mitigação com owner e prazo.
- Sempre degradar para execução em fatias quando `SCI` for alto.

---

## 7) Artefato de saída

Gerar `evolution_decision_record.json`:

- `decision`;
- `rationale` (EPI, SVI, SCI);
- `required_governance_controls`;
- `acceptance_criteria`;
- `rollback_strategy`;
- `review_window` (t, t+1).
