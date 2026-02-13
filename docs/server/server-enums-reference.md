# Crystal Server enums (C++ source)

This document lists the enums used by the Crystal Server / Canary core and exposed to Lua/protocol. Values are extracted from C++ sources.

## MessageClasses (MessageType)
Source: `crystalserver/src/utils/utils_definitions.hpp`.

| Name | Value | Status | Usage rules |
| --- | --- | --- | --- |
| `MESSAGE_NONE` | `0` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_GAMEMASTER_CONSOLE` | `13` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_LOGIN` | `17` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_ADMINISTRATOR` | `18` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_EVENT_ADVANCE` | `19` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_GAME_HIGHLIGHT` | `20` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_FAILURE` | `21` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_LOOK` | `22` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_DAMAGE_DEALT` | `23` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_DAMAGE_RECEIVED` | `24` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_HEALED` | `25` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_EXPERIENCE` | `26` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_DAMAGE_OTHERS` | `27` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_HEALED_OTHERS` | `28` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_EXPERIENCE_OTHERS` | `29` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_STATUS` | `30` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_LOOT` | `31` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_TRADE` | `32` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_GUILD` | `33` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_PARTY_MANAGEMENT` | `34` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_PARTY` | `35` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_LAST_OLDPROTOCOL` | `37` | legacy | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_REPORT` | `38` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_HOTKEY_PRESSED` | `39` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_TUTORIAL_HINT` | `40` | legacy | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_THANK_YOU` | `41` | legacy | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_MARKET` | `42` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_MANA` | `43` | legacy | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_BEYOND_LAST` | `44` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_ATTENTION` | `48` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_BOOSTED_CREATURE` | `49` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_OFFLINE_TRAINING` | `50` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_TRANSACTION` | `51` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |
| `MESSAGE_POTION` | `52` | valid | Use with player:sendTextMessage; avoid legacy/no-effect types. |

## TextColor_t
Source: `crystalserver/src/utils/utils_definitions.hpp`.

| Name | Value | Status | Usage rules |
| --- | --- | --- | --- |
| `TEXTCOLOR_BLUE` | `5` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_LIGHTGREEN` | `30` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_LIGHTBLUE` | `35` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_DARKBROWN` | `78` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_DARKGREY` | `86` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_MAYABLUE` | `95` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_DARKRED` | `108` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_NEUTRALDAMAGE` | `109` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_LIGHTGREY` | `129` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_SKYBLUE` | `143` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_PURPLE` | `154` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_ELECTRICPURPLE` | `155` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_RED` | `180` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_PASTELRED` | `194` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_ORANGE` | `198` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_LIGHTPURPLE` | `199` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_YELLOW` | `210` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_WHITE_EXP` | `215` | valid | Use in animated/combat text rendering. |
| `TEXTCOLOR_NONE` | `255` | valid | Use in animated/combat text rendering. |

## MagicEffectClasses (MagicEffect)
Source: `crystalserver/src/utils/utils_definitions.hpp`.

| Name | Value | Status | Usage rules |
| --- | --- | --- | --- |
| `CONST_ME_NONE` | `0` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DRAWBLOOD` | `1` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_LOSEENERGY` | `2` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_POFF` | `3` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLOCKHIT` | `4` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_EXPLOSIONAREA` | `5` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_EXPLOSIONHIT` | `6` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FIREAREA` | `7` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_YELLOW_RINGS` | `8` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_RINGS` | `9` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HITAREA` | `10` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_TELEPORT` | `11` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ENERGYHIT` | `12` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MAGIC_BLUE` | `13` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MAGIC_RED` | `14` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MAGIC_GREEN` | `15` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HITBYFIRE` | `16` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HITBYPOISON` | `17` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MORTAREA` | `18` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SOUND_GREEN` | `19` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SOUND_RED` | `20` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_POISONAREA` | `21` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SOUND_YELLOW` | `22` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SOUND_PURPLE` | `23` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SOUND_BLUE` | `24` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SOUND_WHITE` | `25` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BUBBLES` | `26` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CRAPS` | `27` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GIFT_WRAPS` | `28` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FIREWORK_YELLOW` | `29` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FIREWORK_RED` | `30` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FIREWORK_BLUE` | `31` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_STUN` | `32` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SLEEP` | `33` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WATERCREATURE` | `34` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GROUNDSHAKER` | `35` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HEARTS` | `36` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FIREATTACK` | `37` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ENERGYAREA` | `38` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALLCLOUDS` | `39` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HOLYDAMAGE` | `40` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BIGCLOUDS` | `41` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ICEAREA` | `42` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ICETORNADO` | `43` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ICEATTACK` | `44` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_STONES` | `45` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALLPLANTS` | `46` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CARNIPHILA` | `47` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PURPLEENERGY` | `48` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_YELLOWENERGY` | `49` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HOLYAREA` | `50` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BIGPLANTS` | `51` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CAKE` | `52` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GIANTICE` | `53` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WATERSPLASH` | `54` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PLANTATTACK` | `55` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_TUTORIALARROW` | `56` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_TUTORIALSQUARE` | `57` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MIRRORHORIZONTAL` | `58` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MIRRORVERTICAL` | `59` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SKULLHORIZONTAL` | `60` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SKULLVERTICAL` | `61` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ASSASSIN` | `62` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_STEPSHORIZONTAL` | `63` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLOODYSTEPS` | `64` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_STEPSVERTICAL` | `65` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_YALAHARIGHOST` | `66` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BATS` | `67` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMOKE` | `68` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_INSECTS` | `69` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DRAGONHEAD` | `70` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ORCSHAMAN` | `71` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ORCSHAMAN_FIRE` | `72` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_THUNDER` | `73` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FERUMBRAS` | `74` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CONFETTI_HORIZONTAL` | `75` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CONFETTI_VERTICAL` | `76` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLACKSMOKE` | `158` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_REDSMOKE` | `167` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_YELLOWSMOKE` | `168` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREENSMOKE` | `169` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PURPLESMOKE` | `170` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_EARLY_THUNDER` | `171` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_RAGIAZ_BONECAPSULE` | `172` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CRITICAL_DAMAGE` | `173` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PLUNGING_FISH` | `175` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLUE_ENERGY_SPARK` | `176` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ORANGE_ENERGY_SPARK` | `177` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_ENERGY_SPARK` | `178` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_ENERGY_SPARK` | `179` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_ENERGY_SPARK` | `180` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_YELLOW_ENERGY_SPARK` | `181` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MAGIC_POWDER` | `182` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PIXIE_EXPLOSION` | `184` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PIXIE_COMING` | `185` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PIXIE_GOING` | `186` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_STORM` | `188` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_STONE_STORM` | `189` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLUE_GHOST` | `191` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_VORTEX` | `193` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_TREASURE_MAP` | `194` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_BEAM` | `195` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_FIREWORKS` | `196` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ORANGE_FIREWORKS` | `197` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_FIREWORKS` | `198` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLUE_FIREWORKS` | `199` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SUPREME_CUBE` | `201` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLACK_BLOOD` | `202` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PRISMATIC_SPARK` | `203` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_THAIAN` | `204` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_THAIAN_GHOST` | `205` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GHOST_SMOKE` | `206` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WATER_BLOCK_FLOATING` | `208` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WATER_BLOCK` | `209` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ROOTS` | `210` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GHOSTLY_SCRATCH` | `213` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GHOSTLY_BITE` | `214` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BIG_SCRATCH` | `215` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SLASH` | `216` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BITE` | `217` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CHIVALRIOUS_CHALLENGE` | `219` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DIVINE_DAZZLE` | `220` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ELECTRICALSPARK` | `221` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PURPLETELEPORT` | `222` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_REDTELEPORT` | `223` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_ORANGETELEPORT` | `224` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREYTELEPORT` | `225` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_LIGHTBLUETELEPORT` | `226` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FATAL` | `230` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DODGE` | `231` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HOURGLASS` | `232` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DAZZLING` | `233` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SPARKLING` | `234` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FERUMBRAS_1` | `235` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GAZHARAGOTH` | `236` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MAD_MAGE` | `237` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_HORESTIS` | `238` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DEVOVORGA` | `239` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_FERUMBRAS_2` | `240` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_SMOKE` | `241` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_SMOKES` | `242` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WATER_DROP` | `243` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_AVATAR_APPEAR` | `244` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DIVINE_GRENADE` | `245` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_DIVINE_EMPOWERMENT` | `246` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WATER_FLOATING_THRASH` | `247` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_AGONY` | `249` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_LOOT_HIGHLIGHT` | `252` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_MELTING_CREAM` | `263` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_REAPER` | `264` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_POWERFUL_HEARTS` | `265` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CREAM` | `266` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GENTLE_BUBBLE` | `267` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_STARBURST` | `268` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SIURP` | `269` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CACAO` | `270` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_CANDY_FLOSS` | `271` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_HITAREA` | `272` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_RED_HITAREA` | `273` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLUE_HITAREA` | `274` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_YELLOW_HITAREA` | `275` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_FLURRYOFBLOWS` | `276` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_FLURRYOFBLOWS` | `277` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_FLURRYOFBLOWS` | `278` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_ENERGYPULSE` | `279` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_ENERGYPULSE` | `280` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_ENERGYPULSE` | `281` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_TIGERCLASH` | `282` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_TIGERCLASH` | `283` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_TIGERCLASH` | `284` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_EXPLOSIONHIT` | `285` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_EXPLOSIONHIT` | `286` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLUE_EXPLOSIONHIT` | `287` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PINK_EXPLOSIONHIT` | `288` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_WHITE_ENERGYSHOCK` | `289` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_GREEN_ENERGYSHOCK` | `290` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_YELLOW_ENERGYSHOCK` | `291` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_INK_SPLASH` | `292` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_PAPER_PLANE` | `293` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SPIKES` | `294` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_BLOOD_RAIN` | `295` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_OPEN_BOOKMACHINE` | `296` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_OPEN_BOOKSPELL` | `297` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALL_WHITE_ENERGYSHOCK` | `298` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALL_GREEN_ENERGYSHOCK` | `299` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALL_PINK_ENERGYSHOCK` | `300` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALLWHITE_ENERGY_SPARK` | `301` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALLGREEN_ENERGY_SPARK` | `302` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_SMALLPINK_ENERGY_SPARK` | `303` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |
| `CONST_ME_LAST` | `304` | valid | Use with Position:sendMagicEffect / Game::addMagicEffect. Ensure effect is registered. |

## ShootType_t (ShootEffect)
Source: `crystalserver/src/utils/utils_definitions.hpp`.

| Name | Value | Status | Usage rules |
| --- | --- | --- | --- |
| `CONST_ANI_NONE` | `0` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SPEAR` | `1` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_BOLT` | `2` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ARROW` | `3` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_FIRE` | `4` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ENERGY` | `5` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_POISONARROW` | `6` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_BURSTARROW` | `7` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_THROWINGSTAR` | `8` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_THROWINGKNIFE` | `9` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SMALLSTONE` | `10` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_DEATH` | `11` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_LARGEROCK` | `12` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SNOWBALL` | `13` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_POWERBOLT` | `14` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_POISON` | `15` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_INFERNALBOLT` | `16` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_HUNTINGSPEAR` | `17` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ENCHANTEDSPEAR` | `18` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_REDSTAR` | `19` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_GREENSTAR` | `20` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ROYALSPEAR` | `21` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SNIPERARROW` | `22` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ONYXARROW` | `23` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_PIERCINGBOLT` | `24` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_WHIRLWINDSWORD` | `25` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_WHIRLWINDAXE` | `26` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_WHIRLWINDCLUB` | `27` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ETHEREALSPEAR` | `28` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ICE` | `29` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_EARTH` | `30` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_HOLY` | `31` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SUDDENDEATH` | `32` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_FLASHARROW` | `33` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_FLAMMINGARROW` | `34` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SHIVERARROW` | `35` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ENERGYBALL` | `36` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SMALLICE` | `37` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SMALLHOLY` | `38` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SMALLEARTH` | `39` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_EARTHARROW` | `40` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_EXPLOSION` | `41` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_CAKE` | `42` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_TARSALARROW` | `44` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_VORTEXBOLT` | `45` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_PRISMATICBOLT` | `48` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_CRYSTALLINEARROW` | `49` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_DRILLBOLT` | `50` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ENVENOMEDARROW` | `51` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_GLOOTHSPEAR` | `53` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SIMPLEARROW` | `54` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_LEAFSTAR` | `56` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_DIAMONDARROW` | `57` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_SPECTRALBOLT` | `58` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_ROYALSTAR` | `59` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_CANDYCANE` | `61` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_CHERRYBOMB` | `62` | valid | Use for distance effects (projectile animations). |
| `CONST_ANI_LAST` | `62` | legacy | Internal/marker value; do not send to client. |
| `CONST_ANI_WEAPONTYPE` | `254` | legacy | Internal/marker value; do not send to client. |

## SpeakClasses
Source: `crystalserver/src/utils/utils_definitions.hpp`.

| Name | Value | Status | Usage rules |
| --- | --- | --- | --- |
| `TALKTYPE_SAY` | `1` | valid | Use for creature/player speech types. |
| `TALKTYPE_WHISPER` | `2` | valid | Use for creature/player speech types. |
| `TALKTYPE_YELL` | `3` | valid | Use for creature/player speech types. |
| `TALKTYPE_PRIVATE_FROM` | `4` | valid | Use for creature/player speech types. |
| `TALKTYPE_PRIVATE_TO` | `5` | valid | Use for creature/player speech types. |
| `TALKTYPE_CHANNEL_MANAGER` | `6` | valid | Use for creature/player speech types. |
| `TALKTYPE_CHANNEL_Y` | `7` | valid | Use for creature/player speech types. |
| `TALKTYPE_CHANNEL_O` | `8` | valid | Use for creature/player speech types. |
| `TALKTYPE_SPELL_USE` | `9` | valid | Use for creature/player speech types. |
| `TALKTYPE_PRIVATE_NP` | `10` | valid | Use for creature/player speech types. |
| `TALKTYPE_NPC_UNKOWN` | `11` | legacy | Use for creature/player speech types. |
| `TALKTYPE_PRIVATE_PN` | `12` | valid | Use for creature/player speech types. |
| `TALKTYPE_BROADCAST` | `13` | valid | Use for creature/player speech types. |
| `TALKTYPE_CHANNEL_R1` | `14` | valid | Use for creature/player speech types. |
| `TALKTYPE_PRIVATE_RED_FROM` | `15` | valid | Use for creature/player speech types. |
| `TALKTYPE_PRIVATE_RED_TO` | `16` | valid | Use for creature/player speech types. |
| `TALKTYPE_MONSTER_SAY` | `36` | valid | Use for creature/player speech types. |
| `TALKTYPE_MONSTER_YELL` | `37` | valid | Use for creature/player speech types. |
| `TALKTYPE_MONSTER_LAST_OLDPROTOCOL` | `38` | legacy | Use for creature/player speech types. |
| `TALKTYPE_CHANNEL_R2` | `255` | valid | Use for creature/player speech types. |

## ProtocolGame client opcodes (recvbyte)
Source: `crystalserver/src/server/network/protocol/protocolgame.cpp` (`ProtocolGame::parsePacketFromDispatcher`).

| Opcode | Handler | Status | Usage rules |
| --- | --- | --- | --- |
| `0x14` | `logout(true, false);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x1D` | `g_game().playerReceivePingBack(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x1E` | `g_game().playerReceivePing(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x28` | `parseStashWithdraw(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x29` | `parseRetrieveDepotSearch(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x2A` | `parseCyclopediaMonsterTracker(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x2B` | `parsePartyAnalyzerAction(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x2C` | `parseLeaderFinderWindow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x2D` | `parseMemberFinderWindow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x32` | `parseExtendedOpcode(msg);` | valid | Client → server opcode; ExtendedOpcode payloads (OTClient). |
| `0x38` | `parsePlayerTyping(msg); // player are typing or not` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x60` | `parseInventoryImbuements(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x61` | `parseOpenWheel(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x62` | `parseSaveWheel(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x64` | `parseAutoWalk(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x65` | `g_game().playerMove(player->getID(), DIRECTION_NORTH);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x66` | `g_game().playerMove(player->getID(), DIRECTION_EAST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x67` | `g_game().playerMove(player->getID(), DIRECTION_SOUTH);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x68` | `g_game().playerMove(player->getID(), DIRECTION_WEST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x69` | `g_game().playerStopAutoWalk(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x6A` | `g_game().playerMove(player->getID(), DIRECTION_NORTHEAST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x6B` | `g_game().playerMove(player->getID(), DIRECTION_SOUTHEAST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x6C` | `g_game().playerMove(player->getID(), DIRECTION_SOUTHWEST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x6D` | `g_game().playerMove(player->getID(), DIRECTION_NORTHWEST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x6F` | `g_game().playerTurn(player->getID(), DIRECTION_NORTH);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x70` | `g_game().playerTurn(player->getID(), DIRECTION_EAST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x71` | `g_game().playerTurn(player->getID(), DIRECTION_SOUTH);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x72` | `g_game().playerTurn(player->getID(), DIRECTION_WEST);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x73` | `parseTeleport(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x77` | `parseHotkeyEquip(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x78` | `parseThrow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x79` | `parseLookInShop(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x7A` | `parsePlayerBuyOnShop(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x7B` | `parsePlayerSellOnShop(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x7C` | `g_game().playerCloseShop(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x7D` | `parseRequestTrade(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x7E` | `parseLookInTrade(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x7F` | `g_game().playerAcceptTrade(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x80` | `g_game().playerCloseTrade(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x81` | `parseFriendSystemAction(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x82` | `parseUseItem(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x83` | `parseUseItemEx(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x84` | `parseUseWithCreature(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x85` | `parseRotateItem(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x86` | `parseConfigureShowOffSocket(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x87` | `parseCloseContainer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x88` | `parseUpArrowContainer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x89` | `parseTextWindow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x8A` | `parseHouseWindow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x8B` | `parseWrapableItem(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x8C` | `parseLookAt(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x8D` | `parseLookInBattleList(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x8E` | `` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x8F` | `parseQuickLoot(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x90` | `parseLootContainer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x91` | `parseQuickLootBlackWhitelist(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x92` | `parseOpenDepotSearch();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x93` | `parseCloseDepotSearch();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x94` | `parseDepotSearchItemRequest(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x95` | `parseOpenParentContainer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x96` | `parseSay(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x97` | `g_game().playerRequestChannels(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x98` | `parseOpenChannel(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x99` | `parseCloseChannel(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x9A` | `parseOpenPrivateChannel(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x9E` | `g_game().playerCloseNpcChannel(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x9F` | `parseSetMonsterPodium(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA0` | `parseFightModes(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA1` | `parseAttack(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA2` | `parseFollow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA3` | `parseInviteToParty(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA4` | `parseJoinParty(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA5` | `parseRevokePartyInvite(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA6` | `parsePassPartyLeadership(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA7` | `g_game().playerLeaveParty(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xA8` | `parseEnableSharedPartyExperience(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xAA` | `g_game().playerCreatePrivateChannel(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xAB` | `parseChannelInvite(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xAC` | `parseChannelExclude(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xAD` | `parseCyclopediaHouseAuction(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xAE` | `parseSendBosstiary();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xAF` | `parseSendBosstiarySlots();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xB0` | `parseBosstiarySlot(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xB1` | `parseHighscores(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xB2` | `parseImbuementWindow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xB3` | `parseWeaponProficiency(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xBA` | `parseTaskHuntingAction(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xBE` | `g_game().playerCancelAttackAndFollow(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xBF` | `parseForgeEnter(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xC0` | `parseForgeBrowseHistory(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xC8` | `parseSelectSpellAimProtocol(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xC9` | `` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xCA` | `parseUpdateContainer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xCB` | `parseBrowseField(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xCC` | `parseSeekInContainer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xCD` | `parseInspectionObject(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xCF` | `sendBlessingWindow();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xD2` | `uint16_t startBufferPosition = msg.getBufferPosition(); const auto &outfitModule = g_modules().getEventByRecvbyte(0xD2, false); if (outfitModule) { outfitModule->executeOnRecvbyte(player, msg); } if (msg.getBufferPosition() == startBufferPosition) { g_game().playerRequestOutfit(player->getID()); }` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xD3` | `uint16_t startBufferPosition = msg.getBufferPosition(); const auto &outfitModule = g_modules().getEventByRecvbyte(0xD3, false); if (outfitModule) { outfitModule->executeOnRecvbyte(player, msg); } if (msg.getBufferPosition() == startBufferPosition) { parseSetOutfit(msg); }` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xD4` | `parseToggleMount(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xD5` | `parseApplyImbuement(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xD6` | `parseClearImbuement(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xD7` | `parseCloseImbuementWindow(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xDC` | `parseAddVip(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xDD` | `parseRemoveVip(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xDE` | `parseEditVip(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xDF` | `parseVipGroupActions(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE1` | `parseBestiarySendRaces();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE2` | `parseBestiarySendCreatures(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE3` | `parseBestiarysendMonsterData(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE4` | `parseSendBuyCharmRune(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE5` | `parseCyclopediaCharacterInfo(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE6` | `parseBugReport(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE7` | `parseWheelGemAction(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xE8` | `parseOfferDescription(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xEB` | `parsePreyAction(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xED` | `parseSendResourceBalance();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xEE` | `parseGreet(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF0` | `g_game().playerShowQuestLog(player->getID());` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF1` | `parseQuestLine(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF3` | `` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF4` | `parseMarketLeave();` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF5` | `parseMarketBrowse(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF6` | `parseMarketCreateOffer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF7` | `parseMarketCancelOffer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF8` | `parseMarketAcceptOffer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xF9` | `parseModalWindowAnswer(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0xFF` | `parseRewardChestCollect(msg);` | valid | Client → server opcode; handled by ProtocolGame. |
| `0x0F` | `disconnect/respawn flow (parsePacketDead)` | valid | Client → server opcode; handled in death/connection flow. |
