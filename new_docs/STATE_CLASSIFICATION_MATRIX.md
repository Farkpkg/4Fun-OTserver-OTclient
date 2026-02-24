# STATE_CLASSIFICATION_MATRIX

Classificação aplicada: 
- **CURRENT_STATE** = aderente ao código/estrutura atual e utilizável hoje sem nova instrumentação.
- **PARTIALLY_IMPLEMENTED** = parte útil hoje, parte depende de automação/instrumentação ausente.
- **TARGET_STATE** = visão futura; não executável no estado atual.

| Documento | Estado | Justificativa objetiva |
|---|---|---|
| ADAPTIVE_STABILITY_CONTROL.md | TARGET_STATE | Recalibração automática de budget/risco não implementada. |
| AI_DECISION_MODEL.md | PARTIALLY_IMPLEMENTED | Útil como guia humano; não há engine determinístico automatizado. |
| ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md | CURRENT_STATE | Template utilizável imediatamente em PR/ADR manual. |
| ARCHITECTURAL_INTEGRITY_SCORE.md | TARGET_STATE | Fórmula AIS não está instrumentada em pipeline ativo. |
| ARCHITECTURAL_LAWS.md | PARTIALLY_IMPLEMENTED | Regras úteis, sem enforcement técnico completo. |
| ARCHITECTURAL_LEARNING_LOG.md | TARGET_STATE | Loop de aprendizado/predição não está operacionalizado. |
| ARCHITECTURE_DRIFT_PREVENTION.md | PARTIALLY_IMPLEMENTED | Diretrizes válidas; prevenção ativa automática ausente. |
| AUDIT_COMPLEXITY_AND_PRAGMATISM.md | CURRENT_STATE | Diagnóstico factual baseado no estado atual. |
| AUDIT_CORRECTIONS_AND_IMPROVEMENTS.md | CURRENT_STATE | Plano corretivo aplicável ao estado atual. |
| AUDIT_CROSS_DOCUMENT_CONSISTENCY.md | CURRENT_STATE | Auditoria de consistência já executável/documental. |
| AUDIT_EXECUTION_FEASIBILITY.md | CURRENT_STATE | Avaliação objetiva de exequibilidade atual. |
| AUDIT_FACTUAL_VALIDATION.md | CURRENT_STATE | Validação factual já ancorada em código/filesystem. |
| AUTOMATED_STRUCTURAL_CHECKS_SPEC.md | TARGET_STATE | Checks descritos, mas sem conjunto implementado completo. |
| AUTONOMOUS_DEVELOPMENT_PROTOCOL.md | TARGET_STATE | Operação autônoma multiagente não implantada. |
| CHANGE_GATE_CHECKLIST.md | CURRENT_STATE | Gate manual executável hoje em revisão de PR. |
| CHANGE_IMPACT_PROTOCOL.md | PARTIALLY_IMPLEMENTED | Processo manual possível; automação de impacto ausente. |
| COHESION_AND_COUPLING_ANALYSIS.md | PARTIALLY_IMPLEMENTED | Conceito válido; reprodução contínua dos números ainda incompleta. |
| CONTROLLED_EVOLUTION_FRAMEWORK.md | TARGET_STATE | Framework depende de métricas e gates automatizados ausentes. |
| EVOLUTION_DECISION_ENGINE.md | TARGET_STATE | Engine decisório não está implementado como sistema. |
| FEATURE_PROPOSAL_TEMPLATE.md | CURRENT_STATE | Template operacional imediato para propostas. |
| FUTURE_AI_EXTENSION_GUIDE.md | TARGET_STATE | Guia explicitamente orientado a expansão futura. |
| GLOBAL_DEPENDENCY_MATRIX.md | PARTIALLY_IMPLEMENTED | Base estrutural útil, mas sem pipeline contínuo de atualização. |
| MULTI_AI_COORDINATION_PROTOCOL.md | TARGET_STATE | Coordenação multi-IA com locks não implementada. |
| OPERATIONAL_GOVERNANCE_LAYER.md | PARTIALLY_IMPLEMENTED | Processo humano aplicável; camada operacional automatizada parcial. |
| PREDICTIVE_STRUCTURAL_RISK_MODEL.md | TARGET_STATE | Modelo preditivo não treinado/operacional no repositório. |
| PROJECT_FULL_MAP.md | CURRENT_STATE | Mapa de referência documental aplicável hoje. |
| PROJECT_MENTAL_MODEL.md | PARTIALLY_IMPLEMENTED | Modelo conceitual útil, não totalmente verificável automaticamente. |
| PROJECT_RISK_SURFACE.md | PARTIALLY_IMPLEMENTED | Identificação de superfícies existe; score operacional contínuo não. |
| PROJECT_SELF_AUDIT.md | PARTIALLY_IMPLEMENTED | Diagnóstico útil, porém parte das afirmações depende de roadmap. |
| SELF_IMPROVING_ARCHITECTURE_LOOP.md | TARGET_STATE | Loop automático de melhoria não implantado. |
| SELF_VALIDATION_SYSTEM.md | TARGET_STATE | Sistema de auto-validação não implementado ponta-a-ponta. |
| STRUCTURAL_SIMULATION_MODEL.md | TARGET_STATE | Simulação pré-merge não implementada em tooling. |
| STRUCTURAL_STABILITY_GUARANTEES.md | TARGET_STATE | Garantias dependem de enforcement técnico inexistente hoje. |
| SYSTEM_HEALTH_DASHBOARD_SPEC.md | TARGET_STATE | Dashboard especificado, sem implementação integrada encontrada. |
| SYSTEM_INVARIANTS.md | PARTIALLY_IMPLEMENTED | Invariantes úteis como política; validação automática ainda parcial. |
| client/FILE_MANIFEST.md | CURRENT_STATE | Inventário aderente ao filesystem atual. |
| database/DATABASE_SURFACE_MAP.md | CURRENT_STATE | Superfície DB listada e verificável hoje. |
| network/NETWORK_SURFACE_MAP.md | CURRENT_STATE | Superfície de protocolo listada e verificável hoje. |
| server/FILE_MANIFEST.md | CURRENT_STATE | Inventário aderente ao filesystem atual. |
| systems/DEPENDENCY_GRAPH.md | PARTIALLY_IMPLEMENTED | Documento útil, porém baseline numérica requer recalibração/reprodução. |

## Totais
- **CURRENT_STATE:** 14
- **PARTIALLY_IMPLEMENTED:** 13
- **TARGET_STATE:** 13

## Regra de uso imediato
1. Tudo em **CURRENT_STATE** pode ser usado como fonte normativa hoje.
2. Tudo em **PARTIALLY_IMPLEMENTED** deve ter marcação explícita do que é manual vs automático.
3. Tudo em **TARGET_STATE** não pode ser tratado como controle ativo.
