# Extração Técnica — OTUI e Widgets (OTClient/CrystalServer)

Baseado no `Extracao.md` (AI_EXTRATOR.md), com foco em **OTUI** e **Widgets** no workspace.

## 1. Visão Geral

### OTUI
- **OTUI** é o formato declarativo de interface usado pelo OTClient (arquivos `.otui`), parseado via OTML.
- Define:
  - estilos (`StyleName < BaseStyle`),
  - árvore de widgets,
  - estados visuais (`$hover`, `$pressed`, `$disabled`, etc.),
  - propriedades, callbacks Lua (`@onClick`, `@onCheckChange`) e expressões (`!text`).

### Widgets
- **Widget** é a unidade base da UI (classe C++ `UIWidget`) e suas especializações (`UIMap`, `UIItem`, `UITextEdit`, etc.).
- Widgets são:
  - instanciados pelo pipeline OTUI→UIManager→Lua class `create`,
  - estilizados com OTML/OTUI,
  - controlados por Lua (`g_ui`, métodos de `UIWidget`) e C++ (render/input/layout).

### Lado de atuação
- ( ) Servidor
- (x) Cliente
- ( ) Ambos

> Não encontrado no código: engine OTUI/widget no CrystalServer (server-side). O sistema está concentrado no OTClient.

---

## 2. Localização no Código

### Núcleo OTUI/Widgets (C++)
- `otclient/src/framework/ui/uimanager.cpp`
- `otclient/src/framework/ui/uimanager.h`
- `otclient/src/framework/ui/uiwidget.cpp`
- `otclient/src/framework/ui/uiwidget.h`
- `otclient/src/framework/ui/uiwidgetbasestyle.cpp`
- `otclient/src/framework/ui/uiwidgettext.cpp`
- `otclient/src/framework/ui/uiwidgetimage.cpp`
- `otclient/src/framework/otml/otmldocument.cpp`
- `otclient/src/framework/otml/otmlparser.cpp`
- `otclient/src/framework/luafunctions.cpp`
- `otclient/src/client/luafunctions.cpp`

### Bootstrap de estilos OTUI
- `otclient/modules/client_styles/styles.lua`
- `otclient/data/styles/*.otui` (base styles globais)
- `otclient/modules/**/*.otui` (janelas/componentes de features)

### Extensões Lua de widgets base
- `otclient/modules/corelib/ui/*.lua`
- `otclient/modules/gamelib/ui/*.lua`

### Exemplo de uso prático (carregamento e criação dinâmica)
- `otclient/modules/game_screenshot/game_screenshot.otui`
- `otclient/modules/game_screenshot/game_screenshot.lua`

> Lista extensa e completa de arquivos em: `APENDICE_ARQUIVOS_OTUI_WIDGETS.md`.

---

## 3. Código Extraído (trechos relevantes)

### 3.1 Carregamento de OTUI + seleção device/OS + criação de widget
Arquivo: `otclient/src/framework/ui/uimanager.cpp`

```cpp
UIWidgetPtr UIManager::loadUI(const std::string& file, const UIWidgetPtr& parent)
{
    OTMLNodePtr widgetNode = nullptr;
    const auto& doc = OTMLDocument::parse(g_resources.guessFilePath(file, "otui"));

    for (const auto& node : doc->children()) {
        std::string tag = node->tag();
        if (tag.find('<') != std::string::npos)
            importStyleFromOTML(node);
        else {
            if (widgetNode)
                throw Exception("cannot have multiple main widgets in otui files");
            widgetNode = node;
        }
    }

    // override por device e OS
    const auto device = g_platform.getDevice();
    const auto& deviceWidgetNode = loadDeviceUI(file, device.type);
    const auto osWidgetNode = loadDeviceUI(file, device.os);
    if (deviceWidgetNode) widgetNode = deviceWidgetNode;
    if (osWidgetNode) widgetNode = osWidgetNode;

    return createWidgetFromOTML(widgetNode, parent);
}
```

### 3.2 Instanciação por classe OTUI (`__class`) e lifecycle Lua
Arquivo: `otclient/src/framework/ui/uimanager.cpp`

```cpp
UIWidgetPtr UIManager::createWidgetFromOTML(const OTMLNodePtr& widgetNode, const UIWidgetPtr& parent)
{
    const auto& originalStyleNode = getStyle(widgetNode->tag());
    const auto& styleNode = originalStyleNode->clone();
    styleNode->merge(widgetNode);

    const std::string widgetType = styleNode->valueAt("__class");
    const auto& widget = g_lua.callGlobalField<UIWidgetPtr>(widgetType, "create");

    if (parent)
        parent->addChild(widget);

    widget->callLuaField("onCreate");
    widget->setStyleFromNode(styleNode);

    for (const auto& childNode : styleNode->children()) {
        if (!childNode->isUnique()) {
            createWidgetFromOTML(childNode, widget);
            styleNode->removeChild(childNode);
        }
    }

    widget->callLuaField("onSetup");
    return widget;
}
```

### 3.3 Aplicação de estilo OTUI no widget
Arquivo: `otclient/src/framework/ui/uiwidget.cpp`

```cpp
void UIWidget::onStyleApply(const std::string_view, const OTMLNodePtr& styleNode)
{
    if (const auto& node = styleNode->get("id"))
        setId(node->value());

    parseBaseStyle(styleNode);
    parseImageStyle(styleNode);
    parseTextStyle(styleNode);
    parseCustomStyle(styleNode);

    repaint();
}
```

### 3.4 Parsing de propriedades OTUI (base)
Arquivo: `otclient/src/framework/ui/uiwidgetbasestyle.cpp`

```cpp
void UIWidget::parseBaseStyle(const OTMLNodePtr& styleNode)
{
    // callbacks e campos lua
    if (node->tag().starts_with("@")) { ... }
    else if (node->tag().starts_with("&")) { ... }

    // propriedades comuns
    else if (node->tag() == "x") setX(node->value<int>());
    else if (node->tag() == "y") setY(node->value<int>());
    else if (node->tag() == "width") setWidth(node->value<std::string>());
    else if (node->tag() == "height") setHeight(node->value<std::string>());
    else if (node->tag() == "background") setBackgroundColor(node->value<Color>());
    else if (node->tag() == "icon-source") setIcon(stdext::resolve_path(node->value(), node->source()));
    ...
}
```

### 3.5 Exposição de API de UI para Lua (`g_ui`)
Arquivo: `otclient/src/framework/luafunctions.cpp`

```cpp
g_lua.registerSingletonClass("g_ui");
g_lua.bindSingletonFunction("g_ui", "importStyle", &UIManager::importStyle, &g_ui);
g_lua.bindSingletonFunction("g_ui", "loadUI", &UIManager::loadUI, &g_ui);
g_lua.bindSingletonFunction("g_ui", "createWidget", &UIManager::createWidget, &g_ui);
g_lua.bindSingletonFunction("g_ui", "createWidgetFromOTML", &UIManager::createWidgetFromOTML, &g_ui);
```

### 3.6 Exemplo OTUI real com herança + eventos
Arquivo: `otclient/modules/game_screenshot/game_screenshot.otui`

```otui
ScreenshotType < UIWidget
  background-color: alpha

  CheckBox
    id: enabled
    @onCheckChange: modules.game_screenshot.onUICheckBox(self, self:isChecked())
```

### 3.7 Exemplo Lua real com `loadUI` + `createWidget`
Arquivo: `otclient/modules/game_screenshot/game_screenshot.lua`

```lua
optionPanel = g_ui.loadUI('game_screenshot', modules.client_options:getPanel())
for _, screenshotEvent in ipairs(AutoScreenshotEvents) do
  local label = g_ui.createWidget("ScreenshotType", optionPanel.allCheckBox)
  ...
end
```

---

## 4. Fluxo de Execução

### Fluxo principal OTUI → Widget

`client_styles/styles.lua:init()`
↓ (varre `/data/styles` e importa `.otui`)
`g_ui.importStyle(...)`
↓
`UIManager::importStyle` + `importStyleFromOTML`
↓
módulo Lua chama `g_ui.loadUI("arquivo", parent)`
↓
`UIManager::loadUI`
↓ (parse `.otui`, separa nós de estilo e widget root)
`UIManager::createWidgetFromOTML`
↓
resolve `__class` da style e chama `Class.create` via Lua
↓
`UIWidget::setStyleFromNode` → `applyStyle`
↓
`parseBaseStyle/parseImageStyle/parseTextStyle/parseCustomStyle`
↓
cria children recursivamente
↓
`onSetup`
↓
widget entra na árvore, recebe input/render/layout via `UIManager`

### Fluxo de input e estados

`UIManager::inputEvent`
↓
propagação para widget foco/mouse
↓
`onMousePress/onMouseRelease/onMouseMove/onClick`
↓
transições de estado (`$hover`, `$pressed`, `$checked`, etc.)
↓
`UIWidget::updateStyle` recompõe style de estado

---

## 5. Dependências

### Dependências de parsing/estrutura
- OTML: `OTMLDocument`, `OTMLNode`, `OTMLParser`.
- Resource manager: resolução/leitura de arquivos OTUI.
- Lua engine: `g_lua` para criar classes e callbacks.

### Dependências de runtime UI
- `UIManager` (root widget, input, render, hover/drag/focus, lifecycle).
- `UIWidget` (árvore de children, estilos, eventos, layout, desenho).
- Layouts: `UIAnchorLayout`, `UIVerticalLayout`, `UIHorizontalLayout`, `UIGridLayout`.
- Render: draw pool, fontes, texturas, shaders.

### Dependências de módulo
- `client_styles/styles.lua` para bootstrap global.
- Módulos funcionais (`game_*`, `client_*`) com seus `.otui` e scripts Lua.

---

## 6. Integração Server ↔ Client (se existir)

- **OTUI/WIDGETS não utilizam opcode próprio** no protocolo.
- O sistema OTUI é puramente do cliente (definição, criação e renderização de interface).
- Integração com servidor ocorre **indiretamente**:
  - servidor envia dados de gameplay (opcodes/protocol packets),
  - módulos Lua/client processam,
  - widgets são atualizados para refletir estado.

> Não encontrado no código: packet/opcode dedicado exclusivamente ao parser OTUI.

---

## 7. Pontos de Modificação

### Alterar comportamento global de OTUI
- `UIManager::importStyle*`, `UIManager::loadUI`, `UIManager::createWidgetFromOTML`.

### Adicionar/alterar propriedades OTUI
- `UIWidget::parseBaseStyle` (+ parseImageStyle/parseTextStyle quando aplicável).

### Alterar lógica de estados visuais
- `UIWidget::updateStyle` (matching de `$state` e merge de style stateful).

### Criar novos tipos de widget
- Criar classe C++ (`UI...`) e binding `bindClassStaticFunction<...>("create", ...)`.
- Disponibilizar style `NomeDoWidget < ...` com `__class` resolvendo para classe Lua/C++.

### Debug
- logs de falha em `loadUI/importStyle/createWidgetFromOTML`.
- `g_ui.setDebugBoxesDrawing(true)` para bounding boxes de widgets.

---

## 8. Riscos e Efeitos Colaterais

- **Quebra de herança de styles**: mudar base style pode impactar dezenas de widgets derivados.
- **Falha de criação**: `__class` inválido quebra instanciação em runtime.
- **Erro silencioso de UI**: OTUI inválido pode resultar em widget nulo e tela incompleta.
- **Regressão de input/foco**: mudanças em `UIManager::inputEvent` afetam toda navegação.
- **Performance**:
  - excesso de widgets dinâmicos,
  - recálculo frequente de layout/estilo,
  - text/image updates intensivos.

---

## 9. Resumo Técnico

OTUI é a DSL declarativa da UI no OTClient, parseada como OTML e aplicada via `UIManager`/`UIWidget`. O pipeline central é: importar styles → carregar OTUI → resolver classe (`__class`) → criar widgets (Lua/C++) → aplicar estilo/estados → processar input/render/layout. O sistema é 100% client-side; o servidor só influencia indiretamente pelos dados de jogo consumidos pelos módulos Lua.

---

## 10. Sugestões

- Padronizar naming de styles e IDs para reduzir colisões e facilitar refator.
- Separar componentes OTUI reutilizáveis em arquivos de style dedicados.
- Criar checklist de validação OTUI (lint básico: classe existente, main widget único, callbacks válidos).
- Instrumentar métricas de custo de layout/repaint para telas grandes.
