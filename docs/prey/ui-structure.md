# PREY — Estrutura de UI

## Arquivos UI
- Layout principal: `otclient/modules/game_prey/prey.otui`
- Controller/UI logic: `otclient/modules/game_prey/prey.lua`
- Módulo: `otclient/modules/game_prey/prey.otmod`

## Componentes principais

### Janela principal
- `MainWindow#preyWindow` com 3 `SlotPanel` (`slot1..slot3`)
- Cada slot contém:
  - `locked` (`LockedPreyPanel`)
  - `inactive` (`InactivePreyPanel`)
  - `active` (`ActivePreyPanel`)

### Elementos de slot
- botão reroll (`rerollButton`)
- botão choose (`choosePreyButton`)
- botão seleção específica (`pickSpecificPrey`)
- checkboxes de opção:
  - `autoRerollCheck`
  - `lockPreyCheck`
- barra de tempo (`ProgressBar`)
- grade de estrelas (`Star/NoStar`)
- full list com busca (`searchEdit`, `searchClearButton`, `entries`)

### Tracker (miniwindow)
- `PreyTracker` com 3 linhas (`slot1..slot3`), cada uma com:
  - criatura
  - tipo de bônus
  - progressbar de tempo

## Eventos de UI mapeados
- `@onClick`
  - store buttons
  - seleção de criatura
  - reroll
  - clear busca
- `@onHoverChange`
  - praticamente todos os botões/icones relevantes (tooltip/description panel)
- `onItemBoxChecked`, `onPreyRaceListItemClicked`, `onPreyRaceListItemHoverChange`
- callbacks de rede (`onPreyLocked`, `onPreyInactive`, `onPreyActive`, etc.)

## Atualização dinâmica
- `onPreyTimeLeft` atualiza simultaneamente:
  - barra do tracker
  - tooltip contextual
  - barra de tempo do slot ativo
- `onPreyRerollPrice` e `setTimeUntilFreeReroll` alteram preço exibido e estado visual do botão reroll.
- `refreshRerollButtonState` bloqueia/desbloqueia ação conforme gold total.
- `updatePickSpecificPreyButton` habilita/desabilita por quantidade de wildcards.

## Assets visuais utilizados
- Iconografia de bônus (small + big)
- Estados de botão (`*_blocked`)
- recursos de custo (gold/wildcard)
- ícones de estrela/slot inativo

## Limitações de UI detectadas
1. Strings e regras de preço parcialmente hardcoded no Lua (`setUnsupportedSettings`).
2. Dependência em ids específicos OTUI; alterações estruturais quebram callbacks sem fallback robusto.
3. Fluxo de “wildcard selection” existe no cliente, mas pode não ser emitido pelo servidor atual.

## Exemplo real de callback
```lua
function onPreyActive(slot, name, outfit, bonusType, bonusValue, bonusGrade, timeLeft, ...)
  -- troca painéis, atualiza criatura, bônus, estrelas e timer
end
```

## Diagrama textual
```text
Evento de rede onPreyActive
  -> prey.lua mapeia estado
  -> slot.active:show / slot.inactive:hide
  -> atualiza ícones/textos/progressbar
  -> atualiza tracker
```

## Sugestões de melhoria
- Extrair constantes de caminhos de imagem e ids para reduzir duplicação.
