# Plano de implementação — Server (crystalserver)

## 1) Princípio
Manter o `crystalserver` como fonte única de verdade e reutilizar o domínio de Task Hunting já existente, minimizando risco e retrabalho.

## 2) Arquivos-alvo (fase 1)
- `crystalserver/src/io/ioprey.hpp`
- `crystalserver/src/io/ioprey.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.hpp`
- `crystalserver/src/creatures/players/player.cpp`
- `crystalserver/src/creatures/players/player.hpp`

## 3) Alterações recomendadas

### 3.1 Endurecimento de contrato de Task Hunting
- Revisar mensagens de erro e validações de estado em `parseTaskHuntingAction` para retornos consistentes por ação.
- Garantir que `reloadTaskSlot` seja chamado em todos os caminhos de sucesso e nos erros recoverable onde UI precisa refrescar.

### 3.2 Extensão opcional para Task Board oficial (fase 2)
- Adicionar novos pacotes para Weekly/Shop somente quando houver cliente pronto.
- Definir novos enums de estado/ação em namespace isolado (evitar sobrecarregar enums de prey).

### 3.3 Feature-gate
- Nova flag de config (ex.: `TASK_BOARD_ENABLED`) separada de `TASK_HUNTING_ENABLED`.
- Compatibilidade:
  - `TASK_BOARD_ENABLED=false` e `TASK_HUNTING_ENABLED=true`: fluxo atual mantém funcionalidade.
  - ambos true: habilita envio complementar para cliente novo.

## 4) Persistência

### Fase 1
- Sem migration obrigatória (usa estrutura existente de task hunting em memória/salvamento atual do player).

### Fase 2 (Weekly/Shop)
- Criar migration para progresso semanal, janela de reset e saldo/itens de loja.
- Atualizar IO de load/save para novos campos com fallback seguro.

## 5) Regras não negociáveis
1. Nenhuma decisão de recompensa final no cliente.
2. Nenhum bypass de validação por confiar em estado da UI.
3. Toda ação deve respeitar premium/free constraints no server.
4. Protocolo novo só entra com simetria client pronta.

## 6) Critérios de pronto (server)
- Ações inválidas nunca alteram estado.
- Estado de slot é sempre serializável em pacote único consistente.
- Log/metrics mínimos para auditar consumo de reroll/cancel/claim.
