# Linked Tasks: como começar a usar no jogo (OTClient + CrystalServer)

Este guia é um passo a passo **prático** para subir o sistema de Linked Tasks e também explica o erro de log ao usar `!task`.

## 1) Pré-requisitos mínimos

- OTClient com módulo `tasksystem` habilitado:
  - `otclient/modules/tasksystem/tasksystem.lua`
  - `otclient/modules/tasksystem/tasksystem.otui`
  - `otclient/modules/tasksystem/tasksystem.otmod`
- Servidor com suporte a ExtendedOpcode.
- Banco de dados com tabela de tasks de jogador (ex.: `player_tasks` ou tabela equivalente definida pelo seu backend).

> Importante: neste repositório, o **módulo do client existe**, mas você precisa garantir o backend server-side das Linked Tasks (opcodes + persistência + talkaction).

---

## 2) Fluxo de integração obrigatório

Para funcionar dentro do jogo, você precisa das 4 partes abaixo:

1. **Configuração das tasks** (catálogo de tasks, objetivos, recompensas).
2. **Persistência** (tabela por jogador, progresso e status).
3. **Protocolo** (opcodes 220/221/222, como descrito em `docs/ai/PROTOCOLS.md`).
4. **Comando/TalkAction** (`!task`) apenas para controle do jogador, sem bootstrap pesado.

Sem essas 4 partes, a janela no client abre, mas não terá estado consistente para exibir.

---

## 2.1) Botão no menu do jogo

Sim: o módulo do OTClient cria botão no top menu com texto **Linked Tasks** e ícone de help (`/images/topbuttons/help`).
Ao clicar, a janela de tasks abre e solicita sync ao servidor.

> Referência: `otclient/modules/tasksystem/tasksystem.lua` (`addLeftGameButton` no `init()`).

---

## 3) Como o jogador usa no jogo

Fluxo recomendado para o player:

1. Loga no jogo.
2. Server envia full sync no opcode `220`.
3. Player usa `!task list` para ver catálogo (opcional).
4. Player usa `!task start <id>` para iniciar.
5. Progresso é atualizado por kill/collect e enviado via opcode `221`.
6. Player usa `!task check` (ou botão/UI) para validar tarefas de coleta.
7. Ao concluir, server entrega recompensa e envia novo sync (`220`).

---

## 4) Por que aparece este erro no log?

Erro relatado:

```text
[ProtocolGame::sendTextMessage] - Message type is wrong, missing or invalid ...
```

Esse erro ocorre quando algum script chama `player:sendTextMessage(...)` com um MessageType inválido/nulo (na prática o core recebe `MESSAGE_NONE`).

### Causa mais comum no Linked Tasks

Uso de constante **não registrada no Lua** (por exemplo `MESSAGE_INFO_DESCR`, que não está na lista de enums exportados).

### Tipos seguros para usar

- `MESSAGE_EVENT_ADVANCE` (sucesso/progresso)
- `MESSAGE_FAILURE` (erro)
- `MESSAGE_STATUS` (informativo neutro)

---

## 5) Checklist de correção do `!task`

1. Abra seu script do comando `!task`.
2. Substitua qualquer uso de tipo inválido por `MESSAGE_STATUS`, `MESSAGE_EVENT_ADVANCE` ou `MESSAGE_FAILURE`.
3. Garanta que o comando **não** dispara bootstrap completo/opcode sem validação.
4. Garanta que o comando só faz:
   - parse do parâmetro,
   - validação,
   - chamada de função de serviço já segura,
   - feedback único ao jogador.

Exemplo seguro:

```lua
if not param or param == '' then
  player:sendTextMessage(MESSAGE_STATUS, 'Uso: !task list | !task start <id> | !task check')
  return false
end
```

---

## 6) Validação rápida após ajuste

- Teste 1: `!task` sem parâmetro -> deve responder uso, sem erro no log.
- Teste 2: `!task start 1` -> deve iniciar ou retornar erro funcional (não erro de protocolo).
- Teste 3: matar monstro objetivo -> deve atualizar progresso.
- Teste 4: relogar -> progresso persistido deve voltar no sync inicial.

Se qualquer teste voltar com erro de MessageType, revise imediatamente todos `sendTextMessage` do fluxo de tasks.
