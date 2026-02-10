# Custom Protocols Documentation

## Regras Gerais
- Opcode >= 200
- Nunca reutilizar opcode
- Toda alteração deve ser documentada aqui

---

## Exemplo de Protocolo

### Opcode 200 – Player Prestige

Direção:
- Server → Client

Estrutura do Pacote:
- uint8 opcode
- uint16 prestigeLevel
- uint64 prestigeExperience

Fluxo:
1. Server calcula prestígio
2. Server envia pacote
3. Client atualiza UI

Implementação:
- Server: protocolgame.cpp (sendExtendedOpcode)
- Client: protocolgame.cpp (parseExtendedOpcode)

---

## Observações
- Mudanças em protocolos exigem:
  - Alteração no server
  - Alteração no client
  - Atualização deste arquivo

## Linked Tasks System

### Opcode 220 – Linked Tasks Full Sync

Direção:
- Server → Client

Estrutura do pacote (string delimitada por linha/tab):
- Linha 1: `ACTIVE	<activeTaskId>`
- Linhas seguintes por task:
  - `TASK	<taskId>	<status>	<progress>	<required>	<name>	<description>	<objectiveType>	<objectiveTarget>	<rewardGold>	<rewardExperience>	<rewardItems>`

Status:
- `0` = não iniciada
- `1` = em progresso
- `2` = concluída

Observação:
- `rewardItems` no formato `itemId:count,itemId:count` ou `none`.

---

### Opcode 221 – Linked Task Incremental Update

Direção:
- Server → Client

Estrutura do pacote:
- `UPDATE	<taskId>	<status>	<progress>	<required>`

Uso:
- Atualiza progresso parcial sem reenviar o snapshot completo.

---

### Opcode 222 – Linked Task Client Request

Direção:
- Client → Server

Estrutura do pacote:
- String simples com ação:
  - `sync` → solicita sincronização completa
  - `check` → força validação de task ativa (especialmente objetivo de coleta)

---

Implementação:
- Server: `crystalserver/data/scripts/lib/linked_tasks.lua`, `crystalserver/data/scripts/creaturescripts/player/linked_tasks.lua`, `crystalserver/data/scripts/talkactions/player/task.lua`
- Client: `otclient/modules/tasksystem/tasksystem.lua`
