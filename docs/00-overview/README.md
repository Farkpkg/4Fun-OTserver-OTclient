# CrystalServer + OTClient Documentation

Esta documentação foi reconstruída do zero a partir do código-fonte atual de:

- `crystalserver/` (server C++ + Lua)
- `otclient/` (client C++ + Lua/OTUI)

## Escopo

- Arquitetura ponta-a-ponta (bootstrap, runtime e protocolos)
- Coerência Client ⇄ Server com rastreabilidade de opcodes e eventos
- Persistência SQL real baseada em `crystalserver/schema.sql`
- Guias de extensão focados em manutenção de longo prazo

## Princípios adotados

1. **Zero conteúdo fictício**: somente funcionalidades observáveis no código.
2. **Rastreabilidade**: cada seção aponta para caminhos reais de implementação.
3. **Separação de responsabilidades**: documentos divididos por domínio técnico.
4. **Escalabilidade documental**: estrutura preparada para crescimento incremental.

## Mapa dos diretórios

- `00-overview/`: visão executiva e macroarquitetura.
- `01-architecture/`: arquitetura técnica client, server, protocolo e fluxos.
- `02-client/`: sistema de módulos, UI, opcodes e automação.
- `03-server/`: núcleo do servidor, eventos, criaturas, itens, players e banco.
- `04-systems/`: documentação por sistema real identificado no inventário.
- `05-protocol/`: opcodes server, extended opcodes e estrutura de pacotes.
- `06-database/`: visão de schema, referência de tabelas e fluxos de persistência.
- `07-dev-guides/`: padrões de implementação para novos componentes.
- `99-archive/`: reservado para snapshots legados e descontinuações.
