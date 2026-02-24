# PROJECT_MENTAL_MODEL

- Server autoritativo; client apresentacional.
- Camadas: Core -> Domínio -> Infra -> Lua -> UI.
- Alto acoplamento em protocol + dados de player + scripts.
- Pontos frágeis: opcodes, migrations, feature flags.
- Antes de alterar: mapear fronteira, contrato de rede, persistência e reflexo Lua/UI.
