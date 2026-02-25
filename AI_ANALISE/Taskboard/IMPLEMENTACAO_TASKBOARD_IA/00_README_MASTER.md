# Task Board Independente — Pacote Mestre para Implantação por IA

## Diretriz central (obrigatória)
A Task Board deve ser um **sistema isolado**, com domínio, estados, contratos de rede e persistência próprios.

- **Não reutilizar domínio Prey** (`IOPrey`, estados/enums/ações de prey).
- **Pode reutilizar apenas padrões técnicos** (arquitetura client/server, convenções OTUI/Lua, padrões de widgets e organização de módulo).

## Regras de conformidade com o projeto existente (obrigatório)
Toda implementação deve seguir explicitamente os padrões já existentes do repositório:

1. **Governança técnica (`new_docs`)**
   - `new_docs/SYSTEM_INVARIANTS.md`
   - `new_docs/CHANGE_IMPACT_PROTOCOL.md`
   - `new_docs/CHANGE_GATE_CHECKLIST.md`
   - `new_docs/UI_CANONICAL_RULES.md`
   - `new_docs/PROJECT_FULL_MAP.md`

2. **Padrão de codificação e organização do código existente**
   - Server: manter convenções e organização de `crystalserver/src/*` (nomes, separação header/impl, validação server-side).
   - Client C++: manter padrão de `otclient/src/client/*` (parse/send, game API, feature gates).
   - Client Lua/OTUI: manter padrão de `otclient/modules/*` e `otclient/data/styles/*` (naming, layout por anchors, widgets reutilizáveis, estados visuais).

3. **Regra de ouro**
   - “Seguir padrão existente” = copiar estrutura e convenções do projeto.
   - “Não acoplar domínio” = não compartilhar estado/regra de negócio com Prey.

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
- `07_REFERENCIAS_UI_WIDGETS_E_PADROES.md`

## Ordem recomendada de execução
1. Ler referências e padrões de UI/widgets (`07`).
2. Definir contrato e estados isolados (`05`).
3. Implementar núcleo server e persistência própria (`03`).
4. Implementar módulo cliente dedicado (`04`).
5. Validar com gate + testes + rollout (`06`).
