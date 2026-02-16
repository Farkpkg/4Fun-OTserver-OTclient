---
title: Index
tags: [index.md]
date: 2026-02-16
---

# Documentação Técnica do Projeto

Este diretório foi reorganizado para separar documentação por domínio e reduzir acoplamento entre conteúdos de cliente, servidor, API e operação.

## Sumário Geral

- [`architecture/`](architecture/index.md): visão macro de arquitetura e decisões transversais.
- [`api/`](api/index.md): contratos e protocolos (ex.: ExtendedOpcode).
- [`server/`](server/index.md): fluxos, regras e diagnósticos do CrystalServer.
- [`client/`](client/index.md): documentação funcional e relatórios de UI/UX do OTClient.
- [`deployment/`](deployment/index.md): playbooks operacionais e execução.
- [`reports/`](reports/docs-reorganization-report.md): relatório de reorganização da documentação.
- [`wiki/`](wiki/index.md): base de conhecimento histórica (mantida como área de referência).
- [`ai/`](ai/project-context.md): materiais auxiliares para automação/LLM.

## Convenções adotadas

- Nomes em `kebab-case.md` para novos/renomeados arquivos.
- Estrutura padrão por documento:
  - Título
  - Contexto/descrição
  - Seções objetivas
  - Exemplos (quando aplicável)
- Em caso de dúvida de aderência ao código atual, manter marcação explícita:

```md
<!-- REVIEW: descrição do problema -->
```

