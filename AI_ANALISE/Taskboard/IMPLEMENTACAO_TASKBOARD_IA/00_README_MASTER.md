# Task Board (estilo Tibia 2025) — Pacote Mestre para Implantação por IA

## Objetivo
Este diretório consolida um **plano completo, cruzado e executável** para implantar um sistema de Task Board semelhante ao da documentação em `AI_ANALISE/Taskboard`, respeitando:
- arquitetura atual `crystalserver` (server autoritativo),
- arquitetura atual `otclient` (cliente representacional),
- contratos de protocolo existentes,
- padrões recorrentes de UI/UX já utilizados no projeto,
- governança da pasta `new_docs`.

## Escopo
- **Não implementa código neste pacote**; define tudo para implementação segura.
- Cobre: server, client, protocolo, dados/config, riscos, testes, rollout, gate de merge.

## Resultado da análise (resumo executivo)
1. O repositório **já possui base funcional de Task Hunting** no server (`IOPrey`, `TaskHuntingSlot`, envio de pacotes 0xBA/0xBA-parse + 0xBA? dados server->client 0xBA/0xBB), incluindo lógica de estado, progressão e recompensa.
2. O `otclient` já recebe os pacotes `GameServerTaskHuntingBasicData` (186) e `GameServerTaskHuntingData` (187), porém o parse atual está praticamente em modo descarte (consome bytes sem acionar UI).
3. O `otclient` **não expõe** hoje um fluxo completo de envio de ação de Task Hunting equivalente ao prey (gap crítico de simetria de contrato para interação).
4. Melhor estratégia: **evolução incremental sobre Task Hunting existente**, criando módulo visual Task Board no cliente e mantendo server como fonte única de verdade.

## Estrutura deste pacote
- `01_FEATURE_PROPOSAL_TASKBOARD.md`
- `02_GAP_ANALYSIS_CROSSDATA.md`
- `03_PLANO_SERVER_CRYSTALSERVER.md`
- `04_PLANO_CLIENT_OTCLIENT_UI_PROTOCOLO.md`
- `05_CONTRATO_PROTOCOLO_E_ESTADOS.md`
- `06_CHECKLIST_GATE_TESTES_ROLLOUT.md`

## Ordem recomendada para outra IA executar
1. Ler `02_GAP_ANALYSIS_CROSSDATA.md` para entender estado atual e limitações.
2. Aplicar `05_CONTRATO_PROTOCOLO_E_ESTADOS.md` para fechar contrato client/server.
3. Implementar server conforme `03_PLANO_SERVER_CRYSTALSERVER.md` (somente se necessário evoluir além da base existente).
4. Implementar cliente conforme `04_PLANO_CLIENT_OTCLIENT_UI_PROTOCOLO.md`.
5. Validar e liberar seguindo `06_CHECKLIST_GATE_TESTES_ROLLOUT.md`.
