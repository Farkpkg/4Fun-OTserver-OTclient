# PREY — Integração com Creature / Combat

## Aplicação real de bônus (não apenas visual)

## Dano e defesa (C++ combate)
Em `combat.cpp`:
- **Player -> Monster**: se prey ativo com `PreyBonus_Damage`, aumenta dano primário/secundário por `%`.
- **Monster -> Player**: se prey ativo com `PreyBonus_Defense`, reduz dano primário/secundário por `%`.

Isso altera cálculos internos de combate diretamente.

## Experiência (Lua event player)
Em `data/events/scripts/player.lua`:
- no fluxo de ganho de EXP, aplica:
```lua
exp = math.ceil((exp * self:getPreyExperiencePercentage(monsterType:raceId())) / 100)
```
- `getPreyExperiencePercentage` retorna 100 base ou 100+bonus, conforme slot ativo e tipo XP.

## Loot (Lua event callback)
Em `ondroploot_prey.lua`:
- calcula chance prey por participante (ou party), com fator de diminuição configurável.
- se procar, adiciona roll extra de loot ao cadáver e anexa sufixo de mensagem de loot.

## Integração com Player/Creature
- Assinatura de monster prey é por `raceId`.
- Query principal: `Player::getPreyWithMonster(raceId)`.
- Usada por:
  - C++ combate (dano/defesa)
  - Lua XP/loot (via bindings)

## Conclusão técnica
O bônus de prey **impacta cálculo interno real** em:
- dano causado
- dano recebido
- experiência recebida
- chance de loot extra

Portanto não é um sistema cosmético; ele interfere no balanceamento PvE e economia.

## Pontos críticos
1. Stack com outros multiplicadores (boosted creature, stamina, VIP, forge, etc.) amplia variância de EXP final.
2. Loot prey em party depende de parâmetro de diminishing factor; tuning inadequado pode inflacionar drop.
3. Defesa prey subtrai percentual do dano já calculado; comportamento com dano negativo/zero precisa cuidado em edge cases.

## Diagrama textual
```text
Monster morre / ataque ocorre
  -> resolve raceId
  -> Player::getPreyWithMonster(raceId)
  -> aplica bônus (combat.cpp ou Lua XP/Loot)
  -> resultado final de dano/exp/drop
```

## Exemplo real adicional
```cpp
if (slot && slot->isOccupied() && slot->bonus == PreyBonus_Damage && slot->bonusTimeLeft > 0) {
  damage.primary.value += ceil((damage.primary.value * slot->bonusPercentage) / 100);
}
```
