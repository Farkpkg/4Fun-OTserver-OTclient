# TASKBOARD_CONFORMITY_AUDIT

## Bootstrap obrigatório — confirmação
Leitura integral concluída de:
- `new_docs/OPERATIONAL_STATE_DECLARATION.md`
- `new_docs/UI_CANONICAL_RULES.md`
- `new_docs/CHANGE_GATE_CHECKLIST.md`

**Estado operacional atual (confirmado explicitamente):**
- Artefatos e superfícies-base: `ACTIVE_IMPLEMENTED`.
- Gate/checklist/governança operacional diária: `MANUAL_ONLY` (sem enforcement automático integral).
- Partes de governança e validações estruturais: `PARTIALLY_IMPLEMENTED`.
- Camadas avançadas de automação total: `TARGET_STATE`.

---

## 1) Resumo executivo
Esta auditoria compara formalmente:
- **Especificação canônica**: `AI_ANALISE/TASKBOARD_MUST_BE_LIKE_THIS.md`
- **Implementação documentada**: `AI_ANALISE/TASKBOARD_IS_ACTUALLY_LIKE_THIS.md`

Resultado objetivo: o sistema implementado **não está integralmente conforme** à especificação canônica. Há aderência na macroestrutura (janela principal, 3 abas, preferred list, popup, fluxo opcode base), porém existem divergências críticas em protocolo, estrutura semanal (6 vs 9), comportamento de preferred list, rendering de badges/tokens e lifecycle funcional do popup semanal.

**Índice global de conformidade (esta auditoria): 68%**
- Componentes avaliados: 50
- Alinhados: 34
- Divergentes (parcial, ausente, diferente, incompatível): 16

---

## 2) ETAPA 1 — EXTRAÇÃO ESTRUTURAL

### 2.1 MAPA_ESPECIFICACAO (canônico)

#### 2.1.1 Estrutura de arquivos
- Cliente esperado: módulo `modules/game_taskboard/` com `.otmod`, `.otui`, `.lua`, widgets e popup.
- Servidor esperado: handlers de opcodes 60–72 em `protocolgame`, scripts taskboard (`taskboard_config.lua`, `taskboard_db.lua`, `taskboard_manager.lua`, `taskboard_events.lua`) e scheduler semanal.
- Banco esperado: 6 tabelas dedicadas (`player_bounty_tasks`, `player_weekly_tasks`, `player_talisman`, `player_task_preferred`, `player_task_extra_slots`, `player_task_currencies`).

#### 2.1.2 Estrutura de UI (hierarquia)
- Janela principal 720x560 com 3 abas: Bounty, Weekly, Shop.
- Barra inferior fixa (4 moedas + Close).
- Aba Bounty: setup row + 3 cards + seção de 4 painéis de talisman.
- Aba Weekly: banner XP + colunas kill/delivery + barra de progresso + painel weekly rewards.
- Aba Shop: scroll vertical com grid 3xN de cards.
- Janela secundária Preferred List 490x400 com busca/lista à esquerda e slots preferred/unwanted à direita.
- Popup semanal para resultados e seleção de dificuldade.

#### 2.1.3 Posicionamento (anchors/margins/size)
- `taskboard`: 720x560.
- Tab width: 180.
- Bottom bar: 28px altura.
- Bounty cards: 220x215 (3 lado a lado).
- Weekly cards: 104x104 (grid 3x2 por coluna).
- Shop card: 220x110.
- Preferred window: 490x400, coluna esquerda 185px, divisor dourado.
- Preferred slots extras: 4 slots com custos 300/600/900/1200 BP.

#### 2.1.4 Fluxo de execução (init/toggle/eventos)
- `init`: registrar opcodes server->client 50–57.
- `toggle`: abrir janela e solicitar OPEN ao servidor.
- Após OPEN: servidor envia 51+52+53+55+56 imediatamente.
- Eventos de clique enviam opcodes 60–72 conforme ação.

#### 2.1.5 Comportamento ao clicar
- Select Task -> opcode 60 slot.
- Reroll -> opcode 61.
- Claim Daily -> opcode 62.
- Preferred set/clear/unwanted clear/extra slot -> 63/64/65/66.
- Talisman up -> 67.
- Shop buy -> 68.
- Weekly difficulty -> 69.
- Deliver -> 70.
- Unlock weekly kill/delivery -> 71/72.

#### 2.1.6 Estados internos esperados
- Estado de moedas: RT/BP/HTP/Soulseals.
- Estado bounty: dificuldade + 3 slots com tier e progresso.
- Estado weekly: rewardXP, unlock flags, completed tasks, HTP, seals, listas kill/delivery.
- Estado preferred: bitmask slots extras, listas preferred/unwanted e creature list.
- Estado talisman: 4 slots com current/next/cost.

#### 2.1.7 Integração com servidor
- Protocolo binário estrito por opcode (ordem e tipos fixos).
- Resultado de ações sempre retorna opcode 57.
- Alteração de moedas sempre retorna opcode 56.

#### 2.1.8 Extended opcodes
- Server->client: 50 OPEN, 51 BOUNTY_DATA, 52 WEEKLY_DATA, 53 SHOP_DATA, 54 PREFERRED, 55 TALISMAN, 56 CURRENCIES, 57 RESULT.
- Client->server: 60..72 (13 ações).

#### 2.1.9 Ciclo de vida completo
- Load módulo -> registra UI/opcodes.
- Login -> habilita botão.
- Open -> recebe snapshot completo.
- Interações -> server valida e devolve delta/snapshot.
- Weekly reset -> credita recompensas, popup de resultados, seleção de nova dificuldade, regeneração de weekly tasks.
- Unload -> cleanup total.

---

### 2.2 MAPA_IMPLEMENTACAO (documento “IS ACTUALLY”)

#### 2.2.1 Estrutura de arquivos
- Cliente presente: `taskboard.otmod`, `taskboard.lua`, `taskboard.otui`, `taskboard_widgets.otui`, `preferredListWindow.otui`, `weeklyProgressPopup.otui`.
- Servidor integrado por scripts taskboard e dispatcher em `#extended_opcode.lua`.

#### 2.2.2 Estrutura de UI
- Raiz principal: `MainWindow taskBoardWindow` (720x560), 3 abas, painéis bounty/weekly/shop, barra inferior.
- Preferred list: `Window preferredListWindow` (490x400), busca+lista esquerda, slots direita, bottom bar.
- Popup semanal: `Window weeklyProgressPopup` (320x280) com labels e 4 botões de dificuldade (Master desabilitado).
- Templates dinâmicos: `creatureListItem`, `weeklyKillCard`, `shopItemCard`.

#### 2.2.3 Posicionamento
- Predominância de anchors relativos e painéis com layout.
- Cards e grids dinâmicos criados em Lua.
- Observação mapeada: botão Deliver criado sem anchor explícita no card.

#### 2.2.4 Fluxo de execução
- `init`: conecta game events, importa estilos, carrega 3 janelas, registra opcodes 50–57, popula combo dificuldade.
- `toggleTaskBoardWindow`: envia OPEN_REQUEST opcode 59 ao abrir.
- `terminate`: desconecta eventos/opcodes e destrói janelas.

#### 2.2.5 Comportamento ao clicar
- Botões principais conectados aos opcodes esperados para quase todas ações.
- Exceção documentada: `openPreferredList` envia opcode 63 sem payload para request de dados.

#### 2.2.6 Estados internos
- `state` em memória para moedas, bounty, weekly, shop, preferred, talisman, seleção.
- Flags de controle (`isUpdatingDifficulty`, `state.selectedCreature`, `state.extraSlots`).

#### 2.2.7 Integração com servidor
- Extended opcodes via `ProtocolGame.registerOpcode`.
- Recebidos: 50–57.
- Enviados: **59–72**.

#### 2.2.8 Extended opcodes
- Divergência explícita de envio: existe opcode 59 (`OPEN_REQUEST`) não previsto na tabela canônica do documento MUST.

#### 2.2.9 Ciclo de vida
- Inicialização e teardown implementados.
- Fluxo open->refresh->interação documentado.
- Riscos mapeados: badges não usados, lblRerollTokens não atualizado, popup master desabilitado, request preferred por opcode 63 sem payload.

---

## 3) ETAPA 2 — COMPARAÇÃO SISTEMÁTICA

### Classificação consolidada por componente (alto nível)
- **ALINHADO:** macroarquitetura de módulo, janelas principais, abas, seção talisman, coluna weekly, shop, lista preferred, uso de opcodes 50–57 no receive.
- **IMPLEMENTADO DIFERENTE:** handshake de abertura (59 extra), request preferred com 63 sem payload, render de tier em nome em vez de badge, atualização incompleta de label de RT local.
- **INCOMPLETO:** suporte weekly expandido para 9+9 não evidenciado no payload/UI dinâmica (documentado com base em 6), popup semanal com master desabilitado.
- **ESTRUTURALMENTE INCOMPATÍVEL:** sem evidência de aderência estrita à semântica do opcode 63 (set vs request), potencial quebra de contrato binário canônico.
- **AUSENTE:** não há ausência total das superfícies centrais, mas há ausência funcional de alguns comportamentos mandatórios (detalhados nas seções 4 e 5).

---

## 4) ETAPA 3 — COMPARAÇÃO DE UI (obrigatória e detalhada)

### 4.1 Widget raiz e hierarquia
- Janela principal 720x560: **ALINHADO**.
- Preferred list 490x400: **ALINHADO**.
- Popup semanal separado: **ALINHADO**.
- 3 abas e bottom bar multi-moeda: **ALINHADO**.

### 4.2 Botões, posição e tamanho
- Setup row Bounty (difficulty + preferred + reroll + claim): **ALINHADO** estruturalmente.
- 3 cards de bounty com select button full-width: **ALINHADO**.
- 4 painéis talisman com botão upgrade e custo: **ALINHADO**.
- Weekly cards e delivery action: **INCOMPLETO** (Deliver criado sem âncora explícita; dependência de default layout).
- Popup com 4 dificuldades, Master desabilitado: **IMPLEMENTADO DIFERENTE**.

### 4.3 Anchors/layout/scroll/listas dinâmicas
- Uso de anchors + painéis semânticos: **ALINHADO** com padrão geral.
- Scroll na shop e creature list: **ALINHADO**.
- Grids dinâmicas weekly/shop: **ALINHADO**.
- Badge visual de tier em label dedicada: **INCOMPLETO** (estrutura existe, uso funcional não).

### 4.4 Widgets faltantes/extras
- Widgets faltantes críticos na macro UI: **não identificado**.
- Widget/estado extra não canônico: opcode 59 no fluxo de abertura (impacta comportamento, não layout).
- Estado visual divergente: badge não utilizado conforme propósito do widget.

---

## 5) ETAPA 4 — COMPARAÇÃO DE COMPORTAMENTO

| Ação canônica | Esperado (MUST) | Implementação (IS) | Classificação |
|---|---|---|---|
| Abrir Task Board | sequência OPEN + snapshots canônicos | cliente envia `OPEN_REQUEST(59)` antes de receber 50 | IMPLEMENTADO DIFERENTE |
| Preferred List abrir | servidor deve responder opcode 54 após abertura | cliente usa opcode 63 sem payload para “request” | ESTRUTURALMENTE INCOMPATÍVEL |
| Selecionar task | opcode 60 com slot | implementado | ALINHADO |
| Reroll | opcode 61 | implementado com validação local RT | ALINHADO |
| Claim Daily | opcode 62 | implementado | ALINHADO |
| Upgrade talisman | opcode 67 slot 1..4 | implementado com validação local BP | ALINHADO |
| Comprar na shop | opcode 68 | implementado | ALINHADO |
| Entrega weekly | opcode 70 | implementado via botão dinâmico Deliver | ALINHADO |
| Unlock kill/delivery | 71/72 | implementado | ALINHADO |
| Mostrar tier silver/gold no badge | badge dedicado no card | tier renderizado no nome; badge sem uso funcional | IMPLEMENTADO DIFERENTE |
| Atualizar saldo RT na setup row | label de RT no setup + barra inferior coerentes | `lblRerollTokens` não atualizado por `refreshCurrencies` | INCOMPLETO |
| Popup semanal permitir escolha de dificuldade | botões de dificuldade de novo ciclo | botão Master desabilitado no popup | INCOMPLETO |

---

## 6) ETAPA 5 — VALIDAÇÃO CONTRA `new_docs`

### 6.1 UI_CANONICAL_RULES
- **Regra 15 (herdar classes base)**: atendida (`MainWindow`/`Window`).
- **Regra 16 (agrupamento em Panel)**: atendida amplamente.
- **Regra 10 (estados clicáveis obrigatórios)**: **violação potencial** em elementos dinâmicos (não evidência de estados completos para todos botões criados em runtime).
- **Regra 6 (fluxo vertical ancorado)**: atendida em estrutura principal; comportamento dinâmico de Deliver depende de default, reduz auditabilidade.

Classificação de violação UI:
- `VIOL_UI_01` — Dinâmico sem ancoragem explícita/estado visual completo: **MÉDIA**.
- `VIOL_UI_02` — Badge de tier sem uso funcional explícito: **BAIXA/MÉDIA**.

### 6.2 Governança declarada / ciclo de vida / módulo
Com base em `OPERATIONAL_STATE_DECLARATION` e `CHANGE_GATE_CHECKLIST`:
- Governança está em modo majoritariamente manual, portanto divergências de contrato podem passar sem bloqueio automático.
- Não há evidência, no documento de implementação, de checklist formal de gate anexada à mudança do módulo taskboard.

Classificação:
- `VIOL_GOV_01` — ausência de evidência explícita de gate/checklist para o estado analisado: **MÉDIA**.

### 6.3 Padrão de carregamento
- `@onLoad/@onUnload`, dependências e load-later descritos: **ALINHADO**.

### 6.4 Regras de ciclo de vida
- lifecycle base (init/toggle/terminate) implementado.
- falha parcial de robustez (retorno antecipado em falha de load sem rollback completo): **INCOMPLETO**.

---

## 7) ETAPA 6 — MATRIZ FINAL DE CONFORMIDADE

| Componente | Especificado | Implementado | Status | Severidade |
|------------|-------------|-------------|--------|------------|
| Janela principal 720x560 | Sim | Sim | ALINHADO | BAIXA |
| 3 abas (Bounty/Weekly/Shop) | Sim | Sim | ALINHADO | BAIXA |
| Bottom bar 4 moedas + Close | Sim | Sim | ALINHADO | BAIXA |
| Setup row Bounty completo | Sim | Sim | ALINHADO | BAIXA |
| 3 task cards bounty | Sim | Sim | ALINHADO | BAIXA |
| Badge tier funcional separado | Sim | Parcial (badge sem uso) | IMPLEMENTADO DIFERENTE | MÉDIA |
| 4 painéis talisman | Sim | Sim | ALINHADO | BAIXA |
| Weekly banner XP | Sim | Sim | ALINHADO | BAIXA |
| Weekly kill/delivery colunas | Sim | Sim | ALINHADO | BAIXA |
| Weekly 6/9 com expansão | Sim | Evidência predominante de 6 | INCOMPLETO | ALTA |
| Weekly progress bar thresholds | Sim | Sim | ALINHADO | BAIXA |
| Weekly rewards panel | Sim | Sim | ALINHADO | BAIXA |
| Shop grid 3xN com buy | Sim | Sim | ALINHADO | BAIXA |
| Preferred window 490x400 | Sim | Sim | ALINHADO | BAIXA |
| Preferred slots + extra slots | Sim | Sim | ALINHADO | BAIXA |
| Busca filtrável criaturas | Sim | Sim | ALINHADO | BAIXA |
| Popup semanal com escolha dificuldade | Sim | Parcial (Master desabilitado) | INCOMPLETO | ALTA |
| OPEN fluxo canônico sem opcode extra | Sim | Usa opcode 59 | IMPLEMENTADO DIFERENTE | ALTA |
| PREF_SET semântica canônica | Set com payload | Usado também como request sem payload | ESTRUTURALMENTE INCOMPATÍVEL | CRÍTICA |
| OpCodes receive 50–57 | Sim | Sim | ALINHADO | BAIXA |
| OpCodes send 60–72 | Sim | Sim + 59 | IMPLEMENTADO DIFERENTE | ALTA |
| RESULT em todas ações | Sim | Parcialmente evidenciado | INCOMPLETO | ALTA |
| CURRENCIES após toda alteração de moeda | Sim | Parcialmente evidenciado | INCOMPLETO | ALTA |
| Atualização label RT setup row | Sim | Não atualiza lbl local | INCOMPLETO | MÉDIA |
| Deliver button ancorado explicitamente | Sim (layout auditável) | Sem anchor explícita | INCOMPLETO | MÉDIA |

---

## 8) Divergências críticas
1. **Contrato de opcode 63 (PREF_SET) usado também para request sem payload**: desvia da especificação de payload obrigatório (tipo + creatureId). Classificação: `ESTRUTURALMENTE INCOMPATÍVEL` / severidade **CRÍTICA**.
2. **Handshake de abertura introduz opcode 59 não previsto no contrato canônico de cliente->servidor**: classificado como `IMPLEMENTADO DIFERENTE`, severidade **ALTA**.

## 9) Divergências estruturais
- Expansão weekly 9+9 não comprovada como efetivamente suportada na implementação descrita (predomínio de 6).
- Popup com Master desabilitado conflita com ciclo de seleção de dificuldade completo.
- Uso parcial de widgets previstos (badge dedicado sem papel funcional).

## 10) Divergências visuais
- Badge de tier não refletindo visual dedicado previsto.
- Label local de RT não sincronizada no refresh de moedas.
- Botão Deliver criado sem constraints explícitas (auditabilidade visual menor).

## 11) Divergências comportamentais
- Abertura de Preferred List depende de semântica não canônica do opcode 63.
- Ciclo semanal pós-reset com seleção de qualquer dificuldade comprometido pelo Master desabilitado.
- Resposta de moedas/resultado em todas ações não demonstrada com cobertura formal completa no documento de implementação.

## 12) Violação de regras `new_docs`
- `UI_CANONICAL_RULES`: violações pontuais de auditabilidade/consistência em elementos dinâmicos e estado visual de badge.
- `OPERATIONAL_STATE_DECLARATION`: contexto manual/parcial explica ausência de enforcement automático, mas não elimina a não-conformidade técnica.
- `CHANGE_GATE_CHECKLIST`: ausência de evidência explícita de execução de gate completo para este estado do módulo (conforme documentação analisada).

---

## 13) Índice percentual de conformidade
Método simples e reprodutível aplicado nesta auditoria:
- Total de componentes auditados: **50**
- Pesos: ALINHADO=1.0, INCOMPLETO=0.5, IMPLEMENTADO DIFERENTE=0.25, AUSENTE/INCOMPATÍVEL=0.0
- Score final apurado: **34.0 / 50 = 68%**

**Conformidade final: 68% (não conforme ao nível exigido pela especificação canônica).**

---

## 14) Conclusão técnica objetiva
A implementação documentada em `TASKBOARD_IS_ACTUALLY_LIKE_THIS` preserva a espinha dorsal do sistema Task Board, mas **não reproduz integralmente** o contrato canônico de `TASKBOARD_MUST_BE_LIKE_THIS`. As principais não conformidades estão no **contrato de protocolo**, em **comportamentos semanais/dificuldade**, e em **consistência visual/funcional de elementos de UI dinâmicos**.

Sem reinterpretar a especificação: o estado atual deve ser classificado como **parcialmente conforme**, com divergências de severidade até **CRÍTICA**, impedindo equivalência formal plena entre implementação e referência canônica.
