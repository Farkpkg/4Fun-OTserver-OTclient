# AGENT_BOOTSTRAP

## 1) CONTEXT LOAD

### Projeto
- Repositório com dois componentes principais:
  - `crystalserver` (servidor C++/Lua, autoridade de gameplay, protocolo e persistência).
  - `otclient` (cliente C++/Lua, renderização e interação de protocolo).
- `new_docs/` contém documentação arquitetural, auditorias e propostas de governança.

### Estado implementado (código real)
- Estrutura de protocolo server/client existe e está versionada no código.
- Persistência e migrations existem no servidor.
- Workflows CI de build/lint/test existem em `crystalserver/.github/workflows` e `otclient/.github/workflows`.

### Estado somente documental
- AIS completo (CHS/CLS/CDS/RCS/ECS/DCS), modelo preditivo de risco, simulação estrutural, dashboard e controle adaptativo estão documentados, mas não operacionais como sistema integrado.

### TARGET_STATE (não ativo)
- Qualquer mecanismo que dependa de instrumentação não implementada, coleta histórica estruturada, calibração de modelo ou gate bloqueante ainda não existente.

---

## 2) STATE CLASSIFICATION

### CURRENT_STATE
Definição operacional:
- Artefato/regra executável hoje sem nova instrumentação.
- Evidência direta em código, CI atual ou processo manual explícito.

### PARTIALLY_IMPLEMENTED
Definição operacional:
- Parte executável hoje, parte depende de automação/instrumentação ausente.
- Não pode ser tratado como controle totalmente ativo.

### TARGET_STATE
Definição operacional:
- Visão futura sem implementação executável no estado atual.
- Não pode ser usado como critério de bloqueio real.

---

## 3) ACTIVE GOVERNANCE CORE

### Invariantes ativas (operacionais hoje)
1. Mudança de protocolo server deve ter revisão de impacto no client.
2. Mudança de persistência deve ter revisão de migration.
3. Mudança em superfície crítica deve ter declaração explícita de impacto.

Status de enforcement:
- Ativo como processo de revisão manual.
- Ainda não ativo como gate CI bloqueante dedicado.

### Métricas realmente calculáveis hoje
1. Contagem de alterações em superfícies críticas por diff (`git diff --name-only`).
2. Presença/ausência de mudança correlata server/client em protocolo por diff.
3. Presença/ausência de migration quando há alteração de persistência por diff.
4. Taxa manual de conformidade de checklist por release.

### Gates ativos
- Gates automáticos dedicados de governança arquitetural: **não ativos** no momento.
- Gates de qualidade já ativos: build/lint/test existentes nos workflows atuais.

### O que NÃO pode bloquear pipeline
- AIS completo não instrumentado.
- Modelo probabilístico de risco sem treino e validação operacional.
- Simulação estrutural não implementada.
- Qualquer score sem fonte de dados verificável no CI atual.

---

## 4) DRIFT CONTROL

### Definição de deriva
Deriva = alteração em superfície crítica sem evidência mínima de alinhamento arquitetural (simetria protocolo, migration correlata, declaração de impacto).

### Deriva com alerta
Gerar alerta quando ocorrer qualquer um:
- alteração em protocolo server sem evidência de ajuste/revisão no client;
- alteração de persistência sem migration associada;
- alteração crítica sem registro de impacto.

### Deriva observacional
- Mudança crítica com justificativa registrada e plano de correção explícito.
- Divergência temporária aceita com prazo e responsável.

---

## 5) DECISION RULES

1. Não promover teoria a controle ativo.
2. Não criar métrica sem mecanismo verificável de coleta.
3. Não criar gate sem implementação possível no CI.
4. Não assumir que documentação implica execução.
5. Em conflito, código real e comportamento executável têm prioridade.

---

## 6) FEATURE EXECUTION FLOW

1. **Proposta**
   - Definir escopo, superfícies afetadas e impacto esperado.
2. **Implementação**
   - Alterar apenas componentes necessários.
3. **Validação**
   - Executar build/test/lint aplicáveis.
   - Verificar simetria protocolo e migration quando aplicável.
4. **Log**
   - Registrar impacto arquitetural e decisão no documento/checklist de mudança.
5. **Encerramento**
   - Confirmar estado final e pendências.

---

## 7) SIMPLICITY PRINCIPLE

- Governança deve ser proporcional ao tamanho e maturidade reais do projeto.
- Toda complexidade adicional exige ganho mensurável de controle, qualidade ou redução de risco.
- Sem ganho mensurável, manter solução mais simples.

---

## 8) FORBIDDEN BEHAVIORS

1. Criar sistemas paralelos não solicitados.
2. Expandir escopo sem pedido explícito.
3. Introduzir modelos teóricos não implementáveis no estado atual.
4. Reclassificar estados sem justificativa técnica verificável.

---

## 9) FUTURE ARCHITECTURE – NOT ACTIVE

Itens permitidos apenas como planejamento:
- AIS completo com componentes avançados e pesos calibrados.
- Predictive Structural Risk Model com treino/validação contínuos.
- Structural Simulation pré-merge.
- Adaptive Stability Control automático.
- Dashboard de saúde arquitetural com ingestão contínua.
- Governança multiagente com locking e arbitragem automáticos.

Regra:
- Não usar estes itens como gate bloqueante até implementação verificável.

---

## 10) AGENT START DIRECTIVE

- O agente deve assumir **CURRENT_STATE** como realidade operacional.
- **TARGET_STATE** é visão de evolução, não regra ativa.
- Governança deve ser aplicada proporcionalmente ao estado real do projeto.
- Código real e evidência executável têm prioridade sobre modelagem conceitual.

---

## 11) REFLECTION LAYER (CONTROLLED ANALYTICAL MODE)

Objetivo:
Permitir que o agente produza reflexões analíticas explícitas, separadas da execução técnica, sem afetar governança operacional.

IMPORTANTE:
- Reflexão não é consciência.
- Reflexão não é opinião subjetiva.
- Reflexão não pode alterar decisões automaticamente.
- Reflexão não pode criar novos sistemas.
- Reflexão não pode promover TARGET_STATE a ativo.

### Definição

Reflection Layer = bloco opcional onde o agente pode registrar:

- Riscos potenciais não explícitos
- Padrões emergentes observados
- Possíveis simplificações futuras
- Pontos de atenção estrutural
- Inconsistências comportamentais detectadas
- Hipóteses técnicas (claramente marcadas como hipóteses)

### Regras da Reflection Layer

1. Deve estar sempre claramente separada da execução.
2. Deve ser rotulada como:
   `[REFLECTION — NON-BINDING]`
3. Não pode introduzir novos gates.
4. Não pode alterar classificação de estado.
5. Não pode gerar obrigação futura.
6. Não pode expandir escopo sem solicitação explícita.
7. Não pode misturar julgamento estético com regra técnica.

### Limitação

A Reflection Layer:
- Não substitui decisão humana.
- Não altera CURRENT_STATE.
- Não ativa TARGET_STATE.
- Não modifica governança.
- É puramente observacional.

### Uso Permitido

Pode ser utilizada quando:
- Uma decisão estrutural for tomada.
- Um padrão repetitivo for identificado.
- Um risco emergente for percebido.
- Um desvio leve for detectado.
- Houver oportunidade clara de simplificação futura.

### Proibição

Não é permitido:
- Escrever reflexões filosóficas.
- Inserir pensamentos sobre assuntos externos ao projeto.
- Produzir conteúdo não relacionado à engenharia do repositório.
- Gerar comentários aleatórios.

"A Reflection Layer é uma ferramenta de observação técnica, não um mecanismo de autonomia decisória."

