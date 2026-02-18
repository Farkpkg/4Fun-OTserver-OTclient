# TibiaForever OnDeath Auto-Register (Relatório de uso)

## O que foi implementado
Foi adicionado o script `data/scripts/globalevents/system/tibiaforever_ondeath_register.lua`, que roda no startup do servidor e:

1. Identifica automaticamente o datapack ativo via `configManager.getString(configKeys.DATA_DIRECTORY)`.
2. Faz varredura recursiva nos arquivos `.lua` do datapack ativo.
3. Coleta nomes de monstros definidos com `Game.createMonsterType("...")`.
4. Registra os eventos definidos em `registerEvents` para cada `MonsterType` válido.
5. Ignora monstros listados em `blockedNames`.

## Como usar
1. Edite este arquivo:
   - `data/scripts/globalevents/system/tibiaforever_ondeath_register.lua`
2. Atualize os eventos que deseja aplicar em lote:
   - tabela `registerEvents`
3. (Opcional) adicione nomes a bloquear em:
   - tabela `blockedNames`
4. Reinicie o servidor.

## Logs esperados
No startup, os logs devem indicar:

- Quantidade de monstros válidos encontrados.
- Erros de monstros inválidos (se existirem).
- Lista de eventos aplicados.

Prefixo padrão de log:

- `[TibiaForever OnDeath Register]`

## Observações técnicas
- A rotina usa deduplicação de monstros para evitar múltiplos `registerEvent` no mesmo `MonsterType`.
- O script suporta ambiente Linux e Windows para varredura de arquivos.
