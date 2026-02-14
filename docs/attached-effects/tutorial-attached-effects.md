# Tutorial Técnico — Attached Effects (OTClient + OTServer)

> Este documento **complementa** a documentação existente com base no conteúdo consolidado da Wiki **"Tutorial Attached Effects"**, adotado aqui como fonte oficial para operação do sistema.

## 1. Conceito do sistema

**Attached Effects** é um sistema do OTClient para anexar efeitos visuais dinâmicos a entidades do jogo, principalmente:

- **Creatures** (player/monstros/NPCs)
- **Tiles**
- **Widgets/UI** (quando exposto por camada de render)

Os efeitos são renderizados como camadas adicionais sobre/abaixo do sprite base e podem representar:

- asas
- auras
- fogo
- brilho
- partículas decorativas
- composições visuais em cascata

No cliente, a implementação principal está no módulo:

- `modules/game_attachedeffects/effects.lua`

E os assets normalmente ficam em:

- `data/images/game/effects/`

---

## 2. Capacidades visuais suportadas

O sistema suporta, entre outros:

- texturas estáticas (**PNG**)
- texturas animadas (**APNG**)
- offsets por eixo (`offsetX`, `offsetY`)
- rotação/ajuste por direção da criatura
- acoplamento fixo ou sincronizado com animação de movimento
- efeito temporário com remoção automática (`duration`)
- adição/remoção dinâmica em runtime

---

## 3. Registro de efeitos no cliente (Lua)

Efeitos são declarados no registro Lua com metadados de render. Estrutura base recomendada:

- `id`
- `name`
- `texture`
- `offsetX`
- `offsetY`
- `speed`
- `loop`
- `opacity`
- `duration`
- `onTop`
- `directionBasedOffset`
- `transform`

### 3.1 Semântica das propriedades críticas

- **`directionBasedOffset`**: permite deslocamentos distintos por direção (N/S/E/W), essencial para alinhar asas/aura em outfits diferentes.
- **`onTop`**: controla ordem de desenho (acima/abaixo da camada principal).
- **`loop`**: determina se animação reinicia automaticamente.
- **`duration`**: timeout em ms para auto-detach.
- **`transform`**: transformações de escala/rotação/composição (dependendo do preset).

---

## 4. Fluxo de aplicação em criaturas

Fluxo funcional esperado:

1. OTServer decide aplicar/remover um efeito.
2. Servidor envia comando de attach/detach (ou estado no snapshot).
3. OTClient resolve `effectId` no registry local.
4. Cliente executa `attachEffect`/`detachEffect` no objeto alvo.
5. Render pipeline inclui a camada adicional até remoção.

No lado de API de criatura no cliente, as operações centrais são:

- `attachEffect(effectId)`
- `detachEffect(effectId)`

> Observação prática de integração OTServer: no scripting Lua do servidor, o padrão costuma ser expor algo como `creature:attachEffectById(id[, temporary])` e `creature:detachEffectById(id)` para acionar os mesmos eventos de rede.

---

## 5. Exemplos Lua (lado servidor)

Os exemplos abaixo mostram padrões de uso no servidor para acionar os efeitos no cliente.

### 5.1 Exemplo básico: `attachEffect`

```lua
-- Exemplo: aplicar aura ao entrar em área especial
local AURA_EFFECT_ID = 8

local moveEvent = MoveEvent()

function moveEvent.onStepIn(creature, item, position, fromPosition)
    if not creature or not creature:isPlayer() then
        return true
    end

    -- API comum no OTServer custom:
    creature:attachEffectById(AURA_EFFECT_ID)
    creature:sendTextMessage(MESSAGE_STATUS_SMALL, "Aura ativada.")
    return true
end

moveEvent:type("stepin")
moveEvent:aid(45001)
moveEvent:register()
```

### 5.2 Exemplo básico: `detachEffect`

```lua
-- Exemplo: remover aura ao sair da área
local AURA_EFFECT_ID = 8

local moveEvent = MoveEvent()

function moveEvent.onStepOut(creature, item, position, fromPosition)
    if not creature or not creature:isPlayer() then
        return true
    end

    creature:detachEffectById(AURA_EFFECT_ID)
    creature:sendTextMessage(MESSAGE_STATUS_SMALL, "Aura removida.")
    return true
end

moveEvent:type("stepout")
moveEvent:aid(45001)
moveEvent:register()
```

### 5.3 Exemplo temporário (efeito com duração de gameplay)

```lua
-- Exemplo: buff de 10s com efeito visual
local BUFF_EFFECT_ID = 7
local BUFF_DURATION_MS = 10 * 1000

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    if not creature then
        return false
    end

    creature:attachEffectById(BUFF_EFFECT_ID, true) -- temporary=true, se suportado

    addEvent(function(cid, effectId)
        local player = Player(cid)
        if player then
            player:detachEffectById(effectId)
        end
    end, BUFF_DURATION_MS, creature:getId(), BUFF_EFFECT_ID)

    return true
end

spell:name("Visual Buff")
spell:words("utori vis")
spell:register()
```

> Ajuste nomes/assinaturas conforme a API Lua específica da sua base OTServer.

---

## 6. Suporte a partículas

Attached Effects também pode ser usado para partículas decorativas, desde que o preset respeite:

- tempo de vida (`duration`)
- repetição (`loop`)
- posição relativa ao owner
- offsets por direção

Para cenários com muitos efeitos simultâneos, limitar quantidade por criatura reduz custo de draw e overdraw.

---

## 7. Requisitos de protocolo cliente-servidor

Para funcionamento consistente em produção, garantir:

1. **Comandos de attach/detach no protocolo**
   - envio incremental ao aplicar/remover efeito em runtime.
2. **Feature flag habilitada no cliente**
   - ex.: `GameCreatureAttachedEffect`.
3. **Mapeamento estável de `effectId`**
   - IDs no servidor devem corresponder ao registro do cliente.
4. **Sincronização por snapshot + incremental**
   - snapshot inicial ao entrar em range/login + updates posteriores.
5. **Resync em eventos de estado**
   - outfit change, death/respawn, teleport e outras transições.

### 7.1 Checklist de compatibilidade

- [ ] Cliente com módulo `game_attachedeffects` carregado
- [ ] Catálogo de efeitos alinhado entre server/client
- [ ] Opções de feature habilitadas na versão do protocolo
- [ ] Attach/detach disparados para espectadores relevantes
- [ ] Limpeza de efeitos em remoções de criatura e troca de contexto

---

## 8. Boas práticas

### 8.1 Design de conteúdo visual

- Padronize convenção de IDs por categoria (aura, wing, fx utilitário).
- Evite offsets mágicos sem comentário; documente por looktype quando necessário.
- Prefira APNG curta e otimizada para efeitos contínuos.

### 8.2 Integração e sincronização

- Trate attach/detach como **estado replicado**, não apenas evento visual.
- Reaplique efeitos persistentes após outfit update e teleporte.
- Garanta detach explícito em logout/death para evitar efeito “fantasma”.

### 8.3 Performance

- Evite empilhar muitos efeitos `onTop` em personagens densos na tela.
- Use `duration` para efeitos transitórios ao invés de loop infinito.
- Limite composição recursiva de subefeitos em cadeia.

### 8.4 Operação e manutenção

- Mantenha tabela mestre de `effectId -> nome -> asset -> owner`.
- Valide assets faltantes em pipeline de build/deploy.
- Faça smoke tests com múltiplos clientes em situações de troca rápida de estado.

---

## 9. Guia rápido de troubleshooting

- **Efeito não aparece:** conferir feature flag, ID e asset path.
- **Offset quebrado por direção:** revisar `directionBasedOffset`.
- **Efeito preso após remover outfit:** forçar `detachEffect` no evento de troca.
- **Diferença entre clientes:** validar cache de assets/APNG e versão de módulo.

---

## 10. Resumo operacional

Attached Effects deve ser tratado como uma camada visual replicada com contrato explícito entre servidor, protocolo e registro Lua do cliente. O sucesso da integração depende de:

- catálogo de IDs consistente;
- envio correto de attach/detach + snapshot;
- configuração de render (offset/camada/duração) adequada ao tipo de conteúdo.
