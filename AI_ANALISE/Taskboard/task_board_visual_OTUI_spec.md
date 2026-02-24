# Task Board — Especificação Visual Completa para Recriação em OTUI

> **Objetivo:** Documentar com precisão absoluta cada elemento visual, posição, comportamento e interação do sistema Task Board do Tibia, de forma que uma IA possa recriar fielmente toda a interface em formato OTUI sem nunca ter visto as imagens originais.

---

## 1. ESTRUTURA GLOBAL DA JANELA

### 1.1 Container Principal (TaskBoard Window)

A janela principal do Task Board é um painel retangular fixo, **não redimensionável**, com as seguintes características:

- **Dimensões aproximadas:** ~990 × 585 pixels
- **Borda externa:** moldura dupla estilo medieval/rustic, cor marrom-dourada escura (`#3a2a1a` aprox.), com cantos levemente arredondados. A borda tem espessura de ~4px externa + ~2px interna.
- **Fundo do corpo:** cinza-escuro texturizado (`#2a2a2a` aprox.) simulando pedra ou metal fosco. Não é cor plana — há ruído/textura sutil.
- **Cor da borda interna (highlight):** linha fina de 1px dourada/amarelada (`#8a7a3a` aprox.) logo dentro da borda externa.

### 1.2 Barra de Título

- **Posição:** topo absoluto da janela, largura total.
- **Altura:** ~22px
- **Fundo:** gradiente horizontal levemente mais claro que o corpo, tom cinza-médio (`#3d3d3d`)
- **Texto:** `"Task Board"` — fonte branca (`#ffffff`), tamanho ~12px, centralizado horizontalmente, verticalmente centralizado na barra.
- **Sem botão de fechar no título** — o fechar está no rodapé.

---

## 2. BARRA DE ABAS (Tab Navigation)

Localizada **logo abaixo da barra de título**, ocupa toda a largura da janela. Altura da barra de abas: ~40px.

### 2.1 Layout das 3 Abas

As abas são distribuídas horizontalmente em **3 blocos iguais**, separadas por divisórias verticais finas. Cada aba ocupa ~1/3 da largura total (~330px cada).

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│  [ícone] Bounty Tasks      │  [ícone] Weekly Tasks      │  [ícone] Hunting Task Shop  │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Aba Ativa vs Inativa

- **Aba ATIVA:** fundo levemente mais claro/elevado (~`#4a4a4a`), sem sublinhado. Visualmente "sobe" em relação às outras, simulando uma aba pressionada. Borda inferior da aba ativa se funde com o conteúdo abaixo (sem linha separadora).
- **Aba INATIVA:** fundo mais escuro (~`#303030`), existe uma linha separadora fina na base que a separa do conteúdo. Ao hover: leve clareamento.
- **Ao clicar em uma aba inativa:** a aba se torna ativa, a aba anteriormente ativa volta ao estado inativo, e o painel de conteúdo central muda completamente para exibir o conteúdo correspondente.

### 2.3 Ícones e Textos das Abas

**Aba 1 — Bounty Tasks:**
- Ícone: sprite de um personagem pequeno com chapéu de caçador (tipo NPC Walter Jaeger), ~20×20px, posicionado à **esquerda** do texto.
- Texto: `"Bounty Tasks"` — cor branca, fonte sem serifa de ~11px.
- Ícone posicionado a ~8px da borda esquerda da aba, texto logo à direita com ~4px de gap.

**Aba 2 — Weekly Tasks:**
- Ícone: sprite de um livro/caderno aberto (tipo diário de tarefas), ~20×20px, à **esquerda** do texto.
- Texto: `"Weekly Tasks"` — mesma fonte/cor.

**Aba 3 — Hunting Task Shop:**
- Ícone: sprite de uma garrafa ou frasco (tipo item de loja), ~20×20px, à **esquerda** do texto.
- Texto: `"Hunting Task Shop"` — mesma fonte/cor.

---

## 3. RODAPÉ GLOBAL (Bottom Bar)

Presente em **todas as abas**, fixo na base da janela. Altura: ~30px. Fundo: mesma textura escura do corpo.

### 3.1 Layout do Rodapé

```
[ 30 ⊕ ]   [ 0 ⊙ ]   [ 0 ⊛ ]                                           [ Close ]
  └─ esq ─┘  └─ meio ─┘  └─ dir ─┘                                      └─ extrema dir ─┘
```

- **Bloco esquerdo:** campo com valor `"30"` seguido de um **ícone circular dourado** (Bounty Points). Dimensão do campo: ~50×20px, fundo levemente escurecido, borda fina. O valor é numérico editável/read-only, alinhado à direita dentro do campo.
- **Bloco central:** campo com valor `"0"` seguido de um **ícone circular com símbolo diferente** (Hunting Task Points). Mesma dimensão.
- **Bloco direito:** campo com valor `"0"` seguido de um **terceiro ícone** (Soulseals). Mesma dimensão.
- Os 3 blocos estão alinhados verticalmente ao centro do rodapé, com ~10px de separação entre eles. Posicionados na **extremidade esquerda** do rodapé.
- **Botão "Close":** posicionado na extremidade **direita** do rodapé. Dimensões ~60×20px. Fundo escuro, borda fina, texto branco `"Close"`. Ao clicar: fecha a janela completamente.

---

## 4. ABA 1 — BOUNTY TASKS

### 4.1 Seção Superior: "Set Up & Reroll Tasks"

**Container da seção:**
- **Título da seção:** texto `"Set Up & Reroll Tasks"` — centralizado horizontalmente, cor branca/off-white, fonte ~11px, posicionado ~10px abaixo das abas. Há uma linha horizontal fina (`#555`) estendendo-se de ambos os lados do texto até as bordas do container, criando um separador de seção estilo "título com linha".

**Linha de controles (logo abaixo do título da seção):**
- Alinhamento: horizontal, ~15px abaixo do título.
- Elementos da esquerda para direita:

**① Ícone de informação (ⓘ):**
- Posição: extrema esquerda, ~15px da borda.
- Aparência: círculo pequeno (~14px) com a letra "i" dentro, cor cinza/branco.
- Ao clicar/hover: exibe tooltip explicando o sistema de dificuldade.

**② Label "Task Difficulty:"**
- Texto `"Task Difficulty:"` — cor cinza-claro (`#aaaaaa`), fonte ~11px.
- Posicionado ~8px à direita do ícone ⓘ.

**③ Dropdown de Dificuldade:**
- Posição: ~5px à direita da label.
- Dimensões: ~100×22px.
- Aparência: campo retangular com fundo escuro (`#222`), borda fina (`#555`), texto branco com o valor atual (ex: `"Expert"`), seta dropdown `▼` no lado direito do campo em cor cinza.
- **Estado expandido (dropdown aberto):** Uma lista flutuante aparece **abaixo** do campo, com fundo escuro e borda. Lista contém 4 opções em ordem vertical:
  - `"Beginner"` — cor branca normal
  - `"Adept"` — cor branca normal
  - `"Expert"` — cor branca, **bold** (item atualmente selecionado aparece destacado)
  - `"Master"` — cor branca **bold/maior** (parece ter destaque visual diferente do selecionado — pode ser hover)
  - Cada item: ~22px de altura, padding horizontal ~8px. Hover: fundo levemente mais claro. Click: seleciona e fecha dropdown.

**④ Botão "Preferred List":**
- Posição: ~40px à direita do dropdown (após gap).
- Dimensões: ~100×22px.
- Aparência: botão retangular, fundo cinza-médio (`#444`), borda fina, texto branco `"Preferred List"`, sem ícone.
- **Ao clicar:** abre a janela modal **Preferred List** (documentada separadamente na Seção 7).

**⑤ Botão "Reroll Tasks":**
- Posição: ~8px à direita do botão Preferred List.
- Dimensões: ~90×22px.
- Aparência: idêntica ao botão anterior. Texto `"Reroll Tasks"`.
- **Ao clicar:** consome 1 Reroll Token e gera 3 novas tarefas aleatórias. Os 3 cards de tarefa são substituídos por novos.

**⑥ Campo de Reroll Tokens:**
- Posição: ~5px à direita do botão "Reroll Tasks".
- Dimensões: ~45×22px.
- Aparência: campo numérico pequeno com fundo escuro, borda fina, valor `"1"` (quantidade atual de tokens). Seguido imediatamente de um **ícone de folha verde** (Reroll Token) de ~14×14px.

**⑦ Botão "Claim Daily":**
- Posição: ~5px à direita do campo de tokens.
- Dimensões: ~100×22px.
- Aparência: botão com texto `"Claim Daily"`, seguido de um ícone de folha verde ~14px à direita do texto, dentro do botão.
- **Ao clicar:** resgata 1 Reroll Token gratuito diário. Se já coletado, botão fica desabilitado (cor acinzentada, não clicável).

---

### 4.2 Grid de 3 Cards de Tarefa

**Container do grid:**
- Posição: ~15px abaixo da linha de controles.
- Layout: 3 cards lado a lado, separados por ~10px de gap.
- Cada card ocupa ~1/3 da largura disponível (~300px × ~220px).

**Estrutura de cada Card de Tarefa:**

```
┌─────────────────────────────────────────┐
│          [NOME DA CRIATURA]              │  ← banner/header do card
│  ┌───────────────────────────────────┐  │
│  │                                   │  │
│  │     [SPRITE DA CRIATURA 64x64]    │  │  ← área de imagem centralizada
│  │                                   │  │
│  └───────────────────────────────────┘  │
│           0 / [X] kills                 │  ← contador de progresso
│                                         │
│  Reward:                                │  ← seção de recompensas
│  ● [XP] XP                             │
│  ● [N] [ícone BP]                       │
│  ● [N] [ícone token]                    │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │         Select Task             │   │  ← botão de ação
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**Detalhes visuais do Card:**

**→ Fundo do card:** cinza texturizado levemente mais claro que o fundo geral (~`#353535`). Borda externa fina (`#555`). Cantos levemente arredondados (~2px).

**→ Banner/Header do card (nome da criatura):**
- Ocupa toda a largura do card no topo.
- Altura: ~22px.
- Fundo: **gradiente horizontal dourado-acastanhado** — cores estilo pergaminho/ouro (`#8a7030` para `#6a5020`), com textura levemente envelhecida.
- Borda inferior do banner: linha fina mais escura (`#3a2a10`).
- Texto: nome da criatura em **branco** (`#ffffff`), fonte ~11px, **negrito**, centralizado.
- Exemplo: `"Biting Book"`, `"Crazed Winter Vanguard"`, `"Wardragon"`

**→ Indicador de Tarefa Especial (ícone no canto do banner):**
- Visible **apenas** em Silver/Gold tasks.
- No card do meio da imagem ("Crazed Winter Vanguard"), há um **escudo heráldico** (~28×28px) posicionado no canto esquerdo do banner, ligeiramente sobreposto ao banner (centralizado verticalmente entre o banner e a área de sprite).
- O escudo tem fundo vermelho com detalhes dourados e uma estrela/símbolo no centro — indica task especial (Silver ou Gold).
- Tarefas normais **não têm esse escudo**.

**→ Área de Sprite da Criatura:**
- Container interno: retângulo com fundo levemente mais escuro (~`#252525`), borda fina interna de 1px (`#444`).
- Dimensões do container: ~120×80px (varia conforme o card), centralizado horizontalmente no card.
- O sprite da criatura é renderizado **dentro deste container**, centralizado. Tamanho do sprite: ~64×64px (escalonado para caber).
- Fundo do container: escuro sólido — o sprite flutua sobre ele sem background transparente visível.

**→ Contador de Progresso:**
- Texto `"0 / [X] kills"` — branco, ~11px, centralizado abaixo do container de sprite.
- Margem acima: ~5px após o container.
- Quando há progresso (ex: 17 de 2000): o número atual fica em **cor amarela/dourada** e o total em branco.

**→ Seção de Recompensas:**
- Label `"Reward:"` — cor branca, ~11px, alinhado à esquerda, ~10px de margem esquerda.
- Lista de 3 linhas de recompensa, cada uma iniciando com `"●"` (bullet point pequeno) seguido do valor e ícone:
  - Linha 1: `"● [número] XP"` — texto branco
  - Linha 2: `"● [número] [ícone de Bounty Point]"` — número branco + ícone colorido ~12px
  - Linha 3: `"● [número] [ícone de Reroll Token]"` — número branco + ícone colorido ~12px
- Espaçamento entre linhas: ~4px.
- Margem esquerda: ~10px.

**→ Botão "Select Task":**
- Posição: ~10px acima da borda inferior do card.
- Largura: ~90% da largura do card, centralizado.
- Altura: ~22px.
- Aparência: botão retangular, fundo cinza-escuro (`#3a3a3a`), borda fina, texto branco `"Select Task"`, centralizado.
- **Hover:** fundo levemente mais claro.
- **Ao clicar:** a tarefa é selecionada e se torna a tarefa ativa. O card pode mudar de aparência para indicar estado ativo (ex: borda dourada). As outras 2 tarefas ainda são visíveis mas ficam "não selecionáveis" até que a ativa seja completada.

---

### 4.3 Seção "Bounty Ring" (Rodapé da Aba Bounty Tasks)

**Título da seção:**
- Texto `"Bounty Ring"` — branco, centralizado horizontalmente, com linhas horizontais de cada lado (mesmo estilo do título "Set Up & Reroll Tasks"). ~10px acima dos cards de bônus.

**Container dos 4 cards de bônus:**
- Layout: 4 cards em linha horizontal, distribuídos igualmente.
- Cada card: ~220px × ~80px.
- Separados por ~8px de gap.
- Fundo: ligeiramente mais escuro que o fundo geral, com borda fina.

**Estrutura de cada Card de Bônus:**

```
┌──────────────────────────────────────────┐
│  [ícone circular]  [Nome do Bônus]        │  ← linha superior
│                    Current: [X] %         │  ← valor atual
│                                           │
│  [ Upgrade Ring ]      [custo] [ícone BP] │  ← linha de ação
└──────────────────────────────────────────┘
```

**→ Ícone circular de bônus:**
- Posição: canto superior esquerdo, ~8px das bordas.
- Dimensão: ~32×32px.
- Aparência: **anel/círculo** colorido com símbolo interno específico para cada bônus. Os anéis têm gradiente de cor variado (um é mais amarelo, outro azul, etc.). Visual de "Talisman" ou "Anel Mágico".

**→ Nome do bônus:**
- Texto branco, ~11px, posicionado à direita do ícone, alinhado ao topo.
- Pode ter 2 linhas (ex: `"Damage Against"` / `"Creatures"` ou `"Chance for Double"` / `"Bestiary Progress"`).

**→ Linha "Current: X %":**
- Texto `"Current: [valor] %"` — cor cinza-claro (~`#aaaaaa`), ~11px, na segunda linha à direita do ícone.

**→ Botão "Upgrade Ring":**
- Posição: linha inferior do card, alinhado à esquerda.
- Dimensões: ~90×18px.
- Aparência: botão pequeno, fundo cinza-escuro, borda fina, texto branco `"Upgrade Ring"`, ~10px.
- **Habilitado/desabilitado** conforme disponibilidade de Bounty Points.
- **Ao clicar:** gasta os Bounty Points exibidos ao lado e aumenta o % do bônus correspondente.

**→ Campo de custo:**
- Posição: ~5px à direita do botão "Upgrade Ring", na linha inferior.
- Dimensões: ~45×18px.
- Campo numérico com valor (ex: `"29"`, `"41"`, `"53"`, `"17"`), seguido do ícone de Bounty Point (~12px).

**Dados dos 4 Cards de Bônus (da esquerda para a direita):**

| # | Nome | % Atual | Custo Próx. Upgrade |
|---|------|---------|---------------------|
| 1 | Damage Against Creatures | 3.5 % | 29 ⊕ |
| 2 | Reduced Damage Taken | 4 % | 41 ⊕ |
| 3 | More Loot | 4.5 % | 53 ⊕ |
| 4 | Chance for Double Bestiary Progress | 6 % | 17 ⊕ |

**→ Ícone ⓘ no canto inferior esquerdo da seção Bounty Ring:**
- Posicionado abaixo dos 4 cards, extrema esquerda.
- Ao clicar/hover: exibe tooltip explicando como o Bounty Talisman e os bônus funcionam.

---

## 5. ABA 2 — WEEKLY TASKS

### 5.1 Estrutura Geral da Aba

A aba Weekly Tasks é dividida em **4 zonas principais**, empilhadas verticalmente:

```
┌──────────────────────────────────────────────────────────┐
│  [ Kill Tasks — painel esquerdo ] [ Delivery Tasks — dir]│  ← Zona 1: grid de tarefas
│  [ Unlock permanently ]           [ Unlock permanently ] │  ← Zona 2: banner locked row
├──────────────────────────────────────────────────────────┤
│         Each task rewards you with [X] XP.               │  ← Zona 3: info XP
│  ┌──────────────────────────────────────────────────┐    │
│  │  Weekly Progress (barra com milestones)          │    │  ← Zona 4: progresso semanal
│  └──────────────────────────────────────────────────┘    │
│                              [ Weekly Rewards — painel ] │
└──────────────────────────────────────────────────────────┘
```

### 5.2 Zona 1: Painéis de Kill Tasks e Delivery Tasks

**Layout dos dois painéis:**
- Lado a lado, separados por ~10px.
- Cada painel: ~460px de largura × ~230px de altura.
- **Título de cada painel:** texto em branco `"Kill Tasks"` e `"Delivery Tasks"`, respectivamente. Centralizado no topo do painel, com linha horizontal de cada lado (mesmo estilo de seção). Fundo do título: levemente destacado (`#3a3a3a`), ~22px de altura.

**Grid interno de tarefas:**
- Layout: **2 linhas × 3 colunas** = 6 células por painel.
- Cada célula: ~145px × ~90px.
- Borda fina entre células (`#444`).

**Estrutura de cada Célula de Tarefa:**

```
┌────────────────────────────────────────┐
│  [Nome da Criatura / Item]             │  ← header da célula
│  ┌──────────┐   [N]                   │
│  │  SPRITE  │   of                    │
│  │ (48x48)  │   [Total]               │
│  └──────────┘                         │
│              [ Deliver ]              │  ← apenas em Delivery Tasks
└────────────────────────────────────────┘
```

**→ Header da célula:**
- Fundo: cinza-escuro (`#2e2e2e`), altura ~18px.
- Texto: nome da criatura/item em branco, ~10px, centralizado.

**→ Sprite:**
- Posição: lado esquerdo da célula, centralizado verticalmente.
- Dimensão: ~48×48px renderizado.
- Fundo: escuro sólido atrás do sprite.

**→ Contador de progresso (Kill Tasks):**
- Posição: à **direita** do sprite, centralizado verticalmente.
- Formato: dois valores em coluna:
  - Valor atual (ex: `"17"`) — cor **laranja/vermelha** (`#cc4400` aprox.) se não completado, verde se completo.
  - Texto `"of"` — branco, menor.
  - Total (ex: `"2000"`) — branco.
- Valores empilhados verticalmente, alinhados ao centro-direita da célula.

**→ Botão "Deliver" (apenas Delivery Tasks):**
- Posição: parte inferior direita da célula.
- Dimensões: ~55×16px.
- Aparência: botão pequeno cinza-escuro, texto `"Deliver"`, ~9px.
- **Habilitado** apenas quando o jogador possui os itens necessários no inventário.
- **Ao clicar:** entrega os itens e marca a tarefa como concluída.
- Quando a tarefa está completa, o botão fica verde ou a célula muda de aparência.

**Dados das células visíveis nas imagens:**

*Kill Tasks (6 células):*
| Célula | Criatura | Progresso |
|--------|----------|-----------|
| 1 | Any Creature | 17 of 2000 |
| 2 | Goblin Assassin | 0 of 97 |
| 3 | Misguided Thief | 0 of 148 |
| 4 | Corym Skirmisher | 0 of 65 |
| 5 | Waspoid | 0 of 148 |
| 6 | Misguided Thief | 0 of 89 |

*Delivery Tasks (6 células):*
| Célula | Item | Progresso |
|--------|------|-----------|
| 1 | Rubber Cap | 0 of 10 |
| 2 | Bonebreaker | 0 of 12 |
| 3 | Combat Knife | 0 of 14 |
| 4 | Diamond Sceptre | 0 of 95 |
| 5 | Wereboar Loincloth | 0 of 13 |
| 6 | Lavafungus Ring | 0 of 179 |

### 5.3 Zona 2: Banner "Unlock Permanently"

- Posicionado **abaixo** do grid de 6 células, dentro de cada painel.
- **Dimensões:** largura total do painel, ~45px de altura.
- **Fundo:** azul-escuro (`#1a3a5a` aprox.) — distinto do restante, sinaliza estado "bloqueado/premium".
- **Conteúdo:** ícone de folha verde (Tibia Coins ou item especial) seguido do texto `"Unlock permanently"` em branco, centralizado.
- **Ao clicar:** redireciona para compra na Tibia Store de expansão permanente de Weekly Tasks.
- Existe **nos dois painéis** (Kill Tasks e Delivery Tasks), cada um com seu próprio banner.

### 5.4 Zona 3: Informação de XP por Tarefa

- Texto centralizado: `"Each task rewards you with [X] XP."` — branco, ~11px.
- Posicionado ~8px abaixo dos painéis de tarefas.
- O valor de XP (ex: `"412,813"`) é dinâmico e muda conforme o nível do personagem.

### 5.5 Zona 4: Weekly Progress (Barra de Progresso Semanal)

**Container da barra:**
- Título: `"Weekly Progress"` — branco, centralizado, com linhas horizontais de cada lado.
- Dimensões: ocupa ~80% da largura total da janela, alinhado à esquerda.
- Fundo: cinza-escuro, borda fina.

**Estrutura interna do container:**

```
┌────────────────────────────────────────────────────────────────────┐
│  "Weekly Progress"                                                 │
│                                                                    │
│  Reward Multiplier  │  ×1  │  ×1.3  │  ×1.7  │  ×2  │  ×2.5  │  │  ← row labels
│                     ├──────────────────────────────────────────┤  │
│                     │████████████████████████░░░░░░░░░░░░░░░░│  │  ← barra de progresso
│                     ├──────────────────────────────────────────┤  │
│  Completed Tasks    │  0   │   4    │   8    │  12  │   15   │18│  │  ← row labels
└────────────────────────────────────────────────────────────────────┘
```

**→ Linha "Reward Multiplier":**
- Label à esquerda: `"Reward Multiplier"` — branco, ~11px, alinhado à esquerda.
- Valores de multiplicador distribuídos acima da barra nos pontos de milestone: `×1`, `×1.3`, `×1.7`, `×2`, `×2.5` — branco, ~10px, cada um centralizado acima do marco correspondente.

**→ Barra de progresso:**
- Altura: ~12px.
- Largura: ocupa o espaço entre os marcadores.
- Fundo da barra (vazia): cinza-escuro (`#333`).
- Preenchimento (progresso atual): **cor sólida dourada/laranja** (`#c87820` aprox.) preenchendo da esquerda até o ponto atual.
- A barra **não está subdividida** visualmente em segmentos — é contínua.
- **Marcadores de milestone:** pequenas linhas verticais finas acima/abaixo da barra nos pontos 4, 8, 12, 15, 18.

**→ Linha "Completed Tasks":**
- Label à esquerda: `"Completed Tasks"` — branco, ~11px.
- Números abaixo da barra nos pontos de milestone: `0`, `4`, `8`, `12`, `15`, `18` — branco, ~10px.

### 5.6 Painel "Weekly Rewards"

- Posição: lado **direito** da zona 4, fora do container de progresso, alinhado verticalmente ao centro da barra.
- Dimensões: ~160px × ~80px.
- Título: `"Weekly Rewards"` — branco, centralizado no topo do painel, com linha abaixo.
- **Conteúdo:** 2 campos empilhados verticalmente:
  - Campo 1: valor `"0"` com ícone de Hunting Task Points (ícone circular colorido) ao lado direito. Seguido de ícone ⓘ à direita.
  - Campo 2: valor `"0"` com ícone de Soulseals ao lado direito. Seguido de ícone ⓘ à direita.
- Os campos são read-only, mostram quantas recompensas pendentes serão entregues na próxima segunda-feira.

---

## 6. ABA 3 — HUNTING TASK SHOP

### 6.1 Estrutura Geral da Aba

- Sem título de seção separado — a aba inteira é a loja.
- Layout: **grid de 3 colunas × N linhas** de cards de produto.
- Cada card: ~310px × ~120px.
- Gap entre cards: ~8px horizontal, ~8px vertical.
- **Scrollbar vertical** no lado direito da área de produtos (aparece quando há mais itens do que cabem na tela). A scrollbar é fina (~8px), estilo medieval, com alça deslizável.

### 6.2 Estrutura de cada Card de Produto

```
┌──────────────────────────────────────────────────┐
│           [NOME DO PRODUTO]                      │  ← header do card
│  ┌────────┐                                      │
│  │ SPRITE │  [Descrição do item em texto]        │  ← corpo
│  │(48×48) │                                      │
│  └────────┘                                      │
│  ┌────────┐  [Custo] [ícone moeda] [ícone extra] │  ← rodapé do card
│  │  Buy   │                                      │
│  └────────┘                                      │
└──────────────────────────────────────────────────┘
```

**→ Header do card:**
- Fundo: cinza-médio (`#3a3a3a`), altura ~20px.
- Texto: nome do produto em branco, centralizado, ~11px. Exemplos: `"Feral Trapper (Base Outfit)"`, `"Falconer (Addon 1)"`, `"Tidal Seawater Predator (Mount)"`.

**→ Sprite do produto:**
- Posição: lado esquerdo do corpo do card, ~8px de margem.
- Dimensão: ~60×60px container, sprite centralizado.
- Fundo do container: escuro (`#1e1e1e`), sem borda visível ou borda fina.
- Os sprites mostram: personagem com a outfit, addon equipado, ou a montaria.

**→ Texto descritivo:**
- Posição: à direita do sprite, alinhado ao topo.
- Cor: branco/cinza-claro, ~10-11px, pode ter 2-3 linhas.
- Exemplos: `"The newest fashion from Walter Jaeger."`, `"Spice up your outfit for long hunts."`, `"Swim through a sea of prey."`

**→ Rodapé do card (linha de compra):**
- Altura: ~26px. Fundo levemente mais escuro que o corpo.
- **Botão "Buy":**
  - Posição: extrema esquerda do rodapé, ~5px de margem.
  - Dimensões: ~40×18px.
  - Aparência: botão pequeno, fundo cinza-escuro, borda fina, texto `"Buy"`, ~10px.
  - **Ao clicar:** abre confirmação de compra ou compra diretamente o item, debitando o custo em HTP.
  - **Desabilitado** (acinzentado, não clicável) se o jogador já possui o item ou não tem HTP suficientes.

- **Campo de custo:**
  - Posição: ~5px à direita do botão "Buy".
  - Valor numérico com milhar (ex: `"120,000"`, `"50,000"`, `"180,000"`).
  - Imediatamente seguido de **ícone de Hunting Task Points** (~14px).

- **Ícone de raridade/categoria (no canto direito do rodapé):**
  - Posição: extrema direita do rodapé.
  - Dimensão: ~24×24px.
  - Para outfits (Feral Trapper e Falconer): ícone de **silhueta humana** em fundo rosa/magenta, indica categoria "Outfit".
  - Para montarias (Predator mounts): ícone de **ferradura ou símbolo de montaria** em fundo dourado/laranja (`#8a4000` aprox.), indica categoria "Mount".

**Produtos listados (3 linhas visíveis + scrollbar para mais):**

*Linha 1 (Feral Trapper):*
| Coluna | Produto | Custo | Categoria |
|--------|---------|-------|-----------|
| 1 | Feral Trapper (Base Outfit) | 120,000 HTP | Outfit (rosa) |
| 2 | Feral Trapper (Addon 1) | 50,000 HTP | Outfit (rosa) |
| 3 | Feral Trapper (Addon 2) | 50,000 HTP | Outfit (rosa) |

*Linha 2 (Falconer):*
| Coluna | Produto | Custo | Categoria |
|--------|---------|-------|-----------|
| 1 | Falconer (Base Outfit) | 100,000 HTP | Outfit (rosa) |
| 2 | Falconer (Addon 1) | 35,000 HTP | Outfit (rosa) |
| 3 | Falconer (Addon 2) | 35,000 HTP | Outfit (rosa) |

*Linha 3 (Montarias):*
| Coluna | Produto | Custo | Categoria |
|--------|---------|-------|-----------|
| 1 | Tidal Seawater Predator (Mount) | 180,000 HTP | Mount (dourado) |
| 2 | Ashen Coast Predator (Mount) | 180,000 HTP | Mount (dourado) |
| 3 | Crimson Bay Predator (Mount) | 180,000 HTP | Mount (dourado) |

---

## 7. JANELA MODAL — PREFERRED LIST

### 7.1 Características da Janela Modal

- Abre **sobre** o Task Board, bloqueando interação com o fundo até ser fechada.
- **Dimensões:** ~600 × 430px.
- **Posição:** centralizada sobre o Task Board.
- Mesma paleta visual: fundo escuro texturizado, borda medieval dourada.
- **Barra de título:** `"Preferred List"` — branco, centralizado, mesma estética.
- **Sem sobreposição** de outras janelas.

### 7.2 Layout Interno (Dois Painéis Lado a Lado)

```
┌─────────────────────────────────────────────────────────────────────┐
│  "Preferred List"  (título)                                         │
│                                                                     │
│  ┌──────────────────────────────┐  ┌───────────────────────────┐   │
│  │  Painel Esquerdo             │  │  Painel Direito           │   │
│  │  (Lista de criaturas)        │  │  (Slots configurados)     │   │
│  └──────────────────────────────┘  └───────────────────────────┘   │
│                                                          [ Close ]  │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.3 Painel Esquerdo — Lista de Criaturas

- **Dimensões:** ~270px de largura, altura total utilizável (~360px).
- **Borda:** linha fina (`#555`) ao redor.
- **Fundo:** mesmo cinza-escuro texturizado.

**Campo de busca (topo do painel esquerdo):**
- Dimensões: largura total do painel, ~24px de altura.
- Fundo: cinza levemente mais claro.
- Placeholder: `"Type to search"` — cinza-claro, itálico.
- **Botão X:** no extremo direito do campo, quadrado (~18px), com `"×"` em branco. Ao clicar: limpa o texto digitado e volta a listar todas as criaturas.
- **Ao digitar:** a lista abaixo filtra instantaneamente, mostrando apenas criaturas cujo nome contém o texto.

**Lista de criaturas (abaixo do campo de busca):**
- Lista vertical scrollável.
- Cada item da lista: ~30px de altura, linha horizontal fina separadora.
- Estrutura de cada item:
  - **Ícone/sprite** da criatura: ~22×22px, lado esquerdo, ~4px de margem.
  - **Nome da criatura**: texto branco, ~11px, ~6px à direita do ícone.
- **Hover:** fundo do item levemente mais claro.
- **Ao clicar:** seleciona a criatura para arrastar/atribuir a um slot.
- **Scrollbar** no lado direito da lista — fina, estilo medieval.

**Criaturas visíveis na imagem (ordem alfabética, scroll no início):**
1. Acolyte Of The Cult (com sprite de criatura cultista)
2. Adept Of The Cult (com sprite)
3. Adult Goanna (com sprite de lagarto)
4. Afflicted Strider (com sprite)
5. Ancient Scarab (com sprite de scarab dourado)
6. Angry Sugar Fairy (com sprite)
7. Animated Feather (com sprite de pena animada)
8. Arachnophobica (com sprite de aranha enorme)
9. Armadile (com sprite de tatu/crocodilo)
10. Assassin (com sprite de humano furtivo)

### 7.4 Painel Direito — Slots de Configuração

- **Dimensões:** ~300px de largura, altura total utilizável.
- Layout: empilhado verticalmente.

**Sub-painel superior: "Preferred" e "Unwanted"**
- Labels `"Preferred ⓘ"` e `"Unwanted ⓘ"` em colunas iguais (~150px cada), branco, ~11px, com ícone ⓘ ao lado.
- Abaixo de cada label: **um slot de criatura configurado**:

**→ Slot Occupied (slot com criatura atribuída):**
- Dimensões: ~80px × ~70px, fundo escuro, borda fina.
- **Sprite da criatura** centralizado no slot: ~48×48px.
- **Botão "Clear":** pequeno botão (~35×16px) acima/sobreposto ao slot, no canto superior direito. Texto `"Clear"` branco, ~9px. Ao clicar: remove a criatura do slot.
- **Campo de custo (reset):** abaixo do sprite, dentro do slot — campo numérico com valor `"300"` seguido de ícone de Bounty Points. Indica o custo para **trocar** a criatura do slot.

**Slot Preferred (visível na imagem):**
- Sprite: criatura de cor verde (parece uma cabeça de goblin ou planta).

**Slot Unwanted (visível na imagem):**
- Sprite: criatura vermelha (parece um demônio/diabinho pequeno).

**→ Como atribuir criatura ao slot:**
- Clicar numa criatura da lista esquerda e depois clicar no slot desejado (Preferred ou Unwanted), **ou** arrastar da lista para o slot.
- Se o slot já tiver criatura, ela é substituída mediante custo em Bounty Points.

**Sub-painel: 4 blocos de "Additional Slots"**
- Quatro blocos idênticos empilhados abaixo dos slots ativos, cada um representando um slot adicional bloqueado.
- Estrutura de cada bloco:
  - **Título:** `"Additional Slots 🔒"` — branco, ~11px, com ícone de cadeado (`🔒`) ao lado direito do texto, indicando estado bloqueado.
  - **Botão "Unlock":** ~70px × ~18px, desabilitado ou ativo conforme pontos disponíveis. Texto `"Unlock"` cinza (desabilitado) ou branco (ativo). Ao clicar: desbloqueia o slot pagando o custo.
  - **Campo de custo:** ~50px × ~18px, valor numérico seguido de ícone de Bounty Points.
  - Borda inferior fina separando cada bloco.

**Custos dos 4 Additional Slots:**
| Bloco | Custo |
|-------|-------|
| 1º | 300 Bounty Points |
| 2º | 600 Bounty Points |
| 3º | 900 Bounty Points |
| 4º | 1.200 Bounty Points |

**Botão "Close" da janela Preferred List:**
- Posição: canto inferior **direito** da janela modal.
- Dimensões: ~60×22px. Estilo idêntico ao Close do rodapé global.
- Ao clicar: fecha apenas a janela Preferred List, retornando ao Task Board.

---

## 8. GUIA DE CORES E TIPOGRAFIA

### 8.1 Paleta de Cores Primárias

| Elemento | Cor (HEX aproximado) | Uso |
|----------|----------------------|-----|
| Fundo geral | `#2a2a2a` | Body de todas as janelas |
| Fundo de cards | `#353535` | Cards de tarefa, cards de bônus |
| Fundo de células | `#2e2e2e` | Headers de células/cards |
| Borda principal | `#3a2a1a` | Moldura externa medieval |
| Borda interna highlight | `#8a7a3a` | Linha dourada interna |
| Banner header card | `#8a7030` → `#6a5020` | Gradiente dourado-pergaminho |
| Texto principal | `#ffffff` | Todo texto primário |
| Texto secundário | `#aaaaaa` | Labels, subtítulos, valores "of" |
| Progresso atual (kills) | `#cc4400` | Número atual em vermelho-laranja |
| Progresso completo | `#44cc44` | Número atual em verde |
| Botão base | `#3a3a3a` | Fundo de botões padrão |
| Borda botão | `#555555` | Bordas de campos e botões |
| Banner locked | `#1a3a5a` | Fundo azul do "Unlock permanently" |
| Barra de progresso fill | `#c87820` | Preenchimento da barra semanal |
| Ícone de outfit (loja) | `#cc3366` | Fundo rosa do ícone de categoria outfit |
| Ícone de mount (loja) | `#8a4000` | Fundo dourado-escuro do ícone de mount |

### 8.2 Tipografia

- **Fonte única:** sans-serif pequena, estilo bitmap/pixel (típica do Tibia OT).
- **Tamanhos usados:**
  - Título da janela: `12px`
  - Texto de seção: `11px`
  - Texto de cards/botões: `11px`
  - Texto secundário/pequeno: `10px` ou `9px`
- **Negrito:** usado em nomes de criatura nos banners dos cards e em opções selecionadas nos dropdowns.
- **Sem itálico exceto em** placeholders de campos de texto.

---

## 9. COMPORTAMENTOS DE INTERAÇÃO (UX)

### 9.1 Transições de Estado dos Cards

| Estado | Aparência Visual |
|--------|-----------------|
| Tarefa disponível (não selecionada) | Borda padrão fina, fundo normal |
| Tarefa com ícone especial (Silver) | Escudo heráldico no banner, sem alteração de fundo |
| Tarefa selecionada (ativa) | Borda fica **dourada** (~`#c8a020`), fundo pode ter leve overlay |
| Tarefa completada | Banner fica esverdeado, contador mostra número completo em verde |

### 9.2 Comportamento dos Botões

| Botão | Estado Normal | Estado Hover | Estado Disabled |
|-------|--------------|--------------|-----------------|
| Select Task | Cinza escuro, texto branco | Fundo levemente mais claro | — |
| Upgrade Ring | Cinza escuro, texto branco | Mais claro | Acinzentado, texto cinza |
| Claim Daily | Cinza escuro + ícone folha | Mais claro | Acinzentado (já coletado) |
| Reroll Tasks | Cinza escuro | Mais claro | Acinzentado (sem tokens) |
| Buy (loja) | Cinza escuro | Mais claro | Acinzentado (já possui/sem HTP) |
| Deliver | Cinza escuro | Mais claro | Acinzentado (sem itens) |
| Unlock (slots) | Cinza escuro | Mais claro | Acinzentado (sem BP) |
| Close | Cinza escuro | Mais claro | — |

### 9.3 Tooltips (ⓘ)

- Todos os ícones ⓘ exibem tooltips ao hover do mouse.
- Tooltip: caixa pequena com fundo escuro e borda fina dourada, texto branco em múltiplas linhas, aparece próximo ao ícone.
- Sem animação de fade — aparece instantaneamente.

### 9.4 Scrollbars

- Aparecem apenas quando o conteúdo excede a área visível.
- Largura: ~8px.
- Alça: retângulo arredondado, cor cinza-médio (`#555`).
- Track: cinza-escuro (`#2a2a2a`).
- Estilo flat/minimal — sem setas de navegação visíveis.

---

## 10. HIERARQUIA DE CAMADAS (Z-ORDER)

```
[1] Fundo texturizado da janela
[2] Painéis e containers internos
[3] Cards de tarefa / células
[4] Sprites de criaturas / itens
[5] Textos e labels
[6] Botões
[7] Dropdown (quando aberto — flutua sobre tudo)
[8] Janela modal Preferred List (flutua sobre Task Board)
[9] Tooltips (camada mais alta — flutua sobre tudo)
```

---

## 11. RESUMO DE DIMENSÕES PARA IMPLEMENTAÇÃO OTUI

```
TaskBoard_Window:
  width: 990
  height: 585

TitleBar:
  height: 22

TabBar:
  height: 40
  tab_count: 3
  tab_width: 330 each

Content_Area:
  y_start: 62  (após title + tabs)
  height: ~493 (até o rodapé)

Footer:
  height: 30
  y_position: bottom of window

-- ABA BOUNTY TASKS --

SetupSection:
  y: 72
  height: 34 (titulo + linha de controles)

TaskCard_Grid:
  y: 110
  card_width: 303
  card_height: 218
  card_gap: 10
  card_count: 3

BountyRing_Section:
  y: 338
  height: 100
  bonus_card_width: 220
  bonus_card_height: 80
  bonus_card_count: 4

-- ABA WEEKLY TASKS --

KillTasks_Panel:
  x: 15
  width: 460
  height: 230

DeliveryTasks_Panel:
  x: 485
  width: 460
  height: 230

Task_Cell:
  width: 145
  height: 90

UnlockBanner:
  height: 45

XPInfo_Label:
  y_offset: 8 abaixo dos painéis

WeeklyProgress_Bar:
  width: ~790
  height: 70
  bar_fill_height: 12

WeeklyRewards_Panel:
  width: 160
  height: 80

-- ABA HUNTING TASK SHOP --

ShopCard:
  width: 310
  height: 120
  columns: 3
  gap: 8

ShopCard_Header:
  height: 20

ShopCard_Sprite_Container:
  width: 60
  height: 60

ShopCard_Footer:
  height: 26

-- PREFERRED LIST MODAL --

PreferredList_Window:
  width: 600
  height: 430

CreatureList_Panel:
  width: 270
  height: 360

SearchField:
  height: 24

CreatureList_Item:
  height: 30

SlotsConfig_Panel:
  width: 300

ActiveSlot:
  width: 80
  height: 70

AdditionalSlot_Row:
  height: 36
  count: 4
```

---

*Documentação visual gerada a partir de análise direta das screenshots do Task Board (Tibia Winter Update 2025). Todos os valores de dimensão são aproximados com base em análise visual proporcional das imagens originais.*
