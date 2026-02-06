[Wiki](README.md) > Roadmap

# Roadmap da documentação

## O que já está bem documentado
- Arquitetura geral e fluxos principais.
- Páginas por sistema de jogo com exemplos práticos.
- Protocolos com opcodes relevantes e pontos de acoplamento.

## O que precisa melhorar
- Cobertura de áreas órfãs (ver `governance/orphans.md`).
- Detalhamento de módulos específicos do cliente.
- Mapeamento de enums e utilitários do servidor.

## Prioridades futuras
1. **Cobertura de órfãos críticos** (enums, utils, kv).
2. **Documentação de módulos chave do cliente** (ex.: `game_interface`, `client_entergame`).
3. **Guia de troubleshooting avançado** (erros de rede, runtime, compatibilidade).

## Débitos de documentação conhecidos
- Ausência de documentação para `crystalserver/src/enums/` e `crystalserver/src/utils/`.
- Ausência de documentação para `otclient/src/tools/`.
- Scripts sem referência explícita: `globalevents`, `talkactions`, `systems`.
