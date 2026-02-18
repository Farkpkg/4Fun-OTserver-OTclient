---
alwaysApply: true
---
# Guia de Client Styles (Styles/Fonts/Particles)

## Escopo

Este guia cobre `modules/client_styles`, responsavel por carregar styles OTUI, fonts e particulas.

## Arquivos principais

- `modules/client_styles/styles.lua`
- `modules/client_styles/styles.otmod`

## O que carrega

- `data/styles/*.otui` via `g_ui.importStyle`.
- `data/fonts/*.otfont` via `g_fonts.importFont`.
- `data/particles/*.otps` via `g_particles.importParticle`.
- Cursores em `data/cursors/` via `g_mouse.loadCursors`.
- Fontes de config via `g_gameConfig.loadFonts()`.

## Onde editar

- Logica de carregamento e fallback: `styles.lua`.

## Relacionados

- `data/AGENTS.md` (estrutura da pasta data).
- `src/framework/ui/AGENTS.md` (UI e import de styles).
- `src/framework/graphics/AGENTS.md` (particulas e draw).
