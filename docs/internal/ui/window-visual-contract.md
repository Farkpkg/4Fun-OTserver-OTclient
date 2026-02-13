# Window Visual Contract (padrão universal)

## 1) Hierarquia estrutural obrigatória
```text
WindowRoot (UIWindow/MiniWindow/PhantomMiniWindow)
├── Header (title, controls)
├── ContentPanel (layout principal)
│   ├── Sections / Lists / Grids
│   └── ActionButtons
└── Optional Overlay (modal/loading/tooltip-helper)
```

## 2) Parenting e ciclo de vida
- Janelas acopladas à lateral: anexar em painel obtido por `modules.game_interface.findContentPanelAvailable(...)`.
- Janelas globais/modais: parent em `g_ui.getRootWidget()`.
- Toggle padrão: `show/open + raise + focus` e `hide/close`.
- Destroy obrigatório em `terminate` do módulo dono.

## 3) Anchors e layout (padrão dominante)

### Uso recomendado
- `anchors.fill`: para painel interno que ocupa toda a janela.
- `anchors.top/left/right/bottom`: para docking explícito de header/content/footer.
- `horizontalCenter/verticalCenter`: apenas para centralização de modais/widgets curtos.
- `margin` para respiro externo; `padding` para espaçamento interno.

### Layout managers
- `verticalBox`: pilhas de blocos/linhas.
- `horizontalBox`: linhas de botões e barras de status.
- `grid`: ícones, slots e botões uniformes (ex.: painel de control buttons 20x20 com spacing 2).

## 4) Contrato visual mínimo por janela
1. Background com `image-source` válido.
2. Frame com `image-border` quando 9-slice for necessário.
3. Content panel separado do header.
4. Botões com estados explícitos (`hover/pressed/disabled`).
5. Uso de clip consistente quando houver spritesheet.

## 5) Padrões extraídos (pixel-oriented)
- Control button padrão: 20x20, clip `0 0 20 20`, `on/pressed => 20 0 20 20`.
- Top button padrão: 26x26 com spritesheet horizontal (estados por coluna).
- Store button largo: 108x20 com alternância vertical (`y=0` e `y=20`).
- Grid de ações: `cell-size` fixo + `cell-spacing` explícito.

## 6) Regras de integração para novas janelas
- Nunca usar imagem sem rastrear origem em `/images`.
- Evitar posição absoluta; preferir anchors/layout.
- Não copiar OTUI manualmente entre módulos sem ajustar contrato visual.
- Reusar componentes de estilo da base (`data/styles/*.otui`) sempre que possível.

## 7) Inconsistências observadas
- Variações de espaçamento e hardcodes entre módulos complexos (principalmente Cyclopedia/Wheel).
- Combinação de múltiplos padrões de abertura (`displayUI` vs `loadUI`) sem padronização única.

## 8) Política obrigatória daqui para frente
- Criação de janelas novas via `WindowFactory.createStandardWindow`.
- Auditoria periódica via `auditWindowsVisualIntegrity()`.
