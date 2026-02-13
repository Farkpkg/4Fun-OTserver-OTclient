# Relatório de Reorganização de `/docs`

## Escopo executado

- Inventário dos arquivos Markdown principais em `docs/`.
- Reorganização estrutural por domínio (`server`, `client`, `architecture`, `deployment`, `api`).
- Padronização de nomenclatura para `kebab-case.md` nos arquivos movidos.
- Atualização de referências internas quebradas por renome/movimentação.
- Inclusão de índices (`README.md`) por área.

## Arquivos renomeados/movidos

### Para `docs/client/`
- `BattlePass_Documentacao_Tecnica.md` → `client/battlepass-documentacao-tecnica.md`
- `Custom_BattlePass_Full_Map.md` → `client/custom-battlepass-full-map.md`
- `Custom_BattlePass_Structure_Map.md` → `client/custom-battlepass-structure-map.md`
- `Weekly_Task_Board_Documentacao_Tecnica.md` → `client/weekly-task-board-documentacao-tecnica.md`
- `TaskBoard_Auditoria_Completa.md` → `client/taskboard-auditoria-completa.md`
- `TaskBoard_Clone_Validation.md` → `client/taskboard-clone-validation.md`
- `TaskBoard_Consolidacao_Final.md` → `client/taskboard-consolidacao-final.md`
- `TaskBoard_Mapeamento_Inicial.md` → `client/taskboard-mapeamento-inicial.md`
- `TaskBoard_Stability_Report.md` → `client/taskboard-stability-report.md`
- `TaskBoard_UI_Clone_Complete.md` → `client/taskboard-ui-clone-complete.md`
- `TaskBoard_UI_Equivalence_Report.md` → `client/taskboard-ui-equivalence-report.md`
- `TaskBoard_UX_Equivalence_Report.md` → `client/taskboard-ux-equivalence-report.md`
- `TaskBoard_Widget_Tree_Proof.md` → `client/taskboard-widget-tree-proof.md`
- `TaskBoard_vs_Custom_Full_Diff.md` → `client/taskboard-vs-custom-full-diff.md`
- `TaskBoard_vs_Custom_Structural_Diff.md` → `client/taskboard-vs-custom-structural-diff.md`
- `taskboard.md` → `client/taskboard-readme.md`
- `TALK_ON_RIGHT_CLICK_NPC.md` → `client/talk-on-right-click-npc.md`

### Para `docs/server/`
- `CRYSTALSERVER_TASK_MESSAGE_DIAGNOSIS.md` → `server/crystalserver-task-message-diagnosis.md`
- `LINKED_TASKS_GETTING_STARTED.md` → `server/linked-tasks-getting-started.md`
- `LINKED_TASKS_RULES.md` → `server/linked-tasks-rules.md`
- `linked_tasks_audit.md` → `server/linked-tasks-audit.md`
- `TALKACTION_RULES.md` → `server/talkaction-rules.md`
- `paperdoll_data_structures.md` → `server/paperdoll-data-structures.md`
- `paperdoll_examples.md` → `server/paperdoll-examples.md`
- `paperdoll_tests.md` → `server/paperdoll-tests.md`
- `enums.md` → `server/server-enums-reference.md`
- `SERVER_ENUMS.md` → `server/linked-tasks-server-enums.md`
- `ENUMS_MESSAGE_TYPES.md` → `server/enums-message-types.md`

### Para `docs/architecture/`
- `paperdoll_architecture.md` → `architecture/paperdoll-architecture.md`
- `paperdoll_overview.md` → `architecture/paperdoll-overview.md`

### Para `docs/api/`
- `paperdoll_protocol.md` → `api/paperdoll-protocol.md`

### Para `docs/deployment/`
- `EXECUTION_PLAYBOOK.md` → `deployment/execution-playbook.md`

## Arquivos removidos

- Nenhum arquivo foi removido.

## Arquivos mesclados

- Nenhuma mesclagem destrutiva foi aplicada nesta etapa.
- Duplicidades foram preservadas quando possuíam focos distintos (ex.: enums gerais vs enums focados em linked tasks).

## Principais correções realizadas

- Correção de links internos com caminhos antigos (`docs/...`) após migração.
- Criação de sumário principal em `docs/README.md`.
- Criação de índice por domínio (`docs/server/README.md`, `docs/client/README.md`, etc.).
- Inclusão de marcação `<!-- REVIEW: ... -->` em documentos que dependem de `COMPLETE_CUSTOM_CLIENT` (fonte externa não presente no repositório), para validação humana antes de considerar como documentação normativa.

## Pontos que precisam de validação manual

1. Documentos que citam `COMPLETE_CUSTOM_CLIENT` devem ser reconciliados com `otclient/` atual deste repositório.
2. Exemplos de Paperdoll (server/client) são guias técnicos e podem requerer ajuste fino na API real em produção.
3. Documentos históricos em `docs/wiki/` e `docs/ai/` não foram renomeados em massa para evitar quebra de fluxos existentes; recomenda-se uma segunda etapa dedicada para essa base histórica.

