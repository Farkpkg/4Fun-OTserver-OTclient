# EXECUTION PLAN — SISTEMA_TROCA_OUTFIT_AUTOMATICA

## 1. Objetivo
Implementar troca automática de outfit a cada 1 segundo via talkaction, com ativação/desativação por comando e variação aleatória de visual.

## 2. Componentes Confirmados no Projeto

### Server
- `crystalserver/data/scripts/talkactions/player/randomoutfit.lua` (talkaction existente e funcional com loop por `addEvent`).
- `crystalserver/data/scripts/talkactions/gm/looktype.lua` (referência de range válido de lookType em comandos administrativos).

### Client
- Nenhum componente obrigatório para alteração.

## 3. Arquitetura Validada
A implementação será exclusivamente no talkaction existente `!randomoutfit`, reaproveitando:
- controle por tabela `activePlayers`;
- agenda recursiva com `addEvent`;
- aplicação de visual por `player:setOutfit`.

Será ajustado o intervalo para `1000` ms e a função de randomização passará a montar outfit completo (lookType + cores + addons).

## 4. Fluxo de Execução Final
`!randomoutfit on`
   ↓
validação do parâmetro (`on/off`)
   ↓
marca jogador como ativo em `activePlayers`
   ↓
gera e aplica outfit aleatório
   ↓
agenda próximo ciclo em 1000 ms
   ↓
`!randomoutfit off` remove marca ativa e encerra recursão no próximo tick.

## 5. Modificações Necessárias

### Server
- `crystalserver/data/scripts/talkactions/player/randomoutfit.lua`
  - trocar `changeInterval` para 1000;
  - adicionar lista configurável de lookTypes válidos;
  - substituir randomização de somente cores por randomização de outfit completo;
  - manter comando e mensagens existentes.

### Client
- Sem alterações.

## 6. Criações Necessárias (Se houver)
Não há criação obrigatória de novos arquivos de runtime.

## 7. Ordem de Implementação
1. Editar `config` e funções de randomização em `randomoutfit.lua`.
2. Ajustar loop de atualização para usar nova rotina.
3. Validar sintaxe Lua e revisão de consistência do comando.

## 8. Riscos Técnicos
- LookType inválido pode gerar comportamento visual inesperado (mitigado pela lista configurável explícita).
- Efeito visual contínuo pode ser excessivo (já mitigável por `showEffect = false`).

## 9. Estado de Confiança
**ALTO** — Baseado em talkaction já existente em produção no projeto; alteração é incremental e usa APIs já presentes (`TalkAction`, `addEvent`, `Player`, `setOutfit`).
