# Ferramentas e Fluxo de Desenvolvimento

## Descrição
Este guia lista somente ferramentas e pontos de entrada que existem no repositório para build/execução de Client e Server.

## Localização no Projeto
- client/
  - `otclient/CMakeLists.txt`
  - `otclient/CMakePresets.json`
- server/
  - `crystalserver/CMakeLists.txt`
  - `crystalserver/CMakePresets.json`

## Arquivos Envolvidos
- `otclient/CMakeLists.txt`
- `otclient/CMakePresets.json`
- `crystalserver/CMakeLists.txt`
- `crystalserver/CMakePresets.json`
- `otclient/tests/`

## Fluxo de Execução
1. Configurar build com CMake usando presets do projeto.
2. Compilar target do client (`otclient`) e/ou do server (`crystalserver`).
3. Rodar client pelo entrypoint `otclient/init.lua`.
4. Rodar server com configuração em `crystalserver/config.lua` derivada de `config.lua.dist`.

## Dependências
- CMake (presets definidos nos dois projetos).
- Toolchain C++ compatível.
- MySQL para o servidor.

## Pontos de Extensão
- Adicionar presets separados para CI/perfil debug.
- Incluir novos testes automatizados em `otclient/tests` e pipelines do server.
