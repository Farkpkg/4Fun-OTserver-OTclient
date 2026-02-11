# Talk on Right Click (NPC)

## Resumo

Foi adicionada uma nova opção de cliente chamada **"Right-click talk to NPC"** para facilitar a interação com NPCs. Quando ativada, um clique direito em NPC envia automaticamente `hi`, respeitando condições de segurança de versão e distância.

## O que foi alterado

### 1) Nova opção na interface de configurações
- Arquivo: `otclient/modules/client_options/styles/controls/general.otui`
- Foi criado um novo `OptionCheckBox` com o id `talkOnRightClick` e texto:
  - `Right-click talk to NPC`
- A opção foi inserida logo após `autoChaseOverride`.

### 2) Persistência da opção
- Arquivo: `otclient/modules/client_options/data_options.lua`
- Foi adicionada a chave:
  - `talkOnRightClick = false`
- Isso define o valor padrão da funcionalidade como desativado.

### 3) Compatibilidade por versão no painel de opções
- Arquivo: `otclient/modules/client_options/options.lua`
- Foi adicionada lógica para esconder a opção `talkOnRightClick` quando:
  - `g_game.getClientVersion() > 1511`
- Nesses casos, o painel da opção é ocultado e colapsado (altura e margem zeradas).

### 4) Opção "Talk" no menu de contexto de criaturas
- Arquivo: `otclient/modules/game_interface/gameinterface.lua`
- No menu de contexto de criatura, ao clicar em um NPC, foi adicionada a opção:
  - `Talk`
- A opção aparece apenas quando:
  - `creatureThing:isNpc()`
  - `g_game.getClientVersion() < 1511`
- A ação executada é `g_game.talk("hi")`.

### 5) Clique direito para falar automaticamente
- Arquivo: `otclient/modules/game_interface/gameinterface.lua`
- Em `processMouseAction`, foi adicionada validação para envio automático de `hi` em NPC quando:
  - existe `creatureThing`
  - é NPC (`isNpc()`)
  - botão é direito (`MouseRightButton`)
  - sem modificadores de teclado (`KeyboardNoModifier`)
  - opção `talkOnRightClick` está habilitada
  - cliente está em versão `< 1511`
  - jogador e NPC estão no mesmo andar (`z`)
  - distância máxima é 3 SQMs
- Quando todas as condições passam, o cliente executa:
  - `g_game.talk("hi")`
  - e retorna `true` para consumir o evento.

## Comportamento esperado

Com a opção ativada:
1. Jogador clica com botão direito em um NPC próximo (até 3 SQMs) no mesmo andar.
2. Cliente envia automaticamente `hi`.
3. A interação não depende de abrir menu manualmente.

Com a opção desativada:
- O comportamento padrão permanece inalterado.

## Observações

- A funcionalidade foi limitada para **protocolos abaixo da versão 1511**, conforme solicitado.
- Em versões acima de 1511, a opção nem aparece no painel de configurações para evitar uso indevido/incompatível.
