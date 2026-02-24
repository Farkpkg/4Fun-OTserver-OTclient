# PROPORTIONAL_GOVERNANCE_REFACTOR

Meta: governança proporcional ao estágio atual, com distribuição:
- **70% prática (operando agora)**
- **20% expansão planejada (próximo ciclo)**
- **10% visão futura (TARGET_STATE)**

## 1) Camada prática (70%)

### Artefatos que ficam centrais
1. `MINIMAL_OPERATIONAL_GOVERNANCE.md`
2. `STATE_CLASSIFICATION_MATRIX.md`
3. `CHANGE_GATE_CHECKLIST.md`
4. `SYSTEM_INVARIANTS.md` (somente invariantes realmente verificáveis no CI)
5. Manifestos/mapas de superfície (`FILE_MANIFEST`, `NETWORK_SURFACE_MAP`, `DATABASE_SURFACE_MAP`)

### Regras obrigatórias
- Nenhuma métrica não mensurável declarada como ativa.
- Nenhum gate declarado sem job CI correspondente.
- Nenhuma garantia declarada sem mecanismo verificável.

## 2) Expansão planejada (20%)

Entram aqui somente após estabilização de P0/P1:
- AIS-Lite evoluindo para AIS intermediário.
- Drift com pesos por gravidade.
- Dashboard simples com ingestão de artefatos por release.

Condição de entrada:
- 3 releases seguidas com gates estáveis + métricas publicadas.

## 3) Visão futura (10%)

Manter explicitamente como `TARGET_STATE`:
- modelo preditivo probabilístico,
- simulação estrutural pré-merge,
- controle adaptativo automático,
- coordenação multi-IA com locking automático.

## 4) Reclassificação obrigatória dos documentos teóricos

Qualquer documento que declare capacidade não implementada deve ter cabeçalho:

```md
Status: TARGET_STATE
Activation criteria: [lista objetiva de condições técnicas]
```

## 5) Critérios de conformidade final

A governança só é considerada alinhada quando:
1. todas as declarações ativas têm evidência em código/CI;
2. todos os gates ativos são bloqueantes;
3. o log por release mostra métricas e drift reais;
4. itens teóricos estão isolados e rotulados como TARGET_STATE.
