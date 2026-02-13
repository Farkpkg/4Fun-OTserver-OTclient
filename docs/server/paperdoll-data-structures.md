# Paperdoll: estruturas de dados (XML, DB, protocolo)

## 1) Arquivo `paperdoll.xml` (catálogo cosmético)

Objetivo: definir **o que existe** de aparência no jogo.

## 1.1 Exemplo completo

```xml
<?xml version="1.0" encoding="UTF-8"?>
<paperdoll version="1">
  <slots>
    <slot id="hair" label="Hair" colorable="1"/>
    <slot id="helmet" label="Helmet" colorable="0"/>
    <slot id="armor" label="Armor" colorable="1"/>
    <slot id="legs" label="Legs" colorable="1"/>
    <slot id="boots" label="Boots" colorable="1"/>
    <slot id="weapon_main" label="Weapon" colorable="0"/>
    <slot id="shield_offhand" label="Shield" colorable="0"/>
    <slot id="cape" label="Cape" colorable="1"/>
  </slots>

  <appearances>
    <appearance id="1001" slot="hair" name="Long Hair A"
      lookType="128" lookAddon="0" layer="hair_front"
      minLevel="1" premium="0" vocationMask="all"
      unlockType="default" enabled="1"/>

    <appearance id="2104" slot="helmet" name="Royal Helm Skin"
      lookType="130" lookAddon="2" layer="head"
      minLevel="80" premium="1" vocationMask="knight,paladin"
      unlockType="quest" unlockRef="quest_royal_order" enabled="1"/>

    <appearance id="3402" slot="cape" name="Dragon Cape"
      lookType="133" lookAddon="0" layer="back"
      minLevel="100" premium="1" vocationMask="all"
      unlockType="shop" unlockRef="shop_offer_501" enabled="1"/>
  </appearances>

  <palettes>
    <palette slot="hair" min="0" max="132" default="78"/>
    <palette slot="armor" min="0" max="132" default="114"/>
    <palette slot="legs" min="0" max="132" default="95"/>
    <palette slot="boots" min="0" max="132" default="40"/>
    <palette slot="cape" min="0" max="132" default="65"/>
  </palettes>
</paperdoll>
```

## 1.2 Atributos relevantes

- `appearance@id`: ID único global da aparência.
- `slot`: camada alvo.
- `lookType/lookAddon`: referência visual compatível com assets do cliente.
- `layer`: dica para ordem de composição (preview/UI).
- `minLevel/premium/vocationMask`: restrições de uso.
- `unlockType`: `default | quest | shop | achievement | token`.
- `unlockRef`: chave externa para sistema de unlock.
- `enabled`: toggle para desativar sem apagar registro.

---

## 2) Arquivo `equipment_paperdoll.xml` (integração item → visual)

Objetivo: mapear equipamento funcional para aparência cosmética sugerida/forçada.

## 2.1 Exemplo

```xml
<?xml version="1.0" encoding="UTF-8"?>
<equipmentPaperdoll version="1">
  <mappings>
    <map itemId="2498" slot="helmet" appearanceId="2104" mode="default"/>
    <map itemId="2465" slot="armor" appearanceId="3001" mode="default"/>
    <map itemId="2400" slot="weapon_main" appearanceId="4101" mode="optional"/>
    <map itemId="2514" slot="shield_offhand" appearanceId="4202" mode="default"/>
  </mappings>

  <rules>
    <rule id="noHelmetWhenOutfitSpirit" condition="outfit=spirit" action="disable_slot" slot="helmet"/>
    <rule id="twoHandedHidesShield" condition="weapon_two_handed=1" action="disable_slot" slot="shield_offhand"/>
  </rules>
</equipmentPaperdoll>
```

## 2.2 Semântica de `mode`

- `default`: aplica automaticamente se jogador não tiver override cosmético.
- `optional`: apenas sugestão para UI.
- `forced`: equipamento impõe visual específico (uso raro e explícito).

---

## 3) Banco de dados

## 3.1 `player_paperdoll`

Estado ativo por personagem + slot.

```sql
CREATE TABLE IF NOT EXISTS player_paperdoll (
  player_id INT NOT NULL,
  slot VARCHAR(32) NOT NULL,
  appearance_id INT NOT NULL,
  color_primary SMALLINT NOT NULL DEFAULT 0,
  color_secondary SMALLINT NOT NULL DEFAULT 0,
  color_tertiary SMALLINT NOT NULL DEFAULT 0,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (player_id, slot),
  KEY idx_paperdoll_player (player_id)
);
```

## 3.2 `player_unlocked_appearances`

Catálogo desbloqueado pelo jogador.

```sql
CREATE TABLE IF NOT EXISTS player_unlocked_appearances (
  player_id INT NOT NULL,
  appearance_id INT NOT NULL,
  unlocked_by VARCHAR(32) NOT NULL DEFAULT 'unknown',
  unlocked_ref VARCHAR(64) NULL,
  unlocked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (player_id, appearance_id),
  KEY idx_unlocked_player (player_id),
  KEY idx_unlocked_appearance (appearance_id)
);
```

## 3.3 `player_paperdoll_presets` (opcional)

```sql
CREATE TABLE IF NOT EXISTS player_paperdoll_presets (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  player_id INT NOT NULL,
  preset_name VARCHAR(32) NOT NULL,
  payload_json JSON NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_player_preset_name (player_id, preset_name)
);
```

---

## 4) Mensagens server ↔ client (modelo)

Formato recomendado via ExtendedOpcode + JSON:

- `type="paperdoll_snapshot"`: estado completo.
- `type="paperdoll_update"`: alteração incremental.
- `type="paperdoll_apply_request"`: pedido do client.
- `type="paperdoll_apply_result"`: confirmação/erro.
- `type="paperdoll_unlock_notify"`: novo unlock.

Exemplo de snapshot:

```json
{
  "schemaVersion": 1,
  "type": "paperdoll_snapshot",
  "playerId": 123,
  "look": { "lookType": 128, "lookHead": 78, "lookBody": 114, "lookLegs": 95, "lookFeet": 40, "lookAddons": 3 },
  "slots": {
    "helmet": { "appearanceId": 2104, "enabled": true },
    "armor": { "appearanceId": 3001, "enabled": true, "colorPrimary": 114 },
    "cape": { "appearanceId": 3402, "enabled": false }
  },
  "unlocked": [1001, 2104, 3001, 3402]
}
```

---

## 5) Relação looktype, outfit, addons e paperdoll

- `lookType`: base principal do outfit (humano, creature, skin principal).
- `lookAddons`: variações clássicas (addon 1/2) aplicáveis ao `lookType`.
- `lookHead/lookBody/lookLegs/lookFeet`: cores padrão OTC.
- paperdoll adiciona granularidade por slot, mas deve convergir para um `Outfit_t` válido para renderização em jogo.

Estratégia recomendada:

1. calcular `Outfit_t` final no servidor/client (conforme capacidade),
2. enviar estado canônico para render,
3. manter metadata paperdoll separada para UI e edição.

---

## 6) Versionamento e migração

- Versionar XML (`version="1"`) e payload (`schemaVersion`).
- Em mudança de slot/appearance:
  - desativar entradas antigas (soft disable),
  - migrar DB por script idempotente,
  - manter compatibilidade de leitura por 1 versão.
