# CrystalServer + OTClient Comprehensive Technical Analysis

## Scope and Method
This assessment covers:
- `crystalserver` (Open Tibia server emulator)
- `otclient` (Open Tibia client)

It is based on source-level inspection of build manifests, networking code, protocol code, gameplay module declarations, scheduler/dispatcher internals, and security-relevant authentication logic.

---

## 1) Codebase Structure & Organization

### CrystalServer (server)

#### Top-level architecture
- Build and dependency management via CMake + vcpkg manifest mode (`CMakeLists.txt`, `vcpkg.json`).
- Core source in `src/` with feature-oriented submodules:
  - `account/` (account/session/auth)
  - `config/` (runtime configuration)
  - `creatures/` (players, monsters, NPCs, combat-adjacent entities)
  - `database/` + `io/` (DB connectivity + persistence/load layers)
  - `game/` (game loop/state/rules)
  - `items/`, `map/`, `lua/`, `server/`, `security/`, `utils/`
- Data-driven runtime content in `data/`, `data-global/`, `data-crystal/` (scripts, NPC, monsters, raids, world assets).
- Tests under `tests/unit` and `tests/integration`.

#### Component relationship model
- `main.cpp` boots DI and runs `CrystalServer`.
- `crystalserver.cpp` orchestrates startup pipeline: config load -> DB init -> module load -> map load -> game state transition -> service start.
- `server/` owns acceptors, connection lifecycle, protocol dispatch and packet IO.
- `game/` is the authoritative simulation domain (movement, inventory ops, money, guild systems, etc.).
- `lua/` and `data/scripts` extend behavior without recompilation.

#### Reusable/modular patterns
- Strong modular CMake decomposition (`add_subdirectory` per domain).
- Dependency Injection container (`lib/di`) centralizes construction and singleton-like ownership.
- Scheduler/dispatcher separates serial and parallel task groups, reusable across gameplay subsystems.

#### Improvement opportunities
- Separate wire-protocol handlers from business logic even further (ProtocolGame is large); move opcode-specific handlers into strategy/map registries.
- Add “domain service interfaces” to reduce direct global singleton use (`g_game()`, `g_dispatcher()`) and improve test isolation.
- Add architectural decision docs for concurrency model and safety invariants.

---

### OTClient (client)

#### Top-level architecture
- CMake + vcpkg-based build; optional Android and WASM paths.
- Core code in `src/` split into:
  - `framework/` (platform abstraction, net, rendering, UI primitives, Lua runtime, async/event dispatch)
  - `client/` (game protocol parser/sender, map, creatures, local player state)
  - `protobuf/` (appearance data schema)
- UX/gameplay features implemented as Lua modules under `modules/` and loaded by priority.

#### Component relationship model
- `init.lua` is the boot coordinator:
  - resource paths
  - settings load
  - module discovery/autoload
  - staged module initialization (`corelib`, `gamelib`, `modulelib`, then client/game modules)
- C++ protocol/network core emits into game/UI systems and Lua module layer.
- `modules/game_interface/interface.otmod` then composes feature modules (walk, minimap, inventory, questlog, market, npc trade, player trade, etc.).

#### Reusable/modular patterns
- Lua module system is highly reusable and extension-friendly.
- Clear split between generic framework and Tibia-specific client logic.
- `.otmod` descriptors offer declarative dependency/load sequencing.

#### Improvement opportunities
- Formalize module API contracts (versioned interfaces) to avoid breakage in large mod ecosystems.
- Create dependency graph tooling for `.otmod` modules to detect cyclic/implicit dependencies.
- Increase typed boundaries between Lua and C++ (schema validation at bridge points).

---

## 2) Dependencies & Libraries

## CrystalServer dependency inventory
From vcpkg + CMake:
- Core runtime: `asio`, `Threads`, `mio`
- DB/data: `libmariadb` (and MySQL abstraction), `protobuf`, `pugixml`, `nlohmann-json`
- Security/auth: `argon2`
- Compression/networking: `zlib`, `curl`
- Infrastructure/utilities: `abseil`, `spdlog`, `magic-enum`, `parallel-hashmap`, `eventpp`, `boost-locale`, `bshoshany-thread-pool`, `atomic-queue`, `bext-di`
- Optional observability: `opentelemetry-cpp` (+ prometheus exporter)
- Big-int backend: `gmp` (Linux) / `mpir` (Windows)

## OTClient dependency inventory
From vcpkg + CMake:
- Net/crypto/http: `asio`, `openssl`, `cpp-httplib`, `cppcodec`
- Asset/data: `protobuf`, `pugixml`, `nlohmann-json`, `liblzma`, `physfs`, `zlib`
- Audio: `openal-soft`, `libogg`, `libvorbis`
- Graphics/font: `opengl`, `glew`, `angle` (Windows), `freetype`
- Scripting/runtime: `luajit` (non-Android/WASM), `inih`, `utfcpp`
- Misc: `parallel-hashmap`, `stduuid`, `fmt`, `discord-rpc`, `libobfuscate`
- Tests: `gtest`

## Dependency risk and modernization guidance
- **Immediate security concern**: OTClient HTTP login path disables TLS certificate verification (`enable_server_certificate_verification(false)`), enabling MITM risk in hostile networks.
- Both projects pin vcpkg baselines, which is good for reproducibility, but should be paired with routine security scanning (OSV, GH Dependabot, Snyk, Trivy SBOM).
- Consider replacing legacy/low-maintenance libraries when feasible (e.g., evaluate `cpp-httplib` operational risk vs mature alternatives with stricter TLS defaults).
- Maintain quarterly dependency review cadence with CI gate for known CVEs.

---

## 3) System Architecture & Communication

### Server/client protocol mechanics
- Server uses TCP sockets (asio) with per-connection state and async reads/writes.
- Connection pipeline:
  - accept socket
  - optional proxy-identification preamble
  - read header + payload
  - protocol routing by protocol identifier
- Protocol layer supports:
  - RSA bootstrap decrypt for initial key exchange
  - XTEA payload encryption
  - checksum modes (adler32 or sequence-based)
  - optional packet compression signaling

### Client network protocol mechanics
- Client protocol stack supports proxy mode or direct connection.
- Packet send pipeline:
  - optional padding (newer protocol)
  - XTEA encrypt
  - checksum or sequence tagging
  - size header write
- Receive pipeline validates size, checksum/sequence, decrypts, optional decompresses, then dispatches parse.

### Data formats in use
- Binary proprietary game protocol over TCP (primary real-time path).
- JSON over HTTP(S) for account/login workflows in OTClient HTTP login path.
- Protobuf schemas for appearance/type metadata in both projects.
- XML/OTML/Lua data-driven configs and scripts for assets/rules/UI behavior.

### Synchronization and real-time model
- CrystalServer dispatcher model combines serial task groups (ordering-sensitive gameplay logic) and parallel groups for scalable work distribution; scheduled tasks are merged and executed with cycle support.
- OTClient uses async dispatcher thread pool sized from hardware concurrency with dedicated comments for workload lanes (map/UI/render-adjacent tasks).

---

## 4) Gameplay Logic & Features Mapping

### Server-side responsibilities (authoritative)
- Core game domain includes movement, item transfer/add/remove, money/economy operations, teleportation, creature speech, guild operations, highscores, world lighting/day cycle, map loading, and player/monster/NPC lifecycle.
- Startup pipeline includes market expiration/stat refresh and house rent/depot transitions.
- Persistence and domain-specific IO layers include market, guild, bestiary/bosstiary, wheel/prey, login data.

### Client-side responsibilities (presentation + interaction)
- `game_interface` module orchestrates feature modules:
  - movement/walk
  - minimap
  - inventory/containers
  - hotkeys/action bar
  - questlog
  - NPC trade + player trade
  - battle, outfit, skills, market, cooldown, modal dialogs
  - newer systems like forge/store/cyclopedia/rewardwall
- This maps to a broad and modular front-end feature surface while server remains authoritative for state changes.

### Data flow model example (movement/combat style interaction)
1. User action in Lua module/UI (e.g., walk/hotkey).
2. Client protocol sender serializes and transmits packet.
3. Server connection/protocol validates checksum/encryption/session/state.
4. Server `Game` applies rules and state mutation.
5. Server emits updates to relevant spectators/clients.
6. Client parser updates local map/creature/UI projections.

---

## 5) Security Considerations

## Implemented controls
- Server authentication supports Argon2 and fallback SHA1 compatibility path.
- Session-expiry checks exist for session auth mode.
- Login/game packets use RSA bootstrap + XTEA + checksum/sequence checks.
- Server has packet-per-second limiting (`maxPacketsPerSecond`) and IP/ban gating.

## Critical / high-risk issues
1. **TLS verification disabled in OTClient HTTP login** (critical): permits credential/session theft via MITM.
2. **Server sends session key as `accountDescriptor + "\n" + password` in login response**; risky if transport endpoint is intercepted or client compromised.
3. **Legacy SHA1 password fallback** retains weaker hash compatibility surface.
4. **Potential sensitive logging**: failed auth logs include password hash material in `Account::authenticatePassword` failure path.

## Hardening recommendations
- Enforce certificate validation in client; add pinning option and explicit user-visible warning for insecure mode.
- Remove plaintext password-in-session-key flow; use short-lived signed tokens (JWT/PASETO-like opaque tokens with rotation).
- Migrate accounts to Argon2-only with staged rehash-on-login; deprecate SHA1 path.
- Sanitize security logs to avoid credential/hash leakage.
- Add server-side anti-abuse controls: IP reputation/rate-limits per endpoint, SYN protection at infrastructure edge, optional challenge throttling.

---

## 6) Performance & Scalability

### Strengths
- Server dispatcher has explicit serial/parallel partitioning and scheduled task handling.
- Client advertises multi-threading model and has thread-pool-backed async dispatcher.
- Packet compression support can reduce bandwidth use.

### Bottlenecks / risk areas
- Large monolithic protocol handlers can become CPU hotspots and maintenance bottlenecks.
- Global singleton-heavy access patterns may hinder sharding and deterministic simulation testing.
- DB-dependent operations risk contention under high concurrency (depends on query quality/indices).

### Recommendations
- Instrument all hot paths with metrics (latency percentiles per opcode, queue depths, DB timings).
- Add load tests: simulated login storms, movement floods, market operations, scripted combat events.
- Optimize DB with query plans + proper indices for account/player/session/market paths.
- Evaluate actor-style partitioning by map region/zone for larger player counts.
- Introduce backpressure and graceful degradation under overload (queue caps, partial feature shedding).

---

## 7) Code Quality & Best Practices

### Observations
- Good modular split by domain in both projects.
- Strong extensibility via Lua modules/scripts and data files.
- Error handling exists at many IO boundaries (socket close, startup exceptions), but style is inconsistent.

### Refactor opportunities
- Decompose very large source files (especially protocol parsing/sending and game logic accumulators).
- Standardize error-handling strategy (typed errors/result wrappers for expected failures).
- Add architecture docs and sequence diagrams for onboarding and safer feature additions.
- Introduce stricter static analysis profile in CI (`clang-tidy`, sanitizers in nightly builds).

---

## 8) Future Integration & Expansion Strategy

### High-impact feature integration candidates
- **External identity/auth**: OAuth2/OIDC gateway for web-account + launcher ecosystem.
- **Commerce**: secure purchase pipeline (web backend) with signed server-consumable receipts.
- **Cross-platform telemetry**: OpenTelemetry traces + metrics for client/server correlation.
- **Cross-play/session continuity**: account session broker service and robust token lifecycle.

### Suggested architecture path
- Keep game server deterministic and authoritative.
- Move account/commerce/social into separate services with signed contracts.
- Add event bus (Kafka/NATS/RabbitMQ) for non-critical async workloads (analytics, audit logs, notifications).

---

## 9) Error Handling & Operational Resilience

### Current strengths
- Server startup has guarded initialization and explicit failure path.
- Connection management includes timeout timers, read/write error handling, and close safeguards.
- Client HTTP login path propagates success/failure back to Lua/UI callbacks.

### Gaps
- Some catch-all blocks and generic messages hide actionable diagnostics.
- Security-sensitive failures can leak data (logging concern above).
- Missing uniform retry/backoff policies in some network paths.

### Improvements
- Introduce structured error codes and correlation IDs across login/game/auth flows.
- Add chaos/fault-injection tests for DB outages, packet corruption bursts, and service restarts.
- Build runbooks and SLOs (login success rate, packet latency, crash-free runtime).

---

## 10) Execution Readiness Plan (for future tasks)
This checklist is now operationalized in repository artifacts:
- `docs/deployment/execution-playbook.md`
- `docs/templates/TASK_EXECUTION_TEMPLATE.md`

Operational steps remain:
1. **Scope lock**: define feature boundaries + protocol impact + migration plan.
2. **Design review**: sequence diagram + failure modes + security impact.
3. **Implementation**:
   - keep server authoritative,
   - preserve backward compatibility gates,
   - add feature flags.
4. **Validation**:
   - unit/integration tests,
   - load + soak tests,
   - security checks.
5. **Rollout**:
   - staged deploy,
   - metrics dashboards + alerting,
   - rollback criteria.

This process enables high confidence delivery for complex feature requests while preserving stability, security, and extensibility.

---

## Priority Action List
1. Fix OTClient TLS verification behavior immediately.
2. Replace plaintext password session-key flow with signed short-lived session tokens.
3. Remove SHA1 fallback once migration complete.
4. Add protocol- and DB-level performance telemetry and load tests.
5. Split oversized protocol/game files into maintainable handlers.
6. Introduce stricter CI security + dependency scanning pipeline.
