<!-- tags: - ui - client - lua priority: high -->

## LLM Summary
- **What**: Arquitetura de UI/OTUI do cliente.
- **Why**: Define layout e interação do usuário.
- **Where**: otclient/data/styles, otclient/modules, otclient/src/framework/ui
- **How**: Layouts e módulos carregam widgets e estilos.
- **Extends**: Criar módulos UI e estilos OTUI/OTML.
- **Risks**: Mudanças em widgets base afetam toda a interface.

[Wiki](../README.md) > UI

# UI e OTUI

## Visão geral
A UI do OTClient é construída com OTUI/OTML e módulos Lua que definem layouts, estilos e comportamento da interface.

## Localização no repositório
- `otclient/data/styles/` — estilos e componentes UI.
- `otclient/modules/` — módulos com layouts e lógica de interface.
- `otclient/src/framework/ui/` — framework de UI em C++.

## Estrutura interna (alto nível)
- **Layouts e estilos**: arquivos `.otui` e `.otml` em `otclient/data/styles/` e módulos.
- **Módulos UI**: `otclient/modules/client_*` e `otclient/modules/game_*`.
- **Framework UI**: widgets e renderização base em `otclient/src/framework/ui/`.

## Fluxo de execução (alto nível)
1. O framework UI inicializa no bootstrap do cliente.
2. Módulos carregam seus layouts e estilos.
3. Eventos do protocolo e do input atualizam a UI via módulos.

## Integrações
- **Input**: subsistema em `otclient/src/framework/input/`.
- **Protocolo**: atualizações vindas de `otclient/src/client/protocolgameparse.cpp`.
- **Módulos**: UI interage com `gamelib`, `corelib` e módulos `game_*`.
