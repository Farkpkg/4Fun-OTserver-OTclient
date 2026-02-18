# Crystal Project
Custom Open Tibia Distribution  
Client (OTClient) + Server (CrystalServer)

---

# 📌 Overview

Crystal Project é uma distribuição customizada de Open Tibia composta por:

- 🖥 OTClient (Client)
- ⚙ CrystalServer (Server)

A arquitetura é baseada em separação clara de responsabilidades:

- O **Server** é a autoridade absoluta do estado do jogo.
- O **Client** é responsável apenas por renderização e interação.
- A comunicação é feita via protocolo Tibia + ExtendedOpcodes customizados.

Este projeto foi estruturado com foco em:

- Escalabilidade
- Modularidade
- Manutenção de longo prazo
- Expansão contínua de sistemas

---

# 🏗 Arquitetura Geral

Player
↓
OTClient (UI, Modules, Rendering)
↓ (Protocol + ExtendedOpcodes)
CrystalServer (Game Engine, Scripts, Persistence)
↓
Database


A documentação completa da arquitetura pode ser encontrada em:

/docs/01-architecture/


---

# 📂 Estrutura do Repositório

/client → OTClient
/server → CrystalServer
/docs → Documentação Enterprise


---

# 📚 Documentação

A pasta `/docs` foi reconstruída seguindo padrão enterprise.

## Estrutura da Documentação

docs/
├── 00-overview/ → Visão geral e arquitetura global
├── 01-architecture/ → Arquitetura detalhada
├── 02-client/ → Sistemas do OTClient
├── 03-server/ → Núcleo e engine do servidor
├── 04-systems/ → Sistemas funcionais reais
├── 05-protocol/ → Protocolo e opcodes
├── 06-database/ → Banco de dados e persistência
├── 07-dev-guides/ → Guias para desenvolvedores
└── 99-archive/ → Histórico e sistemas descontinuados


Toda documentação é:

- Rastreável ao código
- Livre de conteúdo fictício
- Estruturada para manutenção de longo prazo

---

# 🔌 Comunicação Client ⇄ Server

O projeto utiliza:

- Protocolo Tibia padrão
- ExtendedOpcodes customizados
- Feature flags (quando aplicável)

Fluxo geral:

1. Client envia requisição
2. Server processa
3. Server envia resposta
4. Client renderiza estado

Detalhes técnicos:

/docs/05-protocol/


---

# 🧠 Sistemas

Cada sistema funcional implementado possui documentação dedicada em:

/docs/04-systems/


Cada documento contém:

- Objetivo
- Escopo
- Fluxo completo
- Comunicação
- Estruturas de dados
- Dependências cruzadas
- Pontos de extensão
- Riscos técnicos

---

# 🛠 Desenvolvimento

Guias técnicos estão disponíveis em:

/docs/07-dev-guides/


Inclui:

- Como criar um novo sistema
- Como criar um opcode
- Como criar módulo UI
- Padrões de código

---

# 🗄 Banco de Dados

Organização por domínio:

- Conta
- Player
- Inventário
- Progressão
- Economia
- Social
- Mundo

Detalhes:

/docs/06-database/


---

# ⚙ Requisitos

## Server
- C++ Compiler compatível
- CMake
- Banco de dados compatível (MySQL/MariaDB)

## Client
- Compilação OTClient padrão
- Dependências gráficas conforme upstream

---

# 🚀 Objetivo do Projeto

Crystal Project não é apenas um fork.

Ele foi estruturado para:

- Permitir expansão infinita de sistemas
- Manter coerência arquitetural
- Evitar acoplamento desnecessário
- Garantir separação clara Client ⇄ Server
- Servir como base sólida para desenvolvimento contínuo

---

# 📌 Padrões e Regras

- O Server é sempre autoridade.
- O Client nunca altera estado definitivo.
- Toda feature nova deve ser documentada.
- Nenhum sistema deve existir sem documentação correspondente.
- Nenhum opcode deve existir sem rastreabilidade cruzada.

---

# 📎 Manutenção

Sempre que:

- Criar sistema novo
- Criar opcode novo
- Alterar persistência
- Modificar fluxo arquitetural

É obrigatório atualizar `/docs`.

---

# 📜 Licenciamento

Baseado em Open Tibia.
Respeitar as licenças dos projetos originais utilizados.

---

# 👨‍💻 Contribuição

Antes de contribuir:

1. Leia `/docs/00-overview/`
2. Entenda a arquitetura
3. Siga os guias de desenvolvimento
4. Mantenha consistência estrutural

---

# 🧩 Status

✔ Estrutura Enterprise  
✔ Documentação Rastreável  
✔ Arquitetura Modular  
✔ Separação Client ⇄ Server  

---

Crystal Project  
Arquitetura limpa. Escalável. Sustentável.