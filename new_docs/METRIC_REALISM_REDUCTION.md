# METRIC_REALISM_REDUCTION

Objetivo: reduzir AIS/Drift/Risk ao que é **implementável agora**.

## 1) AIS

### Implementável agora
- **AIS-Lite (temporário)** com 3 componentes mensuráveis por diff/CI:
  1. `PCS` (simetria protocolo)
  2. `MCR` (cobertura de migration)
  3. `GGP` (taxa de aprovação de gates)
- Exemplo simples: `AIS_LITE = 0.4*PCS + 0.3*MCR + 0.3*GGP` (0..100).

### Precisa de instrumentação adicional
- CHS/CLS/CDS/RCS/ECS/DCS completos.
- Coesão por módulo com análise estática robusta.

### Puramente conceitual hoje
- AIS completo com pesos refinados e sem pipeline real de coleta.

### Remover temporariamente do “estado ativo”
- Declarações de AIS completo como métrica operacional vigente.

---

## 2) Drift

### Implementável agora
- `drift_event`: quebra de gate crítico.
- `drift_release`: soma de eventos por release.
- `drift_accum_k`: soma das últimas k releases.

### Precisa de instrumentação adicional
- Pesos por gravidade/categoria.
- Drift semântico por acoplamento e arquitetura.

### Puramente conceitual hoje
- Drift multi-dimensional calibrado com learning loop.

### Remover temporariamente do “estado ativo”
- Fórmulas complexas de drift não alimentadas por dados reais.

---

## 3) Risk Model

### Implementável agora
- **Risk heuristic score** (não preditivo):
  - `+1` se toca protocolo,
  - `+1` se toca persistência,
  - `+1` se toca bootstrap/core,
  - `+1` se quebra gate,
  - classe final: baixo (0-1), médio (2), alto (3-4).

### Precisa de instrumentação adicional
- Dataset de outcomes (incidente/regressão) e features históricas.
- Treino, validação, monitoramento de erro.

### Puramente conceitual hoje
- Probabilidade preditiva calibrada por sigmoid/coeficientes.

### Remover temporariamente do “estado ativo”
- Modelo preditivo probabilístico como decisão automática.

---

## 4) Política de simplificação agressiva (imediata)
1. Tratar ativo apenas: `AIS_LITE`, `drift_event/release/accum_k`, `risk heuristic`.
2. Rebaixar o restante para `TARGET_STATE`.
3. Evoluir somente após coleta estável por múltiplas releases.
