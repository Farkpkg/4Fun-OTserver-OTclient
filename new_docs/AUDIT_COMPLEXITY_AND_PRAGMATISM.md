# AUDIT_COMPLEXITY_AND_PRAGMATISM

## Diagnóstico

## 1) Governança excessiva para o tamanho do projeto
**Encontrado:** sim, em nível alto.
- Grande volume de frameworks (AIS, drift, predição, simulação, loop autônomo, coordenação multi-IA, dashboard, controle adaptativo).
- Pouca evidência de instrumentação concreta correspondente.

## 2) Over-engineering
**Encontrado:** sim.
- Camadas analíticas múltiplas para problemas que ainda não têm pipeline mínimo de medição.
- Sofisticação de fórmulas superior à maturidade observável da automação real.

## 3) Métricas sem utilidade prática imediata
**Encontrado:** sim.
- Métricas dependentes de dados inexistentes hoje (prediction accuracy, volatility calibrada, error model, etc.).
- Sem coleta real, geram falsa sensação de controle.

## 4) Formalismo desnecessário
**Encontrado:** parcialmente.
- Templates/ADRs/checklists são úteis.
- Multiplicação de “engines” e “models” sem execução incrementa custo cognitivo.

## 5) Modelos que não agregam controle real
**Encontrado:** sim, no estado atual.
- Sem enforcement automático no CI, os modelos não reduzem risco operacional de forma comprovável.

---

## Recomendação pragmática

1. **Reduzir para um núcleo mínimo operacional**:
   - invariantes obrigatórios,
   - checklist de gate,
   - 3 métricas simples reproduzíveis.
2. **Congelar modelos avançados** (predição/simulação adaptativa) até haver dados reais.
3. **Priorizar execução sobre documentação**: cada regra deve ter comando/script/job associado.
