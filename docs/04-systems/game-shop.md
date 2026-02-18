# Sistema de Game Shop (Módulo Opcional)

## 1. Objetivo
Oferecer interface de loja no client e backend de ações via extended opcode em scripts dedicados.

## 2. Escopo
Controla catálogo, consulta de ofertas, compra e histórico no módulo `game_shop`.
Não controla economia global fora dos scripts e tabelas usados pelo próprio módulo.

## 3. Localização no Código

### Server
- `otclient/modules/game_shop/serverSIDE/data/scripts/game_shop.lua`

### Client
- `otclient/modules/game_shop/game_shop.lua`

## 4. Fluxo de Execução Completo
1. Client registra callback de extended opcode (`GAME_SHOP_CODE`).
2. Ao abrir loja, client envia ação `fetch` em JSON.
3. Server processa `ExtendedEvent.onExtendedOpcode` do shop.
4. Server responde ações (`fetchBase`, `fetchOffers`, `history`, `msg`) em JSON.
5. Client atualiza UI conforme `action` recebida.

## 5. Comunicação
- Opcodes utilizados: `ExtendedOPCodes.CODE_GAMESHOP = 201`.
- Eventos utilizados: callback de extended opcode no módulo.
- Estrutura de payload: JSON com contrato `{ action, data }`.

## 6. Estruturas de Dados
- Classes C++: canal de transporte (`ProtocolGame`/`Player.sendExtendedOpcode`).
- Tabelas Lua: categorias/ofertas/histórico do módulo.
- Tabelas SQL envolvidas: depende da implementação do script (não acoplado no core schema por C++ diretamente).

## 7. Dependências Cruzadas
- Extended opcode dispatch.
- UI framework OTClient.

## 8. Pontos de Extensão Reais
- Novas ações no contrato `action` mantendo backward compatibility.
- Inclusão de validações server-side por tipo de oferta.

## 9. Riscos Técnicos
- Contrato JSON sem versionamento formal.
- Módulo está em `serverSIDE` dentro do client repo (risco de drift com datapack real em produção).

## 10. Status
⚠ Parcial
