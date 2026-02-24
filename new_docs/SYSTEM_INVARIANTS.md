# SYSTEM_INVARIANTS

## Objetivo
Formalizar invariantes não negociáveis do ecossistema `crystalserver` (autoritativo) + `otclient` (representacional), para permitir validação automática de consistência arquitetural antes de mudanças.

## Escopo formal
- Domínios cobertos: protocolo, estado de jogo, persistência, sincronização, scriptability Lua, inicialização.
- Nível: invariantes de sistema (não de feature local).
- Regra de conformidade: qualquer PR que viole um invariante deve ser rejeitado ou acompanhado de plano explícito de migração/versionamento.

---

## INV-01 — Autoridade única de estado de gameplay
**Definição formal**  
Para qualquer entidade persistente ou volátil de gameplay (`Player`, `Creature`, `Item`, `Map state`), a verdade canônica do estado é calculada no servidor; o cliente apenas renderiza/projeta e envia intenções.

**Por que existe**  
Evita divergência de estado, cheating e regressões por decisões distribuídas.

**Se violado, quebra**
- Consistência de combate/movimento.
- Reprodutibilidade de bugs.
- Segurança econômica e anti-cheat.

**Arquivos/superfícies dependentes**
- `crystalserver/src/game/`
- `crystalserver/src/creatures/`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `otclient/src/client/game.cpp`
- `otclient/src/client/protocolgameparse.cpp`

---

## INV-02 — Simetria de contrato de protocolo
**Definição formal**  
Todo opcode, payload e semântica introduzidos/alterados no lado servidor devem ter representação compatível no cliente (parse/send), sob a mesma versão/feature-gate.

**Por que existe**  
Cliente e servidor evoluem separadamente; sem simetria, a conexão degrada com falhas silenciosas.

**Se violado, quebra**
- Handshake/login.
- Interpretação de pacotes (desalinhamento binário).
- Funcionalidades com opcodes estendidos.

**Arquivos/superfícies dependentes**
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/server/network/protocol/protocollogin.cpp`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/client/protocolcodes.*`
- `new_docs/network/NETWORK_SURFACE_MAP.md`

---

## INV-03 — Ordem de bootstrap determinística do servidor
**Definição formal**  
A sequência `loadConfigLua -> initializeDatabase -> loadModules -> setWorldType -> loadMaps -> g_game.start` deve permanecer topologicamente válida (dependências prontas antes do consumo).

**Por que existe**  
Cada etapa inicializa pré-condições para a próxima; ordem incorreta gera estado parcial.

**Se violado, quebra**
- Carregamento de módulos/scripts.
- Integridade de mapa e world state.
- Disponibilidade de serviços de rede.

**Arquivos/superfícies dependentes**
- `crystalserver/src/crystalserver.cpp`
- `crystalserver/src/game/game.*`
- `crystalserver/src/database/`
- `crystalserver/src/lua/modules/`

---

## INV-04 — Persistência com trilha de evolução
**Definição formal**  
Mudanças de estrutura de dados persistentes exigem: schema/migration aplicável + camada IO compatível + leitura/escrita consistente.

**Por que existe**  
Sem evolução rastreável, upgrades quebram em produção e dados ficam órfãos.

**Se violado, quebra**
- Upgrade de versão.
- Carga/salvamento de jogador.
- Integridade referencial lógica.

**Arquivos/superfícies dependentes**
- `crystalserver/schema.sql`
- `crystalserver/data/migrations/*.lua`
- `crystalserver/src/database/`
- `crystalserver/src/io/iologindata*`
- `new_docs/database/DATABASE_SURFACE_MAP.md`

---

## INV-05 — Compatibilidade criptográfica de sessão
**Definição formal**  
Negociação de RSA/XTEA/checksum/sequencing deve ocorrer em ordem compatível entre cliente e servidor para estabelecer canal confiável.

**Por que existe**  
Sessão de jogo depende de handshake seguro e framing consistente.

**Se violado, quebra**
- Login/autenticação.
- Decriptação de payload.
- Conexões intermitentes difíceis de diagnosticar.

**Arquivos/superfícies dependentes**
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/security/`
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/framework/net/`

---

## INV-06 — Boundaries oficiais C++ ↔ Lua
**Definição formal**  
A integração runtime/script deve ocorrer exclusivamente pelos bindings/módulos previstos; lógica de domínio não pode ser duplicada em canal paralelo fora da superfície oficial.

**Por que existe**  
Preserva previsibilidade de execução e auditabilidade de side-effects.

**Se violado, quebra**
- Debugar eventos (efeitos duplicados).
- Governança de mudança (hotfixes inconsistentes).

**Arquivos/superfícies dependentes**
- `crystalserver/src/lua/functions/`
- `crystalserver/src/lua/scripts/`
- `otclient/src/client/luafunctions.cpp`
- `otclient/src/framework/luaengine/`
- `otclient/modules/`

---

## INV-07 — Atomicidade de evento com persistência diferida controlada
**Definição formal**  
Eventos de gameplay alteram estado em memória autoritativa e persistência ocorre por pontos definidos (save/logout/checkpoint), sem misturar múltiplas fontes de verdade concorrentes.

**Por que existe**  
Mantém throughput do loop e evita race de escrita no banco.

**Se violado, quebra**
- Consistência de progresso do personagem.
- Reentrada de eventos e duplicidade de transação.

**Arquivos/superfícies dependentes**
- `crystalserver/src/game/scheduling/`
- `crystalserver/src/io/iologindata*`
- `crystalserver/src/database/databasetasks.*`

---

## INV-08 — Feature-gating explícito para variações de protocolo
**Definição formal**  
Diferenças por versão (`clientVersion`, flags `Game*`) devem ser condicionadas por gate explícito; nunca por heurística implícita.

**Por que existe**  
Permite coexistência de clientes e transição de versão sem efeitos colaterais invisíveis.

**Se violado, quebra**
- Retrocompatibilidade.
- Interpretação condicional de campos.

**Arquivos/superfícies dependentes**
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/protocolcodes.*`
- `crystalserver/src/server/network/protocol/`

---

## INV-09 — Integridade do ciclo request->efeito->feedback
**Definição formal**  
Toda ação iniciada no cliente deve ter rota observável até o efeito no servidor e retorno/estado resultante no cliente.

**Por que existe**  
Sem ciclo fechado, surgem “ações fantasmas” (UI aparenta sucesso sem confirmação real).

**Se violado, quebra**
- UX operacional.
- Diagnóstico de falhas de gameplay.

**Arquivos/superfícies dependentes**
- `otclient/src/client/game.cpp`
- `otclient/src/client/protocolgamesend.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `otclient/src/client/protocolgameparse.cpp`

---

## INV-10 — Não existência de fluxo implícito crítico
**Definição formal**  
Qualquer fluxo estrutural crítico (login, load, save, migração, opcode) deve ter ponto de entrada explícito em arquivo rastreável; fluxos críticos não podem depender de efeito lateral não documentado.

**Por que existe**  
Permite auditoria automática e operação multi-IA sem ambiguidade.

**Se violado, quebra**
- Capacidade de prever impacto.
- Revisão arquitetural confiável.

**Arquivos/superfícies dependentes**
- `new_docs/PROJECT_FULL_MAP.md`
- `new_docs/CHANGE_IMPACT_PROTOCOL.md`
- `new_docs/network/NETWORK_SURFACE_MAP.md`
- `new_docs/database/DATABASE_SURFACE_MAP.md`

---

## Regras de verificação automática (mínimas)
1. **Diff scanner de protocolo**: alteração em `protocolgame*` exige alteração correlata client/server no mesmo PR ou justificativa explícita.
2. **Diff scanner de persistência**: alteração em `src/io/` ou modelos persistidos exige migration/schema impact map.
3. **Bootstrap guard**: mudanças em `crystalserver.cpp` não podem inverter dependências da sequência de startup.
4. **Gate guard**: adição de campo condicional em pacote deve declarar gate/versionamento.
