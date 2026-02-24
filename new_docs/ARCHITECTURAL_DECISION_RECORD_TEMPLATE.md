# ARCHITECTURAL_DECISION_RECORD_TEMPLATE

> Formato obrigatório para qualquer decisão arquitetural relevante.

## ADR-XXXX — [Título curto]
- **Status:** Proposto | Aceito | Substituído | Revogado
- **Data:**
- **Autores:**
- **Feature/PR relacionado:**
- **Prazo de revisão:**

## 1) Contexto
Descrever contexto técnico real com referências objetivas:
- `new_docs/SYSTEM_INVARIANTS.md`
- `new_docs/GLOBAL_DEPENDENCY_MATRIX.md`
- `new_docs/PROJECT_RISK_SURFACE.md`
- `new_docs/ARCHITECTURE_DRIFT_PREVENTION.md`

Campos:
- Problema estrutural:
- Restrições (tempo, compatibilidade, performance, segurança):
- Alternativas descartadas previamente:

## 2) Decisão
Definir exatamente o que será adotado.
- Decisão final:
- Escopo da decisão:
- Fronteiras impactadas:
- Invariantes afetados/preservados:

## 3) Alternativas avaliadas
| Alternativa | Prós | Contras | Motivo de descarte/aceitação |
|---|---|---|---|
| A |  |  |  |
| B |  |  |  |
| C |  |  |  |

## 4) Impacto e risco
- Classe de impacto (crítica/moderada/fraca) conforme `GLOBAL_DEPENDENCY_MATRIX.md`:
- Risco residual:
- Estratégia de mitigação:
- Condições de rollback:

## 5) Compatibilidade e migração
- Mudança de protocolo? (S/N)
- Mudança de persistência/schema? (S/N)
- Estratégia de migração/versionamento:
- Compatibilidade retroativa:

## 6) Anti-drift
- Como a decisão evita drift arquitetural:
- Métrica de drift monitorada:
- Critério que disparará revisão desta ADR:

## 7) Evidências
- PR(s):
- Commits:
- Checks estruturais executados (link/saída):
- Testes relevantes:

## 8) Exceções
Se houver quebra de padrão, preencher obrigatoriamente:
- Justificativa formal:
- Owner responsável:
- Data de expiração da exceção:
- Plano de remoção da exceção:

## 9) Resultado pós-implantação
- Resultado observado:
- Efeitos colaterais:
- Ações corretivas:
