# Sistema de Carregamento de Módulos

## 1. Objetivo
Gerenciar descoberta, ordenação e ciclo de vida de módulos OTClient via `.otmod`.

## 2. Escopo
Controla auto-load, dependências, sandbox e hooks de init/terminate dos módulos.
Não controla lógica de gameplay interna de cada módulo.

## 3. Localização no Código

### Server
- Não se aplica (sistema client-side).

### Client
- `otclient/init.lua`
- `otclient/src/framework/core/modulemanager.cpp`
- `otclient/src/framework/core/module.cpp`
- `otclient/modules/*/*.otmod`

## 4. Fluxo de Execução Completo
1. `init.lua` adiciona paths de `data`, `modules`, `mods`.
2. `g_modules.discoverModules()` encontra manifestos `.otmod`.
3. `autoLoadModules` carrega por prioridade.
4. `ensureModuleLoaded` garante módulos críticos.
5. Cada módulo roda `@onLoad` e registra eventos/opcodes/UI.

## 5. Comunicação
- Opcodes utilizados: indiretos (cada módulo pode registrar handlers).
- Eventos utilizados: hooks de ciclo de aplicação (`onRun`, `onGameStart`, etc.).
- Estrutura de payload: não aplicável ao carregador em si.

## 6. Estruturas de Dados
- Classes C++: `ModuleManager`, `Module`.
- Tabelas Lua: metadados em `.otmod`.
- Tabelas SQL envolvidas: nenhuma.

## 7. Dependências Cruzadas
- Todos os módulos client.
- Recursos de UI e scripts Lua.

## 8. Pontos de Extensão Reais
- Novo módulo com prioridade/deps corretas.
- Uso de `load-later` para evitar ciclos de dependência.

## 9. Riscos Técnicos
- Ordem de carga incorreta quebra módulos dependentes.
- Falha em `terminate()` deixa handlers órfãos.

## 10. Status
✔ Implementado
