# Spells / Runes / Potions (integração com Cyclopedia)

## Visão geral
A Cyclopedia deste cliente não possui um tab exclusivo de spells no módulo `game_cyclopedia`, porém há integração indireta por:
- categorização de itens (`Runes`, `Potions`) no tab `items`
- módulos dedicados de spells (`game_spelllist`)
- dados estáticos de spells em `gamelib/spells.lua`

## Fontes de dados
- `otclient/modules/gamelib/spells.lua` — base principal de spells por perfil.
- `otclient/modules/game_spelllist/spelllist.lua` — UI de listagem, filtros e exibição detalhada.
- `otclient/docs/generate_spell_data.py` — utilitário de geração de dados Lua de spells.

## Spelllist (módulo adjacente)

### Filtros disponíveis
`spelllist.lua` define filtros por:
- vocação (`ANY`, `SORCERER`, `DRUID`, `PALADIN`, `KNIGHT`, `MONK`)
- grupo (`ATTACK`, `HEALING`, `SUPPORT`)
- premium (`ANY`, `YES`, `NO`)
- nível (toggle por regra local)

### Renderização
- monta lista de spells com nome + words.
- usa `clientId` para ícone (`SpellIcon`).
- ao selecionar, preenche painel com fórmula, cooldown, nível, mana, premium, descrição.

## Relação com Cyclopedia

### Itens tipo rune/potion
No tab de itens, as categorias `Potions` e `Runes` são tratadas como parte normal da Cyclopedia de item:
- busca por nome
- filtros por vocação/nível/classificação
- detalhe de preço/inspeção

### Ausências atuais
- Não existe `showSpells()` nativo em `game_cyclopedia`.
- Não há request protocol de "Cyclopedia spells" dedicado neste código.

## Sugestões para expansão futura
1. Reusar `SpellInfo` como provider de um novo tab de Cyclopedia.
2. Indexar runes/potions com cross-link para dados de spells.
3. Integrar cooldown groups e escola elementar em filtros avançados.
