# TaskBoard — Documentação Técnica Oficial

> Status: **implementado e funcional (v1)** com sync/delta, camadas servidor/cliente, UI reativa e hardening inicial.

---

## 1) Visão Geral do Sistema

## Objetivo
O **TaskBoard** é o sistema unificado de tarefas semanais/diárias do projeto, com 3 áreas principais:
- **Bounty Tasks**
- **Weekly Tasks**
- **Hunting Task Shop**

Ele substitui abordagens antigas de task com uma arquitetura por camadas, protocolo versionado, estado cliente reativo e atualização incremental por delta.

## Onde se encaixa no projeto
- **Servidor (Canary)**: define regras, validações, geração, progressão e persistência/cache.
- **Cliente (OTClient)**: renderiza estado recebido do servidor e envia intenções (`open`, `selectDifficulty`, `reroll`, `deliver`, `buy`, `claimBounty`).

## Diagrama conceitual (alto nível)

```text
[Player UI Action]
    -> OTClient game_taskboard/protocol.lua (ExtendedOpcode)
        -> Server taskboard/infrastructure/network.lua
            -> application/service.lua
                -> domain/* + application/* + infrastructure/repository/cache
            <- {sync|deltas}
        <- OTClient state_store -> viewmodel -> controller -> widgets OTUI
```

---

## 2) Arquitetura do Servidor (Canary)

## Estrutura de pastas (atual)

```text
crystalserver/data/modules/taskboard/
  init.lua
  constants.lua
  domain/
    models.lua
    validator.lua
    calculator.lua
  application/
    service.lua
    generator.lua
    bounty_service.lua
    weekly_service.lua
    shop_service.lua
    reset_service.lua
  infrastructure/
    repository.lua
    cache.lua
    serializer.lua
    network.lua
    hooks.lua
```

> **Nota sobre arquitetura alvo**: `config/` e `compatibility/legacy_weekly_adapter.lua` eram previstos no desenho arquitetural, mas **não estão materializados neste snapshot**. O conteúdo/pools está definido diretamente em serviços/generator nesta versão.

## Papel de cada arquivo
- `init.lua`: bootstrap do módulo.
- `constants.lua`: opcode, schema version, actions e nomes de delta.
- `domain/models.lua`: entidades de domínio (tasks, progress, state).
- `domain/validator.lua`: validações puras (kill/delivery/difficulty/reroll).
- `domain/calculator.lua`: multiplicador e cálculo de recompensa.
- `application/service.lua`: façade de casos de uso.
- `application/generator.lua`: geração de bounties/weekly por difficulty.
- `application/bounty_service.lua`: seleção de difficulty, reroll, progresso/claim bounty.
- `application/weekly_service.lua`: kills/delivery semanais + progresso/multiplicador.
- `application/shop_service.lua`: catálogo de ofertas e compra com limites.
- `application/reset_service.lua`: rotação determinística de semana (`weekKey`).
- `infrastructure/repository.lua`: interface de persistência (stubs/TODOs).
- `infrastructure/cache.lua`: cache em memória por jogador.
- `infrastructure/serializer.lua`: encode/decode payload protocolar.
- `infrastructure/network.lua`: dispatcher de actions e emissão sync/delta.
- `infrastructure/hooks.lua`: integração com eventos de login/kill/startup.

## Domain Layer

## Entidades principais (resumo)

| Entidade | Campos-chave | Uso |
|---|---|---|
| `WeeklyTask` | `id`, `subtype`, `targetName`, `targetId`, `required`, `current`, `completed` | Task semanal unificada (kill/delivery). |
| `BountyTask` | `id`, `monsterName`, `required`, `current`, `completed`, `claimed` | Card de bounty com claim. |
| `PlayerTaskState` | `playerId`, `weekKey`, `boardState`, `difficulty` | Estado global do board por jogador/semana. |
| `WeeklyProgress` | `completedKills`, `completedDeliveries`, `totalCompleted`, `taskPoints`, `soulSeals` | Agregado semanal e economia. |
| `MultiplierState` | `value`, `band`, `nextThreshold` | Valor de multiplicador e faixa atual. |
| `ShopItem` | `id`, `name`, `description`, `pricePoints`, `weeklyLimit`, `purchased` | Oferta da loja semanal. |
| `RerollState` | `dailyLimit`, `weeklyLimit`, `dailyUsed`, `weeklyUsed`, `cooldownUntil` | Controle de reroll. |
| `PreferredListState` | (reservado para evolução) | Priorização de alvos em geração futura. |

## Application Layer

## Serviços e interfaces públicas

### `service.lua` (façade)
- `openBoard(playerId, currentWeekKey)`
- `selectDifficulty(playerId, difficulty)`
- `reroll(playerId, currentTimeUTC)`
- `onKill(playerId, monsterName)`
- `deliver(playerId, itemId)`
- `claimBounty(playerId, bountyId)`
- `buy(playerId, offerId)`

Retorno padrão:

```lua
{
  sync = <table|nil>,
  deltas = { ... },
  error = <string|nil>
}
```

### `generator.lua`
- `generateBounties(difficulty, weekKey)`
- `generateWeeklyTasks(difficulty, weekKey)`

### `bounty_service.lua`
- `selectDifficulty`, `reroll`, `incrementKill`, `claimBounty`

### `weekly_service.lua`
- `incrementKill`, `deliverItem`, `recalcProgress`

### `shop_service.lua`
- `getOffers(playerId)`
- `buy(playerId, offerId)`

### `reset_service.lua`
- `ensureWeek(playerId, currentWeekKey)`

## Infrastructure Layer

### `repository.lua`
Camada de persistência (estrutura presente; implementação SQL complexa ainda evolutiva).

### `cache.lua`
Cache em memória por player para estado de board/task/progresso e metadados.

### `serializer.lua`
Serialização central de payload; evita JSON manual por regex.

### `network.lua`
- Escuta `OP_CODE_TASKBOARD`.
- Roteia action -> `TaskBoardService`.
- Envia envelopes:
  - `{ type = "sync", data = ... }`
  - `{ type = "delta", data = ... }`

### `hooks.lua`
- `onLogin`: registra eventos + `openBoard` inicial.
- `onKill`: delega kill ao service.
- `onStartup`: registra weekKey ativa.

## Compatibilidade (legacy)
Nesta versão, não existe arquivo explícito `legacy_weekly_adapter.lua`; migração/convivência com legado deve ser tratada em fase dedicada (compatibility layer).

---

## 3) Protocolo Cliente–Servidor

## Envelopes

```json
{ "type": "sync", "data": { ... } }
{ "type": "delta", "data": { ... } }
```

## `schemaVersion`
Definido no servidor em `constants.lua` como `1`.

## Exemplo de Sync Payload

```json
{
  "state": {
    "playerId": 42,
    "weekKey": "2026-W07",
    "boardState": "ACTIVE",
    "difficulty": "Adept"
  },
  "weekKey": "2026-W07",
  "bounties": [ ... ],
  "weeklyTasks": [ ... ],
  "weeklyProgress": {
    "completedKills": 1,
    "completedDeliveries": 0,
    "totalCompleted": 1,
    "taskPoints": 80,
    "soulSeals": 2
  },
  "multiplier": 1.3,
  "rerollState": {
    "dailyLimit": 1,
    "weeklyLimit": 3,
    "dailyUsed": 0,
    "weeklyUsed": 1,
    "cooldownUntil": 1730000000
  },
  "shopOffers": [ ... ],
  "shopPurchases": {
    "xp_boost_small": 1
  }
}
```

## Eventos Delta

### `taskUpdated`
```json
{
  "type": "taskUpdated",
  "data": {
    "scope": "bounty|weekly",
    "task": { ... }
  }
}
```

### `progressUpdated`
```json
{
  "type": "progressUpdated",
  "data": {
    "taskPoints": 60,
    "totalCompleted": 4
  }
}
```

### `multiplierUpdated`
```json
{
  "type": "multiplierUpdated",
  "data": {
    "value": 1.7
  }
}
```

### `shopUpdated`
```json
{
  "type": "shopUpdated",
  "data": {
    "offerId": "xp_boost_small",
    "purchased": 2,
    "weeklyLimit": 5,
    "limitReached": false
  }
}
```

### `weekRotated`
```json
{
  "type": "weekRotated",
  "data": {
    "weekKey": "2026-W08"
  }
}
```

---

## 4) OTClient — Estrutura do Módulo

```text
otclient/modules/game_taskboard/
  taskboard.lua
  taskboard_controller.lua
  taskboard_viewmodel.lua
  state_store.lua
  protocol.lua
  taskboard.otui
  components/
    bounty_card.otui
    weekly_slot.otui
    shop_card.otui
    progress_track.otui
    talisman_panel.otui
```

## Responsabilidades
- `taskboard.lua`: ciclo de vida, botão lateral, init/terminate.
- `protocol.lua`: registro opcode + dispatch sync/delta + envio actions.
- `state_store.lua`: fonte única de estado + reducers de delta.
- `taskboard_viewmodel.lua`: transforma estado bruto em estado renderizável.
- `taskboard_controller.lua`: manipula widgets/render e envia intenções.
- `*.otui`: definição visual declarativa.

---

## 5) UI & UX — Descrição Visual Técnica

## Abas
1. Bounty Tasks
2. Weekly Tasks
3. Hunting Task Shop

## Bounty
- Toolbar: difficulty, preferred list, reroll, claim daily.
- 3 cards fixos.
- Estados: ativo, em progresso, completo, bloqueado (sem difficulty).

## Weekly
- Coluna esquerda: 3 kill slots.
- Coluna direita: 3 delivery slots.
- Faixa inferior: progresso total + trilho de multiplicador.

## Shop
- Grid 3 colunas + scroll vertical.
- Card com: ícone, nome, descrição, custo, limite semanal, comprado, estado e botão Buy.

---

## 6) Fluxo de Ações

## Abertura da UI
```text
UI open -> sendAction(open)
       -> server service.openBoard
       -> sync full payload
       -> store.setFullState -> viewmodel -> render
```

## Selecionar difficulty
```text
dropdown -> selectDifficulty
         -> server valida + gera tasks
         -> sync/deltas
         -> cliente re-render incremental
```

## Kill update
```text
onKill(server) -> service.onKill -> taskUpdated/progressUpdated/multiplierUpdated
               -> client reducer -> update slot/card específico
```

## Delivery update
```text
deliver action -> service.deliver -> deltas -> update weekly slot/progress
```

## Reroll
```text
reroll click -> sendAction(reroll)
             -> server valida cooldown/limites
             -> taskUpdated(scope=bounty)
             -> client troca cards reativamente
```

## Claim bounty
```text
claim click -> sendAction(claimBounty, { bountyId })
            -> server claimBounty
            -> delta taskUpdated bounty
```

## Shop purchase
```text
buy click -> sendAction(buy, { offerId })
          -> server buy (saldo + limite semanal)
          -> progressUpdated + shopUpdated
          -> client atualiza header e card afetado
```

## Week rotation
```text
server weekRotated -> client marca awaitingSync -> protocol solicita open
                   -> sync novo -> store full replace
```

---

## 7) Comportamento de Estado

## `state_store`
- Mantém `ui` + `server`.
- `setFullState`: substituição total.
- `applyDelta`: patch incremental por tipo de evento.
- `resetServerState`: limpeza de sessão/reconnect.

## `viewmodel`
- Converte payload de domínio em campos de render (`progressPercent`, `stateLabel`, etc.).
- Mantém regra de apresentação fora do controller.

## `controller`
- Atualiza widgets.
- Evita rebuild agressivo.
- Usa render pontual por IDs em deltas (`bountyTaskId`, `weeklyTaskId`, `shopOfferId`).

---

## 8) Regras de Negócio

## Weekly multiplier bands
- 0–3 => 1.0
- 4–7 => 1.3
- 8–11 => 1.7
- 12–15 => 2.0
- 16–18 => 2.5

## Reroll
- Limites diário/semanal + cooldown.
- Validado no servidor.

## Difficulty
- Seleção inicial e travamento conforme estado semanal.

## Shop
- Custo em `taskPoints`.
- Limite semanal por oferta.
- Compra sem desconto otimista no cliente.

## Claim Daily / Claim Bounty
- Requer task completa e não reivindicada.
- Envio com `bountyId` explícito.

---

## 9) Testing & Quality

## Testes já aplicados
- Verificação de wiring por `rg` (actions, deltas, handlers).
- Validação estática de componentes OTUI usados.
- Hardening inicial para rotação/reconnect e anti-spam de ações.

## Testes recomendados (fase hardening)
1. `weekRotated` com janela aberta.
2. reconnect com board aberto.
3. kill spam (20+ eventos rápidos).
4. spam de buy/reroll.
5. limites semanais e cooldown virando em sessão ativa.

## Casos de canto
- Delta fora de ordem.
- Oferta inexistente em `shopUpdated`.
- `sync` parcial após reconnect.
- UI aberta com estado aguardando sync.

---

## 10) FAQ e Troubleshooting

## `RectangleProgressBar is not a defined style`
**Causa**: estilo inexistente no client.
**Correção**: usar `ProgressBar` padrão OTClient.

## `attempt to index upvalue 'window' (a nil value)`
**Causa**: UI não carregou e módulo continuou init.
**Correção**: validar `displayUI` antes de acessar `window`.

## UI não atualiza após delta
- Verifique `payload.type == "delta"`.
- Verifique `dirty flags` no reducer.
- Verifique mapeamento `id -> widget` (slot/card).

## Desync de shop points
- Garantir que cliente não desconta saldo localmente.
- Confirmar recebimento de `progressUpdated` após buy.

---

## 11) CHANGELOG (modelo)

```markdown
## [v1.0] — 2026-02-XX
- initial release
- backend: taskboard module (domain/application/infrastructure)
- client: game_taskboard with sync/delta reactive rendering

## [v1.1] — YYYY-MM-DD
- hardening: reconnect + weekRotated recovery
- shop: weekly limit improvements
```

---

## 12) Exemplo de Uso e Extensão

## Abrir TaskBoard
```lua
TaskBoardProtocol.sendAction('open', {})
```

## Exemplo de delta aplicado no cliente
```lua
local dirty = TaskBoardStore.applyDelta(delta)
TaskBoardController.renderDelta(dirty)
```

## Como estender (ex.: nova reward da shop)
1. Adicionar oferta no `shop_service.lua` (`OFFERS`, `OFFER_ORDER`).
2. Expor no `sync` (`shopOffers` já previsto).
3. Garantir campos no `viewmodel` (`mapShopOffers`).
4. Render automático no controller (cards reutilizáveis).
5. Adicionar teste de limite semanal/saldo para nova oferta.

---

## Boas práticas (docs-as-code)
- Versionar esta documentação junto aos commits do módulo.
- Atualizar seção de protocolo sempre que alterar payload/schema.
- Tratar revisão de documentação como parte do **Definition of Done**.
