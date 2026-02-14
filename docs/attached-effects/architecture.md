# Arquitetura interna do AttachedEffects

## 1) O que é um `AttachedEffect`
No cliente, `AttachedEffect` é um `LuaObject` renderizável com estado gráfico próprio (shader, opacity, light, drawOrder, offset direcional, timers de animação e flags de comportamento). Ele pode referenciar:
- `ThingType` (`m_thingId` + `m_thingCategory`), ou
- `Texture` externa (`m_texturePath`), incluindo caminho para textura animada.

Ele também suporta composição (`std::vector<AttachedEffectPtr> m_effects`) para construir efeitos filhos.

## 2) Armazenamento interno
### Cliente
- Dono: `AttachableObject::Data::attachedEffects` (vetor de `AttachedEffectPtr`).
- Cada `Thing`/`Creature`/`Tile`/`Item` herdando de `AttachableObject` pode conter lista própria.
- Controle de ocultação do dono: contador `m_ownerHidden` incrementado/decrementado por efeitos com `hideOwner`.

### Servidor
- `Creature` mantém apenas IDs (`std::vector<uint16_t> attachedEffectList`) para sincronização de estado.
- Metadados (nome/ID) de wing/aura/effect/shader vêm de `AttachedEffects` carregado do XML.

## 3) Onde fica a lista por criatura
- Cliente: em `AttachableObject::Data` acessível por `Creature::getAttachedEffects()`.
- Servidor: `Creature::attachedEffectList`.

## 4) Ciclo de vida completo

### Criação
- `AttachedEffectManager::registerByThing/registerByImage` cria protótipos.
- `AttachedEffectManager::getById` devolve clone.
- Lua também pode criar on-the-fly: `AttachedEffect.create(thingId, category)`.

### Inicialização
- Configuração de parâmetros no Lua (`lib.lua`): speed, shader, opacity, size, bounce/pulse/fade, duration, loop, transform, offsets, light etc.
- Em `attachEffect`, evento `onStartAttachEffect` é chamado imediatamente; callback Lua (`onAttach`) é disparado via dispatcher assíncrono.

### Atualização
- Timers internos:
  - `m_animationTimer` para fase;
  - timers em `Bounce` para bounce/pulse/fade;
- movimentação temporal por `move(from,to)` produz `m_toPoint` interpolado durante `duration`.

### Renderização
- Cada frame: dono chama `drawAttachedEffect(..., isOnTop=false)` e depois `isOnTop=true`.
- Efeito filtra por `DirControl.onTop` e direção corrente.
- Pode desenhar `ThingType::draw` ou textura externa.

### Remoção
- Manual: `detachEffect`, `detachEffectById`, `clear*`.
- Automática:
  - por `duration` via `scheduleEvent` no attach;
  - por loop (`m_loop`) quando encerra ciclo de animação;
  - por clear de temporários/permanentes.

## 5) Offsets
- Estrutura por direção (`m_offsetDirections[dir]`) com `{ onTop, offset }`.
- `setOffset` aplica em todas direções.
- `setDirOffset` permite ajuste fino por direção.
- Posição final = `dest - offset*scale + deslocamentoInterpolado - bounce`.

## 6) Animações
- Se textura animada: usa `AnimatedTexture::get(frame,timer)`.
- Se DAT com animator: usa `Animator::getPhaseAt`.
- Se `ThingType::isEffect()`: avança por `effectTicksPerFrame / speed` e reinicia no final.
- Para criaturas `animateAlways`: fase periódica por clock global.

## 7) Recursos suportados (estado atual)
- **APNG**: suportado indiretamente via `registerByImage` + `AnimatedTexture` (dependente do loader de textura).
- **Spritesheet DAT**: sim, via `ThingType` e animators.
- **Looping**: sim (`setLoop`, contador decremente em wrap para fase 0).
- **Temporizadores**: sim (`duration`, timers de bounce/pulse/fade).
- **Blend modes**: não há API dedicada por efeito; usa pipeline padrão de draw pool.
- **Shader binding**: sim (`AttachedEffect::setShader`).

## Diagrama textual
```text
registerByThing/Image -> prototype
        |
        v
getById -> clone -> attachEffect(owner)
        |
        +-- onStartAttachEffect (C++)
        +-- schedule duration remove
        +-- onAttach (Lua via dispatcher)

frame loop:
owner.draw -> drawAttachedEffect(bottom)
           -> draw owner thing
           -> drawAttachedEffect(top)
           -> drawAttachedParticles

detach:
manual / duration / loop-end / clear
        -> onStartDetachEffect (C++)
        -> onDetach (Lua)
```

## Pontos críticos e possíveis bugs
- `setOffset(x,y,true)` usado em exemplo Lua, mas assinatura C++ aceita só `(x,y)`; terceiro parâmetro é ignorado no binding (inconsistência API de exemplo).
- No `lib.lua`, branch `if type(x) == 'boolean'` dentro de `dirOffset` parece bug lógico (deveria checar `_x` ou config), potencialmente código morto.
- Em draw, existe cuidado explícito para não “vazar” estado de shader/opacidade, indicando bug histórico de state leak já mitigado.
