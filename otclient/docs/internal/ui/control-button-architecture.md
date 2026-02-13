# Control Buttons — arquitetura oficial (forense)

## Escopo auditado
- Sistema de criação/ordenação/persistência dos botões de controle na lateral direita do client.
- Módulos de referência para fluxo de evento e lifecycle: Skills, Battle, VIP e Task Board.

## 1) Hierarquia real da UI

```text
Root (UI root do client)
├── topMenu (modules.client_topmenu)
└── gameRootPanel (modules.game_interface.displayUI('gameinterface'))
    ├── gameMainRightPanel (coluna superior direita)
    │   └── mainoptionspanel (modules.game_mainpanel)
    │       ├── onPanel.store     (botões grandes, ex: Store)
    │       ├── onPanel.options   (Control Buttons principais, 20x20)
    │       └── onPanel.specials  (botões especiais)
    └── gameRightPanel (conteúdo/miniwindows; não é parent dos control buttons)
```

### Evidências de montagem
- `gameRootPanel` é criado por `g_ui.displayUI('gameinterface')` e é a raiz do ingame UI.  
- `gameMainRightPanel` e `gameRightPanel` são widgets distintos (stack vertical).  
- `mainoptionspanel` é injetado em `gameMainRightPanel` via `optionsController:setUI('mainoptionspanel', modules.game_interface.getMainRightPanel())`.

## 2) Rastreamento de criação dos botões
- Botões de controle (lateral direita) nascem via `modules.game_mainpanel.addToggleButton(...)` (ou `addSpecialToggleButton` / `addStoreButton`).
- A criação física usa `ControlButtonFactory.create(...)`, que aplica padrão visual, registra e valida.
- Exemplos:
  - Skills: `skillsButton` criado no `init()` do módulo `game_skills`.
  - Battle: `battleButton` criado no `init()` do módulo `game_battle`.
  - VIP: `vipButton` criado no `controllerVip:onInit()`.
- Task Board atual **não** usa esse fluxo de control buttons padrão: chama `modules.client_topmenu.addLeftGameButton(...)`, que roteia para `addSpecialToggleButton` (painel `specials`) e não para `options`.

## 3) Padrão pixel-perfect extraído

### Classe `MainToggleButton`
- `size: 20x20`
- `image-source: /images/options/button_empty`
- `image-clip: 0 0 20 20`
- `image-border: 3`
- Estado `pressed/on`: `image-clip: 20 0 20 20`

### Classe `largeToggleButton`
- `size: 108x20`
- `image-clip: 0 0 108 20`
- Estado `pressed/on`: `image-clip: 0 20 108 20`

### Container/layout
- `onPanel.options`: grid com `cell-size 20x20` e `cell-spacing 2`.
- `onPanel.specials`: grid com `cell-size 20x20` e `cell-spacing 2`.
- `onPanel.store`: vertical box com `cell-size 108x20` e `cell-spacing 2`.
- Margens relevantes: `mainoptionspanel.onPanel` com `margin-top: 8`; `options` com `margin-top: 6`; `store` com `margin-left: 8`.

## 4) Fluxo de eventos (event flow)

```text
Click no botão (onMouseRelease)
  -> callback do módulo (toggle)
     -> se janela já existe: alterna open/close (ou show/hide)
     -> se janela não está parentada: tenta anexar em panel disponível
     -> atualiza estado visual do botão (setOn)
```

### Hotkeys
- Skills: Keybind `Alt+S` -> `toggle`.
- Battle: Keybind `Ctrl+B` -> `toggle`.
- VIP: Keybind `Ctrl+P` -> `toggle`.

### Eventos de jogo
- Skills/Battle/VIP conectam `onGameStart/onGameEnd` e estados adicionais (ex.: battle on attack/follow; vip on add/change).

## 5) Persistência e Options > Interface > Control Buttons
- Estrutura persistida em `g_settings` no nó `control_buttons` com:
  - `buttons[id] = { visible, tooltip }`
  - `order[index] = id`
- Carregamento via `loadButtonConfig()` e aplicação em `initControlButtons()` / `onGameStart()`.
- Reordenação visual aplicada por `reorderButtons()` no painel `onPanel.options`.
- Tela de gerenciamento é injetada em `client_options` por `modules.client_options.addButton("Interface", "Control Buttons", ...)`.

## 6) Auditoria do erro do Task Board

### Resultado técnico
- Parent/hierarquia: entra em `specials` (via `addLeftGameButton` -> `addSpecialToggleButton`), **não** no grupo primário `options`.
- Registro em Options: não entra no fluxo primário de `control_buttons` de botões `options` (lista de exibição/ordem principal).
- Padrão visual: usa visual de `MainToggleButton` (20x20), então aspecto base é compatível.
- Lifecycle: botão nasce em `init()` do módulo e destrói em `terminate()`, o que é correto.
- Erro estrutural central: integração semântica inconsistente com o catálogo principal de Control Buttons (categoria/painel incorreta para um botão que foi tratado como “control button principal”).

## 7) Padrão arquitetural oficial (obrigatório)
1. Criar via `ControlButtonFactory.create`.
2. Registrar no `ControlButtonFactory.registry`.
3. Validar via `validateControlButton(button)` após criação.
4. Integrar ao estado `control_buttons` (quando categoria `options`) com `visible`, `tooltip` e `order`.
5. Vincular callback de toggle + keybind no módulo dono da janela.
6. Garantir destruição explícita no terminate.

## 8) Checklist obrigatório antes de novo botão
- [ ] Parent correto (`options`, `specials` ou `store` conforme categoria).
- [ ] Tamanho e clip corretos (20x20 ou 108x20).
- [ ] Registro na factory e validação sem erros.
- [ ] Integração de persistência `control_buttons` para categoria `options`.
- [ ] Callback + toggle da janela + estado `setOn` coerente.
- [ ] Keybind (se aplicável) registrado/removido no lifecycle.
- [ ] Destroy no terminate.

## 9) Ciclo de vida consolidado
1. `game_interface` cria `gameRootPanel`.
2. `game_mainpanel` cria `mainoptionspanel` dentro de `gameMainRightPanel`.
3. Módulos funcionais (skills/battle/vip/...) criam botões chamando APIs de `game_mainpanel`.
4. `onGameStart` carrega `control_buttons`, aplica visibilidade/ordem.
5. Usuário altera em Options -> salva em `g_settings`.
6. `onTerminate` destrói botão e janela no módulo dono.

