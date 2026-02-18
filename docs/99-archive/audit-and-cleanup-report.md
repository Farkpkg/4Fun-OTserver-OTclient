# Auditoria e Limpeza de Documentação (Execução Atual)

## Descrição
Foi executada auditoria completa do conteúdo anterior de `/docs` com critério de verificabilidade direta no código atual. Todo conteúdo não comprovável, duplicado ou contraditório foi removido.

## Localização no Projeto
- docs/

## Arquivos Envolvidos
- Conteúdo antigo removido de `docs/**`.
- Nova base técnica criada em:
  - `docs/01-architecture/repository-topology.md`
  - `docs/02-client/module-loading.md`
  - `docs/03-server/runtime-and-events.md`
  - `docs/04-systems/locale-synchronization.md`
  - `docs/04-systems/revscriptsys-metatable-bridge.md`
  - `docs/05-protocols/extended-opcode.md`
  - `docs/06-database/mysql-and-migrations.md`
  - `docs/07-tools/development-workflow.md`

## Fluxo de Execução
1. Leitura dos documentos anteriores em `/docs` e comparação com estrutura real do repositório.
2. Cruzamento com implementação ativa em `otclient/` e `crystalserver/`.
3. Exclusão integral do acervo legado não verificável/duplicado.
4. Reorganização na estrutura alvo (`01` a `07` e `99-archive`).
5. Reescrita padronizada com foco técnico e verificável.

## Dependências
- Evidências no código-fonte de `otclient` e `crystalserver`.
- Comandos de auditoria por shell (`find`, `rg`, `git status`).

## Pontos de Extensão
- Adicionar novos documentos somente após validação direta no código.
- Quando um sistema for removido do código, remover a documentação correspondente no mesmo PR.
- Manter `99-archive` apenas para registrar decisões de governança documental, sem reintroduzir conteúdo obsoleto.
