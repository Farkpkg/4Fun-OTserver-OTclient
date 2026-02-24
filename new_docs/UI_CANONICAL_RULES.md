# UI_CANONICAL_RULES

## Escopo e método
Este documento **não cria** novo design system. Ele formaliza apenas padrões já implementados em `otclient` (`.otui` de estilos globais e janelas de módulos).

---

## ETAPA 1 — Extração do padrão real

### 1) Estrutura base de janela padrão

**Base clássica (`Window`/`MainWindow`)**
- Janela base com `image-border-top: 27` e área de conteúdo iniciando com `padding-top: 36`.
- Padding interno padrão: `left/right/bottom = 16`.
- Header textual com `text-offset: 0 6` e `text-align: top`.
- Cor textual base da janela: `#dfdfdf`.

**Base nova (`NewWindow`/`NewMainWindow`)**
- Variante com `image-border-top: 17`.
- Padding interno reduzido (`top: 17`, `left/right/bottom: 4`).
- Fonte e cor do título diferentes da base clássica (`Verdana Bold-11px`, `#909090`).

**Rodapé (padrão observado em janelas de ação)**
- Separador horizontal acima dos botões.
- Grupo de botões no canto inferior direito.
- Botão mais à direita normalmente é ação de fechamento/cancelamento.

### 2) Convenções de posicionamento

- **Confirmar**: normalmente à esquerda do botão cancelar/fechar, ancorado por `anchors.right: <cancel>.left` + margem horizontal.
- **Cancelar/Fechar**: normalmente no extremo direito do rodapé (`anchors.right: parent.right`).
- **Botões secundários**: aparecem em sequência horizontal com âncoras relativas (`prev.left` / `prev.right`) e margens de 5–10 px.
- **Ícone em relação ao texto**:
  - Checkboxes usam ícone à esquerda e texto deslocado à direita (`text-offset: 18 ...`).
  - Botões com estado pressionado deslocam conteúdo em `+1,+1` (texto/ícone), simulando profundidade.
- **Espaçamento entre componentes**: predominância de fluxo vertical por `anchors.top: prev.bottom` e margens pequenas (2, 4, 5, 10, 13).

### 3) Convenções visuais

- **Botão padrão base**: `43x20`, fonte `cipsoftFont`, texto claro (`#dfdfdf`), skin `/images/ui/buttons`.
- **Variações recorrentes**:
  - Botões com largura fixa por contexto (`64`, `75`, `80`, `106`), mantendo altura próxima de `20–23`.
  - Botão superior icônico (`TopButton`) em `26x26`.
- **Ícones recorrentes**:
  - Caixa de mensagem usa ícone `16x16` (`icon-rect: 4 4 16 16`).
  - Checkboxes visuais predominantes em `12x12` (há variantes `14x14` e `18x18`).
- **Hierarquia tipográfica observada**:
  - Texto geral: `verdana-11px-antialised`.
  - Botões de ação: `cipsoftFont`.
  - Listagens específicas: `verdana-11px-monochrome`.
  - Alguns headers usam `Verdana Bold-11px`.
- **Estados visuais implementados**:
  - `normal`, `hover`, `pressed`, `on/checked`, `disabled` são amplamente utilizados.
  - `disabled` geralmente reduz contraste/opacidade (`#...88`, `opacity: 0.8`) e pode desabilitar cursor de interação.
- **Uso de cores recorrentes**:
  - Texto principal: `#dfdfdf` / `#c0c0c0`.
  - Título em janelas novas e diálogos de input: `#909090`.
  - Fundo/listas escuras em contextos de configuração: ex. `#404040`.

### 4) Convenções estruturais

- **Nomeação `.otui`**:
  - Predominância de nomes minúsculos com `_` ou `-`.
  - Existem exceções em camel/misto (padrão legado coexistente).
- **Organização de widgets**:
  - Estrutura em blocos verticais por âncoras relativas (`prev.bottom`).
  - Uso frequente de `Panel` como contêiner para rodapé, listas e agrupamentos.
- **Reuso de componentes base**:
  - Herança de estilos (`MainWindow < Window`, `InputBoxWindow < MainWindow`, `Button`/`QtButton`/`StoreButton`, etc.).

---

## ETAPA 2 — Formalização objetiva (regras auditáveis)

### Regras de layout

1. **Regra:** Janelas do padrão clássico devem usar padding interno `top 36 / left 16 / right 16 / bottom 16` quando derivadas diretamente de `Window`.
   - **Rigidez:** HARD RULE

2. **Regra:** Janelas do padrão novo devem usar padding interno `top 17 / left 4 / right 4 / bottom 4` quando derivadas de `NewWindow`.
   - **Rigidez:** HARD RULE

3. **Regra:** Quando houver rodapé de ação, deve existir separador horizontal entre conteúdo e área de botões.
   - **Rigidez:** SOFT RULE

4. **Regra:** Em rodapé com dois botões de ação principal, o botão de cancelamento/fechamento deve ficar no extremo direito.
   - **Rigidez:** HARD RULE

5. **Regra:** Em rodapé com botão confirmar + cancelar, confirmar deve ficar imediatamente à esquerda do cancelar, com margem horizontal positiva (5–10 px observados).
   - **Rigidez:** HARD RULE

### Regras de posicionamento e fluxo

6. **Regra:** O fluxo vertical de campos deve ser encadeado por `anchors.top: prev.bottom`.
   - **Rigidez:** HARD RULE

7. **Regra:** Espaçamentos verticais entre blocos devem usar valores discretos recorrentes do projeto (2, 4, 5, 10, 13).
   - **Rigidez:** SOFT RULE

8. **Regra:** Botões secundários em linha devem usar ancoragem relativa ao botão anterior (`prev.left`/`prev.right`) em vez de posicionamento absoluto.
   - **Rigidez:** SOFT RULE

### Regras visuais

9. **Regra:** Botão padrão textual deve manter baseline `43x20` com `cipsoftFont` ao usar o estilo `Button` clássico.
   - **Rigidez:** HARD RULE

10. **Regra:** Estados interativos obrigatórios para componentes clicáveis: `pressed` e `disabled`; `hover` quando suportado pelo componente base.
    - **Rigidez:** HARD RULE

11. **Regra:** Estado `disabled` deve reduzir legibilidade/ênfase visual por alfa/opacidade (padrão dominante `#...88` e/ou `opacity <= 0.8`).
    - **Rigidez:** HARD RULE

12. **Regra:** CheckBox com texto deve manter ícone à esquerda e deslocamento de texto próximo de `18 px` no eixo X.
    - **Rigidez:** HARD RULE

13. **Regra:** Mensagens modais devem respeitar ícone de referência `16x16` quando usarem `UIMessageBox` padrão.
    - **Rigidez:** HARD RULE

### Regras estruturais

14. **Regra:** Arquivos `.otui` novos devem seguir nomeação minúscula com `_` ou `-`.
    - **Rigidez:** SOFT RULE

15. **Regra:** Janelas devem herdar de classes base existentes (`Window`, `MainWindow`, `NewWindow`, `InputBoxWindow` etc.) antes de criar estrutura ad hoc.
    - **Rigidez:** HARD RULE

16. **Regra:** Agrupamentos de interface devem ser encapsulados em `Panel` quando houver bloco semântico (conteúdo, listas, rodapé).
    - **Rigidez:** SOFT RULE

---

## ETAPA 3 — Classificação de rigidez consolidada

### HARD RULE
- Regras: 1, 2, 4, 5, 6, 9, 10, 11, 12, 13, 15.

### SOFT RULE
- Regras: 3, 7, 8, 14, 16.

### LEGACY PATTERN
- Coexistência de duas famílias de janela com métricas diferentes (`Window` vs `NewWindow`).
- Coexistência de larguras de botão por contexto (`43`, `64`, `75`, `80`, `106`) sem token único global.
- Coexistência de convenções de nome de arquivo (majoritariamente minúsculo, mas com exceções camel/misto).

---

## ETAPA 4 — Análise de inconsistências (sem redesign)

1. **Múltiplos padrões de janela conflitantes**
   - Há dois padrões de moldura/padding/header em uso ativo (clássico e novo), com diferenças mensuráveis de borda, tipografia e espaçamento.

2. **Múltiplos padrões de largura de botão**
   - Botão base é `43x20`, porém diversas telas adotam larguras fixas maiores (`64/75/80/106`) por módulo.

3. **Padronização parcial do rodapé**
   - A regra “cancelar à direita / confirmar à esquerda” é predominante, mas há telas com agrupamento centralizado de botões, não alinhadas ao canto direito.

4. **Padronização parcial de nomenclatura de arquivos**
   - Convenção minúscula domina, mas há arquivos com camel/misto, evidenciando legado histórico.

5. **Tipografia não unificada em um único perfil**
   - Fontes `verdana-11px-antialised`, `verdana-11px-monochrome`, `cipsoftFont` e `Verdana Bold-11px` convivem por contexto.

---

## ETAPA 5 — Integração com governança

## UI IMPACT CHECK
Toda feature que adicionar/alterar interface deve incluir, no PR ou documento técnico da mudança, o bloco abaixo:

```md
UI IMPACT CHECK
- Segue UI_CANONICAL_RULES? [Sim/Não]
- Regras afetadas (IDs): [ex.: 4, 5, 9]
- Há desvio? [Não / Sim]
- Justificativa objetiva do desvio: [texto]
- Classificação do desvio: [HARD RULE / SOFT RULE / LEGACY PATTERN]
```

---

## Resumo curto
O padrão visual atual do `otclient` é **parcialmente consistente e estruturalmente fragmentado**: existe um núcleo estável de convenções (âncoras, estados e rodapé de ação), mas coexistem famílias legadas com métricas e variações visuais distintas.
