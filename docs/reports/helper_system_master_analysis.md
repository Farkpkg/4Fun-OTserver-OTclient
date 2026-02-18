# Documentação Mestre — Sistema de Bot/Helper (OTClient)

> Escopo analisado: implementação **real existente** no repositório para `game_helper` (RTC Helper), incluindo integrações Lua/UI e pontos C++→Lua que abastecem os eventos usados pelo helper.

## ETAPA 1 — Mapeamento Estrutural

### 1.1 Arquivos e módulos relacionados

#### Núcleo direto do helper
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_helper/helper.otmod`  
  Declara o módulo `game_helper`, script principal (`helper.lua`) e entrypoints de ciclo (`init`/`terminate`).
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_helper/helper.lua`  
  Motor completo da automação: heal, potions, training, haste, shooter, auto-target, friend-heal, tracker, persistência e hotkeys.
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_helper/styles/helper.otui`  
  UI principal + tracker + regras/termos + bindings de callbacks (`@onClick`, `@onCheckChange`, `@onOptionChange`, etc.).
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_helper/styles/spell.otui`  
  Janela de seleção/listagem de spells usada em `assignSpell`.
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_helper/styles/shooterPreset.otui`  
  Janela de criar/renomear presets do shooter.

#### Integrações diretas com helper
- `COMPLETE_CUSTOM_CLIENT/modules/game_interface/interface.otmod`  
  Inclui `game_helper` em `load-later` (ordem de carregamento da interface ingame).
- `COMPLETE_CUSTOM_CLIENT/modules/game_sidebuttons/sidebuttons.lua`  
  Abre/fecha janela do helper via botão lateral `helperDialog`.
- `COMPLETE_CUSTOM_CLIENT/modules/corelib/keybinds.lua`  
  Define ações de hotkey para toggle helper, auto target, shooter, preset e show helper.
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_tibia_spelllist/t_spelllist.lua`  
  Faz integração drag-and-drop de spell para slots do helper via `modules.game_helper.onDropSpell(...)`.
- `COMPLETE_CUSTOM_CLIENT/modules/game_playerdeath/playerdeath.lua`  
  Desabilita shooter/auto-target ao morrer.
- `COMPLETE_CUSTOM_CLIENT/modules/game_interface/gameinterface.lua`  
  Atualiza `helperConfig.currentLockedTargetId` em ações de ataque/cancel.
- `COMPLETE_CUSTOM_CLIENT/modules/game_battle/battle.lua`  
  Também sincroniza lock de target (`currentLockedTargetId`) com ações de ataque.
- `COMPLETE_CUSTOM_CLIENT/modules/client_options/options.lua`  
  Garante `helperDialog` ativo por padrão na configuração de botões.

#### Suporte C++→Lua (eventos que o helper consome)
- `otclient/src/client/game.cpp`  
  Dispara `g_game.onGameStart` / `g_game.onGameEnd` para Lua.
- `otclient/src/client/protocolgameparse.cpp`  
  Dispara eventos Lua usados pelo helper: `onSpellCooldown`, `onSpellGroupCooldown`, `onMultiUseCooldown`.
- `otclient/src/client/luafunctions.cpp`  
  Expõe APIs engine (`g_game`, `g_map`, etc.) consumidas pelo helper.

### 1.2 Entry points (pontos de entrada)
1. Loader de módulo: `helper.otmod` (`@onLoad: init`, `@onUnload: terminate`).
2. Evento de jogo: `g_game.onGameStart -> online()`, `g_game.onGameEnd -> offline()`.
3. UI: botão lateral `helperDialog -> modules.game_helper:showTerms()`.
4. Hotkeys: grupo `Helper` em `corelib/keybinds.lua` chama funções públicas do módulo.

### 1.3 Dependências internas/externas

#### Internas (Lua/modules)
- `modules.game_textmessage`, `modules.game_sidebuttons`, `modules.game_party_list`, `modules.game_actionbar`, `modules.game_battle`, `modules.game_interface`, `modules.game_spells`, `modules.gamelib` (SpellInfo/Spelllist), `Options`, `KeyBind/KeyBinds`, `LoadedPlayer`.

#### Externas de engine (bindings)
- `g_game`, `g_map`, `g_ui`, `g_clock`, `g_mouse`, `g_keyboard`, `g_resources`, `g_client`.
- Classes userdata: `LocalPlayer`, `Creature`, itens/mapa/tiles retornados pelas APIs.

### 1.4 Eventos registrados (connect/callback/listeners)

No `init()`:
- `connect(g_game, {...})`: `onGameStart`, `onGameEnd`, `onSpellCooldown`, `onSpellGroupCooldown`, `onUpdateSpellArea`, `onPartyDataUpdate`, `onPartyDataClear`, `onMultiUseCooldown`.
- `connect(Creature, {...})`: `onAppear`, `onDisappear`.
- `connect(LocalPlayer, {...})`: `onPartyMembersChange` (referenciado; não há função local definida no arquivo).

Callbacks OTUI:
- `helper.otui` registra dezenas de callbacks para ações de UI (toggle, add/remove spell/potion/rune, percentuais, prioridades, presets, termos, etc.).
- `spell.otui` registra filtro de busca chamando `onSearchTextChange` e `onClearSearchText`.

### 1.5 Hooks no ciclo do jogo
- Login/start: `online()` faz reset, load config, repovoa UI, inicia loop cíclico.
- Logout/end: `offline()` limpa presets UI, remove ciclo, esconde helper/tracker.
- Think loop: `cycleEvent(helperCycleEvent, 50)` executa scheduler interno do helper.
- Cooldowns de combate: via eventos de protocolo (`onSpellCooldown`/`onSpellGroupCooldown`/`onMultiUseCooldown`).
- Spawn/despawn criaturas: `onCreatureAppear`/`onCreatureDisappear` mantém cache de `spectators` para target/shooter.

---

## ETAPA 2 — Fluxo de execução

### 2.1 Fluxo login → ação automática
1. `init()` monta UI/widgets, conecta eventos e prepara referências de painéis.
2. Em `onGameStart`, `online()`:
   - define `player`
   - `reset()` UI/config visual
   - `loadSettings()` (arquivo por personagem)
   - `loadProfileOptions()` e `onLoadHelperData()` (hidratação de botões/checkboxes)
   - inicia `helperEvents.helperCycleEvent = cycleEvent(..., 50)`.
3. Cada tick (50ms), `helperCycleEvent()` acumula temporizadores por tarefa e dispara ações por intervalo:
   - heal HP
   - mana/training
   - checks rotineiros (food/gold)
   - friend heal
   - haste
   - shooter
   - auto target
   - exercise event
4. Cada subrotina valida estado (`hotkeyHelperStatus`, online, flags específicas, cooldowns, PvP/PZ/AFK/follow) e executa ação (`g_game.talk`, `g_game.useInventoryItem`, `g_game.attack`, etc.).

### 2.2 Call graph (macro visão)

#### Inicialização
- `helper.otmod -> init()`
- `init()` chama: `botStatus()`, `online()` (se já online), setup UI.

#### Runtime principal
- `online() -> cycleEvent(helperCycleEvent, 50)`
- `helperCycleEvent()` chama `eventTable[event].action` quando `timer >= interval`.
- Ações registradas:
  - `checkHealthHealing`
  - `checkMana`
  - `routineChecks`
  - `checkFriendHealing`
  - `checkAutoHaste`
  - `checkMagicShooter`
  - `checkAutoTarget`
  - `checkExerciseEvent`

#### Ações de alto impacto
- `checkHealthHealing -> usePotion / castHealingSpell`
- `checkMana -> checkManaHealing + checkTrainingSpell`
- `checkFriendHealing -> useAutoSio/useAutoGranSio/useAutoTioSio/useAutoUH`
- `checkMagicShooter -> sort+avaliar spells/runes -> g_game.talk / useInventoryItemWith`
- `checkAutoTarget -> heurística de seleção -> g_game.attack`

#### Contextos de execução
- **Loop/Scheduler**: `helperCycleEvent`.
- **Eventos**: start/end game, cooldowns, party updates, creature appear/disappear.
- **UI callbacks**: config dinâmica.
- **Hotkeys**: toggles de estado.

### 2.3 Existe loop principal/scheduler/timers/macros/eventos?
- Loop principal: **sim** (`cycleEvent` de 50ms).
- Scheduler: **sim**, tabela `eventTable` com intervalos por ação.
- Timers: **sim**, `timers[...]` + cooldown maps (`spellsCooldown`, `groupsCooldown`, `multiUseExDelay`).
- Sistema de macros genérico: **não** (não há engine de macros declarativa; há automações fixas orientadas a eventos + scheduler).
- Execução orientada a eventos: **sim**, combinada com loop.

---

## ETAPA 3 — Motor do bot/helper

### 3.1 Como o motor funciona internamente
- O helper mantém um **estado global central** (`helperConfig`) contendo toggles, slots, thresholds, presets e lock de target.
- Um **dispatcher temporal** (`helperCycleEvent`) roda a cada 50ms e ativa tarefas por frequência.
- O motor usa:
  - cache de cooldown de spell/grupo
  - cache de criaturas (`spectators`)
  - validações de segurança (PZ, AFK, follow, cooldown, LOS, alcance, vocação, mana).

### 3.2 Paradigma
Combinação de:
1. **Event-driven** (connects `g_game`/`Creature`/UI/hotkeys).
2. **Loop-driven** (scheduler cíclico).
3. **Rule-driven** (tabelas de config + thresholds/prioridades).

### 3.3 Ciclo de vida de uma automação
1. Usuário configura slot/percentual/toggle.
2. Estado persiste em `helperConfig`.
3. Scheduler verifica condição no intervalo designado.
4. Se condição ok, executa ação no client protocol (`talk/use/attack`).
5. Cooldowns e locks evitam flood/recast indevido.
6. Em logout/hide/death, estados críticos são desligados/limpos.

---

## ETAPA 4 — Sistema de macros

### 4.1 Conclusão objetiva
Não existe engine de macros “registráveis por script” dentro do helper. O que existe é:
- Scheduler interno fixo (`eventTable` + `timers`).
- Ações fixas pré-programadas (heal, shooter, target etc.).

### 4.2 “Arquitetura de macro equivalente” existente
- Registro: atribuição de função em `eventTable.<nome>.action = func`.
- Armazenamento: em memória (tabelas Lua), não persistido como “macro scripts”.
- Execução: `helperCycleEvent` baseado em intervalo.
- Pausa/cancelamento: por flags (`hotkeyHelperStatus`, toggles específicos) ou `removeEvent` no logout.
- Delay/intervalo: `eventTable[event].interval` em ms.
- UI integração: switches em `helper.otui` atualizam `helperConfig` e impactam regras do scheduler.

---

## ETAPA 5 — API disponível para scripts do helper

## 5.1 API pública exportada por `modules.game_helper`

Funções públicas relevantes (chamadas externamente por outros módulos/hotkeys/UI):
- `toggle`, `show`, `hide`, `showTerms`, `toggleHelperTracker`, `botStatus`
- `toggleMagicShooter`, `toggleAutoTarget`, `toggleShooterPreset`
- `isMagicShooterActive`, `isAutoTargetActive`
- `onDropSpell`, `updateAutoTargetMode`
- `move` (dock do tracker em painéis)

Funções de configuração/ação (também públicas no módulo Lua):
- Assign/update/remove: `assignSpell`, `assignRune`, `assignPotionEvent`, `assignExerciseEvent`, `removeAction`, `update*` variados.
- Execução: `checkHealthHealing`, `checkMana`, `checkMagicShooter`, `checkAutoTarget`, `checkFriendHealing`, `checkAutoHaste`, `checkExerciseEvent`.
- Persistência: `saveSettings`, `loadSettings`.

## 5.2 Objetos globais/engine consumidos pelo helper
- `g_game` (combate, uso de item, fala de spell, estado online/alvo/follow).
- `g_map` (visão/LOS, busca criatura por id, busca item por id).
- `g_ui` (widgets, timers de ação, criação de janelas).
- `g_clock` (millis para cooldowns/timers).
- `g_keyboard`/`g_mouse`/`g_client` (input/hotkey capture e lock de input).
- `g_resources` + `json` (persistência em arquivo).
- `Spells`, `SpellInfo`, `SpellAreas`, `SpellIcons`, `SpelllistSettings`.

## 5.3 Objetos de jogo usados
- `LocalPlayer/player`: HP/MP, soul, vocation, level, spells, inventory count, posição, PZ, harmony.
- `Creature`: id, nome, health%, posição, visibilidade, party checks.
- Item/tile retornados por `g_map.findItemsById` e APIs de uso.

---

## ETAPA 6 — Lua ↔ C++ (bindings)

### 6.1 Interações identificadas
- C++ chama Lua (`g_lua.callGlobalField`) para eventos usados pelo helper:
  - `g_game.onGameStart` / `onGameEnd`
  - `g_game.onSpellCooldown`
  - `g_game.onSpellGroupCooldown`
  - `g_game.onMultiUseCooldown`
- Lua chama C++ via bindings de singleton (`g_game`, `g_map`, etc.) definidos em `luafunctions.cpp`.

### 6.2 Como o binding opera
- O core registra funções C++ no estado Lua (`bindSingletonFunction`), expondo APIs para scripts.
- Eventos de protocolo/jogo disparam callbacks Lua no namespace `g_game`.
- O helper depende dessa ponte para receber tempo de cooldown real e estado de sessão.

### 6.3 Funções críticas expostas e usadas pelo helper
Exemplos críticos:
- `g_game.attack`, `cancelAttack`, `getAttackingCreature`, `getFollowingCreature`, `isOnline`, `getLocalPlayer`, `talk`, `useInventoryItem`, `useInventoryItemWith`.
- `g_map.isSightClear`, `g_map.getCreatureById`, `g_map.findItemsById`.

### 6.4 Limitações técnicas observadas
- `onUpdateSpellArea` está conectado no helper, mas não há evidência no core deste repositório de disparo correspondente (pode depender de patch externo).
- `Helper.changeGold()` é usado no helper, porém a origem do binding/objeto `Helper` não aparece no fonte C++ rastreado aqui.
- Uso intenso de estado global mutável (`helperConfig`, `player`, `spectators`) aumenta acoplamento e risco de regressão.

---

## ETAPA 7 — Persistência e configuração

### 7.1 Como os dados são salvos
- Arquivo por personagem: `/characterdata/<LoadedPlayer:getId()>/helper.json`.
- Serialização: `json.encode(helperConfig, 2)` + `g_resources.writeFileContents`.

### 7.2 Arquivos de configuração
- Principal: `helper.json` por personagem.
- Defaults e migração: implementados em `loadSettings()` (hot-fixes para campos ausentes).

### 7.3 Preservação de estado entre sessões
- `loadSettings()` reconstrói defaults e sobrepõe com arquivo existente.
- `onLoadHelperData()` hidrata UI de acordo com config carregada.
- Presets shooter (`shooterProfiles`) e `selectedShooterProfile` persistem.

### 7.4 Riscos de corrupção
- JSON inválido: `pcall(json.decode(...))` retorna false e pode perder estado esperado.
- Estruturas parcialmente inválidas: existem hot-fixes, mas não há schema versionado formal.
- Grande acoplamento entre IDs de widget e estrutura de config (renomear ID em OTUI quebra load/save silenciosamente).

---

## ETAPA 8 — Documentação mestre final

### 8.1 Arquitetura geral
- Camada UI (OTUI) -> callbacks -> atualização `helperConfig`.
- Motor scheduler (`cycleEvent`) -> avaliação de regras -> execução de ações.
- Eventos do jogo/protocolo atualizam contexto (cooldowns, ciclo de sessão, party, criaturas).
- Persistência por personagem mantém continuidade de automações.

### 8.2 Fluxo completo (descrição textual tipo diagrama)
1. Módulo carrega (`init`) e instancia janelas.
2. Login (`online`) ativa loop temporal e carrega estado.
3. Scheduler percorre tarefas por intervalo.
4. Tarefa decide com base em config + estado runtime + cooldown + LOS/PZ/AFK.
5. Se aprovado, emite comando para engine (`talk/use/attack`).
6. UI/tracker refletem estados ativos.
7. Logout/death/desativação limpam/pausam automações.

### 8.3 Eventos disponíveis ao helper
- Sessão: `onGameStart`, `onGameEnd`.
- Cooldowns: `onSpellCooldown`, `onSpellGroupCooldown`, `onMultiUseCooldown`.
- Mundo: `Creature.onAppear`, `Creature.onDisappear`.
- Party: `onPartyDataUpdate`, `onPartyDataClear`.
- UI/hotkeys: dezenas de callbacks OTUI + keybind actions do grupo Helper.

### 8.4 Sistema de macros (status real)
- Não há macro engine genérica; há scheduler interno fixo orientado por tabela.

### 8.5 Pontos seguros para extensão
- Adicionar nova tarefa no scheduler:
  1. criar função
  2. adicionar entrada em `eventTable` + `timers`
  3. ligar toggle/UI.
- Expandir presets em `helperConfig.shooterProfiles`.
- Reutilizar pipeline de drag-and-drop (`onDropSpell`/`onSetupDropSpell`).
- Reusar persistência `loadSettings`/`saveSettings` + migração de schema.

### 8.6 Pontos críticos que podem quebrar o cliente/módulo
- Alterar IDs OTUI sem ajustar `recursiveGetChildById`.
- Alterar sem cuidado `helperConfig` sem migração em `loadSettings`.
- Flood de ações se remover checks de cooldown/PZ/AFK/follow.
- Alterar seleção de target sem manter `currentLockedTargetId` sincronizado com battle/interface.

### 8.7 Boas práticas
- Introduzir `schemaVersion` no JSON.
- Centralizar validação de config antes de uso.
- Encapsular side effects (`g_game.talk/use/attack`) em wrappers com telemetria/debug.
- Reduzir globais: injetar contexto em funções puras quando possível.

### 8.8 Exemplos reais de extensões avançadas (compatíveis com arquitetura atual)
1. **Auto SSA/Might Ring por HP crítico**: nova task de 100ms com histerese e cooldown local.
2. **Auto kite assistido por target mode**: task que ajusta follow/chase de acordo com distância e tipo de alvo.
3. **Shooter contextual por monstro**: camada de regras antes de `checkMagicShooter` escolhendo preset por race/name.
4. **Panic mode**: interruptor global que desliga shooter/target e força rotação defensiva.

---

## ETAPA 9 — Visão de arquiteto (melhorias estruturais)

## 9.1 Módulos plugáveis
Implementação incremental:
- Criar `helper_plugins/` com contrato simples:
  - `plugin.id`, `plugin.init(ctx)`, `plugin.tick(ctx, dt)`, `plugin.terminate(ctx)`.
- No `helperCycleEvent`, iterar plugins registrados.
- Persistir enabled/priority por plugin em `helper.json`.

### 9.2 Hot reload de scripts
- Reusar conceito de reload de módulo com flag de desenvolvimento.
- Adicionar comando admin para:
  1. serializar estado volátil mínimo
  2. unload/load plugin
  3. restaurar estado.

### 9.3 Sistema de prioridades
- Hoje prioridades são locais (potions/shooter). Evoluir para **priority queue global**:
  - cada ação gera `ActionIntent{type, priority, ttl, guardFn, runFn}`
  - arbitrador escolhe intenção vencedora por tick.

### 9.4 Fila de ações
- Inserir `ActionQueue` com deduplicação e anti-spam.
- Ex.: `attack` invalida `attack` anterior; `talk(spell)` respeita cooldown de grupo.

### 9.5 Máquina de estados
- FSM macro: `IDLE -> COMBAT -> SURVIVAL -> RECOVERY`.
- Regras atuais (HP crítico, PZ, AFK, follow) viram transições explícitas.

### 9.6 Behavior Tree
- Para target+shooter: BT por prioridade:
  - Selector(Survival, CrowdControl, Damage, Utility)
  - Sequence(Guard, AcquireTarget, CastAction)
- Permite expansão sem if-else monolítico.

### 9.7 Automação avançada orientada a eventos
- Além do tick: publicar eventos internos (`OnHealthThreshold`, `OnTargetSwitch`, `OnCooldownReady`).
- Plugins se inscrevem nesses eventos e apenas reagem quando necessário (menos custo por tick).

---

## Apêndice A — Inventário funcional principal do `helper.lua`

### Núcleo/ciclo
`init`, `terminate`, `online`, `offline`, `helperCycleEvent`, `loadMenu`, `reset`, `saveSettings`, `loadSettings`, `onLoadHelperData`.

### Healing/Support
`checkHealthHealing`, `checkMana`, `checkManaHealing`, `castHealingSpell`, `checkTrainingSpell`, `checkAutoHaste`, `checkHealthPriority`, `autoEatFood`, `autoChangeGold`.

### Friend heal
`onPartyDataUpdate`, `onPartyDataClear`, `onFriendHealing`, `useAutoSio`, `useAutoGranSio`, `useAutoTioSio`, `useAutoUH`, `manageSioSettings`, `manageGranSioSettings`.

### Shooter/Target
`checkMagicShooter`, `checkAutoTarget`, `toggleMagicShooter`, `toggleAutoTarget`, `toggleShooterPreset`, `loadShooterProfileByName`, `updateAutoTargetMode`, `updateMagicShooterPriority`, `updateMagicShooterCreatures`, `updateRuneShooterPriority`, `updateRuneShooterCreatures`.

### UI/assign/hotkeys
`updateButton`, `assignSpell`, `assignRune`, `assignPotionEvent`, `assignExerciseEvent`, `onDropSpell`, `manageHotkeys`, `toggle`, `show`, `hide`, `toggleNextWindow`, `toggleHelperTracker`, `showTerms`, `closeTerms`, `createHelperRules`, `botStatus`.

---

## Apêndice B — Achados importantes de risco técnico
- Existe referência de conexão para `onPartyMembersChange` sem implementação local visível no arquivo.
- `Helper.changeGold()` não tem binding identificado no código C++ rastreado.
- `onUpdateSpellArea` está implementado no helper, porém sem evidência de origem no parser/core analisado.

