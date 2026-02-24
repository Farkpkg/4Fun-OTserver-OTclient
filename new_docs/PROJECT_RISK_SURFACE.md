# PROJECT_RISK_SURFACE

## Método
Risco classificado por probabilidade x impacto em produção:
- **Alto**: alta chance de falha sistêmica ou perda de consistência.
- **Médio**: falhas relevantes, porém contidas por domínio.
- **Baixo**: falhas localizadas com recuperação simples.

---

## 1) Pontos críticos de performance

| Área | Risco | Justificativa |
|---|---|---|
| Loop de gameplay + scheduler server | Alto | Concentra eventos concorrentes e carga de entidades online. |
| Parsing/serialização de protocolo em alta taxa | Alto | Qualquer ineficiência multiplica por número de conexões. |
| Operações de IO/DB em momentos de pico | Médio-Alto | Contenção de escrita aumenta latência de ações sensíveis. |
| Render/UI client modular | Médio | Degrada UX, mas sem derrubar autoridade do jogo. |

## 2) Pontos críticos de sincronização

| Área | Risco | Justificativa |
|---|---|---|
| Handshake/login (RSA/XTEA/checksum) | Alto | Etapa obrigatória para toda sessão; erro impede entrada. |
| Consistência opcode client/server | Alto | Divergência produz desserialização inválida e desconexão. |
| Feature-gates por versão | Alto | Erro afeta compatibilidade cruzada entre versões. |
| Sinais Lua/UI no cliente | Médio | Pode causar estado visual incorreto sem corromper estado server. |

## 3) Pontos críticos de persistência

| Área | Risco | Justificativa |
|---|---|---|
| `schema.sql` + migrations | Alto | Base de compatibilidade histórica de dados. |
| `iologindata` (load/save player) | Alto | Erro afeta continuidade de progresso do jogador. |
| `databasetasks` assíncrono | Médio-Alto | Race/ordenação incorreta pode causar inconsistência temporal. |
| Dados auxiliares não centrais | Médio/Baixo | Impacto funcional mais localizado. |

## 4) Pontos críticos de rede

| Área | Risco | Justificativa |
|---|---|---|
| `protocolgame` server/client | Alto | Superfície principal de comunicação em tempo real. |
| `protocollogin` | Alto | Porta de entrada; falha bloqueia autenticação. |
| `protocolstatus` | Médio | Impacta observabilidade/status, não necessariamente gameplay em sessão. |
| Extended opcodes | Médio-Alto | Alto uso por features custom; fácil introduzir assimetria. |

## 5) Pontos com maior probabilidade de bug
1. Condicionais por versão/client feature.
2. Campos de pacote adicionados no meio de payload legado.
3. Ajustes em save/load sem cobertura de migração.
4. Scripts Lua dependentes de binding alterado.
5. Mudanças simultâneas em scheduler + IO assíncrono.

---

## Mapa consolidado de risco
- **Alto**: protocolo, bootstrap server, persistência de player, versionamento de handshake.
- **Médio**: bindings Lua, módulos client, status/telemetria auxiliar.
- **Baixo**: assets e ajustes de apresentação sem alteração de contrato.

## Estratégia de mitigação mínima por nível
- **Alto**: impacto em cadeia obrigatório + verificação cruzada + evidência de teste.
- **Médio**: revisão de integração e smoke test direcionado.
- **Baixo**: validação local e documentação de decisão.
