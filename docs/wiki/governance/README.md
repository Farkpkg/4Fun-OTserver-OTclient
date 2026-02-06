<!-- tags: - governance - docs priority: high -->

## LLM Summary
- **What**: Regras e padrões da wiki.
- **Why**: Garante consistência e sustentabilidade.
- **Where**: docs/wiki/governance
- **How**: Define padrões, links, e processo de atualização.
- **Extends**: Adicionar regras e processos.
- **Risks**: Quebra de padrão gera documentação inconsistente.

[Wiki](../README.md) > Governança

# Governança da Wiki

## Objetivo
Definir padrões e processos para manter a wiki consistente, atualizada e escalável conforme o projeto evolui.

## Padrões de documentação
- **Formato**: Markdown com títulos claros (`##`, `###`) e listas para estrutura.
- **Escopo**: documentar o que existe no repositório; evitar suposições.
- **Exemplos**: usar trechos pequenos, reais e referenciados por arquivo.
- **Citações**: toda afirmação factual deve ter referência a arquivo real.

## Convenções de nomes
- Pastas e arquivos em **kebab-case**.
- Nomes de sistema iguais aos usados no código (ex.: `protocol`, `game-systems/combate`).
- README principal de cada seção em `README.md`.

## Como adicionar novos sistemas
1. Criar pasta em `docs/wiki/game-systems/<nome>/`.
2. Adicionar `README.md` com: visão geral, arquivos envolvidos, fluxo geral, pontos de extensão.
3. Incluir o novo sistema nos índices:
   - `docs/wiki/README.md`
   - `docs/wiki/INDICES.md`
4. Se houver dependência crítica, registrar no roadmap (`docs/wiki/roadmap.md`).

## Como atualizar páginas existentes
- Preferir **edições incrementais**, mantendo histórico das referências.
- Sempre atualizar **links de navegação** quando um documento novo é criado.
- Se um caminho do repositório mudar, atualizar todos os links em backticks.

## Regras para links e breadcrumbs
- Breadcrumbs no topo da página: `[Wiki](../README.md) > Seção`.
- Links sempre relativos ao documento atual.
- Evitar links quebrados: validar após mudanças estruturais.

## Política para evitar arquivos órfãos
- Todo arquivo de documentação deve ser linkado a partir do hub ou índices.
- Todo sistema crítico deve ter **pelo menos uma página dedicada**.
- Documentos novos devem ser incluídos no índice apropriado.

## Detecção de órfãos
- Relatório de órfãos: `docs/wiki/governance/orphans.md`.
- Revisar o relatório a cada ciclo de documentação.

## Automação e manutenção
- Plano de atualização e scripts sugeridos em `docs/wiki/governance/automation.md`.
