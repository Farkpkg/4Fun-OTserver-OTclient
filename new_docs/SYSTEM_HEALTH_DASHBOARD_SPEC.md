# SYSTEM HEALTH DASHBOARD SPEC

## 1) Objetivo

Definir a especificação funcional/técnica de um dashboard para observabilidade arquitetural contínua, centrado no **AIS** e seus vetores de degradação estrutural.

---

## 2) Visão geral do dashboard

O dashboard deve conter 6 painéis principais:

1. **AIS Atual**
2. **Tendência de AIS por Release**
3. **Drift Score Acumulado**
4. **Exceções Arquiteturais Ativas**
5. **Top Sistemas por Risco Estrutural**
6. **Hotspots de Dependência**

Cada painel deve permitir:

- filtro por release, sistema, domínio (client/server/network/database);
- comparação release atual vs. release anterior;
- drill-down até evidências (checks, ADRs, waivers, matrizes de dependência).

---

## 3) Painéis obrigatórios

## 3.1 AIS Atual

### Visualização

- Gauge 0–100 com zonas: verde, amarelo, laranja, vermelho.
- Exibição dos 6 componentes (CHS, CLS, CDS, RCS, ECS, DCS).

### Campos

- `release_id`
- `ais_score`
- `ais_level`
- `component_scores[]`
- `updated_at`

### Regras

- Destacar variação > 5 pontos desde último release.
- Exibir bloqueio ativo quando regra crítica for acionada.

---

## 3.2 Tendência por release

### Visualização

- Série temporal (linha) com AIS por release.
- Faixas coloridas por nível.

### Campos

- `release_id`
- `release_date`
- `ais_score`
- `ais_level`

### Regras

- Calcular tendência linear (slope) em janela de 5 releases.
- Alertar quando slope < -2 pontos/release.

---

## 3.3 Drift score acumulado

### Visualização

- Barra de orçamento: `drift_accum_k` vs `drift_budget_k`.
- Linha secundária com evolução release a release.

### Campos

- `drift_release`
- `drift_accum_k`
- `drift_budget_k`
- `%budget_used`

### Regras

- Amarelo acima de 70% budget.
- Vermelho acima de 100%.

---

## 3.4 Exceções arquiteturais ativas

### Visualização

- Tabela com filtros e aging.
- Histograma de exceções por idade (dias).

### Campos

- `exception_id`
- `system`
- `rule_violated`
- `opened_at`
- `expires_at`
- `owner`
- `status`

### Regras

- Exceções expiradas aparecem no topo.
- KPI principal: `exceptions_active_count` e `exceptions_expired_count`.

---

## 3.5 Sistemas com maior risco estrutural

### Visualização

- Ranking (top 10) por `structural_risk_score`.
- Heatmap por sistema x dimensão de risco.

### Campos

- `system_name`
- `structural_risk_score`
- `change_frequency`
- `critical_dependencies`
- `incident_correlation`
- `test_coverage_arch`

### Regras

- Score recalculado a cada pipeline de release.
- Hover deve explicar fatores dominantes do risco.

---

## 3.6 Hotspots de dependência

### Visualização

- Grafo direcionado com espessura da aresta por intensidade de acoplamento.
- Destaque para arestas críticas.

### Campos

- `source_system`
- `target_system`
- `dependency_weight`
- `criticality`
- `volatility`

### Regras

- Mostrar “delta de acoplamento” em relação ao release anterior.
- Permitir filtrar somente dependências críticas.

---

## 4) Arquitetura de automação futura

## 4.1 Pipeline de dados

1. **Coletores**:
   - análise estática (grafos de dependência);
   - logs de CI/CD (gates, violações);
   - base de ADR/waivers/exceções;
   - metadados de release.
2. **Processador de métricas**:
   - calcula CHS/CLS/CDS/RCS/ECS/DCS;
   - calcula AIS;
   - gera snapshots por release.
3. **Storage**:
   - tabela histórica `architectural_metrics`;
   - tabela `exceptions`;
   - tabela `dependency_edges`.
4. **Serviço de API**:
   - endpoints para dashboard e alertas.
5. **Camada visual**:
   - dashboard web com atualização por release.

## 4.2 Contrato mínimo de dados (JSON)

```json
{
  "release_id": "2026.03.0",
  "ais": {
    "score": 81.4,
    "level": "green",
    "components": {
      "chs": 84.2,
      "cls": 73.0,
      "cds": 77.4,
      "rcs": 79.8,
      "ecs": 88.0,
      "dcs": 82.1
    }
  },
  "drift": {
    "release": 9.2,
    "accum_k": 38.1,
    "budget_k": 55.0
  },
  "exceptions": {
    "active": 4,
    "expired": 0
  }
}
```

---

## 5) Alertas automáticos

- `AIS < 65` => alerta de risco elevado.
- `AIS < 50` => bloqueio de promoção de release.
- `exceptions_expired_count > 0` => bloqueio imediato.
- `drift_accum_k > drift_budget_k` => bloqueio e plano de remediação obrigatório.
- `critical_dependency_density` em tendência crescente por 3 releases => alerta preventivo.

---

## 6) Critérios de prontidão para implementação

Para considerar este spec “implementável”:

- fórmulas AIS estáveis e versionadas;
- fontes de dados mapeadas por ownership;
- schema de persistência definido;
- políticas de alerta integráveis ao CI/CD;
- trilha de auditoria habilitada por release.
