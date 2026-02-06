[Wiki](../README.md) > Configuração

# Configuração

## Visão geral
Configurações definem parâmetros de runtime do servidor e do cliente, além de registros de dados e regras via XML.

## Localização no repositório
- **Servidor**: `crystalserver/config.lua.dist`, `crystalserver/src/config/`, `crystalserver/data/XML/`.
- **Cliente**: `otclient/config.ini`, `otclient/otclientrc.lua`, `otclient/data/setup.otml`.

## Estrutura interna (alto nível)
- **Servidor**
  - `config.lua.dist` — configuração principal (base).
  - `src/config/` — carregamento e gestão dos valores.
  - `data/XML/` — definições de grupos, vocações, eventos, outfits, etc.
- **Cliente**
  - `config.ini` — parâmetros gerais do cliente.
  - `otclientrc.lua` — configurações em Lua para o cliente.
  - `data/setup.otml` — configuração de setup e recursos.

## Fluxo de execução (alto nível)
- **Servidor**: configuração é carregada na inicialização e usada para parametrizar serviços, I/O e gameplay.
- **Cliente**: configuração é lida no bootstrap para ajustar inicialização e UI.

## Integrações
- **Servidor**: influencia rede, banco, sistemas de jogo e scripts.
- **Cliente**: influencia carregamento de módulos, assets e comportamento visual.
