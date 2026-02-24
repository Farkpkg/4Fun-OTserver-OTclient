# ARCHITECTURE_DRIFT_PREVENTION

## Objetivo
Estabelecer controles anti-drift para impedir degradação progressiva da arquitetura sob evolução contínua por múltiplas IAs.

## Sinais de degradação estrutural
1. **Quebra de autoridade**: cliente passa a decidir estado de gameplay.
2. **Fluxo implícito crítico**: lógica vital sem ponto de entrada rastreável.
3. **Aumento de acoplamento transversal**: mudança simples exigindo patches dispersos sem justificativa arquitetural.
4. **Dependências temporais ocultas**: funcionamento depende de ordem não documentada.

## Sinais de duplicação de lógica
- Mesmo opcode serializado em mais de um ponto canônico.
- Regras de validação de jogador replicadas em camadas diferentes.
- SQL/mapeamento de persistência duplicado fora da camada IO/DB.

## Sinais de inconsistência client/server
- Novo campo em pacote sem parse equivalente.
- Feature flag usada apenas em um lado.
- Divergência de enum/opcode sem migração de versão.

## Sinais de fragmentação de padrão
- Introdução de “micro-padrão local” sem alinhamento ao padrão dominante do subsistema.
- Atalho técnico em vez de extensão do ponto canônico existente.

---

## Checklist automático pré-alteração (obrigatório)

### A. Classificação inicial
- [ ] A mudança toca protocolo?
- [ ] A mudança toca persistência?
- [ ] A mudança toca bootstrap/scheduler?
- [ ] A mudança toca boundary C++/Lua?

### B. Regras de simetria
- [ ] Para cada alteração em `protocolgame*` server há correspondente no client.
- [ ] Para cada novo opcode/campo há gate de versão/feature quando necessário.

### C. Regras de persistência
- [ ] Campos persistentes novos/alterados possuem migration ou justificativa de não necessidade.
- [ ] Camada de carga e salvamento foi atualizada simetricamente.

### D. Regras de arquitetura
- [ ] Mudança reutiliza ponto canônico existente, sem trilha paralela.
- [ ] Não introduz fonte adicional de verdade para estado de gameplay.
- [ ] Ordem de inicialização não foi quebrada.

### E. Regras de evidência
- [ ] Impact map registrado em `new_docs`.
- [ ] Testes/checks mínimos executados e registrados.
- [ ] Risco residual explicitado.

---

## Checklist automático pré-merge (gate final)
1. Diff scanner detecta arquivos de alto risco.
2. Se risco crítico: exigir revisão dupla (domínio + integração).
3. Confirmar invariantes de `SYSTEM_INVARIANTS.md` não violados.
4. Confirmar ausência de fluxo implícito novo.
5. Confirmar atualização documental de decisão arquitetural.

---

## Política de contenção de drift
- Mudança rápida sem mapeamento estrutural = **bloqueio de merge**.
- Mudança com workaround temporário = exige plano explícito de remoção (prazo/owner).
- Incidente recorrente no mesmo hotspot = abrir ação de refatoração dirigida.
