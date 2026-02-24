# GLOBAL_DEPENDENCY_MATRIX

## Premissas
- Classificação mede impacto estrutural de propagação de mudança.
- Dependência direta: chamada/import/uso explícito.
- Dependência indireta: impacto por cadeia (ex.: protocolo -> UI -> scripts).

## Classes de impacto
- **Crítica**: quebra causa indisponibilidade, corrupção de estado ou incompatibilidade de sessão.
- **Moderada**: quebra degrada feature/domínio específico sem derrubar todo sistema.
- **Fraca**: impacto localizado, baixo potencial de cascata.

---

## Sistemas centrais
1. Runtime autoritativo de gameplay (`crystalserver/src/game`, `src/creatures`).
2. Camada de protocolo e conexão (`crystalserver/src/server/network/protocol`, `otclient/src/client/protocol*`).
3. Persistência e IO (`crystalserver/src/database`, `src/io`, migrations/schema).
4. Scheduler/dispatcher/event loop (`crystalserver/src/game/scheduling`, `otclient/src/framework/core`).

## Sistemas satélites
- Módulos UI/Lua do cliente (`otclient/modules`, `.otui`).
- Scripts de conteúdo do servidor (`crystalserver/data/scripts`).
- Métricas, webhook, utilitários e ferramentas auxiliares.

---

## Matriz de dependências (macro)

| Origem | Destino | Tipo | Classe | Impacto estrutural |
|---|---|---|---|---|
| Client `protocolgamesend` | Server `protocolgame` | Direta | Crítica | Mudança de payload quebra login/ações online. |
| Server `protocolgame` | Client `protocolgameparse` | Direta | Crítica | Sem parse simétrico há desserialização inválida. |
| `game/creatures` | `io/iologindata` | Direta | Crítica | Save/load inconsistente afeta continuidade do personagem. |
| `database schema/migrations` | `database + io` | Direta | Crítica | Upgrade sem compatibilidade gera falha de boot ou dados órfãos. |
| `crystalserver.cpp bootstrap` | todos subsistemas server | Direta | Crítica | Ordem incorreta cria estado parcial em inicialização. |
| Server Lua bindings | scripts Lua server | Direta | Moderada | Quebra roteiros/eventos, mas core pode subir. |
| Client Lua bindings | módulos Lua/OTUI | Direta | Moderada | Quebra UX/automação sem necessariamente quebrar rede. |
| Protocol feature-gates | versões de cliente | Indireta | Crítica | Falha de gate gera incompatibilidade cruzada. |
| Dispatcher/scheduler | gameplay + IO tasks | Indireta | Crítica | Regressão de concorrência produz race/latência sistêmica. |
| Assets/UI | render pipeline | Direta | Fraca | Impacto visual localizado. |
| Ferramentas/tests | pipelines de validação | Indireta | Moderada | Reduz capacidade de detectar regressões antes do deploy. |

---

## Pontos de alto acoplamento
1. **Fronteira de protocolo game/login**: interdependência binária cliente-servidor.
2. **Domínio Player ↔ IOLoginData ↔ DB**: acoplamento de modelo persistente com runtime.
3. **Bindings Lua ↔ eventos C++**: alto acoplamento semântico (não só sintático).
4. **Bootstrap global**: acoplamento temporal (ordem de execução).

## Pontos de alto risco
- Alteração de opcode sem espelho no outro lado.
- Mudança em estrutura persistida sem migration.
- Reordenação de inicialização do servidor.
- Inclusão de lógica de domínio no cliente como “atalho”.

---

## Dependências indiretas relevantes (cadeias)
1. `protocolcodes` -> parse/send -> módulos Lua client -> fluxo de UX.
2. `schema/migration` -> loaders IO -> regras de gameplay que assumem campos carregados.
3. `dispatcher` -> eventos de combate/movimento -> frequência de save -> pressão de DB.
4. `feature flags` -> handshake/login -> aceitação de versão -> estabilidade de produção.

---

## Regra de auditoria por classe
- **Crítica**: exige revisão cruzada (server+client+dados quando aplicável), checklist completo e evidência de teste.
- **Moderada**: exige validação de integração e inspeção de regressão indireta.
- **Fraca**: validação local suficiente, mantendo rastreabilidade de decisão.
