# ADAPTIVE STABILITY CONTROL

## 1) Objetivo

Definir um controle adaptativo que recalibra automaticamente limites de estabilidade conforme maturidade do projeto e histórico real de confiabilidade estrutural.

Parâmetros adaptáveis:

- `drift_budget_k`
- `acceptable_risk_threshold`
- `coupling_limit`
- `exception_tolerance`

---

## 2) Sinais de adaptação

- tendência de AIS (`AIS_slope_k`);
- variância de AIS e componentes (`AIS_volatility_k`);
- taxa de incidentes com causa arquitetural;
- taxa de erro do modelo preditivo (falso positivo/falso negativo);
- reincidência de exceções expiradas;
- estabilidade de releases consecutivas.

---

## 3) Índice de maturidade estrutural (SMI)

`SMI = m1*stability_streak + m2*low_incident_ratio + m3*predictive_accuracy + m4*governance_compliance - m5*volatility`

Faixas:

- `SMI < 40`: imaturo
- `40 <= SMI < 70`: em consolidação
- `SMI >= 70`: maduro

---

## 4) Regras adaptativas

## 4.1 Drift budget adaptativo

- imaturo: `drift_budget_k = baseline * 0.75`
- consolidação: `drift_budget_k = baseline * 1.00`
- maduro: `drift_budget_k = baseline * 1.10` (somente se risco estável)

## 4.2 Risco aceitável

- imaturo: `acceptable_risk_threshold = 0.45`
- consolidação: `0.55`
- maduro: `0.60` (com mitigação automática para picos)

## 4.3 Limite de acoplamento

- imaturo: `coupling_limit` mais rígido (ex.: `global_coupling <= 0.28`)
- consolidação: `<= 0.32`
- maduro: `<= 0.35` apenas se `CDS` e `RCS` permanecerem saudáveis

## 4.4 Tolerância de exceções

- imaturo: zero exceção expirada; baixa tolerância de novas exceções
- consolidação: tolerância moderada com SLA curto
- maduro: tolerância seletiva com rastreabilidade estrita

---

## 5) Mecanismo de recalibração automática

Executado a cada release:

1. calcular `SMI`;
2. detectar regime de maturidade;
3. ajustar parâmetros (budget/thresholds);
4. publicar `adaptive_stability_profile`;
5. validar se ajustes não reduzem garantias G1–G5;
6. ativar travas se houver regressão inesperada.

Regra de segurança:

- qualquer recalibração que resulte em aumento simultâneo de `acceptable_risk_threshold` e `drift_budget_k` exige revisão adicional do motor de decisão.

---

## 6) Estratégia anti-oscilação

Para evitar ajustes erráticos:

- usar janela mínima de 3 releases para mudança de regime;
- aplicar `max_step_change` por parâmetro (ex.: ±10% por ciclo);
- exigir confirmação em 2 ciclos para relaxamentos de limite;
- permitir tightening imediato em caso de incidente crítico.

---

## 7) Saídas operacionais

Gerar `adaptive_stability_report.json`:

- regime atual (`imaturo/consolidação/maduro`);
- parâmetros anteriores vs. novos;
- justificativa quantitativa;
- impactos esperados em AIS/risco/drift;
- alertas de segurança e ações corretivas.
