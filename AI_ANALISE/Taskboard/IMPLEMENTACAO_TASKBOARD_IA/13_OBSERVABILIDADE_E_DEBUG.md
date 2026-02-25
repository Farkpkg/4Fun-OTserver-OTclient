# 13. Observabilidade e Debug

## Objetivo
Definir um padrão único de observabilidade para o fluxo de **Daily Reward / Reward Wall / ações econômicas associadas**, cobrindo:
- logs estruturados por ação (`open`, `select`, `reroll`, `claim`, `buy`),
- métricas de erro por `opcode/state`,
- métricas de economia (entrada/saída por moeda),
- tracing do **weekly reset**,
- payload de debug sanitizado para divergência client/server.

---

## 1) Log estruturado por ação

### 1.1 Campos base (obrigatórios)
Todos os eventos devem carregar:
- `event_name`: nome canônico (ex.: `rewardwall.open`, `rewardwall.claim`),
- `action`: `open | select | reroll | claim | buy`,
- `ts_unix_ms`: timestamp em ms,
- `trace_id`: id de correlação fim-a-fim,
- `session_id`: sessão do cliente,
- `player_id_hash`: hash estável do player (não logar nome/plain id),
- `account_id_hash`: hash estável da conta,
- `character_id`: id interno do personagem (se permitido internamente),
- `source`: `client_ui | protocolgame | game | io`,
- `result`: `ok | rejected | error`,
- `latency_ms`: duração da operação (quando aplicável),
- `build`: versão client/server.

### 1.2 Campos por ação

#### `open`
- `surface`: `reward_wall | reward_history | shop`,
- `entry_point`: botão, shrine, hotkey, auto-open,
- `opcode_in` / `opcode_out`.

#### `select`
- `reward_day`,
- `bundle_type` (`items`, `xp_boost`, `prey`, ...),
- `selection_count`,
- `selection_item_ids` (somente ids, sem nome livre).

#### `reroll`
- `reroll_type`: `prey_slot | task_slot | bonus_type | reward_option`,
- `slot`,
- `currency_type`,
- `currency_spent`,
- `free_reroll_used`.

#### `claim`
- `claim_type`: `daily_reward | reward_chest | task_reward`,
- `reward_day`,
- `streak_before`, `streak_after`,
- `joker_before`, `joker_after`,
- `instant_reward_access_used`.

#### `buy`
- `store_context`: `instant_reward_access | premium_boost | shop_npc | market`,
- `offer_id` / `item_id`,
- `amount`,
- `price`,
- `currency_type`,
- `balance_before`, `balance_after`.

### 1.3 Exemplo de log JSON
```json
{
  "event_name": "rewardwall.claim",
  "action": "claim",
  "ts_unix_ms": 1736202345123,
  "trace_id": "4b3e02f6-2df8-4f6e-b06e-d9dcff8b3f4a",
  "session_id": "sess-98ab12",
  "player_id_hash": "p_8f2f...",
  "account_id_hash": "a_102a...",
  "source": "protocolgame",
  "result": "ok",
  "claim_type": "daily_reward",
  "reward_day": 4,
  "streak_before": 12,
  "streak_after": 13,
  "joker_before": 1,
  "joker_after": 1,
  "instant_reward_access_used": true,
  "opcode_in": 216,
  "opcode_out": 226,
  "latency_ms": 18
}
```

---

## 2) Métricas de erro por opcode/state

### 2.1 Contadores recomendados
- `reward_error_total{opcode,state,action,source,reason}`
- `reward_request_total{opcode,action,source}`
- `reward_success_total{opcode,action,source}`
- `reward_rejected_total{opcode,state,action,reason}`

### 2.2 Taxas derivadas
- `error_rate_by_opcode = reward_error_total / reward_request_total`
- `rejected_rate_by_state = reward_rejected_total / reward_request_total`

### 2.3 Estados mínimos padronizados
- `state=not_available`
- `state=already_collected`
- `state=locked`
- `state=insufficient_balance`
- `state=invalid_selection`
- `state=timeout`
- `state=server_exception`

### 2.4 Regras de cardinalidade
- **Não** usar labels de alta cardinalidade (`player_name`, `trace_id`) em métricas.
- `reason` deve ser enum curto (`no_ira`, `bad_slot`, `no_money`, `db_error`, ...).

---

## 3) Métricas de economia (entrada/saída por moeda)

### 3.1 Métricas
- `economy_currency_in_total{currency,context}`
- `economy_currency_out_total{currency,context}`
- `economy_balance_change_total{currency,context,direction}`

`currency` sugerido:
- `gold`, `bank_gold`, `coin`, `coin_transferable`, `prey_cards`, `task_points`, `forge_dust`, `forge_sliver`, `forge_core`, `daily_reward_joker`, `instant_reward_access`.

`context` sugerido:
- `daily_reward_claim`, `reward_reroll`, `task_hunting_reroll`, `shop_buy`, `market_buy`, `market_sell`, `npc_trade`.

### 3.2 Invariantes
- Toda saída (`out`) relevante deve ter evento de origem (`action`) com mesmo `trace_id`.
- Para fluxo de compra: `balance_after = balance_before - spent (+/- fees)`.
- Se falha após débito, registrar compensação explícita (`context=rollback`).

---

## 4) Tracing de weekly reset

### 4.1 Spans
Criar um trace com root span:
- `weekly_reset.run`

E subspans:
- `weekly_reset.begin`
- `weekly_reset.compute_targets`
- `weekly_reset.apply_player_changes`
- `weekly_reset.apply_reward_pool`
- `weekly_reset.persist`
- `weekly_reset.finish`

### 4.2 Atributos obrigatórios
- `reset_week_id` (ex.: `2026-W07`),
- `start_ts`, `end_ts`, `duration_ms`,
- `players_scanned`, `players_updated`, `players_failed`,
- `streaks_reset_count`,
- `jokers_granted_count`,
- `instant_reward_access_granted_count`,
- `affected_item_count` (total),
- `affected_item_types` (agregado por tipo),
- `dry_run`.

### 4.3 Eventos de trace
- `weekly_reset.started`
- `weekly_reset.batch_applied`
- `weekly_reset.error`
- `weekly_reset.completed`

---

## 5) Payload de debug sanitizado (divergência client/server)

### 5.1 Quando emitir
Emitir quando houver mismatch entre estado esperado no client e estado confirmado pelo server:
- reward disponível no client e negada no server,
- diferença de `streak`, `jokers`, `instant_reward_access`,
- seleção inválida após confirmação local,
- resposta com `opcode/state` não esperado.

### 5.2 Schema sanitizado
```json
{
  "event_name": "rewardwall.desync",
  "trace_id": "...",
  "session_id": "...",
  "ts_unix_ms": 1736202345123,
  "client": {
    "build": "otclient-x.y.z",
    "opcode_sent": 218,
    "ui_action": "select",
    "reward_day": 5,
    "selection_item_ids": [3031, 268],
    "selection_count": 2,
    "state_snapshot": {
      "streak": 14,
      "jokers": 2,
      "instant_reward_access": 1
    }
  },
  "server": {
    "build": "crystalserver-x.y.z",
    "opcode_received": 218,
    "state": "invalid_selection",
    "state_snapshot": {
      "streak": 13,
      "jokers": 2,
      "instant_reward_access": 1
    },
    "error_code": "bad_slot"
  },
  "sanitized": true
}
```

### 5.3 Regras de sanitização
- Remover PII: nome de personagem, IP, e-mail, texto livre de chat.
- Hash para IDs de conta/personagem quando sair do ambiente interno.
- Limitar arrays (`selection_item_ids`) por tamanho (ex.: 20).
- Truncar payload total (ex.: 8KB).
- Nunca logar tokens/chaves/sessões completas.

---

## 6) Mapeamento de instrumentação no server

## 6.1 `protocolgame` (entrada/saída de pacote)
**Objetivo:** medir tráfego, opcode/state, latência e rejeições iniciais.

Pontos prioritários:
1. `parseExtendedOpcode(...)` para rotas customizadas de Reward Wall e telemetria por opcode.
2. `parsePlayerBuyOnShop(...)` / `parsePlayerSellOnShop(...)` para ação `buy`.
3. `parseRewardChestCollect(...)` para ação `claim` de reward chest.
4. `updateCoinBalance()` / `sendCoinBalance()` para reconciliar economia pós-operação.
5. pontos de envio de recursos (`sendResourceBalance(...)`) para snapshots de saldo.

Instrumentação:
- iniciar `trace_id` ao entrar no parse,
- logar `opcode_in`, `payload_size`, `action`,
- fechar com `result`, `state`, `latency_ms`.

## 6.2 `game` (regra de negócio)
**Objetivo:** medir decisão de regra e impacto lógico.

Pontos prioritários:
1. fluxos de coleta de recompensa (`playerRewardChestCollect(...)` e correlatos),
2. validações de estado de streak/reward antes de conceder,
3. aplicação de bônus e mudanças de recursos,
4. contadores agregados de sucesso/rejeição por `state`.

Instrumentação:
- logs de decisão (`eligible`, `rejected_reason`),
- métricas de domínio (`reward_success_total`, `reward_rejected_total`),
- vínculo com `trace_id` vindo do protocolo.

## 6.3 `io` (persistência e efeitos econômicos)
**Objetivo:** garantir rastreabilidade de gravação e consistência financeira.

Pontos prioritários:
1. `iologindata_load_player` / `iologindata_save_player` para campos de reward/streak,
2. `ioprey` para `reroll` e `claim` de task/prey,
3. qualquer rotina de save de recursos/moedas associada a `buy` e `claim`.

Instrumentação:
- `io_write_total{table,operation,result}`,
- tempo de query e falhas (`db_error`),
- evento de compensação financeira em rollback.

---

## 7) Mapeamento de eventos de UI no client

### 7.1 Reward Wall (core)
Instrumentar os handlers:
- `show()` → `action=open` (`surface=reward_wall`),
- `onClickshowHistory()` → `action=open` (`surface=reward_history`),
- `onClickDisplayWindowsPickRewardWindow(...)` → `action=select` (intenção e contexto),
- `onTextChangeChangeNumber(...)` → `action=select` (mudança de seleção),
- `onClickBtnOk()` + confirmação final (`requestGetRewardDaily`) → `action=claim`,
- `onClickbuyInstantRewardAccess()` → `action=buy`,
- callbacks de erro/server (`onDailyRewardCollectionState`, mensagens de erro) → `result=rejected|error` com `state`.

### 7.2 Loja / compra (quando acionada pelo fluxo de reward)
- clique para abrir loja de premium boost,
- clique para comprar `Instant Reward Access`,
- retorno de sucesso/falha de compra,
- snapshot de saldo antes/depois (sem PII).

### 7.3 Boas práticas client
- gerar `trace_id` no clique inicial e propagar até resposta,
- não bloquear UI por falha de telemetria,
- usar fila assíncrona com backoff,
- telemetria com sampling para eventos de alta frequência (`onTextChange...`).

---

## 8) Plano mínimo de implementação

1. **Fase 1 (base):** logs estruturados + `trace_id` em `protocolgame` e Reward Wall UI.
2. **Fase 2 (métricas):** contadores de erro por `opcode/state` + economia por moeda.
3. **Fase 3 (weekly reset):** spans completos e eventos de início/fim/itens afetados.
4. **Fase 4 (desync):** payload sanitizado de divergência client/server com alertas.

---

## 9) Alertas operacionais sugeridos
- `error_rate_by_opcode > 3%` por 5 min,
- aumento abrupto de `invalid_selection` ou `insufficient_balance`,
- weekly reset sem evento `completed`,
- diferença anômala entre `economy_currency_out_total` e eventos de `buy/claim`.

