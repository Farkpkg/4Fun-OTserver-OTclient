# PREY — Análise de Performance

## Pontos de custo relevantes

## 1) Geração de listas (`reloadMonsterGrid`)
- Loop até preencher 9 criaturas.
- Usa random + blacklist + validações de bestiary.
- Em ambientes com poucos monstros válidos, o número de tentativas cresce.
- O código já inclui guard para bestiary < 36 (desabilita geração).

## 2) Tick de atualização de tempo (`checkPlayerPreys`)
- O(3) por jogador por chamada (fixo por slots), custo baixo.
- Pode disparar mensagens e reload de slot ao expirar.

## 3) Persistência de `player_prey`
- Save por slot via `INSERT ... ON DUPLICATE KEY UPDATE`.
- Serialização de `monster_list` em blob por slot.
- Custos aceitáveis, mas com alta frequência de save global pode impactar I/O DB.

## 4) UI cliente
- Atualizações frequentes de barra/tooltip.
- Múltiplos `setText`/`setImageSource` e criação de widgets (estrelas/listas).
- Em geral leve, porém há custo de rebuild de listas e busca quando full list está aberta.

## 5) Loot prey em party
- Para cada drop, itera participantes e consulta percentual.
- Custo linear no tamanho da party; usualmente pequeno.

## Gargalos potenciais
1. Rebuild repetido de listas completas de race IDs em `LIST_SELECTION` sem cache incremental.
2. Serialização completa de lista de monstros por atualização de slot (payload pode crescer).
3. Strings/tooltips e atualizações UI frequentes sem throttle (impacto maior em clientes fracos).

## Recomendações de otimização
- Cachear subconjuntos de bestiary por tier de estrela para seleção mais eficiente.
- Evitar recriação total de widgets quando possível (diff update).
- Introduzir checksum/version para evitar enviar slot unchanged.
- Revisar frequência de `sendResourcesBalance` acoplada a pequenas mudanças.

## Exemplo real de custo (código)
```cpp
while (raceIdList.size() < 9) {
  uint16_t raceId = (*(std::next(bestiary.begin(), uniform_random(0, maxIndex)))).first;
  // filtros + blacklist + stages
}
```

## Diagrama textual
```text
Ação de reroll
  -> parsePreyAction
  -> reloadMonsterGrid
  -> reloadPreySlot
  -> sendPreyData
  -> parsePreyData client
```

## Limitações
- Sem microbenchmark nativo para medir tempo de geração de listas por perfil de bestiary.

## Bugs potenciais
- Em cenários extremos de bestiary muito restrito, tentativas repetidas podem aumentar latência percebida.
