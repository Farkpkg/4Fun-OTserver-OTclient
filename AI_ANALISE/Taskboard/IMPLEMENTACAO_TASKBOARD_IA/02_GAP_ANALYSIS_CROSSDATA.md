# GAP Analysis cruzada — Task Board vs estado atual do projeto

## A) O que já existe e deve ser reaproveitado

### Server (crystalserver)
- Núcleo de Task Hunting implementado em `IOPrey` e `TaskHuntingSlot`.
- Regras de ação já cobertas: reroll lista, reroll recompensa, selecionar monstro, listar todos por cards, cancelar, claim.
- Regras de economia já integradas (dinheiro/prey cards/task points).
- Envio de estado por slot e dados básicos via `ProtocolGame::sendTaskHuntingData` e buffer de base (`getTaskHuntingBaseDate`).
- Progressão de kills vinculada ao ciclo de combate/kill do player.

### Client (otclient)
- Opcodes server->client de task hunting já mapeados: 186 e 187.
- Parse atual consome pacotes, mas não alimenta UI/estado útil.
- Módulo maduro de referência para comportamento e widgets: `game_prey` (janela, slots, tracker, estados visuais, ações de usuário).

## B) Gaps críticos (obrigatórios)
1. **Ausência de módulo visual Task Board completo** no cliente.
2. **Ausência de callback Lua dedicado** para Task Hunting em `parseTaskHuntingBasicData`/`parseTaskHuntingData`.
3. **Ausência de envio de ações Task Hunting no cliente** (opcode 0xBA / ação + slot + flags), apesar do server já aceitar.
4. **Ausência de integração de entrada UX** (botão/menu/hotkey) para abrir o painel.

## C) Gaps importantes (fase 2)
1. Aba Weekly Tasks não representada no server atual.
2. Hunting Task Shop (outfits/mounts/promotion points) sem pipeline dedicado.
3. Preferred List no modelo oficial do Task Board ainda não está explícita como módulo separado (há overlap parcial com lógica de seleção/lista do Task Hunting atual).

## D) Dados cruzados (origem → consumo)

### Fluxo 1: slot state
- Origem: `crystalserver` gera estado do slot (`Locked/Inactive/Selection/ListSelection/Active/Completed`).
- Transporte: pacote server->client `GameServerTaskHuntingData`.
- Consumo alvo: store local em Lua (`TaskBoardModel.slots[slotId]`), render de card e ações habilitadas.

### Fluxo 2: opções de recompensa por dificuldade/raridade
- Origem: `IOPrey::initializeTaskHuntOptions()`.
- Transporte: pacote base de task hunting (basic data).
- Consumo alvo: tooltip, preview e decisão de upgrade visual do card.

### Fluxo 3: ações de usuário
- Origem: clique em botões (select/reroll/cancel/claim/upgrade).
- Transporte: `ClientTaskHuntingAction` (novo send no otclient, opcode 0xBA).
- Consumo server: `ProtocolGame::parseTaskHuntingAction` → `Game::playerTaskHuntingAction` → `IOPrey::parseTaskHuntingAction`.

### Fluxo 4: saldo de moedas
- Origem server: resources balance (money, bank, prey cards, task hunting points).
- Consumo client: cabeçalho/rodapé da janela Task Board para custos e feedback em tempo real.

## E) Conclusão técnica de “melhor maneira”
**Melhor caminho é não reescrever backend**.
- Aproveitar o Task Hunting existente como base da aba Bounty-like.
- Criar módulo `game_taskboard` no cliente com arquitetura semelhante a `game_prey` + padrões de UI recorrentes do projeto.
- Evoluir para Weekly/Shop em etapas, somente após fase 1 estabilizar contrato e usabilidade.
