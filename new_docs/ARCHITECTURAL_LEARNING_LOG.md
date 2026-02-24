# ARCHITECTURAL LEARNING LOG

## 1) Objetivo

Instituir uma memória arquitetural contínua para aprender com cada evolução e melhorar progressivamente a capacidade de prever risco e impacto estrutural.

---

## 2) Unidade de aprendizado

Cada mudança aprovada gera um `learning_event` contendo:

- `change_id` e tipo de intervenção;
- motivo da evolução;
- métricas antes/depois;
- previsão vs. resultado real;
- erro de predição e ajuste aplicado.

---

## 3) Schema mínimo do registro

```yaml
learning_event:
  id: string
  timestamp: datetime
  owner: string
  change_type: [coupling_reduction, module_extraction, new_system, persistence_migration, protocol_change]
  reason:
    hotspot: string
    business_driver: string
    governance_trigger: string
  baseline:
    AIS: number
    CHS: number
    CLS: number
    CDS: number
    RCS: number
    ECS: number
    DCS: number
    drift_ratio: number
    risk_probability: number
  predicted:
    delta_AIS: number
    delta_drift_ratio: number
    delta_risk: number
    expected_outcome: string
  observed:
    delta_AIS: number
    delta_drift_ratio: number
    delta_risk: number
    incidents: number
    contract_breaks: number
  prediction_error:
    ais_error: number
    drift_error: number
    risk_error: number
  model_adjustment:
    parameter_changes: string
    threshold_changes: string
    confidence_update: string
  status: [success, partial, failed]
```

---

## 4) Processo de aprendizado

1. **Capturar** baseline e previsão na aprovação da evolução.
2. **Medir** resultado real em `t` e `t+1`.
3. **Comparar** previsto vs observado.
4. **Calcular** erro por dimensão (`AIS`, `drift`, `risk`).
5. **Ajustar** pesos, thresholds e regras do modelo.
6. **Persistir** decisão de ajuste com rastreabilidade.

---

## 5) Regras de melhoria contínua

- falso negativo crítico => revisão prioritária do modelo;
- erro absoluto médio acima do limite por 2 ciclos => recalibração obrigatória;
- ganhos de precisão sustentados por 3 ciclos => aumento gradual de confiança;
- mudança sem dados de observação completos não fecha ciclo de aprendizado.

---

## 6) Indicadores do aprendizado

- `prediction_accuracy` por classe de risco;
- `mean_absolute_error` de `delta_AIS`;
- `drift_prediction_error` médio;
- taxa de acerto em decisões (`manter`, `melhorar`, etc.);
- redução de incidentes por intervenção similar.

---

## 7) Integração com governança

- toda evolução relevante deve anexar `learning_event_id` no ADR;
- decisões futuras devem consultar eventos similares mais recentes;
- ajustes de modelo entram sob versionamento (`model_vN`);
- trilha de auditoria deve explicar por que o modelo mudou.
