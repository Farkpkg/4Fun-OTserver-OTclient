# PREDICTIVE STRUCTURAL RISK MODEL

## 1) Objetivo

Modelar risco estrutural futuro para antecipar:

- surgimento de bugs estruturais;
- divergência client/server;
- regressões invisíveis;
- efeitos cascata por acoplamento.

O modelo usa sinais arquiteturais já definidos (AIS + métricas componentes + histórico de drift/exceções/incidentes).

---

## 2) Unidade de predição

A predição ocorre por **Structural Unit (SU)**, que pode ser:

- sistema (ex.: network, server, client);
- subsistema (ex.: protocol parser, persistence layer);
- dependência crítica (aresta source->target).

Cada SU recebe um `risk_probability` (0–1) e `risk_class`.

---

## 3) Features de entrada

## 3.1 Features principais (release t)

- `AIS_t`
- `delta_AIS_t` (variação vs. t-1)
- `CHS_t`, `CLS_t`, `CDS_t`, `RCS_t`, `ECS_t`, `DCS_t`
- `drift_accum_t`
- `exceptions_active_t`
- `exceptions_expired_t`
- `critical_dependency_density_t`
- `coupling_delta_t`
- `change_frequency_t` por SU
- `test_gap_arch_t` (lacunas de testes em caminhos críticos)

## 3.2 Features históricas (janela k releases)

- tendência (slope) de cada métrica;
- volatilidade (desvio padrão) por SU;
- reincidência de violações por regra;
- correlação de incidentes com dependências críticas.

---

## 4) Alvos de predição

## 4.1 Bugs estruturais

Alvo binário: ocorrência de bug com causa arquitetural em `t+1`.

Critérios de risco alto:

- `RCS < 60` e `delta_AIS < -5`;
- aumento de `change_frequency` + baixa cobertura arquitetural;
- SU no top 20% de blast radius.

## 4.2 Divergência client/server

Alvo binário: inconsistência de protocolo, contrato de opcode ou formato de payload.

Sinais de predição:

- crescimento de exceções em módulos de rede/protocolo;
- aumento de dependência crítica client↔server;
- mudanças assimétricas entre árvores client e server no mesmo release;
- lacunas de validação de contrato.

## 4.3 Regressão invisível

Alvo binário: regressão sem falha imediata visível, detectada tardiamente.

Sinais de predição:

- alta mudança em áreas de baixa observabilidade;
- drift recorrente sem remediação;
- paths críticos com testes ausentes e alto acoplamento.

## 4.4 Efeito cascata por acoplamento

Alvo binário: incidente propagado por múltiplos sistemas.

Sinais de predição:

- `CLS` em queda contínua por 3 releases;
- concentração de arestas de alta centralidade em poucos nós;
- dependências críticas com alta volatilidade.

---

## 5) Modelo quantitativo inicial

Modelo híbrido em duas camadas:

1. **Risk Heuristic Layer (determinística)**
   - gera `base_risk_score` com regras ponderadas.
2. **Probabilistic Layer (ML supervisionado)**
   - estima `risk_probability` calibrada por histórico real.

### 5.1 Fórmula heurística base

`base_risk_score = 0.20*(100-CHS) + 0.18*(100-CLS) + 0.17*(100-CDS) + 0.20*(100-RCS) + 0.10*(100-ECS) + 0.15*(100-DCS)`

Normalização para probabilidade inicial:

`p0 = sigmoid((base_risk_score - 50) / 10)`

### 5.2 Classificação

- **Baixo**: `p < 0.35`
- **Moderado**: `0.35 <= p < 0.60`
- **Alto**: `0.60 <= p < 0.80`
- **Crítico**: `p >= 0.80`

---

## 6) Estratégia de validação

- Backtesting em janela de releases históricas.
- Métricas: AUC, precision@k hotspots, recall para incidentes críticos.
- Curva de calibração para evitar overconfidence.
- Revisão trimestral dos pesos/regras via ADR.

---

## 7) Saídas operacionais

O pipeline preditivo deve produzir:

- `top_risk_units` (SUs com maior probabilidade);
- `risk_type_breakdown` (bug estrutural / divergência C-S / regressão invisível / cascata);
- `expected_impact` (blast radius estimado);
- `recommended_controls` (ações preventivas por SU).

Exemplos de controles:

- congelamento temporário de mudanças em arestas críticas;
- testes de contrato obrigatórios client/server;
- refatoração prioritária de módulos superacoplados;
- remoção de exceções vencidas como pré-condição de merge.

---

## 8) Integração com governança

- Risco “Crítico” bloqueia release sem plano de mitigação aprovado.
- Risco “Alto” exige owner + prazo + checkpoint de redução.
- Modelo e thresholds são versionados (v1, v2...) para auditabilidade.
- Erro preditivo relevante (falso negativo grave) dispara revisão de modelo.
