# 09 — Modelo de Dados do Taskboard

## 1) Objetivo e escopo
Este documento define um **modelo relacional canônico** para o Taskboard (Bounty + Weekly), com foco em:

- tabelas, colunas e tipos;
- PK/FK, chaves únicas e índices;
- constraints de integridade (ex.: 1 profile por player, 3 bounty slots);
- timestamps em UTC e política de timezone para reset semanal;
- idempotência de reset (`week_key`/`cycle_id`);
- estratégia de migração e rollback;
- recuperação de dados inconsistentes.

Também faz o mapeamento para o padrão já usado em:

- `crystalserver/data/migrations/*`;
- `crystalserver/src/io/*`.

---

## 2) Mapeamento com o estado atual do projeto

### 2.1 Padrão de migrations já existente
O projeto aplica migrations numéricas incrementais (`N.lua`) e atualiza a versão após cada script com sucesso. Esse padrão está descrito em `crystalserver/data/migrations/README.md`.

Referências diretas úteis para o Taskboard:

- `32.lua`: criação de tabela com FK e índice (`player_wheeldata`).
- `33.lua`: criação de PK composta (`player_id`, `slot`).
- `56.lua`: manutenção de FKs/PKs e padronização de `ON DELETE CASCADE`.

### 2.2 Padrão de I/O já existente em C++
Mesmo que o Taskboard atual tenha forte presença em Lua, o padrão de persistência em C++ para dados por slot/jogador já existe (Prey/TaskHunt) e deve ser reutilizado:

- Load: `crystalserver/src/io/functions/iologindata_load_player.cpp`
  - leitura por `player_id`;
  - reconstrução de slots;
  - normalização de estado temporal (`disabled_time`/`OTSYS_TIME`).
- Save: `crystalserver/src/io/functions/iologindata_save_player.cpp`
  - estratégia `DELETE + INSERT` por tabela de subentidade do jogador;
  - serialização por slot.
- Transação: `crystalserver/src/io/iologindata.cpp`
  - `savePlayer` encapsulado em `DBTransaction::executeWithinTransaction`.

**Decisão arquitetural recomendada:** manter Taskboard com a mesma filosofia de consistência do `IOLoginData`: gravação transacional por jogador + constraints fortes no banco.

---

## 3) Modelo de dados proposto (Taskboard)

> Convenção: todas as tabelas em InnoDB, `utf8mb4`, e timestamps em UTC.

## 3.1 `player_taskboard_profile`
Estado geral do jogador no sistema.

| Coluna | Tipo | Null | Default | Observação |
|---|---|---:|---|---|
| `player_id` | `INT UNSIGNED` | Não | - | PK + FK para `players.id` |
| `selected_difficulty` | `TINYINT UNSIGNED` | Não | `0` | 0=beginner, 1=adept, 2=expert, 3=master |
| `weekly_expansion_unlocked` | `TINYINT(1)` | Não | `0` | Flag para 18 tarefas |
| `created_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` | auditoria |
| `updated_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` | auditoria |

**Chaves/índices**
- `PRIMARY KEY (player_id)`.
- `CONSTRAINT fk_taskboard_profile_player FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE`.

**Integridade**
- Garante **1 profile por player** via PK em `player_id`.

---

## 3.2 `player_taskboard_currencies`
Saldo de moedas do Taskboard.

| Coluna | Tipo | Null | Default |
|---|---|---:|---|
| `player_id` | `INT UNSIGNED` | Não | - |
| `bounty_points` | `INT UNSIGNED` | Não | `0` |
| `hunting_task_points` | `INT UNSIGNED` | Não | `0` |
| `reroll_tokens` | `SMALLINT UNSIGNED` | Não | `0` |
| `updated_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` |

**Chaves/índices**
- `PRIMARY KEY (player_id)`.
- FK para `players(id)` com cascade.

**Integridade**
- `CHECK (reroll_tokens <= 10)` (se versão MySQL/MariaDB não aplicar `CHECK`, validar no app + trigger opcional).

---

## 3.3 `player_bounty_slots`
Slots diários de bounty por jogador.

| Coluna | Tipo | Null | Default | Observação |
|---|---|---:|---|---|
| `player_id` | `INT UNSIGNED` | Não | - | |
| `slot_id` | `TINYINT UNSIGNED` | Não | - | 1..3 |
| `state` | `TINYINT UNSIGNED` | Não | `0` | idle/active/completed/... |
| `monster_race_id` | `SMALLINT UNSIGNED` | Sim | `NULL` | task atual |
| `required_kills` | `SMALLINT UNSIGNED` | Não | `0` | meta |
| `current_kills` | `SMALLINT UNSIGNED` | Não | `0` | progresso |
| `tier` | `TINYINT UNSIGNED` | Não | `0` | beginner..master |
| `reroll_count` | `SMALLINT UNSIGNED` | Não | `0` | controle de uso |
| `free_reroll_at` | `DATETIME(3)` | Sim | `NULL` | timestamp UTC |
| `expires_at` | `DATETIME(3)` | Sim | `NULL` | rotação/expiração |
| `updated_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` | |

**Chaves/índices**
- `PRIMARY KEY (player_id, slot_id)`.
- `INDEX idx_bounty_player_state (player_id, state)`.
- `INDEX idx_bounty_expires_at (expires_at)`.
- FK `player_id` -> `players.id` (`ON DELETE CASCADE`).

**Integridade**
- **3 bounty slots**: `CHECK (slot_id BETWEEN 1 AND 3)` + seed inicial obrigatória dos 3 slots por jogador.
- `CHECK (current_kills <= required_kills)`.

---

## 3.4 `player_weekly_cycles`
Representa um ciclo semanal por jogador (snapshot da semana).

| Coluna | Tipo | Null | Default | Observação |
|---|---|---:|---|---|
| `cycle_id` | `BIGINT UNSIGNED` | Não | AUTO_INCREMENT | identificador técnico |
| `player_id` | `INT UNSIGNED` | Não | - | |
| `week_key` | `CHAR(8)` | Não | - | `YYYYWW` em UTC (ISO week) |
| `difficulty` | `TINYINT UNSIGNED` | Não | `0` | dificuldade da semana |
| `reset_at` | `DATETIME(3)` | Não | - | instante do reset aplicado |
| `created_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` | |
| `updated_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` | |

**Chaves/índices**
- `PRIMARY KEY (cycle_id)`.
- `UNIQUE KEY uq_weekly_player_week (player_id, week_key)`.
- `INDEX idx_weekly_week_key (week_key)`.
- FK para `players(id)` com cascade.

**Integridade / Idempotência base**
- A chave única (`player_id`, `week_key`) impede duplicar reset para a mesma semana do mesmo jogador.

---

## 3.5 `player_weekly_tasks`
Tarefas semanais vinculadas ao ciclo (`cycle_id`).

| Coluna | Tipo | Null | Default |
|---|---|---:|---|
| `cycle_id` | `BIGINT UNSIGNED` | Não | - |
| `task_id` | `SMALLINT UNSIGNED` | Não | - |
| `task_type` | `TINYINT UNSIGNED` | Não | `0` |
| `slot_order` | `TINYINT UNSIGNED` | Não | `0` |
| `target_id` | `INT UNSIGNED` | Sim | `NULL` |
| `required_amount` | `INT UNSIGNED` | Não | `0` |
| `current_amount` | `INT UNSIGNED` | Não | `0` |
| `is_completed` | `TINYINT(1)` | Não | `0` |
| `claimed_at` | `DATETIME(3)` | Sim | `NULL` |
| `updated_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` |

**Chaves/índices**
- `PRIMARY KEY (cycle_id, task_id)`.
- `UNIQUE KEY uq_weekly_slot (cycle_id, task_type, slot_order)`.
- `INDEX idx_weekly_completed (cycle_id, is_completed)`.
- FK `cycle_id` -> `player_weekly_cycles(cycle_id)` `ON DELETE CASCADE`.

**Integridade**
- `CHECK (current_amount <= required_amount)`.

---

## 3.6 `taskboard_weekly_reset_log`
Log global para idempotência operacional e auditoria do reset.

| Coluna | Tipo | Null | Default |
|---|---|---:|---|
| `week_key` | `CHAR(8)` | Não | - |
| `reset_scope` | `VARCHAR(32)` | Não | `'global'` |
| `started_at` | `DATETIME(3)` | Não | `UTC_TIMESTAMP(3)` |
| `finished_at` | `DATETIME(3)` | Sim | `NULL` |
| `status` | `TINYINT UNSIGNED` | Não | `0` |
| `details` | `TEXT` | Sim | `NULL` |

**Chaves/índices**
- `PRIMARY KEY (week_key, reset_scope)`.
- `INDEX idx_reset_status (status, started_at)`.

**Integridade / Idempotência operacional**
- Um reset semanal só deve “ganhar” se conseguir inserir `(week_key, reset_scope)`.
- Em nova execução para a mesma semana, inserir falha (duplicate key) e processo deve abortar com segurança.

---

## 4) Política de timezone e timestamps (weekly reset)

1. **Fonte de verdade temporal**: UTC no servidor.
2. **week_key**: derivado em UTC (`ISO year + ISO week`). Ex.: `202607`.
3. **Reset semanal**: segunda-feira 00:00 UTC.
4. **Persistência**: `DATETIME(3)` sempre em UTC; não salvar horário local.
5. **Exibição no cliente**: converter UTC -> timezone local só na camada de apresentação.

---

## 5) Política de idempotência (`week_key`/`cycle_id`)

### 5.1 Regras
- `taskboard_weekly_reset_log` controla execução global por `week_key`.
- `player_weekly_cycles` controla aplicação por jogador com `UNIQUE(player_id, week_key)`.
- `cycle_id` é o identificador de referência para todas as tasks da semana.

### 5.2 Fluxo seguro (transacional)
1. Iniciar transação.
2. Tentar `INSERT` em `taskboard_weekly_reset_log` (`status=running`).
3. Para cada jogador elegível:
   - `INSERT ... ON DUPLICATE KEY UPDATE` em `player_weekly_cycles`;
   - recriar `player_weekly_tasks` vinculadas ao `cycle_id` vigente;
   - nunca criar segundo ciclo para mesma `week_key`.
4. Finalizar log com `status=done`, `finished_at`.
5. Commit.

Se ocorrer falha intermediária: rollback e execução posterior reaproveita idempotência por chaves.

---

## 6) Estratégia de migração e rollback

## 6.1 Sequenciamento sugerido em `crystalserver/data/migrations/*`
- `61.lua`: criar tabelas base (`player_taskboard_profile`, `player_taskboard_currencies`).
- `62.lua`: criar `player_bounty_slots` + PK/FK/índices/checks.
- `63.lua`: criar `player_weekly_cycles`, `player_weekly_tasks`, `taskboard_weekly_reset_log`.
- `64.lua`: backfill inicial (seed 3 slots por player existente; profile/currencies padrão).
- `65.lua`: adicionar constraints mais rígidas após backfill (`NOT NULL`, `UNIQUE`, checks finais).

> Modelo segue o estilo já visto em `32.lua`, `33.lua`, `56.lua`: criação incremental, ajuste de constraints, e reforço de cascade.

## 6.2 Rollback
- Rollback por versão com scripts reversos manuais (ex.: `65_rollback.sql` interno de operação) **ou** restore de snapshot.
- Ordem de rollback:
  1. remover FKs dependentes;
  2. remover índices/constraints novas;
  3. dropar tabelas novas (da mais dependente para a base);
  4. restaurar backup lógico se necessário.

## 6.3 Princípios operacionais
- Sempre executar migrations em janela controlada.
- Backup lógico + validação pós-migração.
- Em produção, preferir rollout em duas fases:
  - fase A: schema compatível;
  - fase B: ativar escrita/leitura no app.

---

## 7) Mapeamento com `crystalserver/src/io/*`

## 7.1 Arquivos-alvo para integração
- `crystalserver/src/io/functions/iologindata_load_player.cpp`
  - incluir `loadPlayerTaskboardProfile`, `loadPlayerTaskboardBountySlots`, `loadPlayerTaskboardWeeklyCycle`.
- `crystalserver/src/io/functions/iologindata_save_player.cpp`
  - incluir blocos de persistência Taskboard por tabela, em mesma transação do player.
- `crystalserver/src/io/iologindata.cpp`
  - manter save encapsulado em `DBTransaction::executeWithinTransaction`.

## 7.2 Padrão de implementação recomendado
- Reutilizar padrão Prey/TaskHunt:
  - `SELECT * FROM ... WHERE player_id = ?` no load;
  - `DELETE FROM ... WHERE player_id = ?` + `INSERT` por slot/task no save;
  - logs de warning por falha parcial + abort transacional.
- Weekly (por `cycle_id`) deve ser gravado após garantir existência/consistência do ciclo da semana.

---

## 8) Casos de recuperação de dados inconsistentes

## 8.1 Profile ausente
**Sintoma:** jogador com linhas em slots/moedas sem profile.

**Correção:** upsert em `player_taskboard_profile` para todos os `player_id` órfãos.

## 8.2 Mais de 3 bounty slots por jogador
**Sintoma:** duplicidade de slot ou slot fora de faixa.

**Correção:**
1. remover registros `slot_id NOT BETWEEN 1 AND 3`;
2. deduplicar por `(player_id, slot_id)` mantendo `updated_at` mais recente;
3. recriar PK composta.

## 8.3 Progresso inválido (`current > required`)
**Correção:** clamp para `current = required`; marcar `is_completed = 1` quando aplicável.

## 8.4 Duplicidade de ciclos semanais
**Sintoma:** múltiplos ciclos para mesmo `(player_id, week_key)`.

**Correção:**
1. eleger ciclo canônico (maior `updated_at`);
2. remapear tasks para o canônico;
3. remover ciclos excedentes;
4. aplicar `UNIQUE(player_id, week_key)`.

## 8.5 Reset parcialmente aplicado
**Sintoma:** log em `running` sem `finished_at` após crash.

**Correção:**
- job de reconciliação identifica logs “stale” por timeout;
- reexecuta reset da `week_key` com idempotência por chaves únicas.

## 8.6 Timezone inconsistente
**Sintoma:** registros gravados em hora local.

**Correção:**
- normalização para UTC;
- ajuste do pipeline de escrita para sempre usar UTC no backend.

---

## 9) Checklist de validação pós-implantação

1. `COUNT(*)` de profiles == total de players elegíveis.
2. Todos os jogadores com exatamente 3 slots de bounty.
3. Sem violação de `(player_id, week_key)` em ciclos.
4. Sem tasks com `current_amount > required_amount`.
5. Reset da semana atual executa 1x (idempotente) mesmo com reprocessamento.

---

## 10) Resumo executivo
- O modelo proposto reforça integridade com PK/FK/UNIQUE e checks de domínio.
- `week_key` + `cycle_id` tornam o reset semanal reentrante e auditável.
- O plano de migração segue o padrão já estabelecido em `crystalserver/data/migrations/*`.
- A integração em `crystalserver/src/io/*` pode seguir o mesmo padrão robusto já utilizado por Prey/TaskHunt.
