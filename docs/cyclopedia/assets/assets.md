# Assets da Cyclopedia

## 1) Localizações principais

### Cyclopedia module assets
- `otclient/modules/game_cyclopedia/images/**`

### Ícones globais usados por Cyclopedia
- `otclient/data/images/game/cyclopedia/**`
- `otclient/data/images/game/spells/**`
- `otclient/data/images/game/creatureicons/**`
- `otclient/data/images/options/**`

### Shader relacionado
- `otclient/modules/game_shaders/shaders/fragment/cyclopedia.frag`

## 2) Inventário resumido
Contagem aproximada em `modules/game_cyclopedia/images`:
- Total de arquivos: **188**
- Subpastas mais densas:
  - `bestiary` (~40)
  - `character_icons` (~16)
  - `boss` (~12)
  - `charms` e `charms/border`
  - `houses`

## 3) Tipos de asset e uso
- **PNG**: padrão dominante (ícones, botões, overlays, barras).
- **Spritesheets**: alguns ícones em atlas (`friend-badge-icons`, charm sheets, etc.).
- **Textures de UI**: fundos/painéis/progressbars.
- **Creature rendering**: looktypes via DAT/SPR + `UICreature` (não são pngs diretos da Cyclopedia).

## 4) Pipeline de carregamento
1. OTUI referencia `image-source` (`/images/...` ou `/game_cyclopedia/images/...`).
2. `g_ui.loadUI` instancia widgets.
3. Motor gráfico resolve recursos via `g_resources`.
4. Para criaturas/itens, motor usa `ThingType`/`SpriteManager`.

## 5) Assets de monstros e bosses
- Bestiary: ícones elementais (fire, ice, energy, etc.), barras e estados de progresso.
- Bosstiary: emblemas de categoria (Bane/Archfoe/Nemesis), stars e fills.

## 6) Assets de itens/spells
- Item render geralmente vem de sprites de item (ThingType), não png direto.
- Spelllist usa ícones em `data/images/game/spells`.
- Runes/Potions também aparecem por sprite de item e categoria textual.

## 7) Limitações
- Não há catálogo central versionado de atlas/frames da Cyclopedia (mapeamento está espalhado em OTUI/Lua).
- Sem metadados formais de cache por asset; gerenciamento é implícito no resource manager.
