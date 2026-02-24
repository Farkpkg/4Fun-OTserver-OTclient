# CHANGE_GATE_CHECKLIST

> Gate obrigatório pré-merge. Sem checklist completa e evidenciada, o PR é bloqueado.

## Instrução de uso
- Preencher todos os itens com **SIM / NÃO / N/A**.
- Cada item deve apontar evidência (arquivo, diff, teste, commit, log de check).
- Itens marcados como **CRÍTICO** não aceitam “NÃO”.

---

## A) Impacto estrutural
1. [ ] Foi executada análise de impacto conforme `new_docs/CHANGE_IMPACT_PROTOCOL.md`. **(CRÍTICO)**
2. [ ] As áreas afetadas foram mapeadas com `new_docs/PROJECT_FULL_MAP.md`. **(CRÍTICO)**
3. [ ] Dependências diretas/indiretas foram avaliadas via `new_docs/GLOBAL_DEPENDENCY_MATRIX.md`.
4. [ ] Classe de impacto (crítica/moderada/fraca) foi declarada e justificada.

## B) Invariantes
5. [ ] `new_docs/SYSTEM_INVARIANTS.md` foi validado item a item. **(CRÍTICO)**
6. [ ] Qualquer invariante alterado possui plano formal de migração/versionamento. **(CRÍTICO)**
7. [ ] Não há introdução de segunda fonte de verdade de estado (server continua autoritativo). **(CRÍTICO)**

## C) Risco
8. [ ] Risco foi classificado usando `new_docs/PROJECT_RISK_SURFACE.md`. **(CRÍTICO)**
9. [ ] Existe plano de rollback executável.
10. [ ] Há estratégia de mitigação para os 3 principais riscos.

## D) Acoplamento e coesão
11. [ ] Avaliação realizada com `new_docs/COHESION_AND_COUPLING_ANALYSIS.md`.
12. [ ] Novo acoplamento foi explicitado e justificado.
13. [ ] Não houve violação de fronteiras arquiteturais sem ADR. **(CRÍTICO)**

## E) Validação client/server
14. [ ] Alterações de protocolo possuem simetria client/server comprovada. **(CRÍTICO)**
15. [ ] Feature-gate/versionamento foi aplicado quando necessário. **(CRÍTICO)**
16. [ ] Handshake/login/parse/send foram validados em cenário compatível.

## F) Persistência e dados
17. [ ] Mudança de schema possui migration explícita e testável. **(CRÍTICO)**
18. [ ] IO de carga/salvamento está compatível com novo schema. **(CRÍTICO)**
19. [ ] Não há risco de órfãos/inconsistência sem plano de remediação.

## G) Governança formal
20. [ ] Feature Proposal foi criada com `new_docs/FEATURE_PROPOSAL_TEMPLATE.md`. **(CRÍTICO)**
21. [ ] ADR foi registrada usando `new_docs/ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md` (ou não aplicável com justificativa formal). **(CRÍTICO)**
22. [ ] Exceções, se existirem, têm owner e data de expiração.

## H) Checks estruturais automatizados
23. [ ] Checks em `new_docs/AUTOMATED_STRUCTURAL_CHECKS_SPEC.md` foram executados. **(CRÍTICO)**
24. [ ] Nenhum check crítico falhou sem waiver formal. **(CRÍTICO)**
25. [ ] Resultado dos checks foi anexado ao PR.

## I) Anti-drift
26. [ ] Mudança avaliada contra `new_docs/ARCHITECTURE_DRIFT_PREVENTION.md`.
27. [ ] Drift Score foi registrado no PR.
28. [ ] Se houve desvio, existe ADR com prazo para convergência. **(CRÍTICO)**

---

## Critério de aprovação do gate
- **Aprovado:** todos os itens críticos = SIM; demais sem pendências materiais.
- **Bloqueado:** qualquer item crítico = NÃO ou sem evidência.
- **Aprovado com ressalva:** somente com exceção formal registrada em ADR.
