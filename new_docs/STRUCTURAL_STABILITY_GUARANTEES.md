# STRUCTURAL STABILITY GUARANTEES
Status operacional: TARGET_STATE
Nota: Garantias são normativas e dependem de automação ainda não comprovada.

## 1) Objetivo

Formalizar garantias estruturais não negociáveis do projeto e os gatilhos automáticos de bloqueio para impedir degradação arquitetural em produção.

---

## 2) Garantias mandatórias

## G1 — Nunca quebrar sincronização client/server

**Regra:** alterações em protocolo/opcode/payload devem manter contrato compatível e validado.

**Evidências obrigatórias:**

- contrato versionado;
- validação automatizada client/server;
- teste de compatibilidade backward quando aplicável.

**Bloqueio automático (quando implementado) se:**

- mudança de protocolo sem atualização de contrato;
- falha em testes de contrato C/S;
- divergência detectada em execução paralela de migração.

---

## G2 — Nunca introduzir persistência sem migração formal

**Regra:** qualquer mudança de schema/estado persistente deve incluir plano de migração versionado e rollback.

**Evidências obrigatórias:**

- script de migração identificado;
- estratégia de rollback;
- validação de integridade de dados.

**Bloqueio automático (quando implementado) se:**

- alteração persistente sem artefato de migração;
- migração sem validação de consistência;
- ausência de owner e janela de execução.

---

## G3 — Nunca criar opcode sem contrato validado

**Regra:** opcode novo só entra com especificação formal de request/response, erros e versão.

**Evidências obrigatórias:**

- contrato de opcode;
- teste de serialização/desserialização;
- teste de interoperabilidade client/server.

**Bloqueio automático (quando implementado) se:**

- opcode detectado sem contrato;
- contrato sem testes mínimos;
- alteração breaking sem versionamento.

---

## G4 — Nunca aumentar acoplamento crítico acima do limite

**Regra:** densidade de dependência crítica deve permanecer abaixo do limite operacional.

**Limites:**

- alerta: `critical_dependency_density > 0.12`
- crítico: `> 0.18`

**Bloqueio automático (quando implementado) se:**

- projeção pós-merge excede limite crítico;
- aumento consecutivo por 3 releases em arestas críticas sem plano de redução.

---

## G5 — Nunca permitir drift acima do budget

**Regra:** drift acumulado em janela `k` releases não pode ultrapassar budget aprovado.

**Limites:**

- alerta: `> 70% do budget`
- crítico: `> 100% do budget`

**Bloqueio automático (quando implementado) se:**

- `drift_accum_k > drift_budget_k`;
- existência de violações estruturais sem plano de remediação com prazo.

---

## 3) Matriz de gatilhos automáticos

| Trigger | Fonte | Ação automática |
|---|---|---|
| Falha de contrato client/server | CI de protocolo | Bloquear merge/release |
| Mudança persistente sem migração | Static + checklist gate | Bloquear merge |
| Opcode sem contrato | Linter de protocolo | Bloquear merge |
| Densidade crítica acima do limite | Dependency analyzer | Bloquear promoção de release |
| Drift acima do budget | Drift monitor | Bloquear release + exigir plano de redução |
| Exceção arquitetural expirada | Registry de exceções | Bloquear merge até regularização |

---

## 4) Política de exceções (waiver)

Exceções só podem existir quando:

- risco residual é explicitamente aceito por owner;
- há prazo de expiração (obrigatório);
- existe plano de saída mensurável.

Regras duras:

- exceção não suspende garantias G1–G3 em produção;
- exceção vencida deve bloquear por processo humano; bloqueio automático depende de implementação;
- reincidência exige revisão de arquitetura por ADR.

---

## 5) Integração com AIS e operação autônoma

As garantias alimentam diretamente as métricas:

- G1/G3 impactam CDS e RCS;
- G2 impacta RCS e DCS;
- G4 impacta CLS/CDS;
- G5 impacta DCS e AIS global.

### Condição de operação autônoma contínua

O sistema é considerado apto para operação autônoma de longo prazo quando, por no mínimo 5 releases consecutivas:

- `AIS >= 80`;
- nenhuma garantia G1–G5 violada;
- drift dentro do budget;
- sem exceções expiradas;
- tendência de risco estrutural estável ou descendente.
