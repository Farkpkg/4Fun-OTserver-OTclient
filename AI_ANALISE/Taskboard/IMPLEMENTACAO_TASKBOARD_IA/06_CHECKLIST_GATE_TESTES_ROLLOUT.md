# Checklist, Testes e Rollout — Task Board isolada

## 1) Gate obrigatório
- [ ] Task Board sem dependência semântica de Prey.
- [ ] Novos opcodes com simetria parse/send client-server.
- [ ] Migration Task Board criada e validada.
- [ ] Feature gate `GameTaskBoard` ativo.
- [ ] ADR registrada para novo domínio persistente.

## 2) Testes mínimos
### Funcionais
- [ ] Abrir Task Board e receber snapshot.
- [ ] Bounty: select/progress/complete/claim/reroll.
- [ ] Weekly: progresso e claim.
- [ ] Shop: compra e desbloqueio persistente.
- [ ] Preferred list: update e limites.

### Negativos
- [ ] Claim sem completar.
- [ ] Compra sem saldo.
- [ ] Ação inválida por estado.
- [ ] Pacote malformed rejeitado sem crash.

### Persistência
- [ ] Reconnect mantém estado.
- [ ] Restart server mantém estado.
- [ ] Reset semanal executa apenas uma vez por ciclo.

## 3) Rollout
1. Dark launch (gate off por padrão)
2. Canary interno
3. Parcial por mundo
4. Global

## 4) Go/No-Go
- **Go:** sem erro crítico de protocolo/persistência e sem acoplamento com Prey.
- **No-Go:** qualquer dependência de domínio Prey ou inconsistência de dados entre reconexões.
