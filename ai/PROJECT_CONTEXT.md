# Project Context – Open Tibia Server

## Visão Geral
Este projeto é um Open Tibia Server customizado, com:
- Servidor baseado em Canary
- Client baseado em OTClient Redemption (otcv8 atual)
- Forte uso de protocolos customizados
- UI e sistemas desacoplados entre server e client

---

## Servidor (Canary)

### Base
- Canary (fork padrão, sem TFS legado)
- Código moderno, orientado a performance

### Linguagens
- C++: sistemas base, persistência, segurança
- Lua: gameplay, eventos, spells, quests

### Estrutura
- src/: core do servidor
- data/scripts/: sistemas custom
- data/spells/: magias
- data/movements/: tiles e ações
- data/creaturescripts/: eventos de criatura

---

## Client (OTClient Redemption)

### Base
- otcv8 (versão atual)
- Fork Redemption

### Linguagens
- C++: protocolo e base
- Lua: lógica client-side
- OTUI: interface
- JS: interações avançadas (quando necessário)

### Estrutura
- modules/: sistemas e UI
- styles/: estilos globais
- layouts/: layouts reutilizáveis

---

## Banco de Dados
- MySQL
- Tabelas padrão do Canary
- Tabelas custom devem ser documentadas

---

## Filosofia
- Server é autoridade absoluta
- Client apenas exibe e solicita ações
- Nada crítico depende apenas do client
