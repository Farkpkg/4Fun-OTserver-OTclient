---
alwaysApply: true
---

# Guia de C++ (Core, Protocolo e Engine)

## Escopo

Este guia cobre desenvolvimento em C++ para o núcleo do cliente, protocolo de rede e engine. Para UI e módulos, veja `modules/AGENTS.md` e `data/AGENTS.md`.

## Estratégia de crescimento

- Este arquivo começa como visão geral do C++.
- Quando crescer demais, criar guias por subpasta (ex.: `src/client/AGENTS.md`, `src/framework/AGENTS.md`).
- O guia pai vira índice, com links e resumos curtos de cada subguia.

## Subguias

- `src/framework/AGENTS.md`: ciclo de vida da aplicacao, UI, graphics, Lua e plataforma.
- `src/framework/luaengine/AGENTS.md`: bindings C++ ↔ Lua.
- `src/framework/net/AGENTS.md`: transporte, criptografia e mensagens.
- `src/client/AGENTS.md`: game, protocolo e callbacks.
- `src/client/world.md`: mapa, tiles e entidades.
- `src/client/rendering.md`: visibilidade, lighting e thingtype.
- `src/client/creatures.md`: movimento e animacao de criaturas.
- `src/client/assets.md`: thing types e carregamento de assets.
- `src/client/network.md`: protocolo e fluxo de mensagens.
- `src/client/state.md`: sincronizacao de estado do jogo.
- `src/protobuf/AGENTS.md`: schemas protobuf para assets e dados estaticos.

## Graphics Rendering Pipeline (visao geral)

- O pipeline usa DrawPool no framework e integra com o client (ex.: `client/lightview.*`).
- Para detalhes de batching, pools e atlas, veja `src/framework/AGENTS.md`.

## Visão Geral do OTClient - Redemption

- Cliente alternativo de Tibia para servidores Open Tibia, baseado no fork do OTClient (rev 2.760).
- Implementado em C++20 com forte integração Lua para UI e lógica de módulos.
- Arquitetura modular e data-driven (UI em `.otui` e configurações em `.otml`).

## Filosofia de Arquitetura

- Scriptable by default: UI e módulos em Lua.
- Caminho crítico em C++: rendering, rede, mapas.
- Abstração de plataforma: desktop, mobile e WebAssembly.
- Design data-driven: aparência e fluxos ajustáveis sem recompilar.

## Subsystems Principais

- Framework core: `framework/core/graphicalapplication.cpp` (lifecycle, loop, módulos).
- UI system: `framework/ui/uimanager.cpp`, `framework/ui/uiwidget.cpp`.
- Graphics pipeline: `framework/graphics/drawpool.cpp`, `framework/graphics/painter.cpp`.
- Game state: `client/game.cpp`.
- Network: `client/protocolgame.cpp`, `client/protocolgameparse.cpp`.
- World: `client/map.cpp`, `client/tile.cpp`, `client/creature.cpp`.
- Assets: `client/thingtype.cpp`, `client/spritemanager.cpp`.
- Lua bridge: `client/luafunctions.cpp`.

## Threading Model

- Três threads: network, map, main.
- Sincronização via `g_dispatcher` e filas de eventos.

## Integração Lua ⇄ C++

- Lua chama C++ via bindings (ex.: `g_game.walk`).
- C++ chama Lua via callbacks (ex.: `g_lua.callGlobalField`).

## Compatibilidade de Protocolo

- Suporte a protocolos Tibia 7.72 até 15.11 (varia por servidor).

## Visão Geral da Arquitetura

O OTClient é um cliente MMORPG baseado em C++17/20 com sistema de scripting Lua integrado. A arquitetura segue um padrão modular com separação clara entre protocolo de rede, lógica de jogo e interface do usuário.

## Estrutura de Comunicação

### 1. Sistema de Protocolo

#### Arquivos Principais:
- **`protocolcodes.h`**: Define todos os opcodes de comunicação cliente-servidor
- **`protocolgame.h`**: Interface da classe ProtocolGame para comunicação
- **`protocolgameparse.cpp`**: Implementação do parsing de mensagens do servidor

#### Fluxo de Comunicação:
```
Cliente ←→ ProtocolGame ←→ parseMessage() ←→ Funções específicas de parsing
```

### 2. Sistema de Parsing de Mensagens

#### Função Principal: `parseMessage()`
```cpp
void ProtocolGame::parseMessage(const InputMessagePtr& msg)
{
    uint8_t opcode = msg->getU8();
    
    // Tenta parsing em Lua primeiro
    if(callLuaField("onOpcode", opcode, msg))
        return;
        
    // Fallback para switch C++
    switch(opcode) {
        case Proto::GameServerLoginOrPendingState:
            parsePendingGame(msg);
            break;
        // ... outros casos
    }
}
```

#### Padrões de Leitura com `msg->getU8()`:
- **Opcodes**: `uint8_t opcode = msg->getU8()`
- **Flags booleanas**: `bool flag = msg->getU8()`
- **Contadores**: `uint8_t count = msg->getU8()`
- **Tipos/IDs**: `uint8_t type = msg->getU8()`
- **Enums**: `static_cast<EnumType>(msg->getU8())`

### 3. Hierarquia de Classes

#### Player System:
```
Creature (base)
    ↓
Player (simples, apenas herda de Creature)
    ↓
LocalPlayer (jogador local com funcionalidades específicas)
```

#### Game System:
- **`Game`**: Singleton global (`g_game`) que gerencia estado do jogo
- **`LocalPlayer`**: Representa o jogador local com atributos específicos
- **`ProtocolGame`**: Gerencia comunicação cliente-servidor

## Regras de Desenvolvimento

### 1. Convenções de Código C++

#### Nomenclatura:
```cpp
// Variáveis e funções: camelCase
bool isValidPosition = true;
void processPlayerMovement();

// Classes: PascalCase
class ProtocolGame;
class LocalPlayer;

// Constantes: UPPER_SNAKE_CASE
const uint8_t MAX_PLAYERS = 100;

// Membros privados: m_ prefix
class Player {
private:
    uint32_t m_health;
    std::string m_name;
};
```

#### Smart Pointers:
```cpp
// SEMPRE use smart pointers para gerenciamento de memória
std::shared_ptr<Player> player;
std::unique_ptr<Item> item;

// Typedefs específicos do projeto
PlayerPtr player = std::make_shared<Player>();
LocalPlayerPtr localPlayer = std::make_shared<LocalPlayer>();
```

#### Validação de Parâmetros:
```cpp
void processAction(const PlayerPtr& player, const ItemPtr& item) {
    // SEMPRE valide parâmetros de entrada
    if (!player || !item) {
        g_logger.error("Invalid parameters in processAction");
        return;
    }
    
    // Lógica da função...
}
```

### 2. Sistema de Protocolo

#### Definição de Opcodes:
```cpp
// Em protocolcodes.h
namespace Proto {
    enum GameServerOpcodes : uint8_t {
        GameServerLoginOrPendingState = 0x0A,
        GameServerGMActions = 0x0B,
        GameServerUpdateNeeded = 0x11,
        // ... outros opcodes
    };
}
```

#### Implementação de Parsing:
```cpp
// Padrão para funções de parsing
void ProtocolGame::parseSpecificMessage(const InputMessagePtr& msg)
{
    // 1. Ler dados na ordem correta
    uint8_t type = msg->getU8();
    uint16_t id = msg->getU16();
    uint32_t value = msg->getU32();
    std::string text = msg->getString();
    
    // 2. Validar dados
    if (type > MAX_TYPE_VALUE) {
        g_logger.error("Invalid type received: %d", type);
        return;
    }
    
    // 3. Processar através do Game
    g_game.processSpecificAction(type, id, value, text);
}
```

#### Envio de Mensagens:
```cpp
// Padrão para envio de mensagens
void ProtocolGame::sendSpecificAction(uint8_t action, uint32_t param)
{
    OutputMessagePtr msg = OutputMessagePtr(new OutputMessage);
    msg->addU8(Proto::ClientSpecificAction);
    msg->addU8(action);
    msg->addU32(param);
    send(msg);
}
```

### 3. Sistema de Jogo

#### Processamento no Game:
```cpp
// Todas as ações do jogo passam pela classe Game
void Game::processSpecificAction(uint8_t type, uint32_t id, const std::string& data)
{
    // 1. Validar estado do jogo
    if (!isOnline()) {
        g_logger.warning("Received action while offline");
        return;
    }
    
    // 2. Processar ação
    switch(type) {
        case ActionType::PlayerUpdate:
            if (m_localPlayer) {
                m_localPlayer->updateData(id, data);
            }
            break;
        // ... outros casos
    }
    
    // 3. Notificar Lua se necessário
    g_lua.callGlobalField("g_game", "onSpecificAction", type, id, data);
}
```

#### Gerenciamento de Estado:
```cpp
// Estados do jogo são centralizados na classe Game
class Game {
private:
    bool m_online = false;
    bool m_dead = false;
    LocalPlayerPtr m_localPlayer;
    ProtocolGamePtr m_protocolGame;
    
    // Containers e dados do jogo
    std::unordered_map<uint8_t, ContainerPtr> m_containers;
    std::vector<CreaturePtr> m_vips;
    
public:
    // Getters com validação
    LocalPlayerPtr getLocalPlayer() { return m_localPlayer; }
    bool isOnline() const { return m_online && m_protocolGame; }
    bool canPerformGameAction() const { return m_online && !m_dead; }
};
```

### 4. Sistema LocalPlayer

#### Atributos do Jogador:
```cpp
class LocalPlayer : public Player {
private:
    // Stats básicos
    uint32_t m_health = 0;
    uint32_t m_maxHealth = 0;
    uint32_t m_mana = 0;
    uint32_t m_maxMana = 0;
    uint64_t m_experience = 0;
    uint16_t m_level = 0;
    uint8_t m_levelPercent = 0;
    
    // Skills
    struct Skill {
        uint16_t level = 0;
        uint16_t baseLevel = 0;
        uint16_t levelPercent = 0;
    };
    std::array<Skill, Otc::LastSkill> m_skills;
    
    // Estados
    bool m_known = false;
    bool m_premium = false;
    bool m_pending = false;
    
public:
    // Setters com validação
    void setHealth(uint32_t health, uint32_t maxHealth) {
        m_health = health;
        m_maxHealth = maxHealth;
        // Notificar mudança se necessário
    }
};
```

### 5. Integração com Lua

#### Exposição de Funções:
```cpp
// Registrar funções C++ para Lua
void registerGameFunctions() {
    g_lua.registerClass<Game>();
    g_lua.bindClassMemberFunction<Game>("getLocalPlayer", &Game::getLocalPlayer);
    g_lua.bindClassMemberFunction<Game>("isOnline", &Game::isOnline);
    // ... outras funções
}
```

#### Callbacks Lua:
```cpp
// Chamar funções Lua a partir do C++
void Game::processLogin() {
    // Processar login em C++
    m_online = true;
    
    // Notificar Lua
    g_lua.callGlobalField("g_game", "onLogin");
}
```

### 6. Tratamento de Erros

#### Logging:
```cpp
// Use o sistema de logging do projeto
g_logger.info("Player %s logged in", playerName);
g_logger.warning("Invalid packet received: opcode %d", opcode);
g_logger.error("Failed to process action: %s", errorMessage);
```

#### Validação de Rede:
```cpp
void ProtocolGame::parseMessage(const InputMessagePtr& msg) {
    try {
        uint8_t opcode = msg->getU8();
        
        // Validar opcode
        if (opcode > Proto::LastGameServerOpcode) {
            g_logger.error("Invalid opcode received: %d", opcode);
            return;
        }
        
        // Processar mensagem...
    } catch (const std::exception& e) {
        g_logger.error("Exception in parseMessage: %s", e.what());
        processDisconnect();
    }
}
```

### 7. Performance e Otimização

#### Uso Eficiente de Memória:
```cpp
// Evite cópias desnecessárias
void processText(const std::string_view& text) {  // string_view em vez de string
    // Processar texto sem copiar
}

// Use move semantics quando apropriado
void setPlayerName(std::string&& name) {
    m_name = std::move(name);
}
```

#### Cache e Reutilização:
```cpp
// Cache objetos frequentemente usados
class Game {
private:
    static constexpr size_t CONTAINER_CACHE_SIZE = 64;
    std::unordered_map<uint8_t, ContainerPtr> m_containerCache;
    
public:
    ContainerPtr getContainer(uint8_t id) {
        auto it = m_containerCache.find(id);
        if (it != m_containerCache.end()) {
            return it->second;
        }
        return nullptr;
    }
};
```

### 8. Segurança

#### Validação de Dados:
```cpp
void ProtocolGame::parsePlayerData(const InputMessagePtr& msg) {
    uint16_t level = msg->getU16();
    
    // Validar limites
    if (level > MAX_PLAYER_LEVEL) {
        g_logger.warning("Invalid player level received: %d", level);
        level = MAX_PLAYER_LEVEL;
    }
    
    // Processar dados validados...
}
```

#### Prevenção de Overflow:
```cpp
// Verificar limites antes de operações
void addExperience(uint64_t exp) {
    if (m_experience > UINT64_MAX - exp) {
        m_experience = UINT64_MAX;  // Cap no máximo
    } else {
        m_experience += exp;
    }
}
```

## Estrutura de Arquivos

### Organização do Código:
```
src/client/
├── game.h/cpp              # Núcleo do jogo
├── localplayer.h/cpp       # Jogador local
├── player.h/cpp            # Classe base do jogador
├── protocolgame.h/cpp      # Protocolo de comunicação
├── protocolgameparse.cpp   # Parsing de mensagens
├── protocolcodes.h         # Definições de opcodes
├── creature.h/cpp          # Classe base de criaturas
├── map.h/cpp              # Sistema de mapas
└── ...
```

### Módulos Lua:
```
modules/
├── gamelib/               # Biblioteca base do jogo
├── game_inventory/        # Sistema de inventário
├── game_playertrade/      # Sistema de trade
├── game_playerdeath/      # Sistema de morte
└── ...
```

## Padrões de Implementação

### 1. Singleton Pattern:
```cpp
// Game é um singleton global
extern Game g_game;

// Uso:
if (g_game.isOnline()) {
    g_game.getLocalPlayer()->walk(direction);
}
```

### 2. Observer Pattern:
```cpp
// Notificações através de callbacks Lua
void Game::processPlayerUpdate() {
    // Atualizar estado interno
    updatePlayerData();
    
    // Notificar observadores
    g_lua.callGlobalField("g_game", "onPlayerUpdate");
}
```

### 3. Factory Pattern:
```cpp
// Criação de objetos através de factories
CreaturePtr createCreature(uint32_t id) {
    if (id == g_game.getLocalPlayer()->getId()) {
        return g_game.getLocalPlayer();
    }
    return std::make_shared<Creature>();
}
```

## Debugging e Testes

### Logging Detalhado:
```cpp
#ifdef DEBUG
    g_logger.debug("Processing opcode %d with %d bytes", opcode, msg->getUnreadSize());
#endif
```

### Validação de Estado:
```cpp
void Game::validateGameState() {
    assert(m_online == (m_protocolGame != nullptr));
    assert(!m_localPlayer || m_localPlayer->getId() != 0);
    // ... outras validações
}
```

## Conclusão

Este documento serve como guia completo para desenvolvimento no OTClient. Siga estas regras para manter a consistência, performance e segurança do código. A arquitetura modular permite extensibilidade através de Lua mantendo a performance crítica em C++.

### Pontos Chave:
1. **Sempre valide dados de entrada**
2. **Use smart pointers para gerenciamento de memória**
3. **Mantenha a separação entre protocolo, lógica e UI**
4. **Implemente logging adequado para debugging**
5. **Siga os padrões de nomenclatura estabelecidos**
6. **Teste thoroughly antes de fazer commit**

Para dúvidas específicas, consulte o código existente como referência e mantenha a consistência com os padrões estabelecidos.
# Cursor Context — Encrypt & Builder System (OTClient / Canary)

Este conteúdo foi movido para `tools/AGENTS.md`.
