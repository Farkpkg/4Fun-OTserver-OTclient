# AUDIT_CROSS_DOCUMENT_CONSISTENCY

## 1) Contradições explícitas encontradas

1. **Estado “operacional” vs estado “especificação”**
   - Vários documentos tratam AIS, Drift, Predictive Risk e Gates como capacidades ativas.
   - Outros documentos (templates/specs) evidenciam natureza de desenho/planejamento.
   - Resultado: contradição de posicionamento (implementado vs proposto).

2. **Métricas reproduzíveis vs métricas sem pipeline**
   - `ARCHITECTURAL_INTEGRITY_SCORE.md`, `PREDICTIVE_STRUCTURAL_RISK_MODEL.md`, `STRUCTURAL_SIMULATION_MODEL.md`, `SYSTEM_HEALTH_DASHBOARD_SPEC.md` exigem coleta/cálculo contínuo.
   - `AUTOMATED_STRUCTURAL_CHECKS_SPEC.md` descreve checks, mas não há evidência de implementação correspondente.
   - Resultado: coerência teórica alta, coerência operacional baixa.

3. **Dependência quantitativa inconsistente**
   - `DEPENDENCY_GRAPH.md` contém números específicos não reproduzidos na auditoria atual.
   - Resultado: risco de baseline desatualizada ou metodologia não documentada.

---

## 2) Invariantes, guarantees e gates

- **Invariantes (SYSTEM_INVARIANTS)** aparecem em vários docs (checklist, protocolos, templates).
- **Garantias (STRUCTURAL_STABILITY_GUARANTEES)** dependem de monitoramento e bloqueio automatizado.
- **Gates (CHANGE_GATE_CHECKLIST / AUTOMATED_STRUCTURAL_CHECKS_SPEC)** existem no plano documental.
- **Lacuna cruzada**: não foi encontrado mecanismo executável no código que feche o ciclo invariantes -> métricas -> gate -> bloqueio.

**Conclusão:** não há contradição semântica forte entre fórmulas e thresholds; o problema central é **drift entre documentação de governança e implementação real**.

---

## 3) Protocolos duplicados/divergentes

- Existem múltiplos documentos de “motor de decisão” (AI_DECISION_MODEL, EVOLUTION_DECISION_ENGINE, AUTONOMOUS_DEVELOPMENT_PROTOCOL, SELF_IMPROVING_ARCHITECTURE_LOOP, OPERATIONAL_GOVERNANCE_LAYER).
- Eles são majoritariamente compatíveis em direção (preservar invariantes, minimizar acoplamento), porém há **sobreposição de responsabilidade** e terminologia (gate, loop, engine, governance) sem fonte de verdade única de execução.

---

## 4) Ações para remover inconsistência cruzada

1. Definir status único por documento: `CURRENT_STATE` vs `TARGET_STATE`.
2. Marcar explicitamente quais controles já rodam em CI e quais são roadmap.
3. Consolidar motores duplicados em 1 especificação canônica com anexos.
4. Versionar baseline de métricas com comando de reprodução obrigatório.
