# Dependency Map

## Diagrama textual solicitado

```text
Servidor
   ↓
Protocol
   ↓
NetworkMessage
   ↓
Creature
   ↓
AttachedEffect / Shader
   ↓
Renderer
   ↓
GPU
```

## Explicação etapa por etapa

1. **Servidor**
   - `Game`, `Creature`, `PlayerAttachedEffects`, `AttachedEffects` determinam quais wings/auras/effects/shaders estão ativos.

2. **Protocol**
   - `ProtocolGame` serializa alterações (outfit + opcodes custom 0x34-0x37).

3. **NetworkMessage**
   - Estruturas binárias com ids, strings e flags de feature.
   - No cliente, `InputMessage` é consumida por `ProtocolGame::parse*`.

4. **Creature**
   - Cliente resolve `creatureId`, aplica `attachEffect/detachEffectById/setShader` no objeto runtime.
   - Outfit também injeta wing/aura/effect/shader pela via de troca de outfit.

5. **AttachedEffect / Shader**
   - `AttachedEffect` define comportamento visual e timing.
   - `ShaderManager` entrega programas GLSL por nome/id para map, outfit e mount.

6. **Renderer**
   - `DrawPool`/`DrawPoolManager` fazem batching, binding de shader, FBO passes, draw order e flush.
   - `MapView` e `Creature::internalDraw` coordenam ordem final.

7. **GPU**
   - OpenGL executa vertex+fragment shaders, sampling de texturas e blending/composition.

## Dependências cruzadas (resumo)

- Outfit ↔ Creature: estado visual lógico.
- Creature ↔ AttachableObject: storage e lifecycle de anexos.
- AttachableObject ↔ ParticleManager: partículas anexadas.
- ShaderManager ↔ DrawPool/Painter: aplicação de programas GLSL.
- Protocol ↔ Feature Flags: shape do payload muda por versão/feature.

## Possíveis sistemas inacabados

- Comentários e trechos indicam migração parcial para paperdoll e caminhos alternativos de attachment.
- Alguns hooks e campos estão presentes para extensões futuras (uniforms de item/outfit/mount, callbacks custom).
