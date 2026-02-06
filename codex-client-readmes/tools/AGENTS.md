---
alwaysApply: true
---
# Guia de Tools (Build, Encrypt, Launcher, CLI)

## Escopo

Este guia cobre build, scripts, CLI, encrypt, launcher e pipeline de release.

## Fluxos de build

- Linux: build local via `tools/otclient_cli.sh`.
- Windows release: pipeline com encrypt + launcher.

## Build System

- CMake com VCPKG para dependências.
- `VCPKG_ROOT` aponta para o gerenciador de deps.
- `VCPKG_DEFAULT_TRIPLET` define a arquitetura alvo (ex.: `x64-windows`).
- Feature flags habilitam componentes opcionais (Discord RPC, encryption, tests).
 - Guia detalhado: `tools/build.md`.

## Configuracao do build (CMake)

- `CMakeLists.txt` define toolchain, targets e opcoes.
- `OPTIONS_ENABLE_CCACHE` e `OPTIONS_ENABLE_SCCACHE` aceleram rebuild.
- `OPTIONS_ENABLE_IPO` controla IPO/LTO.
- `OTCLIENT_BUILD_TESTS` habilita/desabilita testes.

## Alvos e entrada

- Executavel principal em `src/main.cpp`.
- Protobuf gerado via target dedicado (CMake).
- `init.lua` e `g_resources.discoverWorkDir()` definem o workdir.

## CLI e ferramentas

- `--encrypt <password>` ativa builder de assets (quando habilitado).
- `--dump-dat-*` exporta DAT para JSON (debug).
- `--help` mostra uso.
- `tools/export_wiki_bundle.py`: exporta os arquivos listados em `wiki.md` para um zip (padrao: `codex_export_<repo>.zip`).

## Dependencias

- Lista em `vcpkg.json` e integrada por CMake.
- Principais: luajit, asio, glew, physfs, openal, protobuf, openssl.

## Plataformas

- Windows, Linux, Android e WebAssembly (Emscripten).

## Pipeline de encrypt e launcher

- `builder.exe` é binário temporário usado para criptografar assets (Lua, módulos, sprites, etc.).
- `builder.exe --encrypt` gera dados criptografados em `client_dir`.
- `tools/builder.zip` é o cache do builder; FAST depende dele.
- Não editar output criptografado manualmente.
- O launcher sempre deve iniciar o cliente com `--from-launcher`.
- `game_data` precisa conter `init.lua`.

## Modos

- `debug-build`: build completo, logs verbosos.
- `release-build`: build completo, runtime silencioso, version bump.
- `debug-fast`: apenas encrypt (usa cache).
- `release-fast`: apenas encrypt (usa cache).
- `--dev` só com build completo (FAST não permite).

## Separação de diretórios

- `base_dir`: fonte.
- `client_dir`: distribuição.
- `game_data`: diretório de runtime.
