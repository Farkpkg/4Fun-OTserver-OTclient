📌 PROMPT PADRÃO — EXTRAÇÃO ENTERPRISE DE SISTEMA

Você está com o projeto completo aberto:

CrystalServer (Server)

OTClient (Client)

A pasta /docs já segue padrão enterprise.

🎯 OBJETIVO

Realizar uma extração técnica completa e auditável do sistema:

🔹 [NOME DO SISTEMA AQUI]

E documentá-lo seguindo rigorosamente o padrão enterprise estabelecido no projeto.

🔎 ETAPA 1 — AUDITORIA PROFUNDA (OBRIGATÓRIA)

Antes de escrever qualquer documentação:

Localizar todos os arquivos relacionados ao sistema no:

Client (modules/, ui/, protocol, bindings Lua, etc.)

Server (C++, scripts, events, IO, database)

Identificar:

Onde o sistema é inicializado

Como é acionado

Fluxo completo de execução

Classes C++ envolvidas

Scripts Lua envolvidos

Eventos registrados

Opcodes utilizados

Estruturas internas

Persistência (SQL/KV/blob)

Dependências cruzadas

Confirmar:

O que está implementado

O que está parcial

O que é stub

O que possui TODO

⚠️ Proibido assumir padrão upstream.
⚠️ Proibido documentar funcionalidade inexistente.
⚠️ Proibido escrever texto genérico.

📂 ETAPA 2 — CRIAR DOCUMENTAÇÃO

Criar (ou atualizar):

docs/04-systems/[nome-do-sistema].md


Seguindo EXATAMENTE este template:

# [Nome do Sistema]

## 1. Objetivo
Descrição técnica clara e verificável.

## 2. Escopo
O que controla e o que NÃO controla.

## 3. Localização no Código

### Server
- caminhos completos reais

### Client
- caminhos completos reais

## 4. Fluxo de Execução Completo
Do evento inicial até renderização final.

## 5. Comunicação Client ⇄ Server
- Lista completa de opcodes
- Direção (Client → Server ou Server → Client)
- Estrutura real de payload (binário detalhado)
- Handlers envolvidos

## 6. Estruturas de Dados
- Classes C++
- Estruturas internas
- Tabelas Lua
- Estruturas parseadas
- Tabelas SQL/KV/blob

## 7. Dependências Cruzadas
Lista explícita de sistemas dependentes.

## 8. Pontos de Extensão Reais
Onde pode ser expandido sem quebrar arquitetura.

## 9. Riscos Técnicos
- Sincronização
- Performance
- Volume de dados
- Dependência circular
- Inconsistências potenciais

## 10. Status
✔ Implementado
⚠ Parcial
❌ Stub
(Com justificativa técnica objetiva)

🔄 ETAPA 3 — ATUALIZAÇÕES CRUZADAS (OBRIGATÓRIO)

Se o sistema utilizar:

Opcodes

Atualizar:

docs/05-protocol/opcodes-client.md
docs/05-protocol/opcodes-server.md
docs/05-protocol/extended-opcodes.md

Banco de dados

Atualizar:

docs/06-database/tables-reference.md
docs/06-database/persistence-flow.md

Dependências cruzadas

Atualizar documentação do outro sistema afetado.

🧠 ETAPA 4 — VALIDAÇÃO FINAL

Antes de finalizar:

Confirmar que cada opcode listado realmente existe.

Confirmar que cada caminho listado realmente existe.

Confirmar que cada classe mencionada realmente existe.

Confirmar que cada tabela SQL realmente existe.

Garantir ausência total de placeholders.

Garantir ausência total de texto genérico.

Se algo não puder ser confirmado no código:
→ Marcar como ⚠ Parcial e explicar o motivo.

📊 RESULTADO ESPERADO

A documentação deve permitir que:

Um desenvolvedor novo compreenda o sistema em menos de 1 hora.

Seja possível modificar o sistema com segurança.

Seja possível expandir o sistema.

Seja possível auditar dependências.

Seja possível debugar problemas estruturais.

⚠️ REGRA FINAL

Este é um processo de extração técnica do estado real do código, não de planejamento futuro.

Somente documentar o que realmente existe.