# Network Integration

## Cadeia server -> client

## 1. Payload de outfit (canal principal)
- Server preenche `Outfit_t` com:
  - `lookWing`, `lookAura`, `lookEffect`, `lookShader`
- Envio no outfit window e em mudanças de outfit.
- Client parseia em `ProtocolGame::getOutfit` e grava no `Outfit` local.
- Client também envia de volta em `sendChangeOutfit`.

## 2. Eventos incrementais OTCR

### Servidor envia
- `0x34`: attach effect `(creatureId:uint32, effectId:uint16)`
- `0x35`: detach effect `(creatureId:uint32, effectId:uint16)`
- `0x36`: creature shader `(creatureId:uint32, shaderName:string)`
- `0x37`: map shader `(shaderName:string)`

### Cliente recebe (enum Proto)
- `GameServerAttchedEffect = 52`
- `GameServerDetachEffect = 53`
- `GameServerCreatureShader = 54`
- `GameServerMapShader = 55`

## 3. Outras mensagens de effects
- `GameServerGraphicalEffect = 131` -> `parseMagicEffect`
- `GameServerTextEffect = 132` (inclui caminho de remoção custom)
- `GameServerMissleEffect = 133`

## 4. Network message structures (resumo)

- **Attach/Detach**
  - byte opcode
  - u32 creature id
  - u16 attached effect id
- **Creature shader**
  - byte opcode
  - u32 creature id
  - string shader
- **Map shader**
  - byte opcode
  - string shader
- **Outfit estendido (OTCR)**
  - wing u16
  - aura u16
  - effect u16
  - shader string

## 5. Consistência e validação

- Server valida ownership e catálogo antes de aplicar.
- Client valida existência do effect id em `g_attachedEffects` e ignora ids inválidos.
- `ThingType`/dat id inválido gera log e aborta render/parse.

## Riscos

- Divergência de catálogo server/client (id existe no server mas não no client) quebra visual sem quebrar sessão.
- Uso misto de id numérico e string de shader aumenta chance de mismatch de nome.

## Melhorias

- Versionamento de catálogo de attached effects no handshake.
- Mensagem de erro opcional para diagnosticar ids desconhecidos no client.
