# Project Vision

## Objetivo técnico do stack

O stack opera como uma plataforma MMORPG com:

- **Server autoritativo** (`crystalserver`) para estado de mundo, regras de jogo, persistência e rede.
- **Client OTClient** (`otclient`) para renderização, UI, input e integração com protocolo.

## Direcionadores arquiteturais observados

1. **Scriptabilidade em Lua**
   - Server: camadas de eventos e scripts carregadas em bootstrap (`data/scripts`, `data-global/scripts`).
   - Client: módulos `.otmod` e scripts Lua carregados em `init.lua`.

2. **Núcleo performático em C++**
   - Server: gameplay, rede, mapa, criaturas, IO e banco em C++.
   - Client: loop gráfico, protocolo, parser de rede e managers em C++.

3. **Extensibilidade por protocolo**
   - Uso de opcodes clássicos + extended opcode (0x32/50) para integrações customizadas.

4. **Persistência relacional consolidada**
   - Schema único (`schema.sql`) com versionamento via `server_config.db_version` + migrações Lua.

## Critérios de evolução

- Preservar autoridade do servidor nas regras de gameplay.
- Evitar acoplamento direto módulo-client ↔ script-server fora de contrato de protocolo.
- Expandir sistemas por pontos de extensão existentes (callbacks Lua, parse/send handlers, módulos OTClient).
