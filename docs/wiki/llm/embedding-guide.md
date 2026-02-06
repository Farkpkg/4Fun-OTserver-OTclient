[Wiki](../README.md) > Guia de embeddings

# Guia de embeddings (corpus da wiki)

## Objetivo
Fornecer um corpus estruturado para indexação semântica (RAG) baseado somente na wiki.

## Arquivo gerado
- `docs/wiki/llm/embeddings.jsonl`

## Estrutura do JSONL
Cada linha contém:
- `id`: identificador único do chunk
- `system`: sistema ou seção principal
- `doc_path`: caminho do documento fonte
- `type`: classificação (server/client/protocol/game-system/etc.)
- `section`: título da seção (H2)
- `content`: conteúdo do chunk

## Regras de chunking aplicadas
- **Um chunk por seção H2** (`##`).
- **Contexto preservado** via metadados (system, doc_path, type, section).
- **Sem mistura de sistemas** no mesmo chunk.

## Uso recomendado
- Indexar `embeddings.jsonl` diretamente.
- Reindexar quando houver mudanças na wiki.
