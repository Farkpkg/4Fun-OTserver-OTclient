# Open Tibia Execution Playbook (Canary + OTClient Redemption/otcv8)

Este playbook operacionaliza o **Step 10** com foco no stack deste projeto.

## Regras Obrigatórias (sempre aplicar)
1. **Nunca quebrar compatibilidade** entre client e server.
2. Sempre classificar o impacto da entrega como:
   - **Server-side**
   - **Client-side**
   - **Ambos**
3. Respeitar padrões do **Canary** (server) e **otcv8/OTClient Redemption** (client).
4. Código limpo, organizado e com comentários quando necessário.
5. Nunca implementar lógica crítica de gameplay apenas no client.
6. Toda feature deve considerar abuso/exploit e validações server-side.
7. Nunca hardcodar UI no C++.
8. UI deve viver em módulos próprios (`modules/`, OTUI, Lua/JS).

---

## 1) Scope Lock
Antes de codar, produzir um breve documento com:
- Problema e objetivo.
- Escopo / fora de escopo.
- Impacto em protocolo, persistência, scripts e UI.
- Plano de migração e rollback.
- Classificação da entrega: **Server-side / Client-side / Ambos**.

Critério de saída:
- Arquivos e subsistemas afetados listados.
- Estratégia de compatibilidade definida (dual-path, flag, ou janela de migração).

---

## 2) Design Review
Obrigatório para mudanças médias/grandes:
- Diagrama de sequência (cliente -> servidor -> persistência -> retorno).
- Tabela de falhas (detecção, mitigação, impacto no jogador).
- Revisão de segurança:
  - autenticação/autorização
  - validação de entrada
  - fronteiras de confiança
  - auditoria de logs sensíveis

Template padrão:
- `docs/templates/TASK_EXECUTION_TEMPLATE.md`

---

## 3) Implementação
Princípios:
- **Servidor autoritativo** para estado/regras de gameplay.
- Compatibilidade mantida por gates/versionamento.
- Uso de feature flags para rollout seguro.

Checklist de implementação:
- Validação server-side primeiro.
- Client tolerante a campos opcionais/novos quando possível.
- Métricas e logs mínimos adicionados no caminho novo.
- Nenhum segredo/token/senha em log.

---

## 4) Protocolo & Comunicação (quando aplicável)
### Convenções para protocolos customizados
- Usar **opcode >= 200**.
- Serialização e desserialização explícitas.
- Documentar no formato:

`Opcode | Direção | Estrutura do pacote`

### Onde tratar
- **Server**: `ProtocolGame` / extended opcode / handlers.
- **Client**: `protocolgame.cpp` / `parseExtendedOpcode` / módulo Lua consumidor.

### Regras de segurança
- Validar tamanho, faixa e consistência dos campos.
- Revalidar permissões no server (nunca confiar no client).
- Aplicar rate limit/throttle para evitar spam/abuso.

---

## 5) Validação
Matriz mínima:
- Unit tests (regras puras/domínio).
- Integration tests (fluxo protocolo + estado).
- Load/soak (concorrência e estabilidade).
- Security checks (lint estático + abuso + dependências).

Casos recomendados:
- Login/autenticação (sucesso/falha/replay).
- Burst de opcodes/movimento/combate.
- Comportamento com feature flag ON/OFF.
- Migração forward/backward (quando houver DB).

---

## 6) Rollout
- Deploy em fases (dev -> canary -> produção parcial -> produção total).
- Dashboards/alertas: taxa de erro por opcode, latência, login, estabilidade.
- Critérios claros de rollback e procedimento testado.

---

## Definition of Done (tarefas complexas)
A tarefa só está concluída quando:
1. Artefatos de scope/design/implementação/validação/rollout existem.
2. Compatibilidade client/server está explícita e validada.
3. Segurança e performance foram avaliadas.
4. Estratégia de rollback está definida e executável.
5. A resposta final segue o formato:
   1) ANÁLISE
   2) SERVER-SIDE
   3) CLIENT-SIDE
   4) PROTOCOLO (se aplicável)
   5) TESTES & VALIDAÇÃO
   6) OBSERVAÇÕES
