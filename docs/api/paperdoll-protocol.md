# Protocolo de sincronização Paperdoll (ExtendedOpcode)

## 1) Estratégia de transporte

Recomendação para OTC v8/Redemption/Mehah:

- usar `ProtocolGame.registerExtendedOpcode(opcodeId, handler)` no client,
- usar callback equivalente no server (Lua/C++) para receber requests.

`opcodeId` sugerido: **92** (ajustar se já ocupado).

Payload em JSON UTF-8, com envelope comum:

```json
{
  "schemaVersion": 1,
  "type": "...",
  "requestId": "uuid-opcional",
  "timestamp": 1730000000,
  "data": {}
}
```

---

## 2) Tipos de mensagem

## 2.1 Server -> Client

### `paperdoll_snapshot`

- enviado no login/reconnect,
- contém estado completo + unlocks.

### `paperdoll_update`

- enviado em atualização incremental (equip, unlock, reset).

### `paperdoll_apply_result`

- retorno de tentativa de aplicação.
- campos:
  - `ok: boolean`
  - `errorCode: string|null`
  - `effectiveState: object`

### `paperdoll_unlock_notify`

- informa unlock recém-obtido.

## 2.2 Client -> Server

### `paperdoll_apply_request`

- tentativa de aplicar mudanças.
- payload:

```json
{
  "schemaVersion": 1,
  "type": "paperdoll_apply_request",
  "requestId": "b4c0de",
  "data": {
    "slots": {
      "helmet": {"appearanceId": 2104, "enabled": true},
      "cape": {"appearanceId": 3402, "enabled": false},
      "armor": {"appearanceId": 3001, "colorPrimary": 114, "enabled": true}
    }
  }
}
```

### `paperdoll_request_snapshot`

- pedido explícito de resync (debug/recovery).

---

## 3) Códigos de erro padronizados

- `ERR_INVALID_SLOT`
- `ERR_INVALID_APPEARANCE`
- `ERR_NOT_UNLOCKED`
- `ERR_PREMIUM_REQUIRED`
- `ERR_LEVEL_REQUIRED`
- `ERR_VOCATION_NOT_ALLOWED`
- `ERR_COLOR_OUT_OF_RANGE`
- `ERR_RATE_LIMIT`
- `ERR_INTERNAL`

---

## 4) Handler server (pseudo-Lua)

```lua
local OPCODE_PAPERDOLL = 92

local function onPaperdollOpcode(player, opcode, buffer)
  if opcode ~= OPCODE_PAPERDOLL then
    return
  end

  local msg = json.decode(buffer)
  if not msg or msg.schemaVersion ~= 1 then
    return
  end

  if msg.type == "paperdoll_apply_request" then
    local ok, result = PaperdollService.applyRequest(player, msg.data)
    PaperdollService.sendApplyResult(player, msg.requestId, ok, result)
    return
  end

  if msg.type == "paperdoll_request_snapshot" then
    PaperdollService.sendSnapshot(player)
    return
  end
end
```

---

## 5) Handler client (pseudo-Lua OTC)

```lua
local OPCODE_PAPERDOLL = 92

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_PAPERDOLL then return end

  local msg = json.decode(buffer)
  if not msg or msg.schemaVersion ~= 1 then return end

  if msg.type == 'paperdoll_snapshot' then
    PaperdollController:setFullState(msg.data)
  elseif msg.type == 'paperdoll_update' then
    PaperdollController:applyIncremental(msg.data)
  elseif msg.type == 'paperdoll_apply_result' then
    PaperdollController:onApplyResult(msg.requestId, msg.data)
  elseif msg.type == 'paperdoll_unlock_notify' then
    PaperdollController:onUnlock(msg.data)
  end
end
```

---

## 6) Sequência recomendada

1. Login concluído -> server envia `snapshot`.
2. Client abre UI e envia `apply_request` quando confirmar alteração.
3. Server valida e responde `apply_result`.
4. Se aprovado, server envia `update` para refletir estado efetivo.
5. Em divergência detectada, client envia `request_snapshot`.

---

## 7) Hardening do protocolo

- `requestId` para correlação e evitar race na UI.
- Rate limit por player/IP.
- Sanitizar JSON (tamanho máximo, campos esperados).
- Fallback para ignorar campos desconhecidos (forward compatibility).
