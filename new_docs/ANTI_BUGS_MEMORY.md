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
