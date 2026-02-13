# TaskBoard vs Custom — Full Diff (Visual + Funcional)

## Backbone de layout
- **Custom**: `mainPanel/optionsTabBar/contentPanel/missionPanel|progressPanel`
- **TaskBoard (novo)**: mesmo backbone replicado.

## Navegação
- **Custom**: `challengesMenu`/`rewardsMenu`
- **TaskBoard**: mesmos IDs e mesmo padrão de alternância.

## Challenges side
- **Custom**: daily + missions + player progress
- **TaskBoard**: daily (derivado de bounties) + weekly tasks + progress widgets equivalentes

## Rewards side
- **Custom**: reward track free/premium + claim state
- **TaskBoard**: reward track free/premium com step unlock por nível, claim e estado locked/claimed

## Estados visuais
- **Custom**: ativo/bloqueado/claimado por widget
- **TaskBoard**: mesma semântica visual aplicada em `TaskBoardTrackRewardSlot` e daily/weekly slots

## Diferenças intencionais (permitidas)
- Opcode/protocolo: `242` com `sync/delta`.
- Backend: stack consolidada TaskBoard.
- Fonte de dados: domínio unificado (bounty/weekly/shop) projetado para alimentar experiência tipo battlepass.

## Conclusão
A clonagem agora é de experiência (layout+navegação+track+estados), mantendo apenas diferenças de transporte de dados e backend interno.
