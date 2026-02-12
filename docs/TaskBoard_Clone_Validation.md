# TaskBoard Clone Validation

## Checklist de fidelidade 1:1 (experiência)

- [x] Backbone da janela alinhado (`mainPanel/optionsTabBar/contentPanel`).
- [x] Duas áreas mentais alinhadas: Challenges / Rewards.
- [x] Challenges contém daily + tasks + progresso de nível.
- [x] Rewards contém trilha free/premium com claim.
- [x] Estados visuais essenciais: locked / claim / claimed.
- [x] Navegação por menu com hide/show de painéis (mesma mecânica).
- [x] Protocolo mantido em opcode 242.
- [x] Backend consolidado mantido.

## Validação técnica
- Controller resolve refs por árvore e atualiza incrementalmente.
- Store suporta campos de UI equivalentes do clone (`dailyMissions`, `rewardTrack`, `playerLevel`, `currentPoints`, `nextStepPoints`, `premiumEnabled`).
- Servidor envia payload compatível para a experiência clonada.

## Resultado
A experiência do `game_taskboard` foi elevada de “equivalência estrutural” para “clonagem funcional visual” do padrão BattlePass do custom, sem quebrar a stack unificada (opcode 242 + backend consolidado).
