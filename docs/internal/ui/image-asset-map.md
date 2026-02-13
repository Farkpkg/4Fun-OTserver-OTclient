# Image Asset Map (engenharia reversa do sistema visual)

## 1) Estrutura global de `/images`
Base real do cliente: `otclient/data/images`.

### Grupos principais mapeados
- `ui/`: frames, backgrounds, botões base, scrollbars, panels, miniwindow skin.
- `game/`: assets funcionais por sistema (`prey`, `viplist`, `analyzer`, `shields`, etc.).
- `options/`: botões laterais de controle (`button_*`, `button_empty`, `store_large`, etc.).
- `topbuttons/`: ícones do topo do client.
- `icons/`: ícones de categorias e widgets.
- `automap/`, `bars/`, `healthmana/`, `store/`, `inventory/`, `flags/`, `skin/`.

## 2) Propriedades visuais em `.otui` (varredura global)
Varredura em 167 arquivos `.otui`.

- `image-source`: 1412 ocorrências.
- `image-clip`: 909 ocorrências.
- `image-border`: 300 ocorrências.
- `image-repeated`: 20 ocorrências.
- `image-offset`: 2 ocorrências.

### Prefixos dominantes de `image-source`
- `/images/ui` (dominante para estrutura base de janela/widgets)
- `/images/game` (dominante para conteúdo funcional de gameplay)
- `/images/icons`, `/images/automap`, `/images/options`, `/images/store`, `/images/bars`

## 3) Spritesheets e padrões de clip identificados

### Padrão 20x20 (Control Buttons)
- Base: `/images/options/button_empty`
- `image-clip` normal: `0 0 20 20`
- `pressed/on`: `20 0 20 20`
- Border: `image-border: 3`

### Padrão 26x26 (Top buttons)
- Base: `/images/ui/button_top` / `/images/ui/button_topgame`
- Sequência de estados por coluna (`x`):
  - normal/desabilitado: `0` ou `26`
  - hover: `26`
  - pressed: `52`
- Fórmula: `clipX = stateIndex * width`.

### Padrão 108x20 (botão largo de store)
- Base: `/images/options/store_large`
- normal: `0 0 108 20`
- pressed/on: `0 20 108 20`

## 4) Mapa de consumo por grupos de janela

### Wheel of Destiny
- OTUI: `modules/game_wheel/wheel.otui`, `modules/game_wheel/styles/wheelMenu.otui`, `gemMenu.otui`, `fragmentMenu.otui`.
- Consumo visual massivo com clips para estados e blocos (é um dos maiores consumidores de `image-*`).
- Assets majoritários: `/images/game/wheel/*`, `/images/ui/*`.

### Cyclopedia / Boss Slots / Bosstiary
- OTUI: `modules/game_cyclopedia/game_cyclopedia.otui`, `cyclopedia_widgets.otui`, tabs em `tab/*`.
- Boss Slots: `tab/boss_slots/boss_slots.otui`.
- Bosstiary: `tab/bosstiary/bosstiary.otui`.
- Usa mix intenso de `/images/game/*`, `/images/ui/*`, com múltiplos clips e borders.

### Prey Dialog
- OTUI: `modules/game_prey/prey.otui`.
- Usa `/images/game/prey/*` + skin base `/images/ui/*`.

### Spell List
- OTUI: `modules/game_spelllist/spelllist.otui`.
- Padrão miniwindow + botões/scroll visual padrão de UI.

### Skills
- OTUI: `modules/game_skills/skills.otui`.
- Estrutura miniwindow com iconografia/percentuais e barras.

### Battle
- OTUI: `modules/game_battle/battle.otui`, `battlebutton.otui`.
- Uso de componentes de lista e botões com estados visuais via clip.

### VIP
- OTUI: `modules/game_viplist/viplist.otui` (+ `addvip/editvip/addgroup`).
- Usa base de miniwindow com ícones de viplist em `/images/game/viplist/*`.

### Quest Log
- OTUI: `modules/game_questlog/styles/game_questlog.otui`.
- Janela principal + tracker com padrões de frame/scroll/lista.

### Options
- OTUI: `modules/client_options/options.otui` e `modules/client_options/styles/**`.
- Forte uso de `/images/ui/*`, `optionstab/*`, botões/checkbox/combobox padrões.

### Exaltation Forge
- Janela carregada pelo módulo `game_forge` via controller (`styles` e UI declarativa do módulo).
- Botão de acesso visual no painel de control buttons via `/images/options/button-exaltation-forge`.

## 5) Relação propriedade -> intenção visual
- `image-source`: textura base (widget/frame/botão).
- `image-border`: cap insets (9-slice), dominante em molduras e botões reutilizáveis.
- `image-clip`: recorte de spritesheet por estado/índice.
- `image-repeated`: preenchimento tiled de fundos.
- `image-offset`: deslocamento fino (raro; usado pontualmente).

## 6) Riscos arquiteturais encontrados
- Reuso inconsistente de assets semelhantes entre módulos diferentes.
- Estados visuais com clips hardcoded sem enum centralizado.
- Alguns módulos com mistura de `displayUI` e `loadUI` sem contrato visual compartilhado.

## 7) Regras operacionais extraídas
1. Todo `image-source` novo deve ser validado contra pasta real (`g_resources.fileExists`).
2. Todo uso de spritesheet deve declarar tabela de estados (normal/hover/pressed/disabled).
3. Sempre preferir assets-base `/images/ui/*` para frame e skin estrutural.
4. Evitar offsets manuais; preferir anchors/layout.
5. Para botões padrão, usar classes OTUI base e não clips ad-hoc soltos.
