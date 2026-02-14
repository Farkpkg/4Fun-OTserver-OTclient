# Pipeline de renderização dos AttachedEffects

## Ponto de inserção no pipeline

### Creature
Ordem em `Creature::internalDraw`:
1. `drawAttachedEffect(..., false)` (**bottom**)
2. render da criatura/mount/paperdolls
3. `drawAttachedEffect(..., true)` (**top**)
4. partículas anexadas

### Item
Mesma estratégia: before/after `ThingType::draw`.

### Tile
- bottom attachments desenhados após ground/bottom layer;
- top attachments desenhados após creature/top;
- partículas anexadas por fim.

## Ordem e camada
- Não é uma camada global separada: depende do dono e de `onTop` por direção.
- Dentro do draw de mapa, efeito pode sobrescrever draw order (`m_drawOrder`) quando `DrawPoolType::MAP`.

## draw(), drawSelf(), drawCreature()
- `AttachedEffect::draw` é o ponto real de render do efeito.
- `Tile::drawCreature` permanece separado e não substitui o fluxo de attached effects.
- Não há `drawSelf` específico para `AttachedEffect`; a semântica equivalente é `draw`.

## FrameBuffer / OpenGL / GLSL
- Draw do efeito vai para `g_drawPool`.
- Em draw de UI da criatura (`Creature::draw(Rect...)`) há `bindFrameBuffer` antes de `internalDraw`, portanto attached effects também passam por esse FBO.
- Shader GLSL é aplicado via `g_drawPool.setShaderProgram(m_shader, true)` por efeito.

## Shader por efeito
Suportado diretamente:
- `AttachedEffect::setShader(name)` resolve em `PainterShaderProgramPtr`.
- Durante draw, shader é ativado por efeito individual.

## Batching
- O draw pool agrega chamadas (`addTexturedRect`, draw de thing type).
- Não há sistema especializado de instancing para attached effects; batching depende do draw pool/global renderer state.

## Performance
### Custos principais
- múltiplos efeitos por criatura aumentam draw calls e mudanças de estado (shader/opacidade/escala);
- efeitos com textura animada exigem atualização de frame;
- composição de subefeitos (`attachEffect` em cascata) cresce recursivamente o custo.

### Mitigações existentes
- early return para camadas incompatíveis (`onTop`/`canDrawOnUI`);
- prevenção explícita de state leak de shader/opacidade;
- remoção automática de loops concluídos e durations expiradas.

### Riscos
- attach massivo em raids/eventos pode gerar pressão de dispatcher (muitos detach events).
- setScaleFactor/setOpacity frequentes podem quebrar eficiência de lote dependendo da ordem de materiais.
