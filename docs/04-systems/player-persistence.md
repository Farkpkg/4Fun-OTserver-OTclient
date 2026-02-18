# Sistema de Persistência de Player

## 1. Objetivo
Persistir estado de jogador entre sessões (dados base, inventário, progresso e metadados).

## 2. Escopo
Controla carga/salvamento de entidades de player e tabelas relacionadas.
Não controla parsing de protocolo no cliente.

## 3. Localização no Código

### Server
- `crystalserver/src/io/iologindata.*`
- `crystalserver/src/creatures/players/player.*`
- `crystalserver/schema.sql`

### Client
- Consumo indireto via pacotes `sendPlayerData`, `sendInventory`, etc.

## 4. Fluxo de Execução Completo
1. Login autentica conta e resolve personagem.
2. Camada IO carrega tabelas de player para objeto em memória.
3. Sessão atualiza estado em runtime.
4. Save/logout persiste blocos alterados no SQL.

## 5. Comunicação
- Opcodes utilizados: família de player data/inventory/skills/state.
- Eventos utilizados: login/logout e triggers de save.
- Estrutura de payload: binária do protocolo + schema SQL relacional.

## 6. Estruturas de Dados
- Classes C++: `Player`, `IOLoginData`.
- Tabelas Lua: storages/scripts podem complementar estado.
- Tabelas SQL envolvidas: `players`, `player_items`, `player_storage`, `player_spells`, `player_outfits`, `player_mounts`, etc.

## 7. Dependências Cruzadas
- Sistema de criaturas e inventário.
- Sistema de database manager/migrations.

## 8. Pontos de Extensão Reais
- Novas colunas/tabelas versionadas por migração.
- Sincronização de novos atributos via camada IO + protocolo.

## 9. Riscos Técnicos
- Mudanças de schema sem migração compatível.
- Salvamento parcial pode gerar inconsistência entre tabelas relacionadas.

## 10. Status
✔ Implementado
