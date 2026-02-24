# AI_DECISION_MODEL

## Objetivo
Definir um modelo determinístico de decisão para IA de engenharia neste projeto, priorizando estabilidade estrutural sem bloquear evolução necessária.

## Princípios
1. **Preservar invariantes antes de otimizar localmente**.
2. **Evoluir por extensão canônica antes de modificar núcleo sensível**.
3. **Minimizar superfície de mudança para reduzir risco de cascata**.
4. **Toda mudança deve ser explicável por impacto estrutural observável**.

---

## Heurística de priorização: estabilidade vs evolução
- Se mudança toca risco **alto** (protocolo/persistência/bootstrap): estabilidade > velocidade.
- Se mudança toca risco **médio**: equilíbrio com validação de integração.
- Se mudança toca risco **baixo**: evolução rápida com validação local.

## Matriz de decisão (extensão vs modificação)
- **Extensão** quando existe ponto canônico capaz de absorver a feature sem quebrar contrato.
- **Modificação** quando:
  1) ponto canônico está incorreto/obsoleto,
  2) extensão criaria duplicação estrutural,
  3) há plano de migração/versionamento explícito.

---

## Processo formal de raciocínio pré-implementação
1. Classificar fronteira afetada (domain/net/data/client).
2. Mapear dependências diretas e indiretas.
3. Verificar invariantes potencialmente tocados.
4. Simular impacto em cadeia (incluindo rollback).
5. Escolher estratégia (extensão/modificação) com justificativa.
6. Definir evidências mínimas de validação.
7. Implementar menor diff viável.
8. Revalidar invariantes após diff final.

---

## Fluxograma textual detalhado
**Início** -> A mudança altera comportamento observável?
- **Não** -> Fazer ajuste local mínimo -> validar lint/build/test -> finalizar.
- **Sim** -> Toca protocolo, persistência ou bootstrap?
  - **Sim** -> classificar como risco alto -> abrir impacto em cadeia obrigatório -> checar simetria e migração -> implementar incrementalmente -> validar cross-layer -> atualizar docs estruturais.
  - **Não** -> Toca bindings Lua ou módulos com efeitos indiretos?
    - **Sim** -> classificar risco médio -> validar integração runtime + callbacks -> monitorar regressão invisível.
    - **Não** -> risco baixo -> validação local e rastreio de decisão.
Após implementação -> Algum invariante ficou ambíguo?
- **Sim** -> bloquear entrega e formalizar ajuste documental/técnico.
- **Não** -> concluir com evidências.

---

## Regras para evitar mudanças desnecessárias
- Não alterar múltiplos subsistemas quando um ponto canônico resolve.
- Não “melhorar” arquitetura fora do escopo solicitado sem gatilho de risco.
- Não introduzir abstração nova sem evidência de repetição estrutural.
- Não converter problema local em refatoração ampla sem plano explícito.

## Critério de aceitação da decisão
Uma decisão é válida quando:
1. Não viola invariantes críticos.
2. Minimiza acoplamento incremental.
3. Mantém compatibilidade de protocolo/persistência.
4. Deixa trilha auditável para futuras IAs.
