# MINIMAL_OPERATIONAL_GOVERNANCE

Objetivo: definir **núcleo mínimo executável agora** (sem teoria extra).

## 1) Invariantes verificáveis agora

### INV-M1 — Mudança de protocolo server deve ter par no client
**Como verificar no CI (script de diff):**
- Se mudar `crystalserver/src/server/network/protocol/**`, exigir mudança em pelo menos um de:
  - `otclient/src/client/protocolgameparse.cpp`
  - `otclient/src/client/protocolgamesend.cpp`
  - `otclient/src/client/protocolcodes.*`

### INV-M2 — Mudança de persistência deve ter migration
**Como verificar no CI:**
- Se houver alteração em `crystalserver/src/io/**` ou SQL/schema, exigir alteração em `crystalserver/data/migrations/*.lua`.

### INV-M3 — Mudança estrutural crítica exige declaração de impacto
**Como verificar no CI:**
- Para PR que toque `crystalserver/src/server/network/protocol/**`, `crystalserver/src/io/**`, `otclient/src/client/protocol*`, exigir arquivo/checklist preenchido (`CHANGE_GATE_CHECKLIST.md` ou template PR).

## 2) Métricas realmente calculáveis agora

### MET-M1 — Protocol Change Symmetry Ratio (PCS)
- Definição: `PCS = PRs com mudança simétrica server+client / PRs com mudança em protocolo server`.
- Fonte: paths alterados no git diff.
- Frequência: por release.

### MET-M2 — Migration Coverage Ratio (MCR)
- Definição: `MCR = PRs com mudança em persistência e migration / PRs com mudança em persistência`.
- Fonte: git diff em paths de persistência + migrations.

### MET-M3 — Critical Surface Churn (CSC)
- Definição: total de arquivos alterados por release em superfícies críticas (protocol/persistence/bootstrap).
- Fonte: git diff.

### MET-M4 — Governance Gate Pass Rate (GGP)
- Definição: `GGP = gates mínimos aprovados / gates mínimos executados`.
- Fonte: jobs CI.

## 3) Gates implementáveis no CI imediatamente

1. **gate-protocol-symmetry** (bash/python): falha se INV-M1 quebrar.
2. **gate-persistence-migration**: falha se INV-M2 quebrar.
3. **gate-impact-declaration**: falha se INV-M3 não estiver documentado.
4. Reusar workflows já existentes de build/lint/test para qualidade base.

## 4) Drift mensurável agora

Drift mínimo (operacional):
- `drift_event = 1` para cada quebra de gate crítico (INV-M1, INV-M2, INV-M3).
- `drift_release = soma(drift_event na release)`.
- `drift_accum_k = soma nas últimas k releases`.

Sem pesos complexos por enquanto.

## 5) O que NÃO declarar como ativo neste momento
- AIS completo com CHS/CLS/CDS/RCS/ECS/DCS.
- Modelo preditivo de risco treinado.
- Simulação estrutural pré-merge.
- Recalibração adaptativa automática.

## 6) Definição de pronto (operacional real)
Considerar governança mínima ativa somente quando:
1. 3 gates mínimos estiverem rodando no CI e bloqueando merge.
2. 4 métricas mínimas forem geradas por release em artefato versionado.
3. Drift mínimo for reportado por release.
