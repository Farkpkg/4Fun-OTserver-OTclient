<!-- tags: - assets - client priority: medium -->

## LLM Summary
- **What**: Assets usados pelo OTClient (imagens, sons, estilos).
- **Why**: Suporta renderização e UI.
- **Where**: otclient/data
- **How**: Carregados pelo framework durante o bootstrap.
- **Extends**: Adicionar assets e referenciar em módulos/UI.
- **Risks**: Assets ausentes quebram UI/render.

[Wiki](../README.md) > Assets

# Assets

## Visão geral
Assets incluem imagens, sprites, fontes, sons e estilos usados pelo OTClient para renderização e UI.

## Localização no repositório
- `otclient/data/` — imagens, fontes, sons, partículas, estilos e things.

## Estrutura interna (alto nível)
- `images/`, `cursors/`, `particles/` — recursos gráficos.
- `fonts/`, `sounds/` — fontes e áudio.
- `styles/` — estilos e definição visual (OTUI/OTML).
- `things/` — assets de entidades do jogo.

## Fluxo de execução (alto nível)
- Assets são carregados pelo framework do cliente durante a inicialização e conforme módulos de UI são exibidos.

## Integrações
- **UI**: estilos e layouts em `otclient/data/styles/`.
- **Cliente**: sprites e things usados no render do mapa e criaturas.
