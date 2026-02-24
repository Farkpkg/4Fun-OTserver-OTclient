# IMPLEMENTATION_ALIGNMENT_ROADMAP

Roadmap em ordem **obrigatória** para fechar ciclo: 
**Invariantes -> Métricas -> Instrumentação -> Gate real -> Bloqueio real -> Log**.

| Etapa | Entrega | Complexidade | Dependências | Impacto | Prioridade | Risco |
|---|---|---|---|---|---|---|
| 1 | Congelar baseline documental (`STATE_CLASSIFICATION_MATRIX`) | Baixa | Nenhuma | Remove ambiguidade do que é ativo vs alvo | P0 | Baixo |
| 2 | Definir superfícies críticas canônicas (protocol/persistência/bootstrap) | Baixa | Etapa 1 | Padroniza escopo dos gates | P0 | Baixo |
| 3 | Implementar script `gate-protocol-symmetry` | Média | Etapa 2 | Evita drift client/server em protocolo | P0 | Médio (falso positivo) |
| 4 | Implementar script `gate-persistence-migration` | Média | Etapa 2 | Evita mudança de persistência sem migration | P0 | Médio |
| 5 | Implementar script `gate-impact-declaration` | Baixa | Etapa 2 | Força rastreabilidade de impacto | P0 | Baixo |
| 6 | Integrar os 3 gates em workflow CI bloqueante | Média | Etapas 3-5 | Enforcement real antes de merge | P0 | Médio (ajuste de PRs antigos) |
| 7 | Gerar artefato de métricas mínimas por PR/release (`PCS`, `MCR`, `CSC`, `GGP`) | Média | Etapa 6 | Cria observabilidade objetiva | P1 | Médio |
| 8 | Persistir histórico por release (`metrics/*.json`) | Baixa | Etapa 7 | Permite tendência e auditoria | P1 | Baixo |
| 9 | Calcular `drift_release` e `drift_accum_k` a partir de falhas de gate | Baixa | Etapa 8 | Drift mensurável sem modelagem teórica | P1 | Baixo |
| 10 | Publicar relatório operacional curto por release (pass/fail + métricas + drift) | Baixa | Etapas 8-9 | Fecha ciclo de governança com evidência | P1 | Baixo |
| 11 | Só após 3 releases estáveis: piloto de AIS reduzido | Média | Etapas 1-10 | Evolução controlada sem sobrecarga | P2 | Médio |
| 12 | Só após dataset mínimo: piloto de risco preditivo | Alta | Etapas 1-11 | Expansão com base empírica | P3 | Alto |

## Critério de avanço entre fases
- **P0 -> P1:** gates rodando e bloqueando merge por pelo menos 2 semanas.
- **P1 -> P2:** métricas e drift publicados por 3 releases consecutivas.
- **P2 -> P3:** erro de medição conhecido e qualidade de dados aceitável.
