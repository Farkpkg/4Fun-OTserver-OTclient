# Data Flow

## Fluxo A — Inicialização completa

1. Server sobe (`CrystalServer::run`) e carrega banco/mapa/scripts.
2. Client executa `init.lua`, carrega módulos base e tela de entrada.
3. Login é processado por protocolo de login.
4. Ao entrar no jogo, cliente inicia módulos `game_*` e passa a consumir stream de estado do mapa/entidades.

## Fluxo B — Pacote cliente para regra server

1. Cliente serializa ação (opcode padrão ou extended opcode).
2. Server recebe em `ProtocolGame::parsePacketFromDispatcher`.
3. Handler C++ chama `g_game()` ou parser específico.
4. Regras atualizam estado e geram respostas para cliente.

## Fluxo C — Evento Lua de extensão

1. Pacote extended opcode chega ao server.
2. `Game::parsePlayerExtendedOpcode` itera eventos `CreatureEvent` registrados no player.
3. Callback Lua processa payload e opcionalmente responde com `Player:sendExtendedOpcode`.
4. Cliente recebe em `ProtocolGame:onExtendedOpcode` e distribui para callback de módulo registrado.

## Fluxo D — Persistência do player

1. IO de login carrega estado SQL em objeto `Player`.
2. Runtime mantém estado em memória durante sessão.
3. Em save/logout, camadas IO persistem inventário, storages, spells, outfits, etc.
