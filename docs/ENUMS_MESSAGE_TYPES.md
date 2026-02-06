# MessageTypes (Crystal Server core)

Fonte: `crystalserver/src/utils/utils_definitions.hpp` (enum `MessageClasses`).

| Nome | Valor | Origem | Uso correto | Uso proibido |
| --- | --- | --- | --- | --- |
| `MESSAGE_NONE` | `0` | `crystalserver/src/utils/utils_definitions.hpp:366` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_GAMEMASTER_CONSOLE` | `13` | `crystalserver/src/utils/utils_definitions.hpp:368` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_LOGIN` | `17` | `crystalserver/src/utils/utils_definitions.hpp:371` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_ADMINISTRATOR` | `18` | `crystalserver/src/utils/utils_definitions.hpp:372` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_EVENT_ADVANCE` | `19` | `crystalserver/src/utils/utils_definitions.hpp:373` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_GAME_HIGHLIGHT` | `20` | `crystalserver/src/utils/utils_definitions.hpp:374` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_FAILURE` | `21` | `crystalserver/src/utils/utils_definitions.hpp:375` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_LOOK` | `22` | `crystalserver/src/utils/utils_definitions.hpp:376` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_DAMAGE_DEALT` | `23` | `crystalserver/src/utils/utils_definitions.hpp:377` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_DAMAGE_RECEIVED` | `24` | `crystalserver/src/utils/utils_definitions.hpp:378` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_HEALED` | `25` | `crystalserver/src/utils/utils_definitions.hpp:379` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_EXPERIENCE` | `26` | `crystalserver/src/utils/utils_definitions.hpp:380` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_DAMAGE_OTHERS` | `27` | `crystalserver/src/utils/utils_definitions.hpp:381` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_HEALED_OTHERS` | `28` | `crystalserver/src/utils/utils_definitions.hpp:382` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_EXPERIENCE_OTHERS` | `29` | `crystalserver/src/utils/utils_definitions.hpp:383` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_STATUS` | `30` | `crystalserver/src/utils/utils_definitions.hpp:384` | Utilizar em player:sendTextMessage conforme severidade. | Não utilizar no sistema de Linked Tasks; manter apenas tipos aprovados pelo projeto. |
| `MESSAGE_LOOT` | `31` | `crystalserver/src/utils/utils_definitions.hpp:385` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_TRADE` | `32` | `crystalserver/src/utils/utils_definitions.hpp:386` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_GUILD` | `33` | `crystalserver/src/utils/utils_definitions.hpp:387` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_PARTY_MANAGEMENT` | `34` | `crystalserver/src/utils/utils_definitions.hpp:388` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_PARTY` | `35` | `crystalserver/src/utils/utils_definitions.hpp:389` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_LAST_OLDPROTOCOL` | `37` | `crystalserver/src/utils/utils_definitions.hpp:391` | Evitar: tipo legado/sem efeito. | Não utilizar em mensagens ao jogador. |
| `MESSAGE_REPORT` | `38` | `crystalserver/src/utils/utils_definitions.hpp:393` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_HOTKEY_PRESSED` | `39` | `crystalserver/src/utils/utils_definitions.hpp:394` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_TUTORIAL_HINT` | `40` | `crystalserver/src/utils/utils_definitions.hpp:395` | Evitar: tipo legado/sem efeito. | Não utilizar em mensagens ao jogador. |
| `MESSAGE_THANK_YOU` | `41` | `crystalserver/src/utils/utils_definitions.hpp:396` | Evitar: tipo legado/sem efeito. | Não utilizar em mensagens ao jogador. |
| `MESSAGE_MARKET` | `42` | `crystalserver/src/utils/utils_definitions.hpp:397` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_MANA` | `43` | `crystalserver/src/utils/utils_definitions.hpp:398` | Evitar: tipo legado/sem efeito. | Não utilizar em mensagens ao jogador. |
| `MESSAGE_BEYOND_LAST` | `44` | `crystalserver/src/utils/utils_definitions.hpp:399` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_ATTENTION` | `48` | `crystalserver/src/utils/utils_definitions.hpp:400` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_BOOSTED_CREATURE` | `49` | `crystalserver/src/utils/utils_definitions.hpp:401` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_OFFLINE_TRAINING` | `50` | `crystalserver/src/utils/utils_definitions.hpp:402` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_TRANSACTION` | `51` | `crystalserver/src/utils/utils_definitions.hpp:403` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
| `MESSAGE_POTION` | `52` | `crystalserver/src/utils/utils_definitions.hpp:404` | Utilizar em player:sendTextMessage conforme severidade. | Não enviar múltiplos MessageTypes na mesma ação. |
