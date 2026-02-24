# Mapeamento Completo de Widgets — Task/Hunting UI (estado real do cliente)

## 1) Bootstrap aplicado + escopo adotado

Seguindo o `AGENT_BOOTSTRAP.md`, este documento usa **CURRENT_STATE** (código executável atual) e não assume módulos apenas documentais.

### Escopo real encontrado
- O repositório contém documentação do **Task Board** em `docs/04-systems/task-board-bounty-system.md`.
- Porém, no cliente atual (`Rubini_Client/modules`) não há pasta `game_taskboard` ativa.
- A implementação de UI de caça/tarefas existente no cliente é o módulo **`game_prey`**, que concentra os widgets funcionais de hunting/prey.

> Portanto, o inventário abaixo cobre **todos os widgets do módulo ativo de hunting/prey** e **todos os widgets compartilhados** que ele reutiliza.

---

## 2) Widgets customizados do módulo `game_prey` (todos)

Arquivo-base: `Rubini_Client/modules/game_prey/prey.otui`.

| Widget | Herda de | Função no sistema |
|---|---|---|
| `Star` | `UIWidget` | Estrela visual de graduação/qualidade de bônus. |
| `NoStar` | `UIWidget` | Estado sem estrela (slot vazio de graduação). |
| `WildcardLabel` | `UIWidget` | Item de linha para lista de criaturas no modo wildcard (com ícone + texto). |
| `WildcardPreyPanel` | `Panel` | Painel de busca/seleção por wildcard (lista, scroll, campo de busca, preview). |
| `LockedPreyPanel` | `Panel` | Estado de slot bloqueado; contém CTA para desbloqueio/loja. |
| `CreatureAndBonus` | `Panel` | Bloco principal do slot ativo: criatura, bônus, grau e tempo restante. |
| `SelectCreature` | `Panel` | Área de preview grande da criatura selecionável. |
| `NoCreaturePanel` | `Panel` | Estado sem criatura atribuída. |
| `InactivePreyPanel` | `Panel` | Estado inativo do slot (antes de seleção/ativação). |
| `SelectPreyPanel` | `Panel` | Estado de seleção de prey, incluindo lista e confirmação. |
| `ActivePreyPanel` | `Panel` | Estado ativo com controles de reroll, lock e bônus. |
| `RerollButton` | `Panel` | Componente visual/funcional de reroll com timer/preço. |
| `SelectPreyCreature` | `Panel` | Card/list item de criatura para seleção de prey. |
| `ChoosePrey` | `Panel` | Botão/área de ação para confirmar prey escolhida. |
| `BonusReroll` | `Panel` | Botão/área para reroll de bônus. |
| `CardLabel` | `FlatPanel` | Label estilizado em formato de “card” para metadados. |
| `GoldLabel` | `Panel` | Label de custo em ouro/token com ícone de moeda. |
| `PreyCreatureBox` | `UIWidget` | Caixa visual de criatura no slot (com estilos de estado). |
| `PreySlotPanel` | `Panel` | Estrutura completa de um slot de prey (locked/inactive/select/active/wildcard). |
| `PreyCreatureTrack` | `Panel` | Item de rastreamento de criatura no tracker lateral. |
| `HuntingCreatureTrack` | `Panel` | Variante de tracking para hunting task/prey track. |
| `PreyTracker` | `MiniWindow` | Miniwindow acoplada de acompanhamento (tracker). |

---

## 3) Widgets compartilhados reutilizados (base de estilos global)

Esses widgets **não são exclusivos do Prey**; são do sistema global de UI e reaproveitados em múltiplos módulos.

| Widget compartilhado | Definição global | Papel no `game_prey` |
|---|---|---|
| `NewMainWindow` | `data/styles/10-windows.otui` | Moldura da janela principal do Prey. |
| `Panel` / `FlatPanel` | `data/styles/10-panels.otui` | Contêineres estruturais de blocos e subblocos. |
| `Button` | `data/styles/10-buttons.otui` | Ações clicáveis (confirmar, reroll, etc.). |
| `CheckBox` | `data/styles/10-checkboxes.otui` | Toggles de seleção/auto comportamento. |
| `Label` / `FlatLabel` | `data/styles/10-labels.otui` | Textos, títulos, contadores e metadados. |
| `HorizontalSeparator` | `data/styles/10-separators.otui` | Separação visual entre seções. |
| `TextEdit` | `data/styles/10-textedits.otui` | Busca por criatura no modo wildcard. |
| `TextList` | `data/styles/10-listboxes.otui` | Lista scrollável de criaturas/opções. |
| `VerticalScrollBar` | `data/styles/10-scrollbars.otui` | Navegação vertical da lista de wildcard. |
| `ProgressBar` / `ProgressBarSD` | `data/styles/10-progressbars.otui` | Tempo restante e barras de progresso do slot. |
| `MiniWindowContents` | `data/styles/30-miniwindow.otui` | Conteúdo interno da miniwindow tracker. |

### Base engine compartilhada (nível framework)
Além dos estilos acima, o módulo usa classes engine padrão (`UIWidget`, `UIButton`, `UICreature`, etc.), que são componentes transversais da UI e não específicos do Prey.

---

## 4) Funções Lua do módulo e responsabilidade funcional

Arquivo-base: `Rubini_Client/modules/game_prey/prey.lua`.

### 4.1 Ciclo de vida
- `init` / `terminate`: inicialização e teardown do módulo, binds e conexões de evento.
- `show`, `hide`, `toggle`, `check`: controle de visibilidade e disponibilidade por sessão/estado.
- `toggleTracker`: exibe/oculta janela de rastreio.

### 4.2 Renderização e atualização de UI
- `updatePreyWidget`: sincroniza estado do slot e widgets derivados.
- `updateRerollTime`, `setTimeUntilFreeReroll`: atualiza barras/timers e condição free reroll.
- `setBonusGradeStars`: desenha graduação via `Star`/`NoStar`.
- `onHover`, `onSpecialHover`: tooltips e descrição contextual dinâmica.

### 4.3 Entrada do usuário e interação
- `onTextEdit`, `onSearchValueChange`, `updateSearchWildcard`: filtro textual e atualização da lista.
- `focusPrevWildcardLabel`, `focusNextWildcardLabel`, `move`, `onSelectHunting`: navegação por teclado e foco.
- `onItemBoxChecked`, `onEnableAutoReroll`, `onEnableLockPrey`: toggles e ações diretas de slot.
- `onRerollButtonAction`, `onConfirmUsingWildcard`: ações confirmadas para reroll/wildcard.

### 4.4 Adaptação a eventos do jogo/protocolo
- `onPreyFreeRolls`, `onPreyTimeLeft`, `onPreyPrice`, `onResourceBalance`: atualização por eventos econômicos/tempo.
- `onPreyActive`, `onPreyInactive`, `onPreySelection`, `onPreyWildcard`, `onPreyLocked`: transição de estado dos slots.
- `storeRedirect`: redirecionamento para store quando fluxo exige compra.

### 4.5 Helpers de domínio (tradução/descrição)
- `bonusDescription`, `bonusTypeTranslate`, `bonusTypeTranslateText`.
- `getBigIconPath`, `getSmallIconPath`, `getExtendIcon`.
- `getBonusDescription`, `getTooltipBonusDescription`, `capitalFormatStr`, `timeleftTranslation`.

---

## 5) Relação “custom x compartilhado” (quem depende de quem)

### Blocos customizados que dependem fortemente de compartilhados
- `PreyTracker` depende de `MiniWindow` + `MiniWindowContents` para comportamento de janela dockável.
- `WildcardPreyPanel` depende de `TextList` + `VerticalScrollBar` + `TextEdit` para UX de busca/listagem.
- `CreatureAndBonus` e `RerollButton` dependem de `ProgressBarSD`/`ProgressBar` para feedback temporal.
- `PreySlotPanel` compõe estados inteiros usando `Panel`, `Label`, `Button`, `CheckBox` e widgets customizados.

### Conclusão estrutural
O módulo `game_prey` é um exemplo de arquitetura híbrida:
- **Camada compartilhada**: estilos e primitivas globais (`data/styles/*`).
- **Camada de domínio**: widgets especializados de prey/hunting (`prey.otui`).
- **Camada comportamental**: orquestração por eventos em `prey.lua`.

---

## 6) Nota sobre Task Board (documental vs implementado)

Conforme o material em `new_docs` e `docs/04-systems/task-board-bounty-system.md`, existe desenho completo do `game_taskboard` (Bounty/Weekly/Shop). No snapshot atual do cliente auditado, esse módulo **não está presente no código em `Rubini_Client/modules`**; por isso este documento lista o conjunto de widgets **executáveis e verificáveis hoje**.

