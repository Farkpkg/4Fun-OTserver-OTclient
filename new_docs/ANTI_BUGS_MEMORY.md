# ANTI_BUGS_MEMORY

Objetivo: transformar erros reais já diagnosticados/corrigidos em memória preventiva estruturada e obrigatória antes de qualquer nova correção.

Protocolo ativo:
1. Consultar este arquivo antes de implementar qualquer correção.
2. Verificar se o erro já ocorreu e aplicar a regra preventiva derivada.
3. Registrar novas ocorrências somente com evidência concreta (sem hipótese).

---

# [0001] — Falha de carregamento da UI do TaskBoard por sintaxe inválida em OTUI

## 1) Sintoma Observado
Logs relevantes observados no fluxo do módulo `game_taskboard`:
- `[game_taskboard] failed to load main UI: taskboard.otui`
- `[game_taskboard] TaskBoard window is nil (UI failed to load)`

Efeito direto: o toggle do TaskBoard era acionado, mas a janela principal não era instanciada, impedindo abertura do painel.

## 2) Contexto
- Quando ocorreu: durante inicialização/carregamento do módulo `otclient/modules/game_taskboard` e também ao tentar abrir o TaskBoard após login.
- Módulo afetado: cliente OTUI/Lua do TaskBoard.
- Condição de ativação: parser OTUI encontrando sintaxe de comentário incompatível no arquivo principal de layout, levando `g_ui.loadUI('taskboard', GameInterface)` a falhar.

## 3) Causa Raiz Confirmada
- Descrição técnica comprovada: o arquivo principal de layout do TaskBoard continha comentário em sintaxe inválida para o parser OTUI utilizado no cliente, quebrando o parse da árvore da janela e retornando `nil` no carregamento da UI.
- Arquivo exato: `otclient/modules/game_taskboard/taskboard.otui`
- Linha exata: 2 (bloco de cabeçalho/comentário do arquivo)
- Tipo de erro: **Sintático**

## 4) Correção Aplicada
- O que foi alterado: normalização da sintaxe de comentários do arquivo OTUI para formato aceito pelo parser em produção, restaurando o carregamento da janela principal.
- Arquivo modificado: `otclient/modules/game_taskboard/taskboard.otui`
- Justificativa: sem parse válido, a janela não é criada; com comentário compatível, `g_ui.loadUI('taskboard', GameInterface)` volta a instanciar `ui.window` corretamente.

## 5) Regra Preventiva Derivada
"Em qualquer `.otui`, usar apenas sintaxe de comentário previamente validada no parser alvo do cliente; ao inserir cabeçalhos/comentários, validar parse antes de merge."

## 6) Teste de Prevenção
1. Iniciar cliente com módulo `game_taskboard` habilitado.
2. Verificar ausência de erro de carregamento:
   - não deve aparecer `[game_taskboard] failed to load main UI: taskboard.otui`.
3. Acionar abertura do TaskBoard e confirmar ausência de:
   - `[game_taskboard] TaskBoard window is nil (UI failed to load)`.
4. Confirmar que `g_ui.loadUI('taskboard', GameInterface)` produz janela válida (`ui.window ~= nil`).

## 7) Severidade
**ALTA**

---

# [0002] — TaskBoard falhava por parent inválido + estilo de aba inexistente

## 1) Sintoma Observado
Logs completos relevantes:
- `ERROR: failed to apply style to widget 'taskBoardWindow': OTML error in '/styles/10-windows.otui:28': cannot create anchor, there is no parent widget!`
- `ERROR: failed to load UI from 'taskboard': 'TabBarTab' is not a defined style`
- `ERROR: [game_taskboard] failed to load main UI: taskboard.otui`

## 2) Contexto
- Quando ocorreu: inicialização do cliente no carregamento do módulo `game_taskboard`.
- Módulo afetado: `otclient/modules/game_taskboard`.
- Condição de ativação:
  1. `g_ui.loadUI('taskboard', GameInterface)` recebia parent nulo em contexto de boot.
  2. `taskboard.otui` declarava `TabBarTab`, estilo não definido no cliente atual.

## 3) Causa Raiz Confirmada
- Descrição técnica comprovada:
  - A janela principal herda `MainWindow`, que aplica `anchors.centerIn: parent` no estilo global (`10-windows.otui`). Com parent nulo, o parser aborta com erro de anchor.
  - O arquivo OTUI do TaskBoard usava nós `TabBarTab`, mas essa classe/estilo não existe nesta base, gerando erro de estilo indefinido.
- Arquivo exato: `otclient/modules/game_taskboard/taskboard.lua`
- Linha exata: chamada de `g_ui.loadUI(..., GameInterface)` no bloco `init`.
- Arquivo exato: `otclient/modules/game_taskboard/taskboard.otui`
- Linha exata: bloco de declaração de abas `TabBarTab`.
- Tipo de erro:
  - **Ciclo de vida** (parent de UI indisponível no momento do load)
  - **Estrutural** (uso de estilo OTUI inexistente)

## 4) Correção Aplicada
- O que foi alterado:
  1. Parent de carregamento da UI alterado para fallback seguro (`rootWidget`) com preferência por `modules.game_interface.getRootPanel()` quando disponível.
  2. Removido uso de `TabBarTab` no OTUI.
  3. Abas do `TabBar` passaram a ser criadas via Lua com `tabBar:addTab(...)` e IDs explícitos para manter `onTabChange` existente.
- Arquivos modificados:
  - `otclient/modules/game_taskboard/taskboard.lua`
  - `otclient/modules/game_taskboard/taskboard.otui`
- Justificativa: elimina falha de ancoragem por parent nulo e alinha criação de abas com API real disponível no cliente.

## 5) Regra Preventiva Derivada
"Nunca carregar janela `MainWindow` com parent potencialmente nulo; usar parent garantido (`rootWidget` ou painel raiz válido)."

"Não declarar em `.otui` estilos/classe não presentes na base atual; para `TabBar`, preferir criação de tabs por API Lua (`addTab`) quando não houver estilo estático definido."

## 6) Teste de Prevenção
1. Carregar módulo `game_taskboard` no bootstrap do cliente.
2. Confirmar ausência dos erros:
   - `cannot create anchor, there is no parent widget`
   - `'TabBarTab' is not a defined style`
3. Confirmar que `taskboard.otui` carrega sem erro e a janela é criada.
4. Abrir TaskBoard e validar troca entre abas Bounty/Weekly/Shop.

## 7) Severidade
**CRÍTICA**

---

# [0003] — TaskBoard OTUI quebrava por sintaxe de border e `%` em `tr()`

## 1) Sintoma Observado
Logs completos relevantes:
- `ERROR: failed to apply style to widget 'taskCard1Creature': ... border param must have its width followed by its color`
- `ERROR: failed to apply style to widget 'taskCard2Creature': ... border param must have its width followed by its color`
- `ERROR: failed to apply style to widget 'taskCard3Creature': ... border param must have its width followed by its color`
- `ERROR: Lua exception: /game_taskboard/taskboard.otui:366: [!text]:1: invalid option '%' to 'format'`
- erros equivalentes nas linhas 416, 466 e 516.
- `ERROR: /game_taskboard/taskboard.lua:312: attempt to index local 'tab' (a nil value)`

## 2) Contexto
- Quando ocorreu: inicialização do módulo `game_taskboard` durante `loadUI`.
- Módulo afetado: `otclient/modules/game_taskboard`.
- Condição de ativação:
  1. Widgets `UICreature` com `border: 1` sem cor.
  2. Uso de `tr('...%')` em labels com percentuais.
  3. Callback de mudança de aba recebendo `tab=nil` em fluxo de inicialização/erro.

## 3) Causa Raiz Confirmada
- Descrição técnica comprovada:
  - O parser OTML desta base exige `border` no formato `largura cor`.
  - A função `tr()` usa `string.format` internamente, então `%` literal precisa ser escapado como `%%`.
  - `onTabChange` assumia `tab` sempre não nulo e fazia `tab:getId()` sem guarda.
- Arquivos exatos:
  - `otclient/modules/game_taskboard/taskboard.otui` (blocos `taskCard*Creature` e botões `talism*Upgrade`).
  - `otclient/modules/game_taskboard/taskboard.lua` (`onTabChange`).
- Linhas exatas:
  - OTUI: regiões dos `border` e `!text` de upgrade com `%`.
  - Lua: acesso direto `tab:getId()`.
- Tipo de erro:
  - **Sintático** (formato inválido de `border` e `%` não escapado)
  - **Estado inconsistente** (callback com `tab=nil` sem proteção)

## 4) Correção Aplicada
- O que foi alterado:
  1. `border: 1` -> `border: 1 #000000` nos três widgets `UICreature`.
  2. `tr('Upgrade to X.XX%')` -> `tr('Upgrade to X.XX%%')` nos quatro botões de upgrade.
  3. Guarda defensiva em `onTabChange` para retornar quando `ui.window` ou `tab` forem nulos.
- Arquivos modificados:
  - `otclient/modules/game_taskboard/taskboard.otui`
  - `otclient/modules/game_taskboard/taskboard.lua`
- Justificativa: garante parse OTUI válido, evita exceção de formatação em runtime e previne crash por callback parcial.

## 5) Regra Preventiva Derivada
"Em OTUI deste cliente, sempre declarar `border` como `largura + cor` (ex.: `border: 1 #000000`), nunca apenas largura."

"Qualquer texto traduzível com `%` deve usar `%%` quando passar por `tr()` para evitar erro de `string.format`."

"Callbacks de UI disparados durante init devem ter guardas para argumentos/estado nulos."

## 6) Teste de Prevenção
1. Carregar módulo `game_taskboard` e validar ausência de erros `border param must have its width followed by its color`.
2. Validar ausência de erros `invalid option '%' to 'format'` em linhas de upgrade.
3. Trocar abas na janela e confirmar ausência de `attempt to index local 'tab' (a nil value)`.
4. Confirmar janela abre normalmente e componentes visuais carregam.

## 7) Severidade
**ALTA**

---

# [0004] — Dessincronização grave de protocolo por registro errado de opcodes do TaskBoard

## 1) Sintoma Observado
Logs relevantes de runtime após selecionar personagem:
- `WARNING: Unhandled opcode 0x00 (0) with 15712 unread bytes; previous opcode: 0x43 (67)`
- Erros em cascata de mapa/movimento: `ProtocolGame::parseCreatureMove: no creature found to move`
- Cliente não iniciava corretamente após login.

## 2) Contexto
- Quando ocorreu: transição login -> game world com módulo TaskBoard ativo.
- Módulo afetado: `otclient/modules/game_taskboard/taskboard.lua`.
- Condição de ativação: módulo enviava dados via `sendExtendedOpcode`, mas registrava handlers com `ProtocolGame.registerOpcode` (canal de opcode normal), capturando/competindo com parser do protocolo base.

## 3) Causa Raiz Confirmada
- Descrição técnica comprovada:
  - Os handlers do TaskBoard (opcodes 50-57) foram registrados no canal de opcode normal (`registerOpcode`), mas o transporte usado pelo módulo era extended opcode (`sendExtendedOpcode`).
  - Isso gerou dessintonia do fluxo de parsing do protocolo de jogo e leitura incorreta do stream de rede.
- Arquivo exato: `otclient/modules/game_taskboard/taskboard.lua`
- Linha exata: bloco `init/terminate` com `registerOpcode/unregisterOpcode` para opcodes do TaskBoard.
- Tipo de erro:
  - **Estrutural** (canal de protocolo incorreto)
  - **Estado inconsistente** (stream de rede dessíncrono)

## 4) Correção Aplicada
- O que foi alterado:
  1. Migração de `registerOpcode/unregisterOpcode` para `registerExtendedOpcode/unregisterExtendedOpcode` no TaskBoard.
  2. Adição de wrappers `onExtended*` para converter `buffer` em `InputMessage` (`InputMessage.create():setBuffer(buffer)`) e reutilizar handlers existentes (`onBountyData`, `onWeeklyData`, etc.).
- Arquivo modificado:
  - `otclient/modules/game_taskboard/taskboard.lua`
- Justificativa: garante simetria entre envio/recebimento via extended opcode e preserva parser binário já implementado nos handlers.

## 5) Regra Preventiva Derivada
"Nunca misturar `sendExtendedOpcode` com `registerOpcode`; para canal extended, usar sempre `registerExtendedOpcode` e decoder compatível do buffer."

## 6) Teste de Prevenção
1. Selecionar personagem com TaskBoard ativo.
2. Confirmar ausência de warning de stream: `Unhandled opcode 0x00 ... unread bytes`.
3. Confirmar ausência de erros em cascata de `parseCreatureMove` no login.
4. Validar abertura/atualização do TaskBoard recebendo dados do servidor.

## 7) Severidade
**CRÍTICA**
