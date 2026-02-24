# AUDIT_CORRECTIONS_AND_IMPROVEMENTS

## Problema 1 — Documentação descreve operação autônoma não implementada
- **Impacto estrutural:** decisões podem assumir controles inexistentes.
- **Risco:** mudanças de alto impacto passarem sem gate real.
- **Correção:** em cada documento, adicionar bloco `STATUS: CURRENT_STATE | TARGET_STATE`.
- **Simplificação:** remover linguagem de garantia absoluta quando não houver enforcement técnico.

## Problema 2 — Métricas avançadas sem pipeline de coleta
- **Impacto estrutural:** AIS/Drift/Risk viram números não auditáveis.
- **Risco:** governança orientada por “score fictício”.
- **Correção:** implementar `tools/architecture_metrics` com saída versionada (`json`) por release.
- **Simplificação:** iniciar com 3 métricas objetivas (acoplamento de includes, hotspots por churn, alterações em superfícies críticas).

## Problema 3 — Gates automatizados não encontrados
- **Impacto estrutural:** checklist fica dependente de disciplina manual.
- **Risco:** inconsistência entre reviewers/PRs.
- **Correção:** criar job CI mínimo:
  1) detectar mudança em protocolo server e exigir mudança client correlata;
  2) detectar mudança em persistência e exigir migration;
  3) exigir declaração de impacto em invariantes.
- **Simplificação:** bloquear apenas violações críticas no início.

## Problema 4 — Baselines quantitativas possivelmente desatualizadas
- **Impacto estrutural:** análise parte de premissas numéricas erradas.
- **Risco:** decisões ruins por dados inválidos.
- **Correção:** cada número em docs deve trazer “comando gerador + data + commit”.
- **Simplificação:** substituir números estáticos por artefatos gerados automaticamente.

## Problema 5 — Sobreposição de modelos/protocolos
- **Impacto estrutural:** ambiguidade de autoridade documental.
- **Risco:** times diferentes seguirem regras diferentes.
- **Correção:** unificar em um documento canônico “Governança Arquitetural Operacional”.
- **Simplificação:** manter anexos opcionais para modelos avançados.

---

## Plano de ajuste objetivo (ordem sugerida)
1. Classificar todos os docs em `CURRENT_STATE` vs `TARGET_STATE`.
2. Implementar 1 pipeline mínimo de métricas + gate crítico.
3. Revalidar invariantes com evidência automatizada por PR.
4. Só então reativar modelos preditivos/simulação.
