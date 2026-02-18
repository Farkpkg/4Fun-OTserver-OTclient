# How to Create a New UI Module

## Estrutura mínima

- `otclient/modules/game_<nome>/<nome>.otmod`
- `otclient/modules/game_<nome>/<nome>.lua`
- `otclient/modules/game_<nome>/<nome>.otui` (quando aplicável)

## Regras de implementação

1. Declarar dependências reais no `.otmod`.
2. Expor `init()` e `terminate()` simétricos.
3. Registrar callbacks/eventos somente em `init()`.
4. Remover callbacks/eventos em `terminate()`.
5. Evitar estado global fora do namespace do módulo.

## Integração com protocolo

- Usar `g_game.getProtocolGame()` para chamadas de rede.
- Para custom payload, usar extended opcode com contrato documentado.
