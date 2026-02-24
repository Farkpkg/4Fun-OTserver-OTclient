# Task Board Independente — Pacote Mestre para Implantação por IA

## Diretriz central (obrigatória)
A Task Board deve ser um **sistema isolado**, com domínio, estados, contratos de rede e persistência próprios.

- **Não reutilizar domínio Prey** (`IOPrey`, estados/enums/ações de prey).
- **Pode reutilizar apenas padrões técnicos** (arquitetura client/server, convenções OTUI/Lua, padrões de widgets e organização de módulo).

## Objetivo
Entregar uma trilha completa para implementar:
1. Aba Bounty Tasks
2. Aba Weekly Tasks
3. Aba Hunting Task Shop
4. Preferred List
5. Moedas e progressões do sistema

Sem acoplamento semântico com Prey.

## Escopo
- Inclui: modelagem, protocolo, server, client, persistência, testes, rollout.
- Não inclui: implementação de código neste pacote (somente blueprint completo).

## Estrutura
- `01_FEATURE_PROPOSAL_TASKBOARD.md`
- `02_GAP_ANALYSIS_CROSSDATA.md`
- `03_PLANO_SERVER_CRYSTALSERVER.md`
- `04_PLANO_CLIENT_OTCLIENT_UI_PROTOCOLO.md`
- `05_CONTRATO_PROTOCOLO_E_ESTADOS.md`
- `06_CHECKLIST_GATE_TESTES_ROLLOUT.md`

## Ordem recomendada de execução
1. Definir contrato e estados isolados (`05`).
2. Implementar núcleo server e persistência própria (`03`).
3. Implementar módulo cliente dedicado (`04`).
4. Validar com gate + testes + rollout (`06`).
