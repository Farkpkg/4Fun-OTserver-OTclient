---
alwaysApply: true
---

# OTClient Agent Map

## Visão Geral

Este arquivo é a base para organização dos AGENTS do projeto. O objetivo é ampliar a documentação para LLMs (como o Codex), mantendo os guias sempre crescendo sem duplicar informação. A partir daqui deve ser possível identificar rapidamente qual AGENT ler para cada tipo de problema ou feature. Antes de usar guias locais, leia as regras globais em `/home/jp/.codex/AGENTS.md`.

## Linguagem e estilo dos AGENTS

- Escreva em PT-BR, com termos técnicos em inglês quando forem nomes do engine ou APIs.
- Use frases curtas e diretas; prefira listas.
- Deixe claro o escopo logo no início.
- Evite duplicar conteúdo entre AGENTS; referencie o guia correto.
- Mantenha exemplos mínimos e focados no fluxo do projeto.
- Ao adicionar informações novas, sempre decidir em qual AGENT elas pertencem e atualizar o índice se necessário.
- Quando um AGENT ficar grande, criar um AGENT em subpasta e mover o conteúdo para lá, deixando no guia pai apenas o mapa e os links.

## Onde encontrar cada guia

- `src/AGENTS.md`: core C++, protocolo e arquitetura do cliente.
- `modules/AGENTS.md`: módulos, Lua e UI em HTML/CSS.
- `data/AGENTS.md`: OTUI, layouts e propriedades de widgets.
- `tools/AGENTS.md`: build, CLI, encrypt, launcher e scripts.

## Documentacao local (.md)

- Algumas pastas podem conter arquivos `.md` adicionais com documentacao especifica (ex.: `src/client/world.md`).
- Esses arquivos complementam os AGENTS e servem como referencia direta do trecho do repositorio.

## Estratégia de crescimento

- Comece documentando no nível mais alto da pasta.
- Quando crescer demais, quebre por subpasta (ex.: `src/client/AGENTS.md`).
- O guia pai deve virar índice e apontar quais subguias ler.
- Use informações do Deep Wiki para enriquecer os guias, sem duplicar conteúdo.
- Durante a construção da wiki, reaproveite sempre os guias existentes e crie novos apenas quando o tema exigir maior profundidade.
- Quando o assunto culminar em um módulo específico (ex.: `corelib`, `gamelib`, `game_*`), crie um `AGENTS.md` dentro do módulo e referencie o C++ como fonte principal.

## Notas rápidas do projeto

- Para build, encrypt e launcher, consulte `tools/AGENTS.md`.
