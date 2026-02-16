---
title: Readme Md
tags: [sources]
date: 2026-02-16
---

# 4Fun OTServer + OTClient

README técnico central do projeto, consolidado a partir da documentação em `docs/`.

> **Fonte de verdade:** este README passa a ser a referência principal de arquitetura, fluxo e operação para desenvolvimento cotidiano.

---

## Escopo oficial de alterações (OBRIGATÓRIO)

### ✅ Pastas autorizadas para mudanças de código
- `crystalserver/`
- `otclient/`

### 🚫 Pastas fora de escopo para alteração
Todas as demais pastas na raiz **não devem ser alteradas** durante desenvolvimento de features/correções de produto.
Essas pastas devem ser tratadas como **auxiliares/temporárias** para consulta técnica, análise e apoio operacional.

---

## Visão geral da arquitetura

O projeto é dividido em dois blocos principais, conectados por protocolo de rede:

1. **CrystalServer (backend autoritativo)**
2. **OTClient (camada de apresentação/interação)**

Princípios arquiteturais consolidados:
- Servidor é autoridade absoluta para estado e regras de gameplay.
- Cliente nunca deve ser fonte única de verdade para regras críticas.
- Compatibilidade cliente-servidor deve ser preservada em toda entrega.
- UI deve ficar em módulos (`modules/`, OTUI, Lua/JS), não hardcodada no core C++.

---

## Responsabilidades por componente

## CrystalServer (`crystalserver/`)
Responsável por:
- Estado global do jogo e ciclo principal.
- Regras de gameplay (combate, itens, progressão, validações).
- Persistência (MySQL/MariaDB) e integração com scripts Lua.
- Segurança/autorização e validações de protocolo.
- Emissão de eventos/sincronização para o cliente.

Camadas (alto nível):
- Core C++ (`src/`)
- Scripting Lua (`data/scripts/`, `data/events/`)
- Database/I/O (`src/database`, `src/io`)
- Network/Protocol (`src/server/network/protocol`)

## OTClient (`otclient/`)
Responsável por:
- Renderização, interface, UX e interação de input.
- Parsing/envio de mensagens de protocolo.
- Organização de features em módulos (`modules/`) e OTUI.
- Atualização visual a partir do estado autorizado pelo servidor.

Camadas (alto nível):
- Framework (`src/framework/`)
- Client core (`src/client/`)
- Módulos Lua/OTUI (`modules/`, `mods/`)
- Assets e dados visuais (`data/`)

---

## Estrutura do repositório (prática)

- `crystalserver/`: backend do jogo.
- `otclient/`: cliente do jogo.
- `docs/`: documentação técnica (insumo desta consolidação).
- Demais pastas na raiz: apoio histórico, automação, referência e exploração técnica.

---

## Dependências e stack técnica

## Servidor
- Build: **CMake + vcpkg**
- Runtime principal: C++ + Lua
- Banco: **MySQL/MariaDB**
- Dependências mapeadas na documentação: `asio`, `mio`, `fmt`, `spdlog`, `protobuf`, `openssl`, `argon2`, `pugixml`, `libarchive`, entre outras gerenciadas por vcpkg.

## Cliente
- Build: **CMake + vcpkg**
- Runtime principal: C++ + LuaJIT/OTUI
- Dependências mapeadas: `boost`, `openssl`, `zlib`, `protobuf`, `physfs`, `glm`, `luajit`, etc.

> Recomendação operacional: manter baseline de dependências revisado periodicamente (scan de CVEs e auditoria de segurança).

---

## Configuração de ambiente

Pré-requisitos recomendados:
- Linux (ambiente principal de scripts existentes)
- `cmake`, compilador C++ (`gcc`/`clang`), `make`/Ninja
- `vcpkg` instalado e acessível
- Banco MySQL/MariaDB configurado para o servidor

Configuração inicial do servidor:
1. Entrar em `crystalserver/`
2. Garantir `config.lua` (se não existir, copiar de `config.lua.dist`)
3. Ajustar parâmetros de DB, rede e logs

Configuração inicial do cliente:
1. Entrar em `otclient/`
2. Garantir path do `vcpkg` usado no build
3. Validar módulos customizados e assets necessários

---

## Build / compilação

## CrystalServer
Opção por script (recomendada pelo repositório):

```bash
cd crystalserver
./recompile.sh /caminho/base/do/vcpkg linux-release
```

Exemplos de preset: `linux-release`, `linux-debug`, `linux-test`.

Opção manual (CMake):

```bash
cd crystalserver
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=/caminho/vcpkg/scripts/buildsystems/vcpkg.cmake --preset linux-release
cmake --build build/linux-release
```

## OTClient
Opção por script:

```bash
cd otclient
./recompile.sh
```

Opção manual (CMake):

```bash
cd otclient
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=/caminho/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build -j"$(nproc)"
```

---

## Execução

## Servidor
Execução direta do binário:

```bash
cd crystalserver
./crystalserver
```

Execução via script de supervisão/restart:

```bash
cd crystalserver
./start.sh
```

## Cliente
Após build, executar o binário gerado do OTClient no diretório de build conforme plataforma/preset utilizados.

---

## Fluxo de comunicação servidor ↔ cliente

Fluxo padrão:
1. Cliente inicia e autentica.
2. Servidor valida sessão/conta e estado.
3. Durante jogo, cliente envia ações; servidor valida e aplica regras.
4. Servidor retorna atualizações de estado para renderização no cliente.

Diretrizes críticas de protocolo:
- Alterações de opcode exigem sincronização bilateral (server + client).
- Para protocolos customizados, usar convenções documentadas e validação server-side rigorosa.
- Payloads devem ser tratados como potencialmente malformados (cliente e servidor defensivos).

### Extended Opcodes documentados
- **Linked Tasks**: opcodes 220/221/222 com framing textual (`\n`, `\t`) e sanitização obrigatória no servidor.
- **Paperdoll (proposta/documentada)**: opcode sugerido 92 com payload JSON versionado (`schemaVersion`) e tipos de mensagem explícitos.

---

## Sistemas críticos documentados

- **TaskBoard / Tasks / BattlePass (cliente)**: documentação extensa em `docs/client/`, incluindo arquitetura de UI, persistência de estado de interface e equivalência com custom legado.
- **Linked Tasks (servidor + cliente)**: regras de segurança, parsing defensivo, fluxo de recompensa e mensagens válidas.
- **Paperdoll (arquitetura + protocolo + exemplos)**: proposta integrada server/client com sincronização incremental e hardening.

---

## Observações críticas para desenvolvimento

1. **Compatibilidade é requisito de release**
   - Toda mudança com impacto em protocolo deve listar estratégia de migração/rollback.

2. **Servidor autoritativo sempre**
   - Qualquer regra crítica deve ser validada no CrystalServer.

3. **Segurança de protocolo e autenticação**
   - Validar tamanho/faixa/consistência de campos.
   - Aplicar proteção contra abuso (rate limit/throttle quando aplicável).

4. **Mensageria e enums**
   - Em Lua server-side, utilizar tipos de mensagem válidos/exportados.
   - Evitar constantes não suportadas que gerem warning de MessageType inválido.

5. **Documentação com origem externa**
   - Parte da documentação de cliente referencia `COMPLETE_CUSTOM_CLIENT` (fonte externa); tratar como base auxiliar e validar contra `otclient/` atual antes de decisões estruturais.

---

## Boas práticas para futuras alterações

- Classificar cada entrega como: `Server-side`, `Client-side` ou `Ambos`.
- Em mudanças médias/grandes, preparar scope/design review com impacto em protocolo, persistência e UI.
- Implementar com feature-gates quando houver risco de compatibilidade.
- Garantir parsing defensivo no cliente e validação estrita no servidor.
- Registrar testes mínimos de login, sincronização, progressão de estado e rollback.

---

## Restrições estruturais do projeto

- Não quebrar acoplamentos de protocolo sem mudança coordenada nos dois lados.
- Não mover lógica de gameplay sensível para o cliente.
- Não hardcodar interface no core C++ quando a feature puder viver em módulo OTUI/Lua.
- Não considerar documentação histórica/auxiliar como normativa sem validação no código vigente.

---

## Referências de documentação analisadas

A consolidação deste README considerou os domínios em `docs/`:
- `docs/architecture/`
- `docs/api/`
- `docs/server/`
- `docs/client/`
- `docs/deployment/`
- `docs/wiki/`
- `docs/ai/`
- `docs/reports/`
- `docs/internal/` e `docs/templates/`

