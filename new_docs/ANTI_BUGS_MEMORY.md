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
