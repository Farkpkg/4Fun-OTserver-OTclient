# CONTROLLED EVOLUTION FRAMEWORK
Status operacional: TARGET_STATE | deprecated_documental
Nota: Documento redundante no estado atual, mantido só como referência teórica.

## 1) Objetivo

Estabelecer um framework formal para evoluir a arquitetura sem degradar integridade, mantendo AIS sob controle e garantindo continuidade operacional.

---

## 2) Princípios de evolução controlada

1. **Evolução orientada por métricas**: nenhuma mudança crítica sem impacto esperado no AIS.
2. **Pequenos passos reversíveis**: modularização incremental com rollback possível.
3. **Contratos antes de implementação**: interfaces e opcodes formalizados primeiro.
4. **Governança por evidência**: ADR + check automático + owner responsável.
5. **Budget de drift explícito**: cada release consome budget limitado.

---

## 3) Ciclo operacional (Evolve Loop)

1. **Diagnóstico**
   - identificar hotspot via AIS/dashboard;
   - mapear dependências críticas e blast radius.
2. **Planejamento**
   - definir meta de melhoria (ex.: +8 pontos em CLS do domínio X);
   - escolher estratégia (desacoplamento, extração de módulo, contrato).
3. **Execução controlada**
   - aplicar mudanças em fatias pequenas;
   - acionar gates de integridade a cada etapa.
4. **Validação**
   - recomputar métricas;
   - comprovar não regressão funcional/estrutural.
5. **Consolidação**
   - remover flags temporárias;
   - atualizar documentação e baseline.

---

## 4) Regras para evoluir sem degradar AIS

- Toda mudança arquitetural deve declarar `AIS_expected_delta`.
- Se `AIS_real_delta < AIS_expected_delta - tolerance`, abrir ação corretiva.
- Mudança é bloqueada quando:
  - reduz AIS total > 5 pontos sem ADR de exceção;
  - leva qualquer componente a nível crítico;
  - aumenta drift acumulado acima de 100% do budget.

Parâmetros iniciais:

- `tolerance = 2 pontos`
- janela de validação: release atual + 1 release subsequente

---

## 5) Estratégia de redução gradual de acoplamento

## 5.1 Método 4 etapas

1. **Mapear acoplamentos dominantes** (top arestas por peso e criticidade).
2. **Criar contratos estáveis** (interfaces/eventos/protocolos versionados).
3. **Introduzir camada anti-corruption** entre sistemas com semântica divergente.
4. **Remover dependência legada** após janela de coexistência monitorada.

## 5.2 Meta quantitativa

- Reduzir `global_coupling` em pelo menos 10% a cada 3 releases em domínios críticos.
- Não aumentar `critical_dependency_density` durante desacoplamento.

---

## 6) Modularização segura

Checklist mínimo de modularização:

- fronteira explícita (API/contrato);
- ownership definido;
- suite de testes de contrato;
- observabilidade por módulo (logs/métricas/chaves de erro);
- plano de rollback.

Critério de aceite:

- módulo novo não pode introduzir dependência circular;
- CHS do sistema afetado não pode cair abaixo de 70;
- impacto em latência/consistência dentro de limites de operação.

---

## 7) Refatoração sob governança

Toda refatoração estrutural deve ter:

- ADR de intenção e risco;
- previsão de impacto em CHS/CLS/CDS;
- migração incremental com marcos verificáveis;
- conclusão condicionada a recomputação do AIS.

Refatorações em áreas críticas exigem “dual review” (arquitetura + domínio).

---

## 8) Migração de sistemas críticos com zero quebra

## 8.1 Estratégia de migração

- **Strangler Pattern** com rota gradativa de tráfego.
- Execução em paralelo (old/new) com comparação de outputs.
- Cutover apenas quando divergência = 0 em janela definida.

## 8.2 Guardrails obrigatórios

- compatibilidade backward por versão de contrato;
- replay de cenários críticos;
- freeze de mudanças não relacionadas durante cutover;
- plano de rollback testado previamente.

## 8.3 Critério “zero quebra”

A migração só fecha quando:

- nenhum incidente severo ligado ao sistema migrado;
- nenhuma divergência de contrato client/server;
- métricas AIS e componentes não entram em faixa crítica pós-cutover.

---

## 9) Indicadores de sucesso do framework

- tendência AIS estável ou ascendente por 5 releases;
- redução consistente de hotspots de acoplamento;
- taxa de exceções arquiteturais em queda;
- drift acumulado sempre dentro do budget;
- redução de incidentes com causa arquitetural.
