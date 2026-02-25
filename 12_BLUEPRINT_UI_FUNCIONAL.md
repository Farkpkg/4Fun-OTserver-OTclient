# 12_BLUEPRINT_UI_FUNCIONAL

## Objetivo
Blueprint funcional da UI do Task Board com foco em implementação OTUI/OTClient, definindo:
- árvore de widgets com `id` final,
- anchors/layout esperado,
- estados visuais (`disabled`, `selected`, `completed`),
- binding explícito de botões para ações de protocolo (`sendTaskBoard*`),
- fonte e spacing conforme `new_docs/UI_CANONICAL_RULES.md`,
- checklist de consistência visual por aba.

> Base visual usada: `AI_ANALISE/Taskboard/task_board_visual_OTUI_spec.md` e `task_board_documentacao.md`.
> Base de protocolo usada: `docs/04-systems/task-board-bounty-system.md` (opcodes 60–72).

---

## 1) Referências canônicas obrigatórias

### 1.1 Estilos OTClient (`otclient/data/styles/*`)
- Janela/base: `10-windows.otui`
- Botões e estados: `10-buttons.otui`
- Labels/tipografia base: `10-labels.otui`
- Tabs: `20-tabbars.otui`
- Inputs e combobox/spinbox quando aplicável: `10-textedits.otui`, `10-comboboxes.otui`, `20-spinboxes.otui`
- Separadores/containers auxiliares: `10-panels.otui`, `10-separators.otui`
- Barras e feedback de progresso: `10-progressbars.otui`

### 1.2 Regras de fonte e espaçamento (canônico)
Aplicar literalmente os padrões de `new_docs/UI_CANONICAL_RULES.md`:
- **Fonte padrão de texto**: `verdana-11px-antialised`.
- **Fonte de botão padrão**: `cipsoftFont`.
- **Window clássica**: `padding-top 36`, `left/right/bottom 16`.
- **Fluxo vertical**: `anchors.top: prev.bottom`.
- **Spacing discreto**: `2, 4, 5, 10, 13`.
- **Estado disabled**: reduzir contraste/opacidade (`#...88`, `opacity <= 0.8`).

### 1.3 Módulos de exemplo (referência estrutural)
Como base de padrão de widgets, considerar módulos OTUI/Lua descritos em `docs/04-systems/task-board-bounty-system.md`:
- `otclient/modules/game_taskboard/taskboard.otui`
- `otclient/modules/game_taskboard/taskboard.lua`

> Observação: o arquivo solicitado `07_REFERENCIAS_UI_WIDGETS_E_PADROES.md` não foi encontrado nesta árvore de trabalho. Este blueprint preserva o objetivo do pedido usando as referências de UI disponíveis no repositório atual.

---

## 2) Contrato de ações de protocolo (`sendTaskBoard*`)

Padronização de nomes de função cliente (wrapper do envio de opcode):

- `sendTaskBoardSelect(slotIndex)` → opcode `60 SELECT`
- `sendTaskBoardReroll()` → opcode `61 REROLL`
- `sendTaskBoardClaimDaily()` → opcode `62 CLAIM_DAILY`
- `sendTaskBoardPreferredSet(payload)` → opcode `63 PREF_SET`
- `sendTaskBoardPreferredClear(slotIndex)` → opcode `64 PREF_CLEAR`
- `sendTaskBoardUnwantedClear(slotIndex)` → opcode `65 UNWANTED_CLEAR`
- `sendTaskBoardExtraSlot(kind, slotIndex)` → opcode `66 EXTRA_SLOT`
- `sendTaskBoardTalismanUpgrade(attrId)` → opcode `67 TALISMAN_UPGRADE`
- `sendTaskBoardShopBuy(offerId)` → opcode `68 SHOP_BUY`
- `sendTaskBoardWeeklyDifficulty(difficultyId)` → opcode `69 WEEKLY_DIFFICULTY`
- `sendTaskBoardWeeklyDeliver(taskIndex)` → opcode `70 WEEKLY_DELIVER`
- `sendTaskBoardWeeklyUnlockKill(slotIndex)` → opcode `71 WEEKLY_UNLOCK_KILL`
- `sendTaskBoardWeeklyUnlockDeliver(slotIndex)` → opcode `72 WEEKLY_UNLOCK_DELIVER`

---

## 3) TELA GLOBAL — Janela principal Task Board

## 3.1 Árvore de widgets (id final)
```text
TaskBoardWindow (MainWindow)
├── taskBoardTitleBar (UIWidget)
├── taskBoardTabs (TabBar)
│   ├── tabBounty (TabBarButton)
│   ├── tabWeekly (TabBarButton)
│   └── tabShop (TabBarButton)
├── taskBoardContentStack (Panel)
│   ├── bountyTabPanel (Panel)
│   ├── weeklyTabPanel (Panel)
│   └── shopTabPanel (Panel)
└── taskBoardFooter (Panel)
    ├── bountyPointsBox (Panel)
    ├── huntingTaskPointsBox (Panel)
    ├── soulsealsBox (Panel)
    └── closeTaskBoardButton (Button)
```

## 3.2 Anchors/layout esperado
- `TaskBoardWindow`: `MainWindow`, dimensão fixa aproximada `990x585`, não redimensionável.
- `taskBoardTabs`: `anchors.top/left/right: parent`; altura fixa.
- `taskBoardContentStack`: `anchors.top: taskBoardTabs.bottom`; `anchors.bottom: taskBoardFooter.top`; `anchors.left/right: parent`.
- `taskBoardFooter`: fixo ao rodapé com `anchors.left/right/bottom: parent`.
- `closeTaskBoardButton`: extremo direito do rodapé (`anchors.right: parent.right`).

## 3.3 Estado visual
- `disabled`: botão e texto em baixa ênfase (`opacity <= 0.8`, `color #...88`).
- `selected` (abas): botão de aba em estado `checked/on`; conteúdo da aba ativa visível, demais ocultos.
- `completed`: não aplicável no container global (aplicado em cards/células internas).

## 3.4 Binding de botões
- `closeTaskBoardButton.onClick` → `TaskBoard.hide()` (sem opcode).
- Troca de abas: apenas UI local + refresh de dados já recebidos.

---

## 4) TELA ABA 1 — Bounty Tasks

## 4.1 Árvore de widgets (id final)
```text
bountyTabPanel
├── bountySetupSection (Panel)
│   ├── bountyInfoButton (Button)
│   ├── bountyDifficultyCombo (ComboBox)
│   ├── preferredListButton (Button)
│   ├── rerollTasksButton (Button)
│   ├── rerollTokensField (TextEdit/Label)
│   └── claimDailyButton (Button)
├── bountyCardsGrid (Panel)
│   ├── bountyCard_1 (Panel)
│   │   ├── bountyCard_1_header (Label)
│   │   ├── bountyCard_1_sprite (UICreature)
│   │   ├── bountyCard_1_progress (Label)
│   │   ├── bountyCard_1_rewards (Panel)
│   │   └── bountyCard_1_selectButton (Button)
│   ├── bountyCard_2 (...)
│   └── bountyCard_3 (...)
└── talismanSection (Panel)
    ├── talismanAttrList (Panel)
    │   └── talismanUpgradeButton_* (Button)
    └── talismanSummary (Panel)
```

## 4.2 Anchors/layout esperado
- `bountySetupSection`: topo da aba, largura total, fluxo horizontal dos controles.
- `bountyCardsGrid`: `anchors.top: bountySetupSection.bottom`, 3 colunas com gaps fixos.
- Cada `bountyCard_*`: largura equivalente (`~1/3`), altura fixa.
- `talismanSection`: `anchors.top: bountyCardsGrid.bottom`; ocupa bloco inferior da aba.

## 4.3 Estado visual
- `disabled`:
  - `claimDailyButton` quando token diário já coletado.
  - `rerollTasksButton` quando tokens = 0.
  - `bountyCard_*_selectButton` para cards não selecionáveis (há task ativa em outro card).
- `selected`:
  - card ativo com borda/realce.
  - `bountyCard_*_selectButton` em estado on/checked no card ativo.
- `completed`:
  - card concluído com selo visual (ex.: overlay/check/realce).
  - progresso exibido como concluído (`kills alvo atingido`).

## 4.4 Binding de botões
- `preferredListButton.onClick` → abrir modal Preferred + `sendTaskBoardPreferredSet({ ping = true })` se necessário para solicitar catálogo/listas.
- `rerollTasksButton.onClick` → `sendTaskBoardReroll()`.
- `claimDailyButton.onClick` → `sendTaskBoardClaimDaily()`.
- `bountyCard_*_selectButton.onClick` → `sendTaskBoardSelect(slotIndex)`.
- `talismanUpgradeButton_*.onClick` → `sendTaskBoardTalismanUpgrade(attrId)`.

## 4.5 Checklist visual da aba
- [ ] Título/separador da seção com alinhamento horizontal consistente.
- [ ] 3 cards com mesma largura/altura e gaps idênticos.
- [ ] Botões de ação seguem fonte `cipsoftFont` e estados `pressed/disabled`.
- [ ] Estado do card ativo é inequívoco (selected).
- [ ] Rodapé da aba não colide com `taskBoardFooter` global.

---

## 5) TELA ABA 2 — Weekly Tasks

## 5.1 Árvore de widgets (id final)
```text
weeklyTabPanel
├── weeklyTopControls (Panel)
│   ├── weeklyDifficultyCombo (ComboBox)
│   └── weeklyInfoLabel (Label)
├── weeklyKillPanel (Panel)
│   └── weeklyKillTaskCell_* (Panel)
│       ├── weeklyKillTaskCell_*_name (Label)
│       ├── weeklyKillTaskCell_*_progress (Label/ProgressBar)
│       └── weeklyKillTaskCell_*_unlockButton (Button)
├── weeklyDeliveryPanel (Panel)
│   └── weeklyDeliveryTaskCell_* (Panel)
│       ├── weeklyDeliveryTaskCell_*_name (Label)
│       ├── weeklyDeliveryTaskCell_*_progress (Label/ProgressBar)
│       ├── weeklyDeliveryTaskCell_*_deliverButton (Button)
│       └── weeklyDeliveryTaskCell_*_unlockButton (Button)
├── weeklyProgressPanel (Panel)
│   ├── weeklyProgressBar (ProgressBar)
│   └── weeklyProgressMilestone_* (Label/Icon)
└── weeklyRewardsSummary (Panel)
```

## 5.2 Anchors/layout esperado
- `weeklyTopControls`: topo da aba.
- `weeklyKillPanel` à esquerda e `weeklyDeliveryPanel` à direita, alinhados pelo topo.
- `weeklyProgressPanel`: abaixo dos dois painéis principais.
- `weeklyRewardsSummary`: acoplado à direita da barra/progresso semanal.

## 5.3 Estado visual
- `disabled`:
  - `deliverButton` desabilitado sem requisitos de item.
  - `unlockButton` desabilitado quando já desbloqueado.
- `selected`:
  - dificuldade selecionada no `weeklyDifficultyCombo`.
  - célula em foco opcional para inspeção detalhada.
- `completed`:
  - tarefa semanal concluída com progress fill completo + badge/check.
  - milestones da `weeklyProgressBar` marcados como atingidos.

## 5.4 Binding de botões
- `weeklyDifficultyCombo.onOptionChange` → `sendTaskBoardWeeklyDifficulty(difficultyId)`.
- `weeklyDeliveryTaskCell_*_deliverButton.onClick` → `sendTaskBoardWeeklyDeliver(taskIndex)`.
- `weeklyKillTaskCell_*_unlockButton.onClick` → `sendTaskBoardWeeklyUnlockKill(slotIndex)`.
- `weeklyDeliveryTaskCell_*_unlockButton.onClick` → `sendTaskBoardWeeklyUnlockDeliver(slotIndex)`.

## 5.5 Checklist visual da aba
- [ ] Dois painéis (kill/delivery) com largura equilibrada.
- [ ] Células seguem mesma grade e alturas equivalentes.
- [ ] Barra semanal apresenta progresso contínuo e marcos legíveis.
- [ ] Botões de unlock/deliver obedecem estados disabled/completed.
- [ ] Tipografia e spacing seguem grid discreto (2/4/5/10/13).

---

## 6) TELA ABA 3 — Hunting Task Shop

## 6.1 Árvore de widgets (id final)
```text
shopTabPanel
├── shopHeaderPanel (Panel)
│   ├── shopCurrencyLabel (Label)
│   └── shopFilterCombo (ComboBox)
└── shopGridPanel (Panel)
    └── shopOfferCard_* (Panel)
        ├── shopOfferCard_*_header (Label)
        ├── shopOfferCard_*_sprite (UIItem)
        ├── shopOfferCard_*_price (Label)
        └── shopOfferCard_*_buyButton (Button)
```

## 6.2 Anchors/layout esperado
- `shopHeaderPanel` no topo; `shopGridPanel` abaixo em layout de 3 colunas.
- cards com largura fixa aproximada e gap uniforme.
- botão de compra no rodapé de cada card.

## 6.3 Estado visual
- `disabled`: `buyButton` sem saldo HTP.
- `selected`: filtro/categoria ativa no `shopFilterCombo`.
- `completed`: oferta única já adquirida (quando aplicável) com marcação de indisponível.

## 6.4 Binding de botões
- `shopOfferCard_*_buyButton.onClick` → `sendTaskBoardShopBuy(offerId)`.

## 6.5 Checklist visual da aba
- [ ] 3 colunas com cards alinhados.
- [ ] Header, sprite e footer em hierarquia visual estável.
- [ ] Preço e moeda visíveis antes da ação de compra.
- [ ] Estado de card indisponível claramente distinguível do estado normal.

---

## 7) TELA MODAL — Preferred List

## 7.1 Árvore de widgets (id final)
```text
preferredListWindow (MainWindow/Window)
├── preferredCatalogPanel (Panel)
│   ├── preferredSearchField (TextEdit)
│   └── preferredCreatureList (ListBox)
│       └── preferredCreatureRow_* (Panel)
├── preferredSlotsPanel (Panel)
│   ├── preferredSlotMain_* (Panel)
│   │   ├── preferredSlotMain_*_creature (UICreature)
│   │   ├── preferredSlotMain_*_costLabel (Label)
│   │   ├── preferredSlotMain_*_setButton (Button)
│   │   └── preferredSlotMain_*_clearButton (Button)
│   └── unwantedSlotMain_* (estrutura equivalente)
└── preferredCloseButton (Button)
```

## 7.2 Anchors/layout esperado
- janela modal centralizada sobre `TaskBoardWindow`.
- coluna esquerda: catálogo + busca.
- coluna direita: slots Preferred/Unwanted e ações.
- botão `preferredCloseButton` no canto inferior direito.

## 7.3 Estado visual
- `disabled`:
  - `setButton` sem seleção de criatura.
  - `clearButton` sem criatura atribuída.
- `selected`:
  - linha selecionada em `preferredCreatureList`.
  - slot alvo (preferred/unwanted) em foco de atribuição.
- `completed`:
  - slot já preenchido com criatura válida.

## 7.4 Binding de botões
- `preferredSlotMain_*_setButton.onClick` → `sendTaskBoardPreferredSet(payload)`.
- `preferredSlotMain_*_clearButton.onClick` → `sendTaskBoardPreferredClear(slotIndex)`.
- `unwantedSlotMain_*_clearButton.onClick` → `sendTaskBoardUnwantedClear(slotIndex)`.
- `preferredSlotMain_*_unlockButton.onClick` (se houver) → `sendTaskBoardExtraSlot(kind, slotIndex)`.
- `preferredCloseButton.onClick` → fechar modal local.

## 7.5 Checklist visual da modal
- [ ] Modal mantém foco acima da janela base (z-order correto).
- [ ] Busca/lista com navegação fluida e estado selected claro.
- [ ] Slots Preferred e Unwanted visualmente distintos.
- [ ] Ações de set/clear/unlock respeitam disabled/completed.

---

## 8) Matriz rápida de consistência por estados

| Estado | Indicador mínimo obrigatório | Exemplo de uso |
|---|---|---|
| `disabled` | `opacity <= 0.8` + `color #...88` + sem cursor interativo | Claim Daily indisponível, Buy sem saldo |
| `selected` | borda/realce + estado `checked/on` quando existir | Aba ativa, card ativo, item de lista selecionado |
| `completed` | badge/check/overlay + ação principal bloqueada/substituída | Task concluída, oferta única já adquirida |

---

## 9) Critérios finais de aceite (UI funcional)
- [ ] Todos os `id` acima estão implementados e estáveis.
- [ ] Todos os botões com ação de backend mapeiam para `sendTaskBoard*` correto.
- [ ] Regras canônicas de fonte/spacing/estados foram aplicadas sem exceção hard.
- [ ] Nenhum estado crítico depende apenas de cor (usar ícone/texto complementar).
- [ ] Navegação por abas não quebra layout e não sobrepõe rodapé global.
- [ ] Preferred modal abre/fecha sem perder estado da tela base.

