# FEATURE_PROPOSAL_TEMPLATE

> Uso obrigatório para qualquer nova feature, mudança de comportamento ou alteração de contrato.

## 1) Identificação
- **Título da proposta:**
- **Autor:**
- **Data:**
- **Tipo:** (feature / correção / refactor / arquitetura)
- **Escopo:** (server / client / database / network / cross)

## 2) Problema e objetivo
- **Problema atual:**
- **Objetivo de negócio/técnico:**
- **Resultado esperado mensurável:**

## 3) Superfícies afetadas
Mapear explicitamente usando:
- `new_docs/PROJECT_FULL_MAP.md`
- `new_docs/client/FILE_MANIFEST.md`
- `new_docs/server/FILE_MANIFEST.md`
- `new_docs/network/NETWORK_SURFACE_MAP.md`
- `new_docs/database/DATABASE_SURFACE_MAP.md`

Preencha:
- **Arquivos/módulos afetados:**
- **Fronteiras cruzadas (client/server/db/network):**
- **Dependências diretas e indiretas (GLOBAL_DEPENDENCY_MATRIX):**

## 4) Invariantes impactados
Referenciar `new_docs/SYSTEM_INVARIANTS.md`.

| Invariante | Impactado? (S/N) | Como será preservado? | Evidência planejada |
|---|---|---|---|
| INV-01 |  |  |  |
| INV-02 |  |  |  |
| INV-03 |  |  |  |
| INV-04 |  |  |  |
| INV-05 |  |  |  |
| INV-06 |  |  |  |
| INV-07 |  |  |  |
| INV-08 |  |  |  |

## 5) Avaliação de risco
Referenciar `new_docs/PROJECT_RISK_SURFACE.md` e `new_docs/CHANGE_IMPACT_PROTOCOL.md`.

- **Nível de risco inicial:** (baixo / médio / alto / crítico)
- **Falhas prováveis:**
- **Mitigações técnicas:**
- **Plano de rollback:**

## 6) Acoplamento e coesão
Referenciar `new_docs/COHESION_AND_COUPLING_ANALYSIS.md`.

- **Acoplamento atual:**
- **Acoplamento após mudança:**
- **Razão do acoplamento adicional (se houver):**
- **Estratégia para reduzir acoplamento no próximo ciclo:**

## 7) Validação client/server
Obrigatório para qualquer mudança em protocolo ou semântica de estado.

- **Contrato alterado?** (S/N)
- **Mudanças server parse/send:**
- **Mudanças client parse/send:**
- **Feature-gate/versionamento aplicado:**
- **Estratégia de compatibilidade retroativa:**

## 8) Plano de testes e checks estruturais
Referenciar `new_docs/AUTOMATED_STRUCTURAL_CHECKS_SPEC.md`.

- **Checks obrigatórios aplicáveis:**
- **Testes automatizados planejados:**
- **Testes manuais críticos:**
- **Critério de aprovação:**

## 9) Decisão arquitetural (ADR)
- **ADR necessária?** (S/N)
- Se sim: criar documento com `ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md`.
- Se não: justificar formalmente por que a mudança não altera arquitetura/contrato.

## 10) Aprovação para implementação
- **Aprovador técnico:**
- **Status:** (aprovado / bloqueado / aprovado com ressalvas)
- **Condições obrigatórias para merge:**
