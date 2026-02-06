[Wiki](../README.md) > [Governança](README.md) > Automação

# Automação de atualização da wiki

## Objetivo
Definir um fluxo simples e sustentável para manter métricas, detectar mudanças relevantes e evitar documentação desatualizada.

## Scripts propostos (não implementados)
> Estes scripts são descritos para padronizar a manutenção. A implementação pode ser feita futuramente em `tools/`.

### 1) `wiki-metrics`
- **Função**: atualizar `docs/wiki/METRICAS.md`.
- **Saídas**:
  - contagem de arquivos/pastas do repositório;
  - número de páginas da wiki;
  - contagem de referências (paths em backticks).

### 2) `wiki-orphans`
- **Função**: detectar caminhos não referenciados pela wiki.
- **Saídas**:
  - relatório em `docs/wiki/governance/orphans.md`;
  - classificação (crítico/legado/assets/scripts);
  - sugestões de onde linkar.

### 3) `wiki-diff-watch`
- **Função**: listar mudanças relevantes (ex.: alterações em `crystalserver/src`, `otclient/src`, `data/`).
- **Saídas**:
  - relatório de arquivos alterados para revisão manual da documentação.

## Workflow manual recomendado
1. Executar `wiki-metrics` após mudanças significativas.
2. Atualizar páginas impactadas.
3. Executar `wiki-orphans` para validar cobertura.
4. Registrar pendências no `docs/wiki/roadmap.md`.

## Integração futura (CI)
- Pipeline simples em CI:
  - rodar scripts `wiki-metrics` e `wiki-orphans`;
  - falhar o build se houver novos órfãos críticos.

## Guardrails
- Não automatizar mudanças de conteúdo sem revisão humana.
- A automação deve produzir **relatórios**, não alterar páginas diretamente.
