# MULTI_AI_COORDINATION_PROTOCOL

## Objetivo
Permitir colaboração de múltiplas IAs sem conflito de alteração, preservando invariantes e auditabilidade.

## 1) Particionamento de trabalho por fronteira arquitetural
Divisão preferencial (uma IA primária por fronteira):
1. **IA-DOMAIN**: gameplay server (`game/`, `creatures/`).
2. **IA-NET**: protocolo e handshake (`protocol*` server/client).
3. **IA-DATA**: persistência (`database/`, `io/`, migrations).
4. **IA-CLIENT**: UX/client modules (`otclient/src/client`, `modules/`).
5. **IA-DOC-GOV**: documentação, invariantes e trilha de decisão.

Regra: evitar duas IAs no mesmo arquivo no mesmo ciclo sem lock explícito.

## 2) Modelo de lock de alteração
- Cada IA declara “lock lógico” por subsistema antes de editar.
- Lock contém: escopo, objetivo, invariantes afetados, janela temporal.
- Se houver sobreposição crítica, aplicar serialização (IA-A conclui -> IA-B rebasa).

## 3) Protocolo de sincronização entre IAs
### Antes da implementação
- Publicar impacto previsto (direto/indireto).
- Declarar critérios de aceite e testes mínimos.

### Durante implementação
- Commits pequenos por fronteira.
- Atualizar mapa de impacto quando escopo crescer.

### Antes do merge
- Rodar validações por classe de risco (alto/médio/baixo).
- Executar checklist anti-drift.
- Registrar decisão arquitetural final.

## 4) Compatibilidade pré-merge
Obrigatório quando há mudanças em mais de uma fronteira:
1. Verificar simetria client/server de protocolo.
2. Verificar compatibilidade de persistência (schema/migration/io).
3. Verificar invariantes globais não violados.
4. Verificar se não há duplicação de lógica introduzida.

## 5) Registro de decisões arquiteturais
Formato mínimo do registro:
- Contexto
- Decisão
- Alternativas descartadas
- Invariantes tocados
- Risco residual
- Plano de reversão

Local recomendado: anexar no PR e refletir em `new_docs` quando estrutural.

## 6) Política de resolução de conflito
- Conflito de código: prevalece solução que preserva mais invariantes com menor acoplamento incremental.
- Conflito de direção técnica: escalar para decisão documentada (ADR curto) antes de merge.
- Conflito de prazo vs qualidade: invariantes críticos nunca podem ser negociados.
