# ARCHITECTURAL_LAWS

1. Sem arquitetura paralela.
2. Feature gameplay nasce no servidor.
3. Opcode novo = mudanças simétricas client/server.
4. Persistência nova = migration + IO + carga/salva.
5. Integração C++/Lua só por bindings oficiais.
6. Módulo client segue padrão existente em `modules/`.
7. Não quebrar compatibilidade de protocolo sem guarda de versão.
