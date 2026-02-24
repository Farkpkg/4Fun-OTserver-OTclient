# OPERATIONAL_GOVERNANCE_LAYER

## Propósito
Transformar a base de `new_docs/` em um **sistema operacional de governança** (não apenas referência), com fluxo obrigatório para qualquer mudança de código, schema, protocolo, script ou infraestrutura.

Este documento é o orquestrador oficial e integra:
- `new_docs/SYSTEM_INVARIANTS.md`
- `new_docs/CHANGE_IMPACT_PROTOCOL.md`
- `new_docs/PROJECT_RISK_SURFACE.md`
- `new_docs/COHESION_AND_COUPLING_ANALYSIS.md`
- `new_docs/GLOBAL_DEPENDENCY_MATRIX.md`
- `new_docs/ARCHITECTURE_DRIFT_PREVENTION.md`
- `new_docs/PROJECT_SELF_AUDIT.md`
- `new_docs/SELF_VALIDATION_SYSTEM.md`
- `new_docs/AI_DECISION_MODEL.md`

Além disso, usa como artefatos operacionais obrigatórios:
- `new_docs/CHANGE_GATE_CHECKLIST.md`
- `new_docs/AUTOMATED_STRUCTURAL_CHECKS_SPEC.md`
- `new_docs/FEATURE_PROPOSAL_TEMPLATE.md`
- `new_docs/ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md`

---

## Fluxo fechado de governança (obrigatório)

Nenhuma mudança deve pular etapas. O fluxo é linear e bloqueante no processo de revisão humana.

### Etapa 0 — Classificação de mudança
Classificar a alteração em uma das classes:
1. **Feature nova**
2. **Mudança arquitetural**
3. **Correção com impacto de contrato**
4. **Refactor interno sem mudança de contrato**
5. **Mudança de baixo risco (UI/docs/tooling)**

### Etapa 1 — Proposal (pré-código)
- Criar proposta usando `FEATURE_PROPOSAL_TEMPLATE.md`.
- Preencher escopo, superfícies afetadas, hipótese de risco e invariantes potencialmente impactados.
- Sem proposal aprovada, não iniciar implementação.

### Etapa 2 — Gate de alteração (pré-merge)
- Executar `CHANGE_GATE_CHECKLIST.md` integralmente.
- Marcar evidências (arquivo, diff, teste, commit).
- Qualquer item “NÃO” em controle crítico deve bloquear merge na revisão humana.

### Etapa 3 — Checks estruturais
- Rodar checks definidos em `AUTOMATED_STRUCTURAL_CHECKS_SPEC.md`.
- Checks críticos com status `FAIL` bloqueiam merge.
- Quando check não for automatizável no contexto, registrar justificativa formal + plano de automação.

### Etapa 4 — ADR obrigatório
- Toda decisão que altere contrato, fronteira de módulo, acoplamento, protocolo, persistência ou bootstrap deve gerar ADR.
- Usar `ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md`.
- Sem ADR (ou isenção formal), merge bloqueado.

### Etapa 5 — Protocolo de PR
PR deve conter blocos obrigatórios:
1. Impact analysis (com referência à matriz de dependência)
2. Invariant validation
3. Risk assessment
4. Coupling analysis
5. Client/server validation
6. ADR link ou justificativa de não aplicabilidade
7. Resultado dos checks estruturais

---

## Critérios de bloqueio (hard gates)
No estado atual (sem automação integral comprovada), o merge **deve ser barrado por revisão humana** se ocorrer qualquer condição abaixo:
1. Invariante crítico violado sem plano de migração/versionamento (`SYSTEM_INVARIANTS.md`).
2. Alteração de protocolo sem simetria client/server validada.
3. Alteração persistente sem trilha de migração + compatibilidade IO.
4. Alteração em zona crítica sem análise de impacto em cadeia.
5. Mudança arquitetural sem ADR.
6. Check estrutural crítico em `FAIL` sem waiver aprovado.

---

## Mecanismo anti-drift ativo

A prevenção de drift arquitetural deixa de ser informativa e passa a ser operacional:

1. **Drift Scan por PR**
   - Calcular Drift Score com base em:
     - quantidade de fronteiras afetadas;
     - mudanças em protocolo/persistência/bootstrap;
     - desvio do mapa estrutural (`PROJECT_FULL_MAP.md`, `GLOBAL_DEPENDENCY_MATRIX.md`).
2. **Drift Review semanal**
   - Revisar PRs da semana e consolidar desvios.
3. **Budget de drift**
   - Cada release tem limite de drift aceito.
   - Excedeu o budget -> congelamento de feature até pagamento de dívida estrutural.
4. **Registro formal**
   - Toda exceção de governança precisa de ADR com prazo de expiração.

---

## Política de exceção formal
Exceções só são válidas com:
- risco explicitado;
- janela temporal de validade;
- owner técnico responsável;
- plano de reversão;
- ADR vinculada.

Sem todos os itens, a exceção é inválida.

---

## Resultado esperado
Com este layer:
- Toda mudança passa por análise de impacto, invariantes, risco e acoplamento.
- Mudanças client/server só entram com validação bilateral.
- Decisões arquiteturais viram registros auditáveis.
- Drift deve ser tratado por medição manual/parcial até existir automação comprovada.
