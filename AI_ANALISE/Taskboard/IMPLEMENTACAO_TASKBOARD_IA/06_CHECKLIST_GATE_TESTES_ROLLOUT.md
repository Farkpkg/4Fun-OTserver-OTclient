# Gate de mudança, testes e rollout — Task Board

## 1) CHANGE GATE (resumo executável)

### A) Impacto estrutural
- [ ] Impacto mapeado (server/client/network/config)
- [ ] Dependências indiretas revisadas (bestiary, resources balance, premium lock)

### B) Invariantes
- [ ] INV-01 preservado (server autoritativo)
- [ ] INV-02 preservado (simetria de protocolo)
- [ ] INV-06 preservado (fronteira C++↔Lua oficial)
- [ ] INV-08 preservado (feature gate explícito)

### C) Risco
- [ ] Plano de rollback definido (desativar módulo cliente/gate)
- [ ] Top-3 riscos com mitigação e teste correspondente

### D) Client/Server
- [ ] Opcodes 186/187 validados no parse client
- [ ] Opcode 0xBA validado no send client + parse server
- [ ] Estado de slot consistente em reconexão

### E) Persistência
- [ ] Fase 1 sem migração (confirmado)
- [ ] Fase 2 com migration + IO plan (se Weekly/Shop entrar)

## 2) Matriz mínima de testes

### Testes funcionais
1. Abrir janela e receber dados básicos.
2. Selecionar criatura em slot de seleção.
3. Reroll de lista com e sem reroll free.
4. Reroll de reward rarity com cards.
5. Completar task e fazer claim.
6. Cancelar task ativa.
7. Validar slot premium/bloqueado.

### Testes negativos
1. Enviar ação inválida para estado inválido.
2. Tentar selecionar criatura duplicada em outro slot.
3. Tentar claim sem completar.
4. Simular ausência de saldo e verificar erro do server.

### Testes de regressão
- Prey module continua funcionando.
- Resource balance continua atualizado para outros sistemas (forge/store etc).

## 3) Estratégia de rollout
1. **Dark launch**: módulo cliente incluído mas oculto por gate.
2. **Canary**: habilitar para ambiente de teste/staff.
3. **Gradual**: liberar para subset de mundos/players.
4. **GA**: liberar global após estabilidade.

## 4) Critérios de go/no-go
- Go:
  - 0 desserializações inválidas em pacotes 186/187;
  - 0 erros Lua críticos no módulo;
  - ações principais concluídas sem inconsistência.
- No-go:
  - qualquer violação de INV-02;
  - qualquer perda de estado de slot em reconexão.

## 5) Entregáveis obrigatórios no PR de implementação
1. Diff de código server/client.
2. Evidência de testes (log/comandos).
3. Checklist gate preenchida.
4. (Se fase 2) ADR + migration + validação de persistência.
