# AUDIT_FACTUAL_VALIDATION

Escopo auditado: todos os `.md` em `/new_docs`, com validação contra código real em `/crystalserver` e `/otclient`.

## Metodologia objetiva
1. Extração de afirmações factuais por documento.
2. Verificação por evidência no código (`rg`, `find`, contagem de arquivos, presença de símbolos).
3. Classificação: **VALIDADA**, **PARCIALMENTE VALIDADA**, **NÃO ENCONTRADA NO CÓDIGO**, **INCORRETA**.

---

## A) Documentos de inventário/superfície (fatos verificáveis em filesystem)

### `client/FILE_MANIFEST.md`
- Afirmação: total de 3758 arquivos no `otclient`. **VALIDADA**.
- Afirmação: lista de caminhos do manifesto existe. **VALIDADA** (0 caminhos faltantes).

### `server/FILE_MANIFEST.md`
- Afirmação: total de 8435 arquivos no `crystalserver`. **VALIDADA**.
- Afirmação: lista de caminhos do manifesto existe. **VALIDADA** (0 caminhos faltantes).

### `database/DATABASE_SURFACE_MAP.md`
- Afirmação: paths de migração/superfície DB listados existem. **VALIDADA** (0 faltantes).

### `network/NETWORK_SURFACE_MAP.md`
- Afirmação: superfícies de protocolo server/client listadas existem. **VALIDADA**.

### `PROJECT_FULL_MAP.md`
- Afirmação: caminhos de referência para docs centrais existem. **VALIDADA**.

### `ARCHITECTURAL_DECISION_RECORD_TEMPLATE.md`, `FEATURE_PROPOSAL_TEMPLATE.md`, `OPERATIONAL_GOVERNANCE_LAYER.md`
- Afirmação factual de referência a arquivos centrais existentes. **VALIDADA**.

---

## B) Documentos com métricas/modelos operacionais (exigem implementação real)

### `ARCHITECTURAL_INTEGRITY_SCORE.md`
- Afirmação: AIS é indicador operacional auditável e comparável entre releases (implícito como sistema ativo). **NÃO ENCONTRADA NO CÓDIGO**.
- Afirmação: componentes CHS/CLS/CDS/RCS/ECS/DCS calculáveis no estado atual do projeto. **NÃO ENCONTRADA NO CÓDIGO**.
- Afirmação: thresholds operacionais (verde/amarelo/laranja/vermelho) aplicados em pipeline. **NÃO ENCONTRADA NO CÓDIGO**.

### `PREDICTIVE_STRUCTURAL_RISK_MODEL.md`
- Afirmação: modelo preditivo de risco estrutural operacional. **NÃO ENCONTRADA NO CÓDIGO**.
- Afirmação: variáveis de treino/calibração disponíveis e conectadas ao CI/CD. **NÃO ENCONTRADA NO CÓDIGO**.

### `STRUCTURAL_SIMULATION_MODEL.md`
- Afirmação: simulação estrutural pré-merge operacional com `delta_AIS`, `delta_drift`, `delta_risk`. **NÃO ENCONTRADA NO CÓDIGO**.

### `SYSTEM_HEALTH_DASHBOARD_SPEC.md`
- Afirmação: dashboard com ingestão de telemetria de arquitetura e alertas automáticos. **NÃO ENCONTRADA NO CÓDIGO**.

### `ADAPTIVE_STABILITY_CONTROL.md`
- Afirmação: recalibração automática de `drift_budget_k` e `acceptable_risk_threshold`. **NÃO ENCONTRADA NO CÓDIGO**.

### `SELF_VALIDATION_SYSTEM.md`, `AUTOMATED_STRUCTURAL_CHECKS_SPEC.md`, `SELF_IMPROVING_ARCHITECTURE_LOOP.md`, `EVOLUTION_DECISION_ENGINE.md`, `CONTROLLED_EVOLUTION_FRAMEWORK.md`, `CHANGE_IMPACT_PROTOCOL.md`, `AUTONOMOUS_DEVELOPMENT_PROTOCOL.md`, `MULTI_AI_COORDINATION_PROTOCOL.md`
- Afirmação recorrente: existência de execução automatizada de gates/checks/modelos. **NÃO ENCONTRADA NO CÓDIGO**.
- Afirmação recorrente: operação autônoma multiagente já suportada por mecanismos técnicos implementados. **NÃO ENCONTRADA NO CÓDIGO**.

---

## C) Documentos de leis/invariantes/regras (parte normativa, parte descritiva)

### `ARCHITECTURAL_LAWS.md`
- Lei 3 (opcode novo exige simetria client/server): como regra de processo é **NORMATIVA**; enforcement automático **NÃO ENCONTRADO NO CÓDIGO**.
- Lei 5 (integração C++/Lua por bindings oficiais): há uso extensivo de bindings/Lua oficiais, então a descrição de padrão atual é **PARCIALMENTE VALIDADA**.
- Lei 6 (módulo client segue padrão `modules/`): estrutura existe, porém sem gate automático no repositório. **PARCIALMENTE VALIDADA**.

### `SYSTEM_INVARIANTS.md`
- Afirmação: servidor como autoridade de gameplay e cliente representacional. **PARCIALMENTE VALIDADA** (arquitetura de protocolo/server-authoritative observável, mas sem prova formal universal para todo domínio).
- Afirmação: invariantes são automaticamente validados antes de mudanças. **NÃO ENCONTRADA NO CÓDIGO**.
- Afirmações de caminhos com wildcard (`protocolcodes.*`, `game.*`, `migrations/*.lua`) tratados como referências genéricas. **PARCIALMENTE VALIDADA** (conceito existe, path literal não existe).

### `STRUCTURAL_STABILITY_GUARANTEES.md`
- Afirmação de “garantias” operacionais (bloqueios/governança automaticamente executados). **NÃO ENCONTRADA NO CÓDIGO**.

### `ARCHITECTURE_DRIFT_PREVENTION.md`
- Afirmação de prevenção ativa de drift via mecanismos automatizados. **NÃO ENCONTRADA NO CÓDIGO**.

### `CHANGE_GATE_CHECKLIST.md`
- Checklist existe como artefato documental. **VALIDADA**.
- Execução automática/obrigatória por pipeline. **NÃO ENCONTRADA NO CÓDIGO**.

---

## D) Documentos de análise/diagnóstico (necessitam rastros mensuráveis)

### `COHESION_AND_COUPLING_ANALYSIS.md`
- Afirmação de análise estrutural quantitativa do estado atual. **PARCIALMENTE VALIDADA** (há base de código para analisar, mas não há job/código de cálculo rastreável no repo para reproduzir integralmente os números).

### `GLOBAL_DEPENDENCY_MATRIX.md`, `PROJECT_RISK_SURFACE.md`, `PROJECT_MENTAL_MODEL.md`, `PROJECT_SELF_AUDIT.md`
- Afirmações descritivas de arquitetura e risco: várias são coerentes em alto nível com a estrutura do projeto. **PARCIALMENTE VALIDADA**.
- Afirmações de institucionalização/execução contínua por motores automáticos. **NÃO ENCONTRADA NO CÓDIGO**.

### `ARCHITECTURAL_LEARNING_LOG.md`, `FUTURE_AI_EXTENSION_GUIDE.md`
- Como guia/template: **VALIDADA** enquanto documento.
- Como capacidade já implantada no pipeline: **NÃO ENCONTRADA NO CÓDIGO**.

### `DEPENDENCY_GRAPH.md`
- Afirmação “C/C++: 450 / Includes: 1953 / SCC>1:0”. **INCORRETA/PARCIAL** frente à reprodução simples feita nesta auditoria (`434` arquivos C/C++ e `1883` includes no escopo de `crystalserver/src`), e sem evidência de metodologia idêntica no documento.

---

## Conclusão factual consolidada
- Itens estritamente de inventário de arquivos: majoritariamente **VALIDADOS**.
- Itens de governança/métricas/modelos: majoritariamente **NÃO ENCONTRADOS NO CÓDIGO** (são arquitetura-alvo/proposta, não implementação atual).
- Há pelo menos um bloco com números técnicos não reproduzidos no estado auditado (`DEPENDENCY_GRAPH.md`).
