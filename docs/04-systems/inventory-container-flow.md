# Sistema de Inventário e Containers

## 1. Objetivo
Gerenciar itens em slots de inventário, containers, depot/inbox e sincronização com cliente.

## 2. Escopo
Controla operações de adicionar/remover/mover itens e atualizações de container.
Não controla UI final do inventário no cliente (somente estado e eventos de rede).

## 3. Localização no Código

### Server
- `crystalserver/src/items/containers/*`
- `crystalserver/src/items/item.*`
- `crystalserver/src/server/network/protocol/protocolgame.cpp` (send/open/change container)

### Client
- `otclient/modules/game_inventory/*`
- `otclient/modules/game_containers/*`

## 4. Fluxo de Execução Completo
1. Ação do client (move/use/trade) chega por opcode.
2. Server valida e altera estrutura de item/container.
3. Server envia diffs (`open/change/delete in container`, inventory slots).
4. Client atualiza widgets de container/inventário.

## 5. Comunicação
- Opcodes utilizados: open/close/create/change/delete container, set/delete inventory.
- Eventos utilizados: callbacks de interface e hooks de move item no server.
- Estrutura de payload: posição, item id, count/subtype, slots/stackpos.

## 6. Estruturas de Dados
- Classes C++: `Item`, `Container`, `Cylinder`, `Player`.
- Tabelas Lua: scripts de eventos de item/move.
- Tabelas SQL envolvidas: `player_items`, `player_depotitems`, `player_inboxitems`, `player_stash`.

## 7. Dependências Cruzadas
- Trade, market, stash, quest rewards.

## 8. Pontos de Extensão Reais
- Novos tipos de container especializados.
- Novos eventos de item via scripts Lua.

## 9. Riscos Técnicos
- Divergência de estado entre server/client em operações concorrentes.
- Regras de capacity/stack incorretas podem duplicar/perder itens.

## 10. Status
✔ Implementado
