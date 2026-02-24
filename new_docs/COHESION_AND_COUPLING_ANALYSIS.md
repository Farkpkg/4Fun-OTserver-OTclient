# COHESION_AND_COUPLING_ANALYSIS

## Escala usada
- Coesão: **Alta / Média / Baixa** (foco funcional interno).
- Acoplamento externo: **Alto / Médio / Baixo** (dependência com outros sistemas).
- Risco de cascata: probabilidade de uma mudança local se propagar de forma sistêmica.

---

## Análise por subsistema

### 1) Server Gameplay Core (`crystalserver/src/game`, `src/creatures`)
- **Coesão interna**: Alta (regras de domínio concentradas).
- **Acoplamento externo**: Alto (protocol, IO, scheduler, scripts).
- **Risco de cascata**: Alto.
- **Risco de regressão invisível**: Alto (efeitos emergentes em combate/movimento/economia).

### 2) Camada de protocolo (server/client)
- **Coesão interna**: Alta (serialização/parsing).
- **Acoplamento externo**: Alto (depende da semântica do domínio e da UI).
- **Risco de cascata**: Alto.
- **Risco de regressão invisível**: Alto (offset de pacote, campo condicional, versão).

### 3) Persistência (`database`, `io`, migrations)
- **Coesão interna**: Média-Alta (responsabilidade clara, porém distribuída).
- **Acoplamento externo**: Alto (todo estado durável converge aqui).
- **Risco de cascata**: Alto.
- **Risco de regressão invisível**: Alto (quebras só aparecem em load/save real).

### 4) Lua runtime e scripts (server)
- **Coesão interna**: Média (múltiplos domínios no mesmo mecanismo).
- **Acoplamento externo**: Médio-Alto (depende de bindings e eventos C++).
- **Risco de cascata**: Médio-Alto.
- **Risco de regressão invisível**: Alto (scripts quebram em runtime, não em compile-time).

### 5) Client core (`otclient/src/client` + `framework`)
- **Coesão interna**: Média-Alta.
- **Acoplamento externo**: Médio-Alto (protocolo, módulos Lua, assets).
- **Risco de cascata**: Médio.
- **Risco de regressão invisível**: Médio-Alto (problemas de UX/estado local).

### 6) Módulos Lua/OTUI do cliente
- **Coesão interna**: Média (por módulo varia muito).
- **Acoplamento externo**: Médio (g_game, sinais, widgets).
- **Risco de cascata**: Médio.
- **Risco de regressão invisível**: Médio (fluxos de UI condicionais).

---

## Hotspots estruturais (vigilância máxima)
1. `protocolgame.cpp` (server) e `protocolgameparse.cpp`/`protocolgamesend.cpp` (client).
2. `iologindata*` + `databasetasks.*` + migrations.
3. Sequência de startup em `crystalserver.cpp`.
4. Boundaries C++/Lua em ambos os lados.

---

## Indicadores de baixa coesão (para detectar cedo)
- Arquivo com múltiplos motivos de mudança (protocolo + regra de negócio + persistência no mesmo local).
- Funções que manipulam mais de um domínio sem interface intermediária.
- Repetição de parsing/serialização em áreas não-canônicas.

## Indicadores de acoplamento excessivo
- Mudança local exigindo alterações em >3 subsistemas não correlatos.
- Dependência de ordem implícita entre módulos sem contrato formal.
- Reuso por cópia (copy-paste) de lógica de protocolo/persistência.

---

## Risco de cascata estrutural (mapa rápido)
- **Muito alto**: protocolo, persistência de player, bootstrap server.
- **Alto**: scheduler/eventos de gameplay.
- **Médio**: bindings Lua e módulos client.
- **Baixo**: assets visuais isolados.

## Risco de regressão invisível
- Maior em sistemas sem cobertura estática forte: scripts Lua, gates por versão e fluxos de reconexão.

---

## Exigências de vigilância da IA
- Toda mudança em hotspot deve executar análise de impacto em cadeia.
- Toda mudança de payload deve produzir mapa de simetria client/server.
- Toda mudança persistente deve mapear ciclo completo: create/read/update/save/migration.
