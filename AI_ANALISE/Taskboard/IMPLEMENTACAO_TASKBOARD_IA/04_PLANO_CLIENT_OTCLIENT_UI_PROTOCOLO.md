# Plano de implementação — Client (otclient): UI, módulo e protocolo

## 1) Arquitetura recomendada
Criar módulo novo: `otclient/modules/game_taskboard/`.

### Estrutura sugerida
- `taskboard.otmod`
- `taskboard.lua`
- `taskboard.otui`
- `styles/style.otui`
- `images/*` (ícones de moedas, badges, fundo, tabs)

## 2) Padrões recorrentes a reaproveitar

### De `game_prey`
- Ciclo de vida de janela (`init/terminate/show/toggle`).
- Conexões com sinais `g_game` e callbacks Lua.
- Estrutura por slots com transições de estado.
- Tooltips dinâmicas e feedback por descrição contextual.

### De módulos com UI moderna do cliente
- Header com moedas/ícones em layout horizontal.
- Tabs com troca de conteúdo por painel.
- Cards com botão de ação e estado habilitado/desabilitado.

## 3) Contrato de parse (obrigatório)

### 3.1 `parseTaskHuntingBasicData`
- Não descartar dados.
- Converter payload para tabela Lua estruturada:
  - `creatureDifficulties[]`
  - `rewardOptions[]` (difficulty, stars, kills/rewards 1 e 2)
- Disparar callback: `g_game.onTaskBoardBasicData(data)`.

### 3.2 `parseTaskHuntingData`
- Materializar payload por estado e slot.
- Disparar callback: `g_game.onTaskBoardSlotData(slotId, stateData)`.

### 3.3 Resource balance
- Reusar callback de resource balance para atualizar moedas no header:
  - money, bank, prey cards, hunting task points.

## 4) Contrato de send (obrigatório)
- Adicionar enum em `protocolcodes.h`: `ClientTaskHuntingAction = 186` (0xBA).
- Implementar em `protocolgamesend.cpp`:
  - `sendTaskHuntingAction(slot, action, upgrade, raceId)`.
- Expor em `game.cpp/game.h` API de alto nível para Lua.

## 5) Modelo de estado Lua (proposto)
```lua
TaskBoardModel = {
  basic = { creatureDifficulties = {}, rewardOptions = {} },
  slots = {
    [0] = { state='locked|inactive|selection|list|active|completed', data={} },
    [1] = { ... },
    [2] = { ... }
  },
  currencies = { money=0, bank=0, preyCards=0, huntingPoints=0 },
  selectedTab = 'bounty'
}
```

## 6) Mapeamento de UX (aba Bounty fase 1)
- Card por slot com:
  - criatura/sprite
  - progresso kills
  - raridade/recompensa prevista
  - botões contextuais (`Select`, `Reroll`, `Claim`, `Cancel`, `Upgrade`)
- Estado visual derivado **somente** de payload recebido.

## 7) Integração de entrada
- Adicionar opção de abrir Task Board no menu onde já existem entradas para Prey.
- Se necessário, hotkey dedicada configurável.

## 8) Internacionalização
- Adicionar chaves mínimas em locales (pt/es/en/de/pl) para labels essenciais do módulo.

## 9) Critérios de pronto (cliente)
1. Nenhum pacote 186/187 é descartado sem uso.
2. Toda ação de botão gera pacote válido 0xBA.
3. Janela recupera estado completo ao reconectar/reabrir.
4. Não há erro Lua ao alternar tabs/slots rapidamente.
