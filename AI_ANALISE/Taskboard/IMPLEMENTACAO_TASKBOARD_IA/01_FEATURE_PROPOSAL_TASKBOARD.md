# FEATURE PROPOSAL — Task Board Isolada (Bounty + Weekly + Shop)

## 1) Identificação
- **Título:** Task Board isolada e independente de Prey
- **Tipo:** feature + arquitetura + protocolo + persistência
- **Escopo:** server/client/network/database

## 2) Problema e objetivo
- **Problema:** proposta anterior acoplava Task Board ao domínio de Prey.
- **Objetivo:** implantar Task Board como sistema independente, com contratos e dados próprios.
- **Resultado esperado:** funcionalidade completa sem compartilhar estado/regra com Prey.

## 3) Superfícies afetadas
- **Server:** novo domínio (ex.: `iotaskboard.*`, `taskboard_service.*`) + integrações em `player`, `game`, `protocolgame`.
- **Client core:** `protocolcodes.h`, `protocolgameparse.cpp`, `protocolgamesend.cpp`, `game.*`.
- **Client UI/Lua:** novo módulo `otclient/modules/game_taskboard/*`.
- **Database:** migration para progresso semanal, preferred list, saldos/moedas de task board, histórico e cooldowns.

## 4) Invariantes impactados
- INV-01: server autoritativo preservado.
- INV-02: simetria de contrato (novos opcodes próprios).
- INV-04: persistência com migration obrigatória.
- INV-06: fronteira C++↔Lua oficial.
- INV-08: feature-gate explícito.

## 5) Riscos e mitigação
- **Risco:** drift por reaproveitar Prey por conveniência.
  - **Mitigação:** regra de bloqueio no review: qualquer dependência semântica em Prey = rejeitar.
- **Risco:** divergência client/server de payload.
  - **Mitigação:** tabela de contrato binário + testes de parse/serialize.
- **Risco:** inconsistência de reset semanal.
  - **Mitigação:** cron server-side + timestamp persistido + reprocessamento idempotente.

## 6) Acoplamento e coesão
- **Permitido:** reaproveitar padrões de UI, helpers genéricos, estilo de organização de módulos.
- **Proibido:** enums de prey, actions de prey, slots de prey, armazenamento de prey, moedas de prey.

## 7) Validação client/server
- Introduzir opcodes exclusivos de Task Board.
- Cliente antigo: ignora feature via gate.
- Servidor: só envia dados Task Board quando gate/versão suportarem.

## 8) ADR
Obrigatória, pois há novo domínio funcional e persistente (não é refactor local).

## 9) Critério de aprovação
- Sistema Task Board funcional sem dependência de Prey.
- Todos os artefatos de governança preenchidos (proposal/checklist/ADR/checks).

## 10) Conformidade com padrão existente (explícito)
- Obrigatório aderir às normas já existentes de codificação/arquitetura/UI do projeto.
- Referências mandatórias: `new_docs/UI_CANONICAL_RULES.md`, `new_docs/SYSTEM_INVARIANTS.md`, `new_docs/CHANGE_GATE_CHECKLIST.md`.
- Qualquer exceção de padrão deve ser registrada e justificada formalmente (ADR/waiver).
