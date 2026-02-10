# Paperdoll para OTClient + CrystalServer (Canary): visão geral e objetivos

## 1) Definição funcional

O **paperdoll** é uma camada de customização visual do personagem que separa:

- **estado funcional** (itens realmente equipados, stats, atributos, defesa/ataque), de
- **estado cosmético** (como o personagem aparece para o próprio jogador e para terceiros).

Em termos práticos no ecossistema OT (OTClient v8/Redemption/Mehah + servidor Canary/Crystal), um sistema paperdoll permite que o jogador:

1. mantenha um set funcional para performance (PvE/PvP), e
2. aplique um set visual independente para aparência.

Essa abordagem cria um fluxo semelhante a “transmog/wardrobe”, com regras de desbloqueio e persistência.

---

## 2) Objetivos do sistema

### 2.1 Objetivos de produto

- **Expressão visual**: permitir identidade cosmética sem sacrificar build.
- **Retenção**: criar loop de progressão por desbloqueios (quests, loja, eventos, drops).
- **Monetização ética**: premium/cosméticos sem quebrar balanceamento de combate.
- **Compatibilidade**: funcionar com pipeline de outfits/sprites existente no cliente.

### 2.2 Objetivos técnicos

- Persistir escolhas cosméticas por personagem.
- Garantir sincronização server → client sem confiar em payload do client.
- Permitir fallback limpo quando asset visual não existir no cliente.
- Minimizar custo de atualização com eventos incrementais em vez de full refresh constante.

---

## 3) Sprite/visual vs item equipado real

## 3.1 Item equipado real (server authoritative)

Representa estado mecânico do jogo:

- itemid real em cada slot (head, armor, legs, etc.),
- atributos aplicados (armor, skills, speed, elemental),
- validações de uso (vocation, level, premium),
- persistência no inventário/equipment normal.

## 3.2 Visual paperdoll (cosmético)

Representa estado gráfico:

- `lookType` base (outfit),
- variações por camada visual (hair, helmet visual, armor visual etc.),
- paleta de cores por parte (head/body/legs/feet + extensões custom),
- efeitos opcionais (cape, aura, trail) sem impacto em combate.

> Regra principal: **o visual nunca pode conceder vantagem de gameplay**. Qualquer bônus vem apenas do equipamento real.

---

## 4) Slots/camadas recomendados

A modelagem deve separar **slot funcional** e **camada cosmética**. Sugestão para OT moderno:

- `base_outfit` (looktype principal)
- `hair`
- `helmet`
- `armor`
- `legs`
- `boots`
- `weapon_main`
- `shield_offhand`
- `cape`
- `backpack_skin` (opcional)
- `aura` (opcional)
- `mount_skin` (opcional)

### 4.1 Mapeamento de prioridade visual

Quando múltiplas camadas existem, usar prioridade (maior vence):

1. efeitos temporários de script (ex.: transformação de spell),
2. override de outfit (eventos especiais),
3. paperdoll persistido,
4. visual derivado do item equipado real,
5. outfit base padrão.

---

## 5) Desbloqueio, personalização e persistência

## 5.1 Fontes de desbloqueio

- quest flags/storage,
- compra com gold/coin,
- premium account,
- level/vocation,
- achievement/evento sazonal,
- drop/token de boss.

## 5.2 Regras de customização

- Cada parte pode aceitar:
  - `appearance_id` (chave do visual),
  - `color_primary/secondary/tertiary` (faixa 0–132 ou escala definida pelo client),
  - `enabled` (liga/desliga camada).
- Algumas camadas podem ser bloqueadas por sexo/outfit base.

## 5.3 Persistência

Persistir em tabelas separadas:

- estado ativo (`player_paperdoll`),
- catálogo desbloqueado (`player_unlocked_appearances`),
- presets opcionais (`player_paperdoll_presets`).

No login:

1. servidor carrega estado,
2. valida contra regras atuais,
3. corrige entradas inválidas,
4. envia snapshot para client.

---

## 6) Compatibilidade OTClient (Redemption/Mehah) e CrystalServer

- **Client**: UI dedicada + integração com `game_outfit`/`game_inventory` e render de layers.
- **Server**: módulo Lua (creaturescripts/actions/talkactions) + chamadas C++/Lua já existentes para outfit e opcodes estendidos.
- **Transporte**: preferencialmente `ExtendedOpcode` com JSON (simples para evolução de schema).

---

## 7) Limitações práticas e decisões de design

- Nem todo cliente tem suporte nativo a “camadas extras” além do outfit clássico.
- Caso não haja compositor completo de sprites, usar estratégia híbrida:
  1. manter `lookType` principal,
  2. trocar partes via addons/colors quando possível,
  3. renderizar overlays em widgets de UI (inventário/painel) para preview avançado.
- Em tela de jogo, priorizar compatibilidade: se camada não suportada, ignorar sem quebrar.

---

## 8) Boas práticas

- Server sempre autoritativo em desbloqueio e aplicação final.
- Validar tudo no backend (IDs, cores, restrições, premium).
- Limitar frequência de sync (debounce no client e rate limit no server).
- Versionar payload (`schemaVersion`) para migrações seguras.
