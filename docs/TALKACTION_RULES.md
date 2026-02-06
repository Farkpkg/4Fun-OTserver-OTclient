# TalkAction rules (Crystal Server)

## O que TalkAction pode fazer

- Interpretar comandos digitados pelo jogador.
- Validar parâmetros e sintaxe.
- Chamar funções **já seguras**, que não executam bootstrap nem enviam opcodes.
- Enviar **uma única** mensagem simples ao jogador.

## O que TalkAction NÃO pode fazer

- Inicializar sistemas ou executar bootstrap.
- Criar rows no banco de dados.
- Sincronizar estado (full sync) ou enviar opcodes.
- Executar lógica estrutural que dispare mensagens indiretas.
- Enviar múltiplas mensagens em uma única execução.

## Erros reais encontrados

- Bootstrap e sync eram disparados a partir de TalkAction (`!task`), causando warnings de protocolo.
- Uso de enums inexistentes (`MESSAGE_INFO_DESCR`) levou a erros de MessageType inválido.

## Boas práticas

- Garanta que o bootstrap ocorre apenas em `onLogin`, `onExtendedOpcode`, `onStartup` ou eventos globais controlados.
- Use apenas enums confirmados no core (ver `docs/ENUMS_MESSAGE_TYPES.md`).
- Trate TalkActions como camada de validação e feedback simples.
