# OPERATIONAL_STATE_DECLARATION

Objetivo: declarar o estado operacional real dos mecanismos descritos em `new_docs`, sem estados implícitos.

Estados permitidos:
- `ACTIVE_IMPLEMENTED`: implementação ativa com evidência concreta no repositório.
- `MANUAL_ONLY`: executável apenas por processo humano (sem enforcement automático).
- `PARTIALLY_IMPLEMENTED`: implementação parcial, não bloqueante.
- `TARGET_STATE`: conceitual/futuro, não operacional no estado atual.


## 0) Bootstrap operacional obrigatório (memória persistente)

- Leitura obrigatória antes de qualquer ação: `OPERATIONAL_STATE_DECLARATION.md`, `UI_CANONICAL_RULES.md` e `CHANGE_GATE_CHECKLIST.md` (quando existir).
- Estado operacional deve ser confirmado explicitamente antes de mudanças.
- Protocolo ANTI-BUG ativo: qualquer erro corrigido/diagnosticado/identificado deve ser registrado em `new_docs/ANTI_BUGS_MEMORY.md`.
- Antes de nova correção, consultar `ANTI_BUGS_MEMORY.md` e aplicar regra preventiva já derivada, se existir entrada correspondente.

## 1) ACTIVE_IMPLEMENTED

1. **Superfícies de código mapeadas existem no repositório**
   - Estado: `ACTIVE_IMPLEMENTED`
   - Evidência objetiva:
     - `crystalserver/src/server/network/protocol/protocolgame.cpp`
     - `otclient/src/client/protocolgameparse.cpp`
     - `otclient/src/client/protocolgamesend.cpp`
     - `crystalserver/data/migrations/` (scripts `.lua` versionados)
     - `new_docs/server/FILE_MANIFEST.md`, `new_docs/client/FILE_MANIFEST.md`, `new_docs/network/NETWORK_SURFACE_MAP.md`, `new_docs/database/DATABASE_SURFACE_MAP.md`

2. **Templates e artefatos base de governança estão presentes e utilizáveis**
   - Estado: `ACTIVE_IMPLEMENTED`
   - Evidência objetiva:
     - `new_docs/FEATURE_PROPOSAL_TEMPLATE.md`
     - `new_docs/ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md`
     - `new_docs/CHANGE_GATE_CHECKLIST.md`

## 2) MANUAL_ONLY

1. Execução do `CHANGE_GATE_CHECKLIST.md` como gate pré-merge.
2. Uso de `FEATURE_PROPOSAL_TEMPLATE.md` no pré-código.
3. Uso de `ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md` para ADR.
4. Análise de impacto por `CHANGE_IMPACT_PROTOCOL.md`.
5. Validação de invariantes por leitura de `SYSTEM_INVARIANTS.md`.
6. Classificação de risco por `PROJECT_RISK_SURFACE.md`.
7. Avaliação de acoplamento por `COHESION_AND_COUPLING_ANALYSIS.md`.
8. Aplicação de `AI_DECISION_MODEL.md` como heurística humana.
9. Aplicação de `AUTONOMOUS_DEVELOPMENT_PROTOCOL.md` como sequência de trabalho humana.
10. Revisões de coerência por `AUDIT_*` documentos.

## 3) PARTIALLY_IMPLEMENTED

1. **Camada de governança operacional** (`OPERATIONAL_GOVERNANCE_LAYER.md`)
   - Parcial: fluxo e critérios existem, mas enforcement automático não comprovado no repositório.

2. **Invariantes de sistema** (`SYSTEM_INVARIANTS.md`)
   - Parcial: invariantes mapeiam superfícies reais, porém validação automática integral não comprovada.

3. **Matriz/classificação de estado** (`STATE_CLASSIFICATION_MATRIX.md`)
   - Parcial: classifica corretamente parte relevante, mas coexistia com documentos que ainda declaravam enforcement ativo.

4. **Trilha mínima de governança** (`MINIMAL_OPERATIONAL_GOVERNANCE.md`, `METRIC_REALISM_REDUCTION.md`, `IMPLEMENTATION_ALIGNMENT_ROADMAP.md`)
   - Parcial: define caminho executável, porém depende de scripts/jobs ainda não comprovados.

## 4) TARGET_STATE

1. `ARCHITECTURAL_INTEGRITY_SCORE.md` (AIS completo automatizado).
2. `SYSTEM_HEALTH_DASHBOARD_SPEC.md` (dashboard com ingestão/alertas automáticos).
3. `PREDICTIVE_STRUCTURAL_RISK_MODEL.md` (modelo preditivo treinado/operacional).
4. `STRUCTURAL_SIMULATION_MODEL.md` (simulação estrutural pré-merge operacional).
5. `ADAPTIVE_STABILITY_CONTROL.md` (recalibração adaptativa automática).
6. `STRUCTURAL_STABILITY_GUARANTEES.md` (garantias com bloqueio automático integral).
7. `AUTOMATED_STRUCTURAL_CHECKS_SPEC.md` (catálogo completo de checks automáticos ativos).
8. `SELF_IMPROVING_ARCHITECTURE_LOOP.md` (ciclo fechado autônomo).
9. `CONTROLLED_EVOLUTION_FRAMEWORK.md` (framework dependente de telemetria/automação ausentes).
10. `EVOLUTION_DECISION_ENGINE.md` (engine decisório operacional).
11. `MULTI_AI_COORDINATION_PROTOCOL.md` (coordenação multi-IA com locking operacional).
12. `SELF_VALIDATION_SYSTEM.md` (auto-validação ponta-a-ponta automatizada).
13. `FUTURE_AI_EXTENSION_GUIDE.md` (orientação explicitamente futura).

## 5) Resolução de sobreposição (frameworks/engines/loops)

### Primário
- `AI_DECISION_MODEL.md` — referência principal de decisão humana no estado atual (`MANUAL_ONLY`).

### Auxiliares
- `OPERATIONAL_GOVERNANCE_LAYER.md` — orquestração documental do fluxo manual/parcial.
- `MINIMAL_OPERATIONAL_GOVERNANCE.md` — baseline mínimo para execução prática.

### Redundantes (marcados como `deprecated_documental`)
- `EVOLUTION_DECISION_ENGINE.md`
- `CONTROLLED_EVOLUTION_FRAMEWORK.md`
- `SELF_IMPROVING_ARCHITECTURE_LOOP.md`

Esses três permanecem apenas como referência teórica (`TARGET_STATE`) e não devem ser tratados como controle ativo.


## 6) Matriz completa por documento (sincronização total)
| Documento | Estado declarado |
|---|---|
| `ADAPTIVE_STABILITY_CONTROL.md` | `TARGET_STATE` |
| `AI_DECISION_MODEL.md` | `MANUAL_ONLY` |
| `ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md` | `ACTIVE_IMPLEMENTED` |
| `ARCHITECTURAL_INTEGRITY_SCORE.md` | `TARGET_STATE` |
| `ARCHITECTURAL_LAWS.md` | `MANUAL_ONLY` |
| `ARCHITECTURAL_LEARNING_LOG.md` | `TARGET_STATE` |
| `ARCHITECTURE_DRIFT_PREVENTION.md` | `PARTIALLY_IMPLEMENTED` |
| `AUDIT_COMPLEXITY_AND_PRAGMATISM.md` | `ACTIVE_IMPLEMENTED` |
| `AUDIT_CORRECTIONS_AND_IMPROVEMENTS.md` | `ACTIVE_IMPLEMENTED` |
| `AUDIT_CROSS_DOCUMENT_CONSISTENCY.md` | `ACTIVE_IMPLEMENTED` |
| `AUDIT_EXECUTION_FEASIBILITY.md` | `ACTIVE_IMPLEMENTED` |
| `AUDIT_FACTUAL_VALIDATION.md` | `ACTIVE_IMPLEMENTED` |
| `AUDIT_INDEPENDENT_TECHNICAL_VERDICT.md` | `ACTIVE_IMPLEMENTED` |
| `AUTOMATED_STRUCTURAL_CHECKS_SPEC.md` | `TARGET_STATE` |
| `AUTONOMOUS_DEVELOPMENT_PROTOCOL.md` | `MANUAL_ONLY` |
| `CHANGE_GATE_CHECKLIST.md` | `ACTIVE_IMPLEMENTED` |
| `CHANGE_IMPACT_PROTOCOL.md` | `MANUAL_ONLY` |
| `COHESION_AND_COUPLING_ANALYSIS.md` | `MANUAL_ONLY` |
| `CONTROLLED_EVOLUTION_FRAMEWORK.md` | `TARGET_STATE` |
| `EVOLUTION_DECISION_ENGINE.md` | `TARGET_STATE` |
| `FEATURE_PROPOSAL_TEMPLATE.md` | `ACTIVE_IMPLEMENTED` |
| `FUTURE_AI_EXTENSION_GUIDE.md` | `TARGET_STATE` |
| `GLOBAL_DEPENDENCY_MATRIX.md` | `PARTIALLY_IMPLEMENTED` |
| `IMPLEMENTATION_ALIGNMENT_ROADMAP.md` | `PARTIALLY_IMPLEMENTED` |
| `METRIC_REALISM_REDUCTION.md` | `PARTIALLY_IMPLEMENTED` |
| `MINIMAL_OPERATIONAL_GOVERNANCE.md` | `PARTIALLY_IMPLEMENTED` |
| `MULTI_AI_COORDINATION_PROTOCOL.md` | `TARGET_STATE` |
| `OPERATIONAL_GOVERNANCE_LAYER.md` | `PARTIALLY_IMPLEMENTED` |
| `PREDICTIVE_STRUCTURAL_RISK_MODEL.md` | `TARGET_STATE` |
| `PROJECT_FULL_MAP.md` | `ACTIVE_IMPLEMENTED` |
| `PROJECT_MENTAL_MODEL.md` | `MANUAL_ONLY` |
| `PROJECT_RISK_SURFACE.md` | `MANUAL_ONLY` |
| `PROJECT_SELF_AUDIT.md` | `MANUAL_ONLY` |
| `PROPORTIONAL_GOVERNANCE_REFACTOR.md` | `PARTIALLY_IMPLEMENTED` |
| `SELF_IMPROVING_ARCHITECTURE_LOOP.md` | `TARGET_STATE` |
| `SELF_VALIDATION_SYSTEM.md` | `TARGET_STATE` |
| `STATE_CLASSIFICATION_MATRIX.md` | `PARTIALLY_IMPLEMENTED` |
| `STRUCTURAL_SIMULATION_MODEL.md` | `TARGET_STATE` |
| `STRUCTURAL_STABILITY_GUARANTEES.md` | `TARGET_STATE` |
| `SYSTEM_HEALTH_DASHBOARD_SPEC.md` | `TARGET_STATE` |
| `SYSTEM_INVARIANTS.md` | `PARTIALLY_IMPLEMENTED` |
| `UI_CANONICAL_RULES.md` | `MANUAL_ONLY` |
| `client/FILE_MANIFEST.md` | `ACTIVE_IMPLEMENTED` |
| `database/DATABASE_SURFACE_MAP.md` | `ACTIVE_IMPLEMENTED` |
| `network/NETWORK_SURFACE_MAP.md` | `ACTIVE_IMPLEMENTED` |
| `server/FILE_MANIFEST.md` | `ACTIVE_IMPLEMENTED` |
| `systems/DEPENDENCY_GRAPH.md` | `PARTIALLY_IMPLEMENTED` |
