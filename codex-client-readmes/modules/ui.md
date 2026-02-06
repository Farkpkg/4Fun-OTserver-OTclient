# UI em Módulos (HTML/CSS)

## Escopo

Este guia cobre UI em módulos via HTML/CSS e Lua. Para OTUI, veja `data/AGENTS.md`. Para a base C++ de UI, veja `src/framework/ui/AGENTS.md`.

## Arquivo `.html` - Interface do Usuário

O arquivo HTML define a **interface visual** usando HTML/CSS:

```html
<style>
  .content {
    position: relative;
    background-color: #2c3e50;
    width: 500px;
    height: 300px;
    border: 2px solid #34495e;
  }
  
  .form {
    display: inline-block;
    width: 50%;
    height: 20%;
    margin-top: 30px;
  }

  #players {
    background-color: #34495e;
    overflow: scroll;
    color: white;
  }

  .footer {
    position: absolute;
    bottom: 10px;
    width: 100%;
  }
</style>

<script type="text">
  self.title = "Meu Módulo";
  self.msg = "Bem-vindo ao meu módulo!";
  self.playerName = "";
</script>

<html>
  <window class="content" anchor="parent" *title="self.title">
    <div style="margin: 30px; text-align: center">{{self.msg}}</div>
    
    <div class="form">
      <label style="padding: 3px">Nome:</label>
      <input type="text" *value="self.playerName" />
    </div>
    
    <div id="players" class="form"></div>
    
    <div style="margin-top: 10px">Nome do jogador: {{self.playerName}}</div>
    
    <div>
      <button onclick="self:addPlayer(self.playerName)">Adicionar</button>
    </div>
    
    <div class="footer">
      <button onclick="alert('Meu Módulo v1.0')">Sobre</button>
      <button style="float: right" onclick="self:unloadHtml()">Fechar</button>
    </div>
  </window>
</html>
```

## Sistema HTML/CSS do OTClient

### Estrutura Obrigatória

Todo arquivo HTML **deve** ter o conteúdo dentro da tag `<html>` raiz:

```html
<html>
  <!-- Todo conteúdo aqui -->
</html>
```

### Boas práticas de HTML/CSS

- Prefira classes em vez de estilos inline quando possível.
- Use estrutura semântica e nomes de classes consistentes.
- Evite `!important`; prefira ajustar a especificidade.

### Diferenças entre OTUI e HTML/CSS

O OTClient suporta **dois sistemas** de interface:

1. **OTUI (tradicional)**: Sintaxe similar ao CSS, mas específica do OTClient
2. **HTML/CSS (novo)**: Sistema moderno que suporta HTML e CSS padrão

#### Vantagens do HTML/CSS:
- **Familiar**: Desenvolvedores web podem contribuir facilmente
- **Flexível**: Mais opções de layout e estilização
- **Moderno**: Suporte a recursos avançados de CSS
- **Produtivo**: Desenvolvimento mais rápido de interfaces

### Seções do HTML

#### 1. **`<style>`** - Definições CSS
```html
<style>
  .minha-classe {
    background-color: rgb(84, 36, 36);
    width: 200px;
    height: 200px;
    text-align: center;
  }
</style>
```

#### 2. **`<script type="text">`** - Lógica Lua Inline
```html
<script type="text">
  self.welcomeMsg = 'Bem-vindo ao OTC'
  self.playerCount = 0
  
  -- Evento cíclico
  self:cycleEvent(function()
      self.playerCount = self.playerCount + 1
  end, 1000)
</script>
```

#### 3. **`<html>`** - Interface Visual
```html
<html>
  <div class="content">{{self.welcomeMsg}}</div>
</html>
```

## Propriedades CSS Suportadas

### Layout e Posicionamento
- **`display`**: `block`, `inline`, `inline-block`, `none`
- **`position`**: `static`, `relative`, `absolute`
- **`float`**: `left`, `right`, `none`
- **`clear`**: `left`, `right`, `both`, `none`

### Dimensões
- **`width`**, **`height`**: `px`, `%`, `auto`, `fit-content`

### Alinhamento
- **`text-align`**: `left`, `right`, `center`, `justify`
- **`justify-items`**: `left`, `right`, `center`
- **`align-items`**: `center`

### Visibilidade
- **`visibility`**: `visible`, `hidden`
- **`overflow`**: `visible`, `hidden`, `clip`, `scroll`

### Cores e Bordas
```css
.exemplo {
  background-color: rgb(255, 0, 0);
  color: #ffffff;
  border: 2px solid #000000;
  font-size: 14px;
}
```

## Atributos Especiais com `*` (Lua Bind)

Atributos com `*` criam **binding** com variáveis Lua:

```html
<!-- Binding de título -->
<window *title="self.windowTitle">

<!-- Binding de valor -->
<input type="text" *value="self.playerName" />

<!-- Binding de visibilidade -->
<div *visible="self.showPanel">
```

## Sistema de Eventos

### Eventos Suportados
- **`onclick`**: Clique do mouse
- **`onchange`**: Mudança de valor
- **`onhover`**: Mouse sobre elemento
- **`onfocus`**: Elemento ganha foco

### Chamando Métodos Lua
```html
<!-- Chamar método do controlador -->
<button onclick="self:meuMetodo()">Clique</button>

<!-- Chamar função global -->
<button onclick="alert('Mensagem')">Alerta</button>

<!-- Passar parâmetros -->
<button onclick="self:addPlayer(self.playerName)">Adicionar</button>
```

### Variáveis Disponíveis nos Eventos
- **`self`**: Referência ao controlador
- **`event`**: Objeto do evento
- **`widget`**: Widget que disparou o evento

## Gerenciamento de Carregamento

### Estratégias de Carregamento

#### 1. **Módulos Core** - Carregar em `onInit`
```lua
function MeuModulo:onInit()
    -- Para módulos essenciais (HUD, etc.)
    self:loadHtml("interface.html")
end
```

#### 2. **Módulos de Jogo** - Carregar em `onGameStart`
```lua
function MeuModulo:onGameStart()
    -- Carrega apenas quando entra no jogo
    self:loadHtml("inventory.html")
end
```

#### 3. **Módulos On-Demand** - Carregar quando necessário
```lua
function MeuModulo:openQuestLog()
    -- Carrega apenas quando abrir
    self:loadHtml("questlog.html")
end

function MeuModulo:closeQuestLog()
    -- Descarrega para liberar memória
    self:unloadHtml()
end
```

### Separação de CSS com `<link>`

```html
<!-- No arquivo HTML -->
<link href="meu_modulo.css" />

<html>
  <div class="content">Conteúdo</div>
</html>
```

```css
/* No arquivo meu_modulo.css */
.content {
    background-color: #2c3e50;
    width: 400px;
    height: 300px;
}
```

### Recursos Avançados do Sistema HTML/CSS

#### 1. **Live Reload** - Recarga Automática
```lua
-- Ativar no init.lua
g_modules.enableAutoReload()
```
- Recarrega automaticamente quando arquivos são modificados
- Acelera desenvolvimento significativamente
- Ideal para testes e ajustes visuais

#### 2. **Suporte a Efeitos e Animações**
```css
.animated-element {
    transition: all 0.3s ease;
    transform: scale(1.0);
}

.animated-element:hover {
    transform: scale(1.1);
}
```

#### 3. **Integração com Sistema de Efeitos**
```html
<!-- Suporte a efeitos visuais do jogo -->
<div class="effect-container" data-effect="aura">
    <img src="player_sprite.png" />
</div>
```

#### 4. **Responsividade e Adaptação**
```css
/* Adapta-se ao tamanho da tela */
.responsive-container {
    width: 100%;
    max-width: 800px;
    min-width: 400px;
}

@media (max-width: 600px) {
    .responsive-container {
        width: 95%;
    }
}
```

## Comparação: OTUI vs HTML/CSS

### Arquivo OTUI (Sistema Tradicional)
```otui
MainWindow
  !text: tr('Spells')
  size: 160 450
  @onEnter: modules.game_spells.destroy()
  @onEscape: modules.game_spells.destroy()

  Label
    id: spellsLabel
    !text: tr('Player Spells')
    width: 130
    anchors.top: prev.top
    anchors.left: prev.left
    margin-top: 5
    margin-left: 5
```

### Arquivo HTML/CSS (Sistema Moderno)
```html
<style>
  .spells-window {
    width: 160px;
    height: 450px;
  }
  
  .spells-label {
    width: 130px;
    margin-top: 5px;
    margin-left: 5px;
  }
</style>

<html>
  <window class="spells-window" title="Spells">
    <label class="spells-label">Player Spells</label>
  </window>
</html>
```

### Quando Usar Cada Sistema

#### Use **OTUI** quando:
- Trabalhando com código legado
- Precisar de compatibilidade total
- Módulos simples e específicos

#### Use **HTML/CSS** quando:
- Criando novos módulos
- Interfaces complexas
- Equipe com conhecimento web
- Desenvolvimento rápido

## Seletores e Manipulação DOM

### Encontrar Elementos
```lua
-- Por ID
local element = self:findWidget('#meuId')

-- Por classe
local elements = self:findWidgets('.minhaClasse')

-- Por tag
local buttons = self:findWidgets('button')
```

### Manipular Conteúdo
```lua
-- Adicionar HTML
element:append('<div>Novo conteúdo</div>')

-- Definir texto
element:setText('Novo texto')

-- Modificar propriedades
element:setHeight(100)
element:setWidth(200)
element:setVisible(false)
```

## Exemplos Práticos

### 1. **Janela de Inventário**
```html
<style>
  .inventory {
    width: 300px;
    height: 400px;
    background-color: #34495e;
    border: 2px solid #2c3e50;
  }
  
  .slot {
    width: 32px;
    height: 32px;
    border: 1px solid #7f8c8d;
    display: inline-block;
    margin: 2px;
  }
  
  .item {
    background-color: #e74c3c;
    border-radius: 4px;
  }
</style>

<html>
  <window class="inventory" *title="self.inventoryTitle">
    <div id="slots">
      <!-- Slots serão adicionados dinamicamente -->
    </div>
  </window>
</html>
```

### 2. **Sistema de Chat**
```html
<style>
  .chat {
    width: 400px;
    height: 200px;
    background-color: rgba(0, 0, 0, 0.8);
  }
  
  .messages {
    height: 150px;
    overflow: scroll;
    padding: 5px;
  }
  
  .input-area {
    height: 30px;
    padding: 5px;
  }
</style>

<html>
  <div class="chat">
    <div id="messages" class="messages"></div>
    <div class="input-area">
      <input type="text" *value="self.message" style="width: 80%" />
      <button onclick="self:sendMessage()">Enviar</button>
    </div>
  </div>
</html>
```

### 3. **Painel de Status**
```html
<style>
  .status {
    width: 200px;
    height: 100px;
    background-color: #2c3e50;
  }
  
  .bar {
    height: 20px;
    background-color: #e74c3c;
    margin: 5px;
  }
  
  .health { background-color: #e74c3c; }
  .mana { background-color: #3498db; }
</style>

<script type="text">
  self.health = 100
  self.maxHealth = 100
  self.mana = 50
  self.maxMana = 100
</script>

<html>
  <div class="status">
    <div>HP: {{self.health}}/{{self.maxHealth}}</div>
    <div class="bar health" *width="(self.health/self.maxHealth)*180"></div>
    
    <div>MP: {{self.mana}}/{{self.maxMana}}</div>
    <div class="bar mana" *width="(self.mana/self.maxMana)*180"></div>
  </div>
</html>
```

## Métodos Úteis do Controller

### Carregamento
```lua
-- Carregar HTML
self:loadHtml('arquivo.html')

-- Descarregar HTML
self:unloadHtml()
```

### Eventos
```lua
-- Evento único
self:scheduleEvent(function()
    print("Executado uma vez")
end, 1000)

-- Evento cíclico
self:cycleEvent(function()
    print("Executado repetidamente")
end, 500)
```

### Manipulação de Widgets
```lua
-- Encontrar widget
local widget = self:findWidget('#meuId')

-- Encontrar múltiplos widgets
local widgets = self:findWidgets('.minhaClasse')

-- Verificar se widget existe
if widget then
    widget:setVisible(true)
end
```

## Boas Práticas

### 1. **Organização de Código**
```lua
-- Separar lógica em métodos específicos
function MeuModulo:onInit()
    self:loadHtml('interface.html')
    self:setupEventHandlers()
    self:initializeData()
end

function MeuModulo:setupEventHandlers()
    -- Configurar eventos
end

function MeuModulo:initializeData()
    -- Inicializar dados
end
```

### 2. **Gerenciamento de Memória**
```lua
function MeuModulo:terminate()
    -- Sempre limpar recursos
    self:unloadHtml()
    
    -- Cancelar eventos se necessário
    if self.myEvent then
        self.myEvent:cancel()
    end
end
```

### 3. **Validação de Dados**
```lua
function MeuModulo:addPlayer(name)
    -- Sempre validar entrada
    if not name or name == "" then
        alert("Nome inválido!")
        return
    end
    
    -- Processar dados válidos
    self:findWidget('#players'):append(string.format([[
        <div>%s</div>
    ]], name))
end
```

### 4. **CSS Modular**
```css
/* Use classes específicas para evitar conflitos */
.meumodulo-container {
    /* estilos do container */
}

.meumodulo-button {
    /* estilos dos botões */
}

.meumodulo-input {
    /* estilos dos inputs */
}
```

## Exemplo Completo: Módulo de Lista de Jogadores

### `player_list.otmod`
```lua
Module
  name: game_player_list
  description: Lista de jogadores online
  author: Seu Nome
  scripts: [ player_list.lua ]
  sandboxed: true
  @onLoad: PlayerList:init()
  @onUnload: PlayerList:terminate()
```

### `player_list.lua`
```lua
PlayerList = Controller:new()

function PlayerList:onInit()
    self.players = {}
    self:loadHtml('player_list.html')
    self:updatePlayerCount()
end

function PlayerList:terminate()
    self:unloadHtml()
end

function PlayerList:addPlayer(name, level)
    if not name or name == "" then
        alert("Nome inválido!")
        return
    end
    
    table.insert(self.players, {name = name, level = level or 1})
    self:refreshPlayerList()
    self:updatePlayerCount()
end

function PlayerList:removePlayer(index)
    table.remove(self.players, index)
    self:refreshPlayerList()
    self:updatePlayerCount()
end

function PlayerList:refreshPlayerList()
    local container = self:findWidget('#playerContainer')
    container:clear()
    
    for i, player in ipairs(self.players) do
        container:append(string.format([[
            <div class="player-item">
                <span>%s (Level %d)</span>
                <button onclick="self:removePlayer(%d)" style="float: right">Remover</button>
            </div>
        ]], player.name, player.level, i))
    end
end

function PlayerList:updatePlayerCount()
    self.playerCount = #self.players
end
```

### `player_list.html`
```html
<style>
  .player-list {
    width: 400px;
    height: 500px;
    background-color: #2c3e50;
    border: 2px solid #34495e;
    color: white;
  }
  
  .header {
    background-color: #34495e;
    padding: 10px;
    text-align: center;
    font-weight: bold;
  }
  
  .add-form {
    padding: 10px;
    background-color: #3a4a5c;
  }
  
  .add-form input {
    margin: 5px;
    padding: 5px;
    width: 150px;
  }
  
  .add-form button {
    margin: 5px;
    padding: 5px 10px;
    background-color: #27ae60;
    color: white;
    border: none;
  }
  
  .player-container {
    height: 300px;
    overflow: scroll;
    padding: 10px;
  }
  
  .player-item {
    padding: 8px;
    margin: 2px 0;
    background-color: #34495e;
    border-radius: 4px;
  }
  
  .player-item:nth-child(odd) {
    background-color: #3a4a5c;
  }
  
  .footer {
    position: absolute;
    bottom: 10px;
    width: 100%;
    text-align: center;
    padding: 10px;
  }
</style>

<script type="text">
  self.playerName = ""
  self.playerLevel = 1
  self.playerCount = 0
</script>

<html>
  <window class="player-list" anchor="parent" title="Lista de Jogadores">
    <div class="header">
      Jogadores Online: {{self.playerCount}}
    </div>
    
    <div class="add-form">
      <div>
        <label>Nome:</label>
        <input type="text" *value="self.playerName" />
      </div>
      <div>
        <label>Level:</label>
        <input type="number" *value="self.playerLevel" />
      </div>
      <div>
        <button onclick="self:addPlayer(self.playerName, self.playerLevel)">
          Adicionar Jogador
        </button>
      </div>
    </div>
    
    <div id="playerContainer" class="player-container">
      <!-- Jogadores serão adicionados aqui -->
    </div>
    
    <div class="footer">
      <button onclick="self:unloadHtml()">Fechar</button>
    </div>
  </window>
</html>
```

## Debugging e Troubleshooting

### Console Lua In-Game
```lua
-- Acessar console Lua no jogo (Ctrl + T)
print("Debug: " .. tostring(self.playerName))

-- Verificar se widget existe
local widget = self:findWidget('#meuId')
if widget then
    print("Widget encontrado!")
else
    print("Widget não encontrado!")
end
```

### Logs de Erro Comuns

#### 1. **"Widget not found"**
```lua
-- ERRO: Widget não existe
local widget = self:findWidget('#inexistente')

-- SOLUÇÃO: Verificar sempre
local widget = self:findWidget('#meuId')
if widget then
    widget:setText("Texto")
end
```

#### 2. **"HTML parsing error"**
```html
<!-- ERRO: Tag não fechada -->
<div>Conteúdo
<!-- SOLUÇÃO: Fechar todas as tags -->
<div>Conteúdo</div>
```

#### 3. **"CSS property not supported"**
```css
/* ERRO: Propriedade não suportada */
.elemento {
    box-shadow: 0 0 10px #000; /* Não suportado */
}

/* SOLUÇÃO: Usar propriedades suportadas */
.elemento {
    border: 1px solid #000;
}
```

### Ferramentas de Debug

#### 1. **Live Reload para Desenvolvimento**
```lua
-- No init.lua
g_modules.enableAutoReload()
```

#### 2. **Inspecionar Widgets**
```lua
-- Listar todos os widgets
local widgets = self:findWidgets('*')
for _, widget in pairs(widgets) do
    print("Widget ID: " .. (widget:getId() or "sem ID"))
end
```

#### 3. **Monitor de Performance**
```lua
-- Medir tempo de execução
local startTime = g_clock.millis()
-- ... código ...
local endTime = g_clock.millis()
print("Tempo: " .. (endTime - startTime) .. "ms")
```

## Recursos Adicionais

### Documentação Oficial
- **Wiki OTClient**:
- **Tutorial de Módulos**:
- **Exemplos de Código**: Pasta `modules/` do OTClient

### Comunidade e Suporte
- **OTLand Forum**: Discussões sobre desenvolvimento
- **GitHub Issues**: Reportar bugs e sugestões
- **Discord/Gitter**: Chat em tempo real

### Módulos de Exemplo para Estudar
```
modules/
├── game_htmlsample/     # Exemplo básico HTML/CSS
├── game_inventory/      # Sistema de inventário
├── game_battle/         # Lista de batalha
├── game_minimap/        # Minimapa
└── game_outfit/         # Sistema de outfit
```

### Ferramentas Recomendadas
- **Editor**: VS Code, Sublime Text, Notepad++
- **Debug**: Console Lua in-game (Ctrl + T)
- **Versionamento**: Git para controle de versão
- **Teste**: Live Reload para desenvolvimento rápido

## Conclusão

Este guia fornece uma base sólida para criar módulos no OTClient usando HTML/CSS e Lua. Lembre-se de:

1. **Seguir a estrutura de 3 arquivos** (.otmod, .lua, .html)
2. **Usar CSS suportado** pelo engine
3. **Gerenciar carregamento** adequadamente
4. **Validar dados** sempre
5. **Limpar recursos** na finalização
6. **Manter código organizado** e modular
7. **Usar Live Reload** para desenvolvimento eficiente
8. **Debuggar com console Lua** quando necessário

### Próximos Passos
1. **Pratique** com o módulo de exemplo `game_htmlsample`
2. **Estude** outros módulos existentes
3. **Experimente** criar seu próprio módulo simples
4. **Contribua** com a comunidade OTClient

Com essas práticas e recursos, você pode criar interfaces ricas, funcionais e profissionais para o OTClient!
