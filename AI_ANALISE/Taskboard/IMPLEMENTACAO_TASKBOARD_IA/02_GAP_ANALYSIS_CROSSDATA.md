# GAP Analysis cruzada — Task Board isolada

## 1) Correção da premissa
A proposta anterior estava incorreta ao aproximar Task Board de Prey.

**Correção:** Task Board = domínio novo, independente.

## 2) O que pode ser reaproveitado
- Pipeline de rede existente (infra de protocol parse/send).
- Padrões de módulo OTClient (`otmod/lua/otui/styles/images`).
- Padrões de layout/widgets recorrentes no cliente.
- Estrutura de persistência e migrations já usada no projeto.

## 3) O que NÃO pode ser reaproveitado semanticamente
- `IOPrey` e derivados.
- States/actions/enums de prey/taskhunting antigos.
- Recursos econômicos de prey (wildcards/cards/prey points).

## 4) Gaps reais para implementação
1. Definir domínio Task Board server-side (entidades, regras e serviços).
2. Definir contrato de rede exclusivo para Task Board.
3. Implementar persistência própria (weekly reset, preferred list, moedas e progresso).
4. Criar módulo UI dedicado com 3 abas e trackers.
5. Integrar ações do usuário aos novos pacotes.

## 5) Dados cruzados obrigatórios
- **Bounty:** oferta de tarefas, seleção, progresso, claim, reroll e ring upgrades.
- **Weekly:** geração semanal, progresso, multiplicador e fechamento de ciclo.
- **Shop:** catálogo, preço, compra, unlocks e auditoria de transação.
- **Preferred List:** likes/dislikes/slots/compras extras.
- **Moedas:** Bounty Points, Hunting Task Points, Soulseals (se adotado), tokens próprios.

## 6) Conclusão técnica
Melhor caminho: **construir Task Board como bounded context próprio**, com adapters mínimos para UI e protocolo, sem reusar domínio de Prey.
