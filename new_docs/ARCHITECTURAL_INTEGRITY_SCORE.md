# ARCHITECTURAL INTEGRITY SCORE (AIS)

## 1) Objetivo

O **Architectural Integrity Score (AIS)** transforma estabilidade estrutural em um indicador quantitativo único, auditável e comparável entre releases. O AIS é composto por métricas normalizadas (0–100), permitindo:

- avaliação contínua de integridade arquitetural;
- gatilhos automáticos de alerta/bloqueio no pipeline;
- previsibilidade de degradação estrutural;
- governança orientada por evidência.

---

## 2) Fórmula principal

Definições (todas no intervalo 0–100, onde 100 é melhor):

- `CHS`: Cohesion Health Score (coesão média por sistema)
- `CLS`: Coupling Lightness Score (inverso do acoplamento global)
- `CDS`: Critical Dependency Safety (inverso da densidade crítica)
- `RCS`: Risk Containment Score (inverso da superfície de risco ponderada)
- `ECS`: Exception Compliance Score (inverso da frequência de exceções)
- `DCS`: Drift Control Score (inverso do drift acumulado por release)

### 2.1 Normalização

Quando a métrica base é “quanto menor melhor”, usar:

`Score = max(0, min(100, 100 * (1 - value / limit_critical)))`

Quando a métrica base é “quanto maior melhor”, usar:

`Score = max(0, min(100, 100 * value / target_excellent))`

### 2.2 Cálculo consolidado

`AIS = 0.22*CHS + 0.18*CLS + 0.16*CDS + 0.18*RCS + 0.12*ECS + 0.14*DCS`

> Racional de pesos:
> - Coesão e risco estrutural têm maior impacto em manutenção de longo prazo.
> - Acoplamento e densidade crítica influenciam propagação de falhas.
> - Exceções e drift capturam disciplina de governança ao longo do tempo.

---

## 3) Métricas componentes

## 3.1 Coesão média por sistema

### Métrica base

Para cada sistema `s`:

`cohesion_s = internal_calls_s / (internal_calls_s + cross_system_calls_s)`

Coesão média global:

`cohesion_avg = sum(cohesion_s * weight_s) / sum(weight_s)`

onde `weight_s` pode ser número de módulos/arquivos/LOC do sistema.

### Score

`CHS = 100 * cohesion_avg`

### Faixas

- **Aceitável**: `CHS >= 75`
- **Alerta**: `60 <= CHS < 75`
- **Crítico**: `CHS < 60`

---

## 3.2 Grau de acoplamento global

### Métrica base

Grafo de dependências entre sistemas:

`global_coupling = cross_edges / total_edges`

Opcionalmente ponderado por intensidade de chamadas:

`global_coupling_w = weighted_cross_edges / weighted_total_edges`

### Score

`CLS = 100 * (1 - global_coupling)`

### Faixas

- **Aceitável**: `CLS >= 70`
- **Alerta**: `50 <= CLS < 70`
- **Crítico**: `CLS < 50`

---

## 3.3 Densidade de dependência crítica

Dependências críticas são arestas com alto potencial de quebra cascata (ex.: client↔server protocol, persistence schema, opcode contracts).

### Métrica base

`critical_dependency_density = critical_edges / total_edges`

### Score

`CDS = 100 * (1 - critical_dependency_density / critical_density_limit)`

Com `critical_density_limit = 0.22` (valor inicial calibrável).

### Faixas

- **Aceitável**: `critical_dependency_density <= 0.12` (`CDS` alto)
- **Alerta**: `0.12 < density <= 0.18`
- **Crítico**: `density > 0.18`

---

## 3.4 Superfície de risco ponderada

### Métrica base

Para cada elemento arquitetural `i`:

`risk_i = change_frequency_i * blast_radius_i * criticality_i * observability_gap_i`

Superfície agregada:

`weighted_risk_surface = sum(risk_i) / N`

Normalização por limite crítico (`risk_surface_limit`):

`RCS = 100 * (1 - weighted_risk_surface / risk_surface_limit)`

### Faixas

- **Aceitável**: `RCS >= 72`
- **Alerta**: `55 <= RCS < 72`
- **Crítico**: `RCS < 55`

---

## 3.5 Frequência de exceções arquiteturais

Exceção arquitetural = desvio aprovado temporariamente (waiver com prazo).

### Métrica base

`exception_frequency = exceptions_open_last_90d / architectural_changes_last_90d`

### Score

`ECS = 100 * (1 - exception_frequency / exception_frequency_limit)`

Com `exception_frequency_limit = 0.20`.

### Faixas

- **Aceitável**: `exception_frequency <= 0.08`
- **Alerta**: `0.08 < freq <= 0.15`
- **Crítico**: `freq > 0.15`

---

## 3.6 Drift acumulado por release

### Métrica base

Para cada release `r`:

`drift_r = sum(violations_weighted_r)`

Drift acumulado em janela móvel `k` releases:

`drift_accum_k = sum(drift_r for r in last_k_releases)`

### Score

`DCS = 100 * (1 - drift_accum_k / drift_budget_k)`

### Faixas

- **Aceitável**: `drift_accum_k <= 70% do budget`
- **Alerta**: `70% < drift_accum_k <= 100%`
- **Crítico**: `drift_accum_k > 100%`

---

## 4) Níveis operacionais do AIS

- **Verde (Estável)**: `AIS >= 80`
- **Amarelo (Atenção)**: `65 <= AIS < 80`
- **Laranja (Risco Elevado)**: `50 <= AIS < 65`
- **Vermelho (Crítico)**: `AIS < 50`

## 4.1 Regras de bloqueio

Mesmo com AIS global alto, há bloqueio se qualquer condição ocorrer:

1. qualquer métrica componente em nível **crítico** por 2 releases consecutivas;
2. `CDS < 40` (densidade crítica descontrolada);
3. `DCS < 35` (drift acima do orçamento tolerável);
4. exceções vencidas > 0 em produção.

---

## 5) Calibração e governança

- Recalibrar limites trimestralmente via ADR.
- Ajustar pesos apenas com justificativa histórica de incidentes.
- Publicar baseline por release em trilha de auditoria.
- Comparar AIS real vs. previsão para melhorar modelo preditivo.

---

## 6) Saídas esperadas para automação

Pipeline deve produzir artefato `ais_report.json` com:

- scores componentes e AIS consolidado;
- classificação por nível;
- justificativas automáticas para quedas > 5 pontos;
- dif entre release atual e anterior;
- recomendações de remediação priorizadas.
