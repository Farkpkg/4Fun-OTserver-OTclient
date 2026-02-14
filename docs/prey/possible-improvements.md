# PREY — Melhorias Possíveis

## 1) Protocolo e compatibilidade
- Formalizar tabela única de opcodes client/server para evitar drift.
- Corrigir/confirmar caminho de `preyRequest` para refresh explícito de slots.
- Isolar payload de prey e task hunting para reduzir ambiguidades de parsing.

## 2) Modelagem de estado
- Unificar estados realmente usados entre cliente e servidor (`WILDCARD_SELECTION` etc.).
- Adicionar validação server-side extra para transições inválidas entre estados.

## 3) UI/UX
- Remover hardcodes de preço em `setUnsupportedSettings()`.
- Internacionalizar todas as mensagens do prey.lua.
- Melhorar feedback de erros (ex.: insuficiente wildcard/gold) com códigos padronizados do server.

## 4) Persistência
- Versionar schema/prey payload para migrações futuras.
- Garantir constraints/chaves explícitas em `player_prey` para evitar duplicidade de slot por jogador.

## 5) Balanceamento
- Revisar fórmulas de raridade/bônus para progressão mais previsível.
- Expor parâmetros de distribuição por estrela no config (hoje embutidos no código).

## 6) Observabilidade
- Adicionar métricas específicas:
  - taxa de reroll pago/grátis
  - taxa de expiração com auto-reroll/lock
  - distribuição real de bônus por tipo/raridade

## 7) Robustez
- Sanitizar raceIds inválidos já no load (não só no send).
- Escrever testes de integração protocolo prey (estado por estado).
- Cobrir edge cases de mudanças de premium status durante sessão.

## 8) Código morto/incompleto (indícios)
- Fluxos no cliente para wildcard-selection parecem mais amplos que o que o servidor efetivamente emite.
- `sendOpenPortableForge` reutiliza opcode de prey request no cliente, sugerindo sobrecarga/confusão histórica.

## Exemplo de ponto a refatorar (código real)
```cpp
void ProtocolGame::sendOpenPortableForge() {
  msg->addU8(Proto::ClientPreyRequest); // indício de sobrecarga indevida de opcode
}
```

## Diagrama de evolução sugerida
```text
Hoje: UI/Protocol/Rules parcialmente acoplados
  -> Proposta: contrato de protocolo versionado + estado tipado + testes de contrato
```
