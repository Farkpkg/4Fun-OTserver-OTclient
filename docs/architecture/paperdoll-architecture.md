# Arquitetura do sistema Paperdoll (CrystalServer + OTClient)

## 1) Visão de componentes

## 1.1 Backend (CrystalServer / Canary mod)

Componentes sugeridos:

- `PaperdollService` (Lua): regra de negócio (apply, validate, merge com equipment).
- `PaperdollRepository` (Lua/DB): persistência e cache de player.
- `PaperdollConfig` loader: parse de `paperdoll.xml` e `equipment_paperdoll.xml`.
- Hooks de eventos:
  - `onLogin` → carregar e sincronizar snapshot,
  - `onLogout` → flush/caches,
  - `onEquip`/`onDeEquip` → recomputar visual incremental,
  - handler de opcode customizado.

## 1.2 Client (OTClient)

- Módulo `game_paperdoll`:
  - UI: janela de seleção/preview,
  - estado local: `currentPaperdoll`, `unlockedSet`,
  - comunicação: registro de `ExtendedOpcode`.
- Integrações:
  - `game_outfit` para preview base,
  - `game_inventory` para gatilhos de refresh,
  - `g_game.getLocalPlayer():setOutfit(...)` conforme pipeline disponível.

---

## 2) Fluxo principal

1. **Login**: server carrega DB e envia `paperdoll_snapshot`.
2. **Client aplica estado** no preview e no personagem local/remoto (quando aplicável).
3. **Equip change**: evento server recalcula slots impactados e envia `paperdoll_update`.
4. **Player edita visual**: client envia `paperdoll_apply_request`.
5. **Server valida** (unlock/restrições), persiste, aplica e responde `paperdoll_apply_result`.

---

## 3) Regras de merge (equipment + paperdoll)

### 3.1 Matriz de decisão por slot

- Se slot cosmético `enabled=true` e `appearance` válido/desbloqueado -> usar cosmético.
- Senão, se item equipado tem mapping `default/forced` -> usar mapping.
- Senão, cair para visual padrão do outfit.

### 3.2 Exceções

- `forced` de eventos críticos pode sobrepor cosmético.
- Transformações de spell podem bloquear paperdoll temporariamente.

---

## 4) Estrutura de módulos Lua (sugestão)

```text
crystalserver/data/scripts/paperdoll/
  config.lua                -- caminhos, opcode, constantes
  loader.lua                -- parse XML
  repository.lua            -- SQL CRUD
  validator.lua             -- regras de unlock/restrição
  service.lua               -- merge + apply + sync
  events_login.lua          -- CreatureEvent onLogin
  events_equip.lua          -- MoveEvent onEquip/onDeEquip
  extopcode.lua             -- handler requests client
  talkactions_debug.lua     -- comandos admin opcional
```

---

## 5) UI e UX no OTClient

Widgets recomendados:

- `PaperdollWindow` (principal)
- `SlotListPanel` (slots disponíveis)
- `AppearanceGrid` (skins desbloqueadas)
- `ColorPickerPanel` (quando `colorable=1`)
- `PreviewCreatureWidget` (preview local antes de confirmar)
- `ApplyButton`, `ResetButton`, `SavePresetButton`

Princípios:

- edição local instantânea no preview,
- confirmação explícita para enviar ao servidor,
- feedback de erro amigável (falta unlock, premium, level).

---

## 6) Performance e escalabilidade

- Cache em memória por sessão para evitar SELECT a cada troca.
- Atualização incremental por slot em vez de snapshot total.
- Rate limit por player no opcode (`N` requests/segundo).
- Compressão opcional de payload se muito grande (não necessário em maioria dos casos).

---

## 7) Compatibilidade e fallback

- Se client não suporta módulo paperdoll:
  - servidor segue gameplay normal,
  - apenas outfit padrão/equipment visual clássico.
- Se asset ID inexistente no client:
  - logar warning,
  - fallback para aparência segura.

---

## 8) Segurança

- Não aceitar `appearance_id` do client sem validar desbloqueio.
- Não aceitar cores fora da faixa permitida.
- Não confiar em `slot` enviado pelo client (validar enum).
- Auditoria opcional em log para detecção de abuso.
