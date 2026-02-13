# Testes e casos de uso do sistema Paperdoll

## 1) Cenários funcionais essenciais

## 1.1 Login e carga inicial

**Dado** jogador com dados persistidos em `player_paperdoll`.

**Quando** logar no jogo.

**Então**:
- server envia `paperdoll_snapshot`,
- client renderiza estado atual,
- preview/UI coincide com DB.

## 1.2 Aplicar mudança válida

**Quando** jogador seleciona `appearanceId` desbloqueado e clica Apply.

**Então**:
- server responde `paperdoll_apply_result.ok = true`,
- DB atualiza slot correspondente,
- personagem recebe visual efetivo.

## 1.3 Bloqueio por unlock

**Quando** client tenta `appearanceId` não desbloqueado.

**Então** server retorna `ERR_NOT_UNLOCKED`.

## 1.4 Bloqueio por premium/nível/vocação

- Premium falso + skin premium -> `ERR_PREMIUM_REQUIRED`.
- Nível abaixo -> `ERR_LEVEL_REQUIRED`.
- Vocação inválida -> `ERR_VOCATION_NOT_ALLOWED`.

## 1.5 Equip/deequip com integração

**Quando** equipa item com mapping no `equipment_paperdoll.xml`.

**Então** slot sem override cosmético recebe visual derivado.

## 1.6 Persistência logout/login

**Quando** jogador aplica skin, desloga e reloga.

**Então** estado restaurado deve ser idêntico.

## 1.7 Resync em desvio de estado

**Quando** client detecta divergência local.

**Então** envia `paperdoll_request_snapshot` e corrige UI.

---

## 2) Casos de segurança

- payload com slot inválido -> rejeitar e logar.
- payload com cor fora da faixa -> rejeitar.
- spam de opcode -> `ERR_RATE_LIMIT`.
- `appearanceId` inexistente -> `ERR_INVALID_APPEARANCE`.
- tampering de requestId -> ignorar impacto funcional (somente correlação UI).

---

## 3) Casos de compatibilidade

- Client sem módulo paperdoll ativo: gameplay não quebra.
- Asset ausente no dat/spr: fallback de visual + warning em log.
- Migração de schemaVersion: mensagens antigas ignoram campos desconhecidos.

---

## 4) Testes de performance

## 4.1 Carga de login

- Simular N jogadores simultâneos com snapshot.
- Medir tempo médio de query e envio de payload.

## 4.2 Burst de alterações

- Aplicar 20 requests sequenciais em 3s.
- Confirmar rate limit e estabilidade.

## 4.3 Banco de dados

- Verificar uso de índices (`PRIMARY(player_id,slot)` e unlocks).
- Garantir ausência de full table scan em fluxo normal.

---

## 5) Exemplo de checklist de QA

- [ ] Login com paperdoll vazio.
- [ ] Login com paperdoll completo.
- [ ] Aplicar skin válida de cada slot.
- [ ] Aplicar skin inválida manualmente (packet test).
- [ ] Equipar/retirar item mapeado.
- [ ] Alterar cor em slot colorível.
- [ ] Tentar cor fora da faixa.
- [ ] Testar em conta premium e free.
- [ ] Testar em vocações diferentes.
- [ ] Logout/login persistência.
- [ ] Reconnect durante edição.
- [ ] Resync manual.

---

## 6) Exemplo de testes automatizáveis (pseudo)

```lua
-- server-side pseudo test
it("rejects locked appearance", function()
  local player = fakePlayer({ level = 100, premium = true })
  local req = { slots = { helmet = { appearanceId = 9999, enabled = true } } }
  local ok, res = PaperdollService.applyRequest(player, req)
  assert.is_false(ok)
  assert.equals("ERR_NOT_UNLOCKED", res.errorCode)
end)
```

```lua
-- client-side pseudo test
it("applies snapshot into UI model", function()
  local snapshot = { type = "paperdoll_snapshot", data = { slots = { armor = { appearanceId = 3001 } } } }
  PaperdollController:onMessage(snapshot)
  assert.equals(3001, PaperdollController.state.slots.armor.appearanceId)
end)
```

---

## 7) Critérios de aceite

- Não há impacto em stats por alteração cosmética.
- Servidor rejeita 100% dos requests inválidos conhecidos.
- Estado persiste corretamente após restart/login.
- Latência de apply visual aceitável (meta: < 200ms intra-região).
- Logs suficientes para suporte e auditoria.
