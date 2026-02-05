# Task Execution Template (Open Tibia)

## 1) ANÁLISE
### Descrição da solução
-

### Decisão técnica (por que C++ ou Lua)
-

### Impacto da entrega
- [ ] Server-side
- [ ] Client-side
- [ ] Ambos

### Compatibilidade
- Como garante não quebrar client/server:
-

---

## 2) SERVER-SIDE
### Arquivos afetados
-

### Alterações C++
-

### Alterações Lua
-

### Segurança/anti-abuso (server)
-

---

## 3) CLIENT-SIDE
### Módulos afetados
-

### UI (OTUI)
-

### Lua / JS
-

### Observações de compatibilidade com servidor
-

---

## 4) PROTOCOLO (se aplicável)
### Tabela de protocolo
| Opcode | Direção | Estrutura do pacote |
|---|---|---|
|  |  |  |

### Tratamento do protocolo
- Server: `ProtocolGame` / extended opcode / handlers
- Client: `protocolgame.cpp` / `parseExtendedOpcode`

### Regras obrigatórias
- [ ] Opcode customizado >= 200
- [ ] Serialização explícita
- [ ] Desserialização explícita
- [ ] Validação de payload no server

### Fluxo envio/recebimento
-

---

## 5) TESTES & VALIDAÇÃO
### Testes manuais
-

### Casos extremos
-

### Possíveis bugs
-

### Comandos executados
```bash
# listar comandos reais utilizados
```

---

## 6) OBSERVAÇÕES
### Melhorias futuras
-

### Otimizações possíveis
-
