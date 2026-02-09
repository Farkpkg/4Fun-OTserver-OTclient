# Architecture Overview

## Princípios
- Separação total entre server e client
- Comunicação apenas via protocolo
- Modularidade acima de tudo

---

## Server Architecture

### Camadas
1. Core (C++)
2. Lua Scripting
3. Database
4. Protocol

### Responsabilidades
- Validação
- Persistência
- Segurança
- Performance

---

## Client Architecture

### Camadas
1. ProtocolGame
2. Lua Logic
3. UI (OTUI)
4. Assets

### Responsabilidades
- Exibição
- Interação
- UX
- Feedback visual

---

## Comunicação
- ProtocolGame
- Extended Opcodes
- Estrutura sempre documentada

---

## Regra de Ouro
Se algo pode ser explorado, ele DEVE ser validado no server.
