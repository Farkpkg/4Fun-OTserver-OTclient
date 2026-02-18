# Documentação Técnica do Projeto (CrystalServer + OTClient)

## Descrição
Este diretório contém somente documentação validada contra o código atual do repositório. O conteúdo antigo de `/docs` foi removido por não estar 100% verificável ou por estar redundante/obsoleto.

## Mapa da Documentação
- `01-architecture/`: visão estrutural entre Client e Server.
- `02-client/`: inicialização e carregamento real do OTClient.
- `03-server/`: bootstrap Lua/C++ e sistema de eventos do CrystalServer.
- `04-systems/`: sistemas ativos validados ponta a ponta.
- `05-protocols/`: protocolo de rede e Extended Opcode implementado.
- `06-database/`: banco, conexão e migrações ativas.
- `07-tools/`: comandos e ferramentas realmente presentes no projeto.
- `99-archive/`: registro da auditoria e decisões de limpeza.

## Guia Rápido para Desenvolvedores
1. Leia `01-architecture/repository-topology.md` para entender o acoplamento entre os projetos.
2. Para fluxo do client, siga `02-client/module-loading.md`.
3. Para pipeline do server, siga `03-server/runtime-and-events.md`.
4. Para integração Client/Server, use `05-protocols/extended-opcode.md`.
5. Para persistência, use `06-database/mysql-and-migrations.md`.
