[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Magias e runas

# Magias e runas

## Visão geral
Magias e runas são implementadas principalmente via scripts Lua no servidor, com suporte de combate e efeitos visuais no cliente.

## Arquivos envolvidos
- **Scripts**: `crystalserver/data/scripts/spells/` e `crystalserver/data/scripts/runes/`.
- **Servidor**: integração em `crystalserver/src/creatures/combat/`.
- **Cliente**: efeitos em `otclient/src/client/effect*.cpp` e `otclient/src/client/missile*.cpp`.

## Estrutura interna (alto nível)
- Definições e lógica de magias em scripts Lua.
- Sistema de combate aplica efeitos e validações.

## Fluxo geral
1. Ação de cast é enviada pelo cliente.
2. O servidor executa a magia via scripts e regras de combate.
3. O cliente renderiza efeitos/partículas recebidos.

## Exemplo prático (do código)
- `crystalserver/data/scripts/spells/#example.lua` registra uma runa e define um `Combat()` com parâmetros de cura/efeito.

## Debug e troubleshooting
- **Sintoma: magia não executa**
  - **Possível causa**: erro no script ou requisitos de nível/magia não atendidos.
  - **Onde investigar**: `crystalserver/data/scripts/spells/` e logs de scripts.

## Performance e otimização
- **Ponto sensível**: magias em área e efeitos visuais podem gerar maior volume de mensagens para o cliente.

## Pontos de extensão
- Scripts de magias e runas em `crystalserver/data/scripts/spells/` e `runes/`.
- Eventos em `crystalserver/data/events/`.
