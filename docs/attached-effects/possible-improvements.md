# Possíveis melhorias e refatorações

## 1) Consistência de API Lua
- Corrigir exemplos que chamam `setOffset(x,y,true)` (assinatura atual não aceita 3º parâmetro).
- Corrigir branch `type(x) == 'boolean'` em `dirOffset` (erro provável de variável).
- Publicar schema formal de config de effect.

## 2) Robustez do ciclo de vida
- Introduzir ID único de instância para debug/telemetria.
- Evitar dupla remoção em cenários de duration + loop simultâneos (guardas explícitas).
- Adicionar validação de `m_duration == 0` em `move` para evitar divisão por zero implícita em fração.

## 3) Render e estado gráfico
- encapsular estado de shader/opacidade/scale em RAII guard para reduzir chance de vazamento.
- avaliar “material key” para batching melhor (texture+shader+blend).

## 4) Rede e compatibilidade
- substituir opcodes mágicos (`0x34..0x38`) por enum compartilhado/constexpr no servidor para manutenção.
- documentar versão mínima do feature set (OTCR/feature flags) em artefato central.

## 5) Arquitetura cross-layer
- hoje há dois modelos:
  1) attached effects renderizados no cliente por ID;
  2) wings/aura/effect/shader como atributos de outfit + storage.

  Unificar metamodelo evitaria duplicidade entre “effect em lista” e “effect no outfit”.

## 6) Engenharia reversa vs OTClient padrão
Mudanças custom relevantes desta fork:
- opcodes custom para attach/detach/shader/mapshader;
- feature `GameWingsAurasEffectsShader` acoplada ao outfit;
- `ThingExternalTexture` e módulo Lua de alto nível para registro dinâmico;
- integração servidor com XML `attachedeffects.xml` + storages de unlock.

Isso indica uma extensão além do OTClient clássico, focada em cosméticos dinâmicos e pipeline híbrido outfit+effect.
