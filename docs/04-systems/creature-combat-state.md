# Sistema de Estado de Criaturas e Combate

## 1. Objetivo
Controlar atributos dinâmicos de criaturas (vida, mana, speed, outfit, efeitos) e resolução de combate.

## 2. Escopo
Controla runtime de combate e broadcast de estados para clientes.
Não controla persistência detalhada de histórico (apenas eventos e estado em sessão).

## 3. Localização no Código

### Server
- `crystalserver/src/creatures/creature.*`
- `crystalserver/src/creatures/combat/*`
- `crystalserver/src/server/network/protocol/protocolgame.cpp` (sendCreatureHealth/outfit/speed/etc.)

### Client
- `otclient/src/client/creature.*`
- `otclient/modules/game_battle/*`
- `otclient/modules/game_healthinfo/*`

## 4. Fluxo de Execução Completo
1. Ação de ataque/skill chega ou é acionada por AI/evento.
2. Engine de combate calcula dano/condição/modificadores.
3. Estado da criatura é atualizado.
4. Server envia mensagens de efeito/health/speed/outfit para espectadores.
5. Client atualiza render, barra de vida e battle list.

## 5. Comunicação
- Opcodes utilizados: creature data/health/light/outfit/speed/skull/party/type, efeitos gráficos.
- Eventos utilizados: callbacks de combat/healthchange/manachange.
- Estrutura de payload: IDs de criatura, valores de status, flags e structs de outfit/light.

## 6. Estruturas de Dados
- Classes C++: `Creature`, `Player`, `Monster`, `Combat`, `Condition`.
- Tabelas Lua: spells/conditions/creature callbacks.
- Tabelas SQL envolvidas: indiretas (`player_deaths`, progressão/skills), conforme evento.

## 7. Dependências Cruzadas
- Sistema de spells, items (weapons), tasks/bestiary e tracking de mortes.

## 8. Pontos de Extensão Reais
- Novas conditions/spells.
- Novos status packets para clientes custom.

## 9. Riscos Técnicos
- Saturação de pacotes em combate massivo.
- Balanceamento incorreto de fórmulas impacta múltiplos subsistemas.

## 10. Status
✔ Implementado
