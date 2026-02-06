# Mapa do repositório

## Pastas principais (nível raiz)
- `ai/` — materiais internos de contexto e execução.
- `codex-client-readmes/` — documentação organizada por áreas do OTClient.
- `crystalserver/` — servidor Open Tibia (CrystalServer).
- `docs/` — documentos gerais do repositório.
- `otclient/` — OTClient customizado.

## Separação por domínio
### Servidor
- `crystalserver/src/` — código C++ do servidor (núcleo, rede, banco, entidades, mapa, etc.).
- `crystalserver/data/` — scripts Lua, eventos, itens, NPCs, spells e configuração em XML.
- `crystalserver/data-crystal/` e `crystalserver/data-global/` — variações de dados/configuração.
- `crystalserver/config.lua.dist` — configuração base do servidor.
- `crystalserver/tests/` — testes do servidor.

### Cliente
- `otclient/src/` — código C++ do cliente (framework + client).
- `otclient/modules/` — módulos de UI e funcionalidades do jogo.
- `otclient/data/` — assets (imagens, fontes, estilos, sons, coisas/“things”).
- `otclient/mods/` — extensões/modificações do cliente.
- `otclient/tools/` e `otclient/tests/` — utilitários e testes.

### Compartilhado / apoio
- `docs/` — documentos gerais (regras, enums, playbooks).
- `ai/` — guias e contexto de execução.
- `codex-client-readmes/` — documentação baseada no OTClient para referência.
