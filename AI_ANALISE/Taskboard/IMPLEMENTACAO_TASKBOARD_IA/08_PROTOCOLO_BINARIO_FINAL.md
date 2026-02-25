# 08 — PROTOCOLO BINÁRIO FINAL

## 1) Escopo e framing

Este documento consolida o **contrato final** do protocolo binário do sistema Task Board/Bounty via canal de extensão.

- Transporte: `ClientExtendedOpcode (0x32)`.
- Canal lógico recomendado: `ExtendedIds.Game (4)`.
- Dentro do `buffer` (string binária), o frame começa por:
  - `u8 opcode`
  - `u8 version`
  - `payload` do opcode.

> Convenções:
> - `string` = `u16 len + bytes UTF-8`.
> - `bool` = `u8` (`0`/`1`).
> - `hasX` = flag booleana que habilita leitura de campos opcionais imediatamente após a flag.

---

## 2) Matriz final por opcode

| Opcode (hex/dec) | Direção | Versão mínima / feature gate | Payload (ordem exata) | Regras opcionais (`hasX`) |
|---|---|---|---|---|
| `0x32 / 50` (`OPEN`) | S->C | `v1` / `taskboard_core` | `u8 uiTabDefault`, `bool hasWelcome`, `string welcomeText?` | Se `hasWelcome=1`, ler `welcomeText`. |
| `0x33 / 51` (`BOUNTY_DATA`) | S->C | `v1` / `taskboard_core` | `u8 selectedDifficulty`, `u8 totalSlots`, `u8 activeSlot`, `u16 activeKills`, `u16 activeRequired`, `u8 offersCount`, `Offer[]` | `Offer`: `string creature`, `u16 requiredKills`, `u8 difficulty`, `bool hasBonus`, `u16 bonusPct?`. |
| `0x34 / 52` (`WEEKLY_DATA`) | S->C | `v1` / `weekly_tasks` | `u8 weeklyDifficulty`, `u8 killTasksCount`, `KillTask[]`, `u8 deliveryTasksCount`, `DeliveryTask[]`, `bool hasWeeklyReward`, `u32 weeklyRewardExp?`, `u16 weeklyRewardPoints?` | `KillTask`: `u16 raceId`, `u16 done`, `u16 goal`, `bool unlocked`; `DeliveryTask`: `u16 itemId`, `u16 done`, `u16 goal`, `bool unlocked`. |
| `0x35 / 53` (`SHOP_DATA`) | S->C | `v1` / `task_shop` | `u16 entries`, `ShopEntry[]` | `ShopEntry`: `u16 entryId`, `u16 itemId`, `u16 amount`, `u32 pricePoints`, `bool hasLimit`, `u16 remainingLimit?`. |
| `0x36 / 54` (`PREFERRED`) | S->C | `v1` / `preferred_list` | `u8 preferredCount`, `u16 preferredRaceId[]`, `u8 unwantedCount`, `u16 unwantedRaceId[]`, `bool hasCatalog`, `u16 catalogCount?`, `u16 catalogRaceId[]?` | Se `hasCatalog=1`, ler catálogo completo. |
| `0x37 / 55` (`TALISMAN`) | S->C | `v1` / `talisman_system` | `u8 level`, `u16 bonusPct`, `u32 nextUpgradeCost`, `bool canUpgrade` | Sem opcionais extras. |
| `0x38 / 56` (`CURRENCIES`) | S->C | `v1` / `taskboard_core` | `u32 bountyPoints`, `u32 huntingTaskPoints`, `bool hasPremiumCurrency`, `u32 premiumCurrency?` | `premiumCurrency` só existe se `hasPremiumCurrency=1`. |
| `0x39 / 57` (`RESULT`) | S->C | `v1` / `taskboard_core` | `u16 resultCode`, `string message`, `bool hasDelta`, `u32 deltaBP?`, `u32 deltaHTP?` | Se `hasDelta=1`, ler ambos os deltas. |
| `0x3C / 60` (`SELECT`) | C->S | `v1` / `taskboard_core` | `u8 slot` | Sem opcionais. |
| `0x3D / 61` (`REROLL`) | C->S | `v1` / `taskboard_core` | `u8 slot` | Sem opcionais. |
| `0x3E / 62` (`CLAIM_DAILY`) | C->S | `v1` / `taskboard_core` | `u8 slot`, `bool hasClientNonce`, `u32 clientNonce?` | `clientNonce` opcional para correlação de UI. |
| `0x3F / 63` (`PREF_SET`) | C->S | `v1` / `preferred_list` | `u8 mode`, `u16 raceId` | `mode`: `1=preferred`, `2=unwanted`, `0=sync_request` (neste caso `raceId=0`). |
| `0x40 / 64` (`PREF_CLEAR`) | C->S | `v1` / `preferred_list` | `u8 mode`, `u16 raceId` | `mode`: `1=preferred`, `2=unwanted`. |
| `0x41 / 65` (`UNWANTED_CLEAR`) | C->S | `v1` / `preferred_list` | `bool clearAll` | Se `clearAll=0`, servidor ignora (idempotência). |
| `0x42 / 66` (`EXTRA_SLOT`) | C->S | `v1` / `extra_slots` | `u8 targetSlots` | Valor esperado: `4` ou `5`. |
| `0x43 / 67` (`TALISMAN_UPGRADE`) | C->S | `v1` / `talisman_system` | `u8 expectedCurrentLevel`, `bool fastTrack` | `fastTrack` só aceito em gate `talisman_fasttrack`. |
| `0x44 / 68` (`SHOP_BUY`) | C->S | `v1` / `task_shop` | `u16 entryId`, `u16 quantity`, `bool hasPreviewOnly`, `bool previewOnly?` | Se `hasPreviewOnly=1`, compra não é executada (somente simulação). |
| `0x45 / 69` (`WEEKLY_DIFFICULTY`) | C->S | `v1` / `weekly_tasks` | `u8 difficulty` | `1=easy`, `2=medium`, `3=hard`. |
| `0x46 / 70` (`WEEKLY_DELIVER`) | C->S | `v1` / `weekly_tasks` | `u8 taskIndex`, `u16 itemId`, `u16 amount`, `bool partialAllowed` | `partialAllowed=1` permite entrega parcial. |
| `0x47 / 71` (`WEEKLY_UNLOCK_KILL`) | C->S | `v1` / `weekly_tasks` | `u8 taskIndex` | Sem opcionais. |
| `0x48 / 72` (`WEEKLY_UNLOCK_DELIVER`) | C->S | `v1` / `weekly_tasks` | `u8 taskIndex` | Sem opcionais. |

---

## 3) Exemplos de frame serializado

> Notação: bytes em hexadecimal, strings com prefixo `u16 len`.

### 3.1 `SELECT (0x3C)` — caso mínimo

Selecionar slot `2` na versão `1`:

`3C 01 02`

- `3C` = opcode
- `01` = versão
- `02` = slot

### 3.2 `CLAIM_DAILY (0x3E)` — caso completo

Claim no slot `1` com nonce `0x0000A1B2`:

`3E 01 01 01 B2 A1 00 00`

- `3E` = opcode
- `01` = versão
- `01` = slot
- `01` = `hasClientNonce`
- `B2 A1 00 00` = nonce (little-endian)

### 3.3 `RESULT (0x39)` — caso mínimo

Retorno de sucesso sem delta de moeda, mensagem `"OK"`:

`39 01 00 00 02 00 4F 4B 00`

- `39` opcode, `01` versão
- `00 00` `resultCode=0`
- `02 00 4F 4B` string `OK`
- `00` `hasDelta=0`

### 3.4 `RESULT (0x39)` — caso completo

Erro com delta de moedas e mensagem `"Reroll concluído"`:

`39 01 03 10 10 00 52 65 72 6F 6C 6C 20 63 6F 6E 63 6C 75 C3 AD 64 6F 01 64 00 00 00 00 00 00 00`

- `resultCode=0x1003` (exemplo `ERR_DAILY_REROLL_LIMIT`)
- `message` UTF-8
- `hasDelta=1`
- `deltaBP=100`
- `deltaHTP=0`

---

## 4) Catálogo de erros por pacote (`ERR_*`)

### 4.1 Códigos

| Código | Nome | Pacotes típicos |
|---|---|---|
| `0x1001` | `ERR_INVALID_OPCODE` | todos |
| `0x1002` | `ERR_INVALID_PAYLOAD` | todos |
| `0x1003` | `ERR_DAILY_REROLL_LIMIT` | `REROLL` |
| `0x1004` | `ERR_SLOT_LOCKED` | `SELECT`, `EXTRA_SLOT` |
| `0x1005` | `ERR_NOT_ENOUGH_POINTS` | `SHOP_BUY`, `TALISMAN_UPGRADE`, `EXTRA_SLOT` |
| `0x1006` | `ERR_TASK_NOT_COMPLETED` | `CLAIM_DAILY`, `WEEKLY_DELIVER` |
| `0x1007` | `ERR_WEEKLY_NOT_UNLOCKED` | `WEEKLY_UNLOCK_KILL`, `WEEKLY_UNLOCK_DELIVER` |
| `0x1008` | `ERR_WEEKLY_ALREADY_CLAIMED` | `WEEKLY_DELIVER` |
| `0x1009` | `ERR_FEATURE_DISABLED` | todos (gate desligado) |
| `0x100A` | `ERR_VERSION_UNSUPPORTED` | todos |
| `0x100B` | `ERR_RATE_LIMIT` | todos |

### 4.2 Comportamento obrigatório do cliente ao receber erro

1. **Nunca desconectar automaticamente** por `ERR_*` funcional (`0x1003+`), apenas em corrupção de stream.
2. **Consumir integralmente o pacote** (`RESULT`) e invalidar estado local otimista relacionado à ação.
3. **Reconciliar UI** solicitando refresh do bloco afetado:
   - `CURRENCIES` após `ERR_NOT_ENOUGH_POINTS`;
   - `BOUNTY_DATA` após `ERR_SLOT_LOCKED`/`ERR_DAILY_REROLL_LIMIT`;
   - `WEEKLY_DATA` após erros semanais.
4. **Mostrar feedback determinístico** com `message` do servidor (sem sobrescrever texto de erro técnico).
5. **Aplicar backoff exponencial** quando `ERR_RATE_LIMIT` (`250ms`, `500ms`, `1000ms`, máx `2s`).
6. **Em `ERR_VERSION_UNSUPPORTED`**: bloquear tela do módulo, exibir aviso de atualização e não reenviar pacote antigo.

---

## 5) Estratégia de compatibilidade retroativa

## 5.1 Cliente antigo -> Servidor novo

- Servidor deve aceitar `version` menor se o opcode existir e o payload mínimo for válido.
- Campos novos devem ser **sempre opcionais via `hasX`**.
- Na ausência do campo, usar default server-side estável (sem inferência por heurística de UI).
- Se o comportamento mudou semanticamente e não há fallback seguro: responder `ERR_VERSION_UNSUPPORTED`.

## 5.2 Cliente novo -> Servidor antigo

- Cliente deve detectar ausência de `feature gate` por erro (`ERR_FEATURE_DISABLED`) ou silêncio com timeout controlado.
- Cliente deve degradar funcionalidade:
  - esconder botão de feature não suportada;
  - manter apenas fluxo `v1` básico (open/select/reroll/claim).
- Reenvio com versão menor é permitido **uma única vez** por sessão/opcode para evitar loop.

## 5.3 Regras de evolução

1. Não reutilizar opcode para semântica diferente.
2. Somente append de campos no final + `hasX`.
3. Documentar novos gates e defaults no mesmo commit.
4. Validar matriz de compatibilidade em testes de integração (`old client/new server`, `new client/old server`).

---

## 6) Checklist de implementação

- [ ] Parser C++/Lua alinhado à ordem binária declarada.
- [ ] Escrita/leitura de `bool` padronizada em `u8`.
- [ ] Todos os campos opcionais protegidos por `hasX`.
- [ ] Todos os erros retornam via `RESULT (0x39)` com `resultCode` e `message`.
- [ ] Logs de versão/opcode habilitados para troubleshooting.
