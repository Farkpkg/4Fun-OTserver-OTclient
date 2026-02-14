# PREY — Comportamento de Renderização

## Pipeline visual

```text
parsePreyData/parsePreyTimeLeft (C++)
  -> callbacks g_game.onPrey*
  -> prey.lua (state reducers + bind de eventos)
  -> atualização de widgets otui (show/hide/text/icon/progress)
  -> feedback visual imediato (slot/tracker)
```

## Estados e visibilidade
- `onPreyLocked`: mostra painel locked e oculta tracker slot.
- `onPreyInactive`: mostra painel de seleção (lista de 9 + actions).
- `onPreyActive`: mostra criatura ativa, bônus, estrelas, barra de tempo, opções lock/auto.
- `onPreySelection*`: popula listas e habilita confirmações.

## Render de bônus
- Ícone grande: `getBigIconPath(bonusType)`
- Ícone pequeno/tracker: `getSmallIconPath(bonusType)`
- Tooltip detalhado: `getTooltipBonusDescription(bonusType, bonusValue)`
- Grade de estrelas: `setBonusGradeStars(slot, grade)`

## Render de timer
- Conversão de tempo: `timeleftTranslation`
- Barra em slot + tracker via `onPreyTimeLeft`
- Reroll free timer via `setTimeUntilFreeReroll`

## Interações de usuário com impacto visual
- `refreshRerollButtonState`: alterna sprite normal/bloqueado por capacidade de pagamento.
- `updatePickSpecificPreyButton`: alterna sprite habilitado/bloqueado por wildcard.
- `updateChoosePreyButtonState`: habilita botão de confirmação quando existe seleção válida.
- Busca na full list (texto + clear button dinâmico).

## Possíveis bugs de renderização
1. Dependência forte de hierarquia/id de widgets pode quebrar silenciosamente se OTUI mudar.
2. `setUnsupportedSettings()` injeta preços fixos na UI; pode divergir dos preços reais vindos do servidor.
3. Em resets de estado, algumas tabelas auxiliares são limpas parcialmente (atenção a referências de widget destruído).

## Exemplo real de atualização visual
```lua
function onPreyTimeLeft(slot, timeLeft)
  local percent = (timeLeft / (2 * 60 * 60)) * 100
  tracker.time:setPercent(percent)
  prey.active.creatureAndBonus.timeLeft:setPercent(percent)
end
```

## Limitações e melhorias
- Não há camada declarativa de estado; updates são imperativos e espalhados.
- Sugestão: centralizar reducer de estado por slot para diminuir regressões visuais.
