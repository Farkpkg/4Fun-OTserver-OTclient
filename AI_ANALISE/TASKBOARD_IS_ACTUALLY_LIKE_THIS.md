# EXTRAÇÃO TÉCNICA COMPLETA — `game_taskboard`

## BOOTSTRAP OBRIGATÓRIO — confirmação

Leitura integral realizada dos documentos obrigatórios:
- `new_docs/OPERATIONAL_STATE_DECLARATION.md`
- `new_docs/UI_CANONICAL_RULES.md`
- `new_docs/CHANGE_GATE_CHECKLIST.md`

**Confirmação explícita do estado operacional atual (antes da análise):**
- A governança/documentação-base está **ativa** (`ACTIVE_IMPLEMENTED`) para artefatos e templates.
- Grande parte do processo de gate e validação estrutural segue como **manual** (`MANUAL_ONLY`).
- Partes de governança/enforcement estão **parcialmente implementadas** (`PARTIALLY_IMPLEMENTED`).
- Camadas avançadas/automação integral permanecem em **estado-alvo** (`TARGET_STATE`).

---

## 1) VISÃO GERAL DO SISTEMA

### Finalidade do módulo
`game_taskboard` implementa a interface cliente para o sistema Task Board com três superfícies principais:
- Bounty Tasks
- Weekly Tasks
- Hunting Task Shop

Também inclui janelas auxiliares para Preferred/Unwanted list e popup de seleção de dificuldade semanal.

### Quando é carregado
- O módulo é registrado em `taskboard.otmod` com `@onLoad: init()` e `@onUnload: terminate()`.
- O `game_interface` lista `game_taskboard` em `load-later`, portanto o carregamento ocorre no ciclo de inicialização da interface do cliente.

### Dependências
- Declaradas no módulo: `game_interface`, `game_mainpanel`.
- Dependências em runtime:
  - `ProtocolGame.registerOpcode`/`unregisterOpcode` para extended opcodes.
  - `g_game` (estado online, protocolo atual).
  - `modules.game_mainpanel.addToggleButton` para botão no painel superior.

### Estado operacional atual do sistema taskboard
**Ativo (`ACTIVE_IMPLEMENTED`)** no cliente para:
- criação/abertura de janelas,
- envio de opcodes cliente→servidor,
- recebimento de payloads servidor→cliente,
- renderização dinâmica de listas/cards.

Existe integração de servidor mapeada via extended opcode handler e scripts `task_board`.

---

## 2) ESTRUTURA DE ARQUIVOS

## `otclient/modules/game_taskboard/taskboard.otmod`
- **Função:** manifesto do módulo.
- **Responsabilidade:** definir nome, dependências, script e ciclo load/unload.
- **Entrada:** carregamento do sistema de módulos.
- **Saída:** invoca `init()`/`terminate()`.
- **Dependências internas:** `taskboard.lua`.

## `otclient/modules/game_taskboard/taskboard.lua`
- **Função:** núcleo comportamental do client.
- **Responsabilidade:** estado local, handlers de opcode, atualização de UI, ações de usuário.
- **Entradas:** eventos de jogo (`onGameStart/onGameEnd`), cliques da UI, opcodes 50–57.
- **Saídas:** envios de opcodes 59–72, mutações visuais, mensagens de feedback.
- **Dependências internas:** widgets definidos em `taskboard.otui`, `preferredListWindow.otui`, `weeklyProgressPopup.otui`, templates `taskboard_widgets.otui`.

## `otclient/modules/game_taskboard/taskboard.otui`
- **Função:** janela principal do Task Board.
- **Responsabilidade:** estrutura visual das abas Bounty/Weekly/Shop e barra inferior.
- **Entrada:** carregamento via `g_ui.loadUI('taskboard', GameInterface)`.
- **Saída:** dispara callbacks `modules.game_taskboard.*`.
- **Dependências internas:** funções Lua exportadas em `taskboard.lua`.

## `otclient/modules/game_taskboard/taskboard_widgets.otui`
- **Função:** templates reutilizáveis.
- **Responsabilidade:** `creatureListItem`, `weeklyKillCard`, `shopItemCard`.
- **Entrada:** `g_ui.importStyle('taskboard_widgets')`.
- **Saída:** instâncias dinâmicas via `g_ui.createWidget(...)`.

## `otclient/modules/game_taskboard/preferredListWindow.otui`
- **Função:** janela auxiliar Preferred/Unwanted.
- **Responsabilidade:** busca, lista de criaturas, slots, desbloqueios extras, barra inferior.
- **Entrada:** `g_ui.loadUI('preferredListWindow', GameInterface)`.
- **Saída:** callbacks para limpar/filtrar/desbloquear.

## `otclient/modules/game_taskboard/weeklyProgressPopup.otui`
- **Função:** popup de progresso semanal e escolha de dificuldade.
- **Responsabilidade:** exibição resumida + botões Beginner/Adept/Expert/Master.
- **Entrada:** `g_ui.loadUI('weeklyProgressPopup', GameInterface)`.
- **Saída:** callback `selectDifficulty(...)`.

## `otclient/modules/game_taskboard/README.md`
- **Função:** documentação de instalação/protocolo (não executável).
- **Responsabilidade:** descrever opcodes e formato de pacotes.

## `otclient/modules/game_taskboard/CODEX_PROMPT.md`
- **Função:** documento de contexto para automação/IA (não executável).

---

## 3) ESTRUTURA DE UI (.otui)

## 3.1 Widget raiz por arquivo

### `taskboard.otui`
- **Raiz:** `MainWindow` (`id: taskBoardWindow`)
- **Tamanho:** `720x560`
- **Anchors:** não ancorada a parent por definição explícita (janela livre)
- **Margins:** não definidos no root
- **Layout:** sem `layout` global; estrutura por anchors internos
- **Z-index:** não definido

### `preferredListWindow.otui`
- **Raiz:** `Window` (`id: preferredListWindow`)
- **Tamanho:** `490x400`
- **Anchors/layout/z-index:** não definidos no root

### `weeklyProgressPopup.otui`
- **Raiz:** `Window` (`id: weeklyProgressPopup`)
- **Tamanho:** `320x280`
- **Anchors/layout/z-index:** não definidos no root

### `taskboard_widgets.otui`
- Não define janela raiz única; define 3 **classes/template** derivadas de `Panel`.

## 3.2 Hierarquia completa de widgets

### A) `taskboard.otui` (árvore estrutural)
- `MainWindow(taskBoardWindow)`
  - `TabBar(taskBoardTabBar)`
    - `TabBarTab(tabBounty)`
    - `TabBarTab(tabWeekly)`
    - `TabBarTab(tabShop)`
  - `Panel(panelBounty)`
    - `Label(lblSetup)`
    - `Panel(setupRow)`
      - `Label` (Task Difficulty)
      - `ComboBox(comboDifficulty)`
      - `Button(btnPreferredList)`
      - `Button(btnReroll)`
      - `Label(lblRerollTokens)`
      - `Button(btnClaimDaily)`
    - `Panel(taskCardGrid)`
      - `Panel(taskCard1)`
        - `Label(taskCard1Name)`
        - `Label(taskCard1Badge)`
        - `UICreature(taskCard1Creature)`
        - `Label(taskCard1Kills)`
        - `Label(taskCard1Reward)`
        - `Button(taskCard1Select)`
      - `Panel(taskCard2)`
        - `Label(taskCard2Name)`
        - `Label(taskCard2Badge)`
        - `UICreature(taskCard2Creature)`
        - `Label(taskCard2Kills)`
        - `Label(taskCard2Reward)`
        - `Button(taskCard2Select)`
      - `Panel(taskCard3)`
        - `Label(taskCard3Name)`
        - `Label(taskCard3Badge)`
        - `UICreature(taskCard3Creature)`
        - `Label(taskCard3Kills)`
        - `Label(taskCard3Reward)`
        - `Button(taskCard3Select)`
    - `Label(lblTalisman)`
    - `Panel(talismanGrid)`
      - `Panel(talism1)`
        - `Label(talism1Name)`
        - `Label(talism1Value)`
        - `Button(talism1Upgrade)`
        - `Label(talism1Cost)`
      - `Panel(talism2)`
        - `Label(talism2Name)`
        - `Label(talism2Value)`
        - `Button(talism2Upgrade)`
        - `Label(talism2Cost)`
      - `Panel(talism3)`
        - `Label(talism3Name)`
        - `Label(talism3Value)`
        - `Button(talism3Upgrade)`
        - `Label(talism3Cost)`
      - `Panel(talism4)`
        - `Label(talism4Name)`
        - `Label(talism4Value)`
        - `Button(talism4Upgrade)`
        - `Label(talism4Cost)`
  - `Panel(panelWeekly)`
    - `Label(lblWeeklyXP)`
    - `Panel(weeklyColumns)`
      - `Panel(killPanel)`
        - `Label` (Kill Tasks)
        - `Panel(killGrid)` [dinâmico por Lua]
        - `Button(btnUnlockKill)`
      - `Panel(deliveryPanel)`
        - `Label` (Delivery Tasks)
        - `Panel(deliveryGrid)` [dinâmico por Lua]
        - `Button(btnUnlockDelivery)`
    - `Panel(weeklyProgressPanel)`
      - `Panel(progressSection)`
        - `Label` (Weekly Progress)
        - `Label(lblMultipliers)`
        - `ProgressBar(weeklyProgressBar)`
        - `Label(lblProgressNums)`
      - `Panel(weeklyRewardsPanel)`
        - `Label` (Weekly Rewards)
        - `Label(lblWeeklyHTP)`
        - `Label(lblWeeklySeal)`
  - `Panel(panelShop)`
    - `ScrollablePanel(shopScroll)` [dinâmico por Lua]
    - `VerticalScrollBar(shopScrollBar)`
  - `Panel(bottomBar)`
    - `Label(lblBottomRT)`
    - `Label(lblBottomBP)`
    - `Label(lblBottomHTP)`
    - `Label(lblBottomSeal)`
    - `Button(btnClose)`

### B) `preferredListWindow.otui`
- `Window(preferredListWindow)`
  - `Panel(prefLeft)`
    - `Panel(prefSearchBar)`
      - `TextEdit(prefSearchInput)`
      - `Button(prefClearBtn)`
    - `ScrollablePanel(prefCreatureList)` [dinâmico por Lua]
    - `VerticalScrollBar(prefCreatureScroll)`
  - `Panel(prefDivider)`
  - `Panel(prefRight)`
    - `Label` (Preferred)
    - `Label` (Unwanted)
    - `Panel(prefSlot1)`
      - `UICreature(prefSlot1Creature)`
      - `Label(prefSlot1Name)`
      - `Button(prefSlot1Clear)`
      - `Label(prefSlot1Cost)`
    - `Panel(unwantedSlot1)`
      - `UICreature(unwantedSlot1Creature)`
      - `Label(unwantedSlot1Name)`
      - `Button(unwantedSlot1Clear)`
      - `Label(unwantedSlot1Cost)`
    - `Panel(extraSlots)` (verticalBox)
      - `Panel(extraSlot1)`
        - `Label`
        - `Button(extraSlot1Unlock)`
        - `Label(extraSlot1Cost)`
      - `Panel(extraSlot2)`
        - `Label`
        - `Button(extraSlot2Unlock)`
        - `Label(extraSlot2Cost)`
      - `Panel(extraSlot3)`
        - `Label`
        - `Button(extraSlot3Unlock)`
        - `Label(extraSlot3Cost)`
      - `Panel(extraSlot4)`
        - `Label`
        - `Button(extraSlot4Unlock)`
        - `Label(extraSlot4Cost)`
  - `Panel(prefBottomBar)`
    - `Label(prefLblRT)`
    - `Label(prefLblBP)`
    - `Button(prefBtnClose)`

### C) `weeklyProgressPopup.otui`
- `Window(weeklyProgressPopup)`
  - `Label(popupKillInfo)`
  - `Label(popupDeliveryInfo)`
  - `Label(popupEarned)`
  - `Label` (texto explicativo)
  - `Button(popupBtnBeginner)`
  - `Button(popupBtnAdept)`
  - `Button(popupBtnExpert)`
  - `Button(popupBtnMaster)` (disabled)

### D) `taskboard_widgets.otui` (templates)
- `creatureListItem < Panel`
  - `UICreature(itemCreature)`
  - `Label(itemName)`
- `weeklyKillCard < Panel`
  - `Label(cardName)`
  - `UICreature(cardCreature)`
  - `Label(cardProgress)`
  - `Label(cardTotal)`
- `shopItemCard < Panel`
  - `Label(shopCardTitle)`
  - `Item(shopCardItem)`
  - `Label(shopCardDesc)`
  - `Panel(shopCardBuyRow)`
    - `Button(shopCardBuyBtn)`
    - `Label(shopCardPrice)`

Observação de propriedades pedidas:
- **Imagem explícita em OTUI:** não há `image-source` nos widgets mapeados.
- **Animação:** não há propriedades de animação definidas.
- **Clipping:** não há `clipping` explícito.
- **Dinâmico x estático:** grids/listas e cards de weekly/shop/creatures são dinâmicos (Lua cria/destrói filhos); restante é estático.

---

## 4) MAPA DE POSICIONAMENTO

- O sistema usa majoritariamente **anchors relativos** (`top/bottom/left/right/horizontalCenter/verticalCenter`) e poucos valores absolutos.
- Há mistura de:
  - blocos ancorados manualmente (cards de bounty e talisman)
  - blocos geridos por `layout` (`grid`, `verticalBox`) nos conteúdos dinâmicos.
- Coordenadas são **relativas ao parent**; não há posicionamento absoluto por `x/y`.

### Relações principais
- A `TabBar` fixa no topo define a referência vertical dos três painéis de aba.
- `panelBounty`, `panelWeekly`, `panelShop` compartilham mesma área (entre tabbar e `bottomBar`) e alternam visibilidade.
- `bottomBar` ancora no rodapé e mantém moedas + botão close.
- `preferredListWindow` divide em duas colunas (`prefLeft` fixo por largura + `prefRight` fluido) separadas por divisor de 2px.

### Verificação frente a `UI_CANONICAL_RULES.md`
- Uso de classes base (`MainWindow`, `Window`) está conforme regra estrutural de herança de janelas.
- Uso de `Panel` para agrupamento semântico é consistente.
- Ações de rodapé com botão Close à direita também aparecem em ambas janelas principais.
- Há **legado/variação**: métricas de botão heterogêneas (40, 54, 60, 90, 100, 180 etc.) sem token único; tipografia única local (`verdana-11px-rounded`) mas sem evidência de adoção global canônica.

### Inconsistências visuais identificadas (somente mapeamento)
- `btnPreferredList`, `btnReroll`, `btnClaimDaily` têm larguras próximas porém não idênticas ao restante dos botões do módulo.
- `taskCard1Badge/2Badge/3Badge` existem no OTUI, mas a atualização visual de tier é aplicada em `taskCardXName` no Lua, deixando badges sem uso funcional explícito.
- Em `refreshWeekly`, botão `Deliver` é criado via Lua sem anchors explícitos no card (depende do comportamento padrão de adição de filho).

---

## 5) FLUXO DE EXECUÇÃO (LUA)

## 5.1 `init()`
- Conecta eventos de jogo: `onGameStart -> checkTaskBoardButton`, `onGameEnd -> hide`.
- Importa estilos/templates: `taskboard_widgets`.
- Carrega 3 UIs: principal, preferred, popup.
- Registra handlers de opcodes 50–57.
- Preenche `comboDifficulty` com 4 opções e configura `onOptionChange` para enviar opcode 69.
- Liga mudança de abas (`tabBar.onTabChange = onTabChange`).
- Se já online, cria botão de Task Board no mainpanel.

## 5.2 `terminate()`
- Desconecta eventos de jogo.
- Destrói botão do mainpanel (`destroyTaskBoardButton`).
- Remove registro dos opcodes 50–57.
- Destrói as 3 janelas (`ui.window`, `ui.prefWindow`, `ui.popupWindow`).

## 5.3 Funções principais mapeadas

### Controle de janela
- `show()`, `hide()`, `toggleTaskBoardWindow()`, `checkTaskBoardButton()`, `destroyTaskBoardButton()`.
- Alteram visibilidade da janela principal e estado do botão toggle.
- `toggleTaskBoardWindow()` envia `OPEN_REQUEST(59)` quando abrindo.

### Troca de abas
- `onTabChange(tabBar, tab)` controla visibilidade de `panelBounty/panelWeekly/panelShop`.

### Transporte de dados (client→server)
- `sendOpcode(opcode, writeCallback)` serializa payload binário (`addU8/U16/U32`) e chama `protocol:sendExtendedOpcode(...)`.

### Handlers server→client
- `onServerOpen`, `onBountyData`, `onWeeklyData`, `onShopData`, `onPreferredData`, `onTalismanData`, `onCurrenciesData`, `onResultData`.
- Todos atualizam `state` e chamam funções de refresh.

### Refresh visual
- `refreshBountyCards`, `refreshTalisman`, `refreshCurrencies`, `refreshWeekly`, `refreshShop`, `refreshPreferredList`, `populateCreatureList`.
- Atualizam textos, outfits, cores, visibilidade, e constroem/removem filhos dinâmicos.

### Ações do jogador
- `selectTask`, `rerollTasks`, `claimDaily`, `upgradeTalisman`, `buyShopItem`, `deliverItem`, `unlockKillTasks`, `unlockDeliveryTasks`, `selectDifficulty`.
- `openPreferredList`, `closePreferredList`, `filterCreatureList`, `clearCreatureSearch`, `selectCreatureInList`, `clearPreferredSlot`, `clearUnwantedSlot`, `unlockExtraSlot`, `addToPreferred`.
- `openWeeklyPopup`, `closeWeeklyPopup`.

---

## 6) EVENTOS E INTERAÇÕES

## Botões da janela principal
- `btnPreferredList` → `openPreferredList()` → abre `prefWindow` e envia opcode `63` sem payload para solicitar dados da lista.
- `btnReroll` → `rerollTasks()` → valida RT local, envia opcode `61`.
- `btnClaimDaily` → `claimDaily()` → envia opcode `62`.
- `taskCard1Select/2/3` → `selectTask(1|2|3)` → envia opcode `60` com slot.
- `talism1Upgrade..talism4Upgrade` → `upgradeTalisman(slot)` → valida BP local e envia opcode `67` com slot.
- `btnUnlockKill` → `unlockKillTasks()` → opcode `71`.
- `btnUnlockDelivery` → `unlockDeliveryTasks()` → opcode `72`.
- `btnClose` → `hide()`.

## Interações dinâmicas na aba Weekly/Shop
- Cards de `killGrid`: criados dinamicamente (`weeklyKillCard`), sem click action.
- Cards de `deliveryGrid`: criados dinamicamente + botão `Deliver` criado por Lua; click chama `deliverItem(i)` → opcode `70`.
- Cards de shop: `shopCardBuyBtn.onClick` chama `buyShopItem(idx)` → opcode `68`.

## Botões na Preferred List
- `prefClearBtn` → `clearCreatureSearch()`.
- `prefSlot1Clear` → `clearPreferredSlot(1)` → opcode `64`.
- `unwantedSlot1Clear` → `clearUnwantedSlot(1)` → opcode `65`.
- `extraSlot1Unlock..extraSlot4Unlock` → `unlockExtraSlot(i)` → valida BP local e envia opcode `66`.
- `prefBtnClose` → `closePreferredList()`.
- Lista de criatura (`creatureListItem` dinâmico): click define `state.selectedCreature`.

## Popup semanal
- `popupBtnBeginner/Adept/Expert/Master` → `selectDifficulty(diff)` → opcode `69` + fecha popup.

---

## 7) INTEGRAÇÃO COM SERVER (SE EXISTIR)

### Extended opcodes usados
Sim. Cliente usa:
- **Recebidos:** 50–57
- **Enviados:** 59–72

### ProtocolGame modificado?
No cliente, não há alteração em core C++ no escopo analisado; integração ocorre via API Lua `ProtocolGame.registerOpcode`.

### Eventos recebidos
Handlers Lua processam payload binário de todos os opcodes 50–57.

### Persistência / dados
No cliente não há persistência local em disco; estado fica em memória (`state`).
No servidor, scripts `task_board` e `#extended_opcode.lua` mostram integração com `TaskBoardDB` e cache em memória de jogador.

### Dependência de login state
Sim. Criação e uso do botão principal dependem de `g_game.isOnline()`, e envio de opcode depende de protocolo ativo (`g_game.getProtocolGame()`).

---

## 8) ESTADO INTERNO DO SISTEMA

## Variáveis/tabelas centrais
- `OPCODE` (mapa de códigos)
- `state` (moedas, tasks, talisman, listas, weekly, shop, seleção)
- `ui` (referências das janelas)
- `MULTIPLIERS`, `EXTRA_SLOT_COSTS`, `DIFFICULTY_TO_ID`, `ID_TO_DIFFICULTY`
- `bitLib`, `isUpdatingDifficulty`, `taskBoardButton`, `sendOpcode`

## Flags e controle
- `isUpdatingDifficulty`: evita loop/reenvio quando combo é atualizado por dado recebido.
- `state.selectedCreature`: seleção atual na lista.
- `state.extraSlots[1..4]`: status de desbloqueio por bitmask recebida.

## Cache interno
- Sem cache persistente cliente; apenas tabela `state` em memória de sessão.

---

## 9) CICLO DE VIDA COMPLETO

1. Cliente inicializa módulos de interface.
2. `game_taskboard` carrega (`init`).
3. Templates são importados e janelas são instanciadas ocultas.
4. OpCodes 50–57 são registrados.
5. Ao entrar no jogo (`onGameStart`), botão toggle no mainpanel é criado.
6. Usuário clica no botão:
   - se janela aberta, fecha;
   - se fechada, envia `OPEN_REQUEST(59)`.
7. Servidor responde com `OPEN(50)` e demais dados (51–57).
8. Cliente atualiza `state` e refaz UI (cards/listas/moedas).
9. Usuário interage (selecionar task, reroll, shop, delivery, preferred, unlock, etc.), gerando opcodes 60–72.
10. Servidor responde com resultado/estado atualizado; cliente reaplica refresh.
11. Usuário fecha janela(s); janelas ficam ocultas.
12. Ao descarregar módulo (`terminate`), opcodes/eventos são desconectados e widgets destruídos.

---

## 10) RISCOS E PONTOS FRÁGEIS (SEM SOLUÇÃO)

- `onTabChange` assume `ui.window` e painéis existentes sem guardas; erro de carregamento parcial pode gerar acesso nil.
- Em `init()`, falha ao carregar `prefWindow`/`popupWindow` retorna cedo sem rollback do que já foi inicializado naquele ponto.
- `openPreferredList()` usa opcode `PREF_SET(63)` sem payload para “request”; depende de interpretação específica no servidor.
- `selectCreatureInList()` remove seleção visual de todos itens com `setStyleFromSelector('!selected')`, mas não aplica estilo de item selecionado explicitamente.
- `refreshWeekly()` cria botão `Deliver` dinamicamente em cada card sem ancoragem explícita; posicionamento depende do comportamento padrão de layout/widget.
- `lblRerollTokens` existe no OTUI, mas `refreshCurrencies()` atualiza barra inferior e não esse label específico.
- `taskCardXBadge` existe no OTUI, porém o tier é renderizado no `taskCardXName` em vez do badge.
- Dependência implícita de `bit32`/`bit`; fallback matemático existe, porém comportamento binário depende da consistência do runtime.

---

## ANEXO — DEPENDÊNCIAS EXTERNAS MAPEADAS

- **Top menu/mainpanel:** botão criado por `modules.game_mainpanel.addToggleButton(...)`.
- **Extended opcode server handler:** `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua` despacha opcodes 59–72 para `TaskBoard`.
- **Servidor TaskBoard:** `taskboard_manager.lua`, `taskboard_db.lua`, `taskboard_config.lua`, `taskboard_weekly_reset.lua`, `taskboard_events.lua`.
- **Carga do módulo no cliente:** `game_interface/interface.otmod` lista `game_taskboard` no `load-later`.

