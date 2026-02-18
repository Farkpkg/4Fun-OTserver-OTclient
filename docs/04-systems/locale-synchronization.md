# Sistema de Sincronização de Localização

## 1. Objetivo
Sincronizar idioma selecionado no OTClient com lógica de servidor via extended opcode.

## 2. Escopo
Controla envio de locale e callback de recepção de locale.
Não controla tradução de textos do server (somente comunicação de preferência de idioma).

## 3. Localização no Código

### Server
- `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua`

### Client
- `otclient/modules/client_locales/locales.lua`
- `otclient/modules/gamelib/const.lua`

## 4. Fluxo de Execução Completo
1. Client inicia/entra no jogo e chama `sendLocale`.
2. `sendLocale` envia `ExtendedIds.Locale` com nome do idioma.
3. Server recebe opcode no `CreatureEvent` de extended opcode.
4. Script server trata `OPCODE_LANGUAGE` e pode persistir/usar preferência.
5. Server também pode responder opcode de locale para ajuste client-side.

## 5. Comunicação
- Opcodes utilizados: `ExtendedIds.Locale = 1` (client) e `OPCODE_LANGUAGE = 1` (server script).
- Eventos utilizados: `onGameStart` (client), `CreatureEvent.onExtendedOpcode` (server).
- Estrutura de payload: string simples (`"en"`, `"pt"`, etc.).

## 6. Estruturas de Dados
- Classes C++: `ProtocolGame`, `CreatureEvent`.
- Tabelas Lua: `installedLocales`, `currentLocale`, `ExtendedIds`.
- Tabelas SQL envolvidas: nenhuma no exemplo padrão.

## 7. Dependências Cruzadas
- Sistema de módulos client (reload de módulos após troca de locale).
- Pipeline de extended opcode.

## 8. Pontos de Extensão Reais
- Persistência de idioma por storage/account no callback server.
- Validação de locales permitidos por configuração.

## 9. Riscos Técnicos
- Divergência de ID de opcode entre client e server.
- Reload de módulos em runtime pode afetar estado transitório de UI.

## 10. Status
✔ Implementado
