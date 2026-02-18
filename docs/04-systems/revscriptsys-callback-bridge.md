# Sistema de Bridge RevScriptSys

## 1. Objetivo
Fornecer API declarativa Lua para registrar callbacks de engine sem editar XML extensivamente.

## 2. Escopo
Controla mapeamento de metatables (`__newindex`) para classes de eventos/script.
Não controla execução de regras específicas de gameplay.

## 3. Localização no Código

### Server
- `crystalserver/data/libs/functions/revscriptsys.lua`
- `crystalserver/src/lua/functions/events/*`
- `crystalserver/src/lua/creature/*`

### Client
- Não se aplica (sistema server-side).

## 4. Fluxo de Execução Completo
1. Script cria objeto de evento (`CreatureEvent`, `MoveEvent`, etc.).
2. Script define função por atribuição (`obj.onLogin = function...`).
3. Metatable intercepta chave e chama registrador correto (`self:type(...)`, `self:onLogin(...)`).
4. Engine C++ executa callback em runtime quando o evento ocorre.

## 5. Comunicação
- Opcodes utilizados: não aplicável diretamente.
- Eventos utilizados: login/logout/think/death/extendedopcode, etc.
- Estrutura de payload: parâmetros do callback definidos pela engine.

## 6. Estruturas de Dados
- Classes C++: wrappers de eventos Lua (`CreatureEvent`, `MoveEvent`, `GlobalEvent`, `EventCallback`).
- Tabelas Lua: funções locais em `revscriptsys.lua` que mapeiam chaves.
- Tabelas SQL envolvidas: indiretas, via lógica dos scripts consumidores.

## 7. Dependências Cruzadas
- Todos os sistemas de scripts do datapack.
- Event callbacks definidos em `data/events/events.xml` e scripts dinâmicos.

## 8. Pontos de Extensão Reais
- Inclusão de novos nomes de callback na tabela/metatable de bridge.
- Criação de novos scripts sem alterar parser XML legado.

## 9. Riscos Técnicos
- Typos em nomes de callback podem falhar em runtime.
- Uso excessivo de lógica pesada em callbacks síncronos impacta tick.

## 10. Status
✔ Implementado
