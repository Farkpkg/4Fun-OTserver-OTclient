---
alwaysApply: true
---
# Guia para Criar Módulos no OTClient

## Escopo

Este guia cobre a criação de módulos com HTML/CSS e Lua. Para OTUI, layouts e propriedades de widgets, consulte `data/AGENTS.md`. Para a base C++ de UI, consulte `src/framework/ui/AGENTS.md`.

## Visão Geral

Este guia ensina como criar módulos no OTClient usando HTML/CSS para interface e Lua para lógica. Baseado na análise do módulo `game_htmlsample` e no tutorial oficial do OTClient.

## Estrutura de um Módulo

Todo módulo no OTClient deve ter **3 arquivos principais**:

```
modules/meu_modulo/
├── meu_modulo.otmod    # Registro do módulo
├── meu_modulo.lua      # Lógica em Lua
└── meu_modulo.html     # Interface HTML/CSS
```

## Arquitetura do Sistema de Módulos

- Módulos são descobertos em `modules/` e carregados por prioridade.
- Faixas de prioridade sugeridas:
  - 0-99: client (login, opções, infraestrutura).
  - 100-499: game (interface, batalha, console).
  - 500+: extensões customizadas.
- Padrão Controller com hooks de lifecycle: init/terminate/callbacks.
 - Ordem base de libs: `corelib` -> `gamelib` -> `modulelib` (ver `init.lua`).

## Subguias de módulos

- `modules/dev.md`: workflow de desenvolvimento de módulos.
- `modules/client/AGENTS.md`: UI base do client (login, menus, estilos).
- `modules/client_styles/AGENTS.md`: carregamento de styles/fonts/particles.
- `modules/client_entergame/AGENTS.md`: login e selecao de personagem.
- `modules/client_options/AGENTS.md`: configuracoes e persistencia.
- `modules/game_interface/AGENTS.md`: UI principal do jogo.
- `modules/game_shaders/AGENTS.md`: shaders GLSL e configuracao em Lua.
- `modules/game_attachedeffects/AGENTS.md`: efeitos anexados (shaders/particulas).
- `modules/game_outfit/AGENTS.md`: janela de outfit e shaders.
- `modules/game_console/AGENTS.md`: chat e console.
- `modules/game_hotkeys/AGENTS.md`: hotkeys.
- `modules/game_textmessage/AGENTS.md`: mensagens na tela.
- `modules/game_textwindow/AGENTS.md`: janelas de texto.
- `modules/game_battle/AGENTS.md`: battle list e tracking de criaturas.
- `modules/game_skills/AGENTS.md`: painel de skills.
- `modules/game_inventory/AGENTS.md`: painel de inventario.
- `modules/game_minimap/AGENTS.md`: minimapa.
- `modules/game_viplist/AGENTS.md`: lista de VIPs.
- `modules/game_containers/AGENTS.md`: containers e sorting.
- `modules/game_healthinfo/AGENTS.md`: barras de vida/mana.
- `modules/corelib/AGENTS.md`: base Lua do client.
- `modules/gamelib/AGENTS.md`: base Lua do jogo.
- `modules/modulelib/AGENTS.md`: Controller e ciclo de vida de modulos.
- `modules/game_features/AGENTS.md`: flags de features do protocolo.

### 1. Arquivo `.otmod` - Registro do Módulo

O arquivo `.otmod` é o **manifesto** que registra o módulo no OTClient:

```lua
Module
  name: meu_modulo
  description: Descrição do meu módulo
  author: Seu Nome
  website: https://seusite.com
  scripts: [ meu_modulo.lua ]
  sandboxed: true
  @onLoad: MeuModulo:init()
  @onUnload: MeuModulo:terminate()
```

**Propriedades importantes:**
- **`name`**: Nome único do módulo
- **`scripts`**: Array com arquivos Lua a carregar
- **`sandboxed`**: `true` para isolamento de segurança
- **`@onLoad`**: Função chamada ao carregar o módulo
- **`@onUnload`**: Função chamada ao descarregar o módulo

### 2. Arquivo `.lua` - Controlador do Módulo

O arquivo Lua contém toda a **lógica** do módulo:

```lua
-- Criar controlador herdando de Controller
MeuModulo = Controller:new()

-- Função de inicialização
function MeuModulo:onInit()
    -- Carregar HTML apenas quando necessário
    self:loadHtml('meu_modulo.html')
    
    -- Inicializar funcionalidades
    self:setupEventHandlers()
end

-- Função de finalização
function MeuModulo:terminate()
    -- Limpar recursos
    self:unloadHtml()
end

-- Exemplo de função personalizada
function MeuModulo:addPlayer(name)
    -- Encontrar elemento e adicionar conteúdo
    self:findWidget('#players'):append(string.format([[
        <div>%s</div>
    ]], name))
end

-- Exemplo de efeito visual
function MeuModulo:equalizerEffect()
    local widgets = self:findWidgets('.line')
    
    for _, widget in pairs(widgets) do
        local minV = math.random(0, 30)
        local maxV = math.random(70, 100)
        
        -- Criar animação cíclica
        self:cycleEvent(function()
            local value = math.random(minV, maxV)
            widget:setHeight(10 + value)
            widget:setTop(89 - value)
        end, 30) -- 30ms de intervalo
    end
end
```

## UI em módulos (HTML/CSS)

- Para guias de HTML/CSS, eventos, exemplos e troubleshooting, veja `modules/ui.md`.
- OTUI e propriedades ficam em `data/AGENTS.md`.
- Base C++ de UI em `src/framework/ui/AGENTS.md`.
