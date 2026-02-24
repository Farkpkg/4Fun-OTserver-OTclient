# FEATURE PROPOSAL — Task Board unificado (Bounty + Weekly + Shop)

## 1) Identificação
- **Título da proposta:** Task Board unificado com interface dedicada no otclient
- **Autor:** IA de análise técnica
- **Data:** 2026-02-24
- **Tipo:** feature + arquitetura de integração
- **Escopo:** cross (server/client/network/config)

## 2) Problema e objetivo
- **Problema atual:** o server já suporta Task Hunting (núcleo de “Bounty-like”), mas o cliente não materializa o sistema em UI funcional equivalente ao Task Board descrito na análise.
- **Objetivo técnico:** ativar experiência completa de Task Board no cliente reaproveitando o backend existente e estendendo somente onde houver lacuna real.
- **Resultado mensurável:**
  - usuário consegue abrir janela Task Board;
  - visualizar slots/estados/recompensas;
  - executar ações (reroll, seleção, claim, cancel, upgrades);
  - protocolo simétrico sem perda de compatibilidade.

## 3) Superfícies afetadas
- **Server:** `crystalserver/src/io/ioprey.*`, `crystalserver/src/server/network/protocol/protocolgame.*`, `crystalserver/src/creatures/players/player.*`.
- **Client core:** `otclient/src/client/protocolcodes.h`, `otclient/src/client/protocolgameparse.cpp`, `otclient/src/client/protocolgamesend.cpp`, `otclient/src/client/game.*`.
- **Client UI/Lua:** novo módulo `otclient/modules/game_taskboard/*` (otmod/lua/otui/imagens/estilos).
- **Fronteiras cruzadas:** network opcode/action, estado runtime do jogador, renderização de UI por callbacks Lua.
- **Dependências indiretas:** bestiary unlocks, recurso `RESOURCE_TASK_HUNTING`, regras de premium/free slot.

## 4) Invariantes impactados (`SYSTEM_INVARIANTS`)
| Invariante | Impactado? | Preservação |
|---|---|---|
| INV-01 servidor autoritativo | Sim | Toda decisão de estado/recompensa continua no `crystalserver`; cliente envia intenção. |
| INV-02 simetria de protocolo | Sim (crítico) | Implementar parse + send + callbacks Lua dos pacotes Task Hunting em ambos os lados. |
| INV-03 bootstrap determinístico | Não | Sem alteração no fluxo de startup do server. |
| INV-04 persistência com trilha | Baixo | Preferir fase 1 sem schema novo; fase 2 com migration formal se Weekly/Shop persistirem em DB. |
| INV-05 compat criptográfica | Não | Sem mudança no handshake/base crypto. |
| INV-06 fronteira C++↔Lua | Sim | Expor eventos via `g_game`/Lua sem duplicar regra de domínio no cliente. |
| INV-07 atomicidade de evento | Sim | Reaproveitar ações server existentes para progressão e claim. |
| INV-08 feature gate explícito | Sim | Adicionar gate de feature Task Board no cliente antes de ativar UI/ações novas. |

## 5) Avaliação de risco
- **Nível inicial:** médio-alto (UI + protocolo + economia).
- **Falhas prováveis:**
  1. desalinhamento de payload entre parser client e server;
  2. UI mostrar estado incorreto por falta de cache por slot;
  3. ações inválidas liberadas no cliente.
- **Mitigações:**
  - model de estado central do módulo;
  - testes binários de pacote por estado;
  - validação server-side já existente permanece mandatória.
- **Rollback:** desabilitar módulo `game_taskboard` e manter apenas fluxos antigos (prey/task interno).

## 6) Acoplamento e coesão
- **Acoplamento atual:** Task Hunting acoplado ao domínio Prey no server.
- **Após mudança:** cliente terá módulo dedicado, reduzindo acoplamento acidental com `game_prey`.
- **Estratégia:** criar adaptador Lua para Task Board e evitar duplicar lógica em múltiplos módulos.

## 7) Validação client/server
- **Contrato alterado?** Sim (lado cliente precisa completar contrato já existente no server).
- **Server parse/send:** já presente para Task Hunting; evoluir apenas se novos blocos Weekly/Shop forem adicionados.
- **Client parse/send:** obrigatório implementar callbacks e `sendTaskHuntingAction`.
- **Versionamento/gate:** `GameTaskBoard` feature flag + fallback silencioso quando ausente.
- **Compatibilidade retroativa:** não enviar ações quando gate desabilitado.

## 8) Plano de testes
- Unitário/light em parse de estados de slot.
- Integração manual: seleção, progresso, claim, cancel, reroll, lock/premium.
- Check estrutural: simetria de opcode + invariantes + checklist gate.

## 9) ADR
- **ADR necessária?** Sim, se incluir novas entidades Weekly/Shop com persistência.
- **Sem ADR:** permitido apenas na fase 1 (UI + integração do Task Hunting já existente).

## 10) Aprovação para implementação
- **Status sugerido:** aprovado com ressalvas.
- **Condições obrigatórias:**
  1. completar simetria de protocolo no cliente;
  2. manter server autoritativo;
  3. entregar checklist de gate e evidências de teste.
