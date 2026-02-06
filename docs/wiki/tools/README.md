<!-- tags: - tools - build priority: low -->

## LLM Summary
- **What**: Ferramentas e scripts auxiliares.
- **Why**: Automatiza build e execução.
- **Where**: crystalserver/*.sh, otclient/tools
- **How**: Scripts chamam CMake/execução.
- **Extends**: Adicionar scripts com documentação mínima.
- **Risks**: Scripts inconsistentes podem quebrar build.

[Wiki](../README.md) > Ferramentas

# Ferramentas

## Visão geral
Esta seção cobre scripts e ferramentas auxiliares para build, execução e manutenção do servidor e do cliente.

## Localização no repositório
- **Servidor**: scripts como `crystalserver/recompile.sh`, `crystalserver/start.sh`, `crystalserver/linux_installer.sh`.
- **Cliente**: `otclient/tools/` e scripts como `otclient/recompile.sh`.

## Estrutura interna (alto nível)
- **Build**: CMake presets e scripts de recompilação.
- **Execução**: scripts de start e suporte a debug.
- **Instalação**: scripts de instalação no servidor.

## Integrações
- **Servidor/Cliente**: ferramentas interagem com CMake e binários gerados para compilar e rodar o projeto.
