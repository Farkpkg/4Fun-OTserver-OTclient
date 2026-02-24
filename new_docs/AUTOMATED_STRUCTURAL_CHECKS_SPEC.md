# AUTOMATED_STRUCTURAL_CHECKS_SPEC
Status operacional: TARGET_STATE
Nota: Catálogo de checks alvo; sem conjunto completo comprovado como job bloqueante ativo.

## Objetivo
Especificar checks estruturais executáveis para impedir regressão de arquitetura, drift e quebra de contrato antes do merge.

> Mesmo quando um check é “conceitual”, ele deve ter critério binário de aprovação (`PASS/FAIL`) e evidência no PR.

---

## 1) Contrato operacional
Todos os PRs devem publicar bloco:
- `Structural Checks Summary`
- lista de checks executados
- status PASS/FAIL
- evidência (comando, log, arquivo alterado)

Sem esse bloco, o PR deve ser tratado como não elegível na revisão humana (até automação existir).

---

## 2) Catálogo de checks estruturais

### SC-01 — Invariant Coverage Check (CRÍTICO)
- **Base:** `new_docs/SYSTEM_INVARIANTS.md`
- **Regra:** cada invariante INV-01..INV-08 deve aparecer no PR com status `preservado/alterado`.
- **FAIL quando:** houver invariante sem status ou sem justificativa.

### SC-02 — Protocol Symmetry Check (CRÍTICO)
- **Base:** `new_docs/network/NETWORK_SURFACE_MAP.md`
- **Regra:** mudança em opcode/payload server exige mudança equivalente em parse/send client (ou feature-gate de backward compatibility).
- **FAIL quando:** alteração unilateral de protocolo.

### SC-03 — Persistence Evolution Check (CRÍTICO)
- **Base:** `new_docs/database/DATABASE_SURFACE_MAP.md` + `SYSTEM_INVARIANTS.md` (INV-04)
- **Regra:** mudança em dados persistidos exige migration + ajuste de leitura/escrita.
- **FAIL quando:** schema mudou sem migration; migration sem adaptação de IO; IO sem retrocompatibilidade.

### SC-04 — Bootstrap Order Integrity Check (CRÍTICO)
- **Base:** `SYSTEM_INVARIANTS.md` (INV-03)
- **Regra:** a cadeia de bootstrap do servidor deve permanecer topologicamente válida.
- **FAIL quando:** ordem ou pré-condição for quebrada sem ADR/migração.

### SC-05 — Coupling Delta Check
- **Base:** `COHESION_AND_COUPLING_ANALYSIS.md`
- **Regra:** todo novo acoplamento inter-módulo deve ser explicitado no PR.
- **FAIL quando:** fronteira nova aparece no diff sem justificativa arquitetural.

### SC-06 — Impact Chain Completeness Check (CRÍTICO)
- **Base:** `CHANGE_IMPACT_PROTOCOL.md` + `GLOBAL_DEPENDENCY_MATRIX.md`
- **Regra:** alterações de classe crítica exigem análise em cadeia (1º, 2º e 3º nível de impacto).
- **FAIL quando:** apenas impacto local foi considerado.

### SC-07 — Risk-to-Test Mapping Check
- **Base:** `PROJECT_RISK_SURFACE.md`
- **Regra:** riscos altos identificados devem ter teste/check correspondente.
- **FAIL quando:** risco alto sem validação associada.

### SC-08 — ADR Presence Check (CRÍTICO)
- **Base:** `ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md`
- **Regra:** mudança arquitetural/contratual exige ADR vinculada.
- **FAIL quando:** ausência de ADR ou justificativa formal.

### SC-09 — Drift Score Check (CRÍTICO)
- **Base:** `ARCHITECTURE_DRIFT_PREVENTION.md`
- **Regra:** PR deve informar Drift Score e comparação com budget vigente.
- **FAIL quando:** score ausente ou acima do budget sem plano aprovado.

### SC-10 — Governance Artifact Completeness Check (CRÍTICO)
- **Base:** este pacote de governança
- **Regra:** PR deve conter Proposal + Checklist + Structural Checks + ADR (quando aplicável).
- **FAIL quando:** qualquer artefato obrigatório estiver ausente.

---

## 3) Exemplo de execução (conceitual automatizável)

```bash
# Exemplo: valida presença de seções obrigatórias no corpo do PR
check_pr_section "Impact analysis"
check_pr_section "Invariant validation"
check_pr_section "Risk assessment"
check_pr_section "Coupling analysis"
check_pr_section "Client/server validation"
check_pr_section "Structural Checks Summary"
```

```bash
# Exemplo: valida mudança de protocolo com simetria bilateral
if changed "crystalserver/src/server/network/protocol" && !changed "otclient/src/client/protocol"; then
  fail "SC-02 FAIL: mudança de protocolo sem atualização no cliente"
fi
```

```bash
# Exemplo: valida mudança persistente com migração
if changed "crystalserver/schema.sql" && !changed "crystalserver/data/migrations"; then
  fail "SC-03 FAIL: schema alterado sem migration"
fi
```

---

## 4) Política de severidade
- **CRÍTICO:** deve bloquear merge na revisão humana; bloqueio automático é TARGET_STATE.
- **ALTO:** deve bloquear merge salvo exceção formal com ADR e prazo.
- **MÉDIO:** não bloqueia automaticamente no estado atual, mas exige issue de follow-up.

---

## 5) Mecanismo anti-drift ativo
1. Rodar SC-09 em todo PR.
2. Consolidar Drift Score por release.
3. Se budget exceder, ativar modo de contenção:
   - bloquear features novas;
   - priorizar PRs de redução de acoplamento;
   - revisar ADRs de exceção vencidas.

Isso operacionaliza `new_docs/ARCHITECTURE_DRIFT_PREVENTION.md` em regime contínuo.
