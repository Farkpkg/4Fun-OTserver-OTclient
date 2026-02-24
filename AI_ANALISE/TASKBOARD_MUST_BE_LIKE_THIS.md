**TASK BOARD SYSTEM**

Documentação Técnica Completa

Bounty Tasks · Weekly Tasks · Bounty Talisman · Hunting Task Shop

|<p>Baseado no Tibia Winter Update 2025 (versão 15.20.7a5cc9)</p><p>Implementação: CrystalServer (Canary) + OTCRedemption (mehah/EDU)</p><p>Protocolo 15x | Fevereiro 2026</p>|
| :-: |



Este documento descreve o sistema de A a Z.

Qualquer desenvolvedor ou IA que leia este arquivo estará apta a implementar o sistema completo.


# **1. Visão Geral do Sistema**
O Task Board é o sistema central de tarefas de caça do Tibia, introduzido no Winter Update 2025 (versão 15.20.7a5cc9, lançado em 24 de novembro de 2025). Ele substituiu completamente o sistema antigo de Prey Hunting Tasks, consolidando todos os desafios de criaturas em uma única interface acessível por um NPC ou atalho de teclado.

O sistema é composto por dois pilares independentes mas interligados:

- Bounty Tasks — desafios infinitos e repetíveis de caça a criaturas específicas, recompensando com XP, Bounty Points e Reroll Tokens.
- Weekly Tasks — tarefas semanais (Kill + Delivery), recompensando com XP, Hunting Task Points (HTP) e Soulseals.

Ambos os pilares compartilham a mesma interface gráfica (Task Board), mas possuem moedas, progressões e lógicas totalmente distintas.

|**⚠️ Nota de Implementação**|
| :- |
|O Task Board NÃO existe em Rookgaard — só funciona no mainland.|
|Jogadores Free Account têm acesso completo ao sistema, mas criaturas Expert/Master requerem acesso Premium a certas áreas.|
|Esta documentação descreve a versão oficial do Tibia adaptada para servidores privados (OTServer).|
||

## **1.1 Arquitetura de Moedas**
O sistema usa quatro moedas exclusivas, cada uma vinculada a uma parte específica:

|**Símbolo**|**Nome**|**Origem**|**Uso**|
| :-: | :-: | :-: | :-: |
|●|Bounty Points (BP)|Completar Bounty Tasks|Upgrade do Talisman, liberar slots|
|◆|Reroll Tokens (RT)|Completar Bounty Tasks (1 por task)|Resorteio das 3 tasks oferecidas|
|▲|Hunting Task Points (HTP)|Completar Weekly Tasks|Hunting Task Shop (outfits, mounts)|
|✦|Soulseals|Completar Weekly Tasks (1 por task)|Batalhas solo no Soulpit|

## **1.2 Fluxo Geral do Jogador**
1. Jogador abre o Task Board (via NPC ou atalho).
1. Seleciona uma das 3 Bounty Tasks sorteadas para a dificuldade escolhida.
1. Vai caçar a criatura até completar o número de kills exigido.
1. Recebe XP, BP e RT ao completar.
1. Paralelamente, completa Weekly Tasks (kill e delivery) ao longo da semana.
1. Na segunda-feira após o server save, recebe HTP e Soulseals pelas Weekly Tasks.
1. Gasta BP para fazer upgrade do Bounty Talisman.
1. Gasta HTP na Hunting Task Shop para comprar outfits e mounts.
1. Usa Soulseals no Soulpit para batalhas solo especiais.


# **2. Bounty Tasks**
As Bounty Tasks são o núcleo do sistema. O jogador sempre tem exatamente 3 tasks disponíveis simultaneamente (os "slots" de escolha), das quais seleciona apenas 1 por vez para executar. Após concluí-la, o slot é liberado e uma nova task aparece.
## **2.1 Dificuldades**
Existem 4 níveis de dificuldade. O jogador pode trocar de dificuldade a qualquer momento, mas a mudança só vale para a próxima task — a task ativa não é afetada.

|**Dificuldade**|**Pool de Criaturas**|**Kill Range**|**Bounty Points**|**Reroll Tokens**|
| :-: | :-: | :-: | :-: | :-: |
|Beginner|Fácil (bestiary "Easy") — 151 criaturas|50 – 100|3 BP|1 RT|
|Adept|Médio + Fácil misturadas|100 – 200|7 BP|1 RT|
|Expert|Difícil + Médio misturadas|200 – 400|16 BP|1 RT|
|Master|Desafiador + Difícil misturadas|400 – 600|54 BP|1 RT|

Nota: "Kill Range" é o intervalo de kills que o servidor sorteia aleatoriamente ao gerar a task. Cada task tem seu próprio número alvo dentro do range.
## **2.2 Tasks Silver e Gold**
Ao sortear as 3 tasks, existe uma chance de algumas serem especiais, com recompensas multiplicadas:

|**Tipo**|**Probabilidade**|**Multiplicador**|**Visual**|
| :-: | :-: | :-: | :-: |
|Normal|~75%|x1 (base)|Badge padrão|
|Silver ◈|~20%|x2 (XP e BP)|Badge prateado|
|Gold ◉|~5%|x4 (XP e BP)|Badge dourado|

Exemplo: Uma task Expert normal dá 16 BP. A mesma task como Gold daria 64 BP e 4x mais XP.
## **2.3 Recompensas por Task Completada**
Ao concluir uma Bounty Task, o jogador recebe imediatamente (não precisa esperar server save):

- XP baseado na dificuldade e nas criaturas mortas, multiplicado pelo tier (x1/x2/x4).
- Bounty Points (BP): 3 / 7 / 16 / 54 por dificuldade, multiplicados pelo tier.
- Reroll Tokens (RT): sempre 1 por task concluída, independente do tier.

|**💡 Cálculo de Recompensa**|
| :- |
|Fórmula BP: BP\_base × tier\_multiplier|
|Exemplo Adept Gold: 7 × 4 = 28 BP|
|Fórmula XP: XP\_base\_criatura × kills × tier\_multiplier|
|RT: sempre 1, sem multiplicador|
||
## **2.4 Reroll Tasks**
O jogador pode resorteiar as 3 tasks disponíveis (descartar todas e receber 3 novas) gastando 1 Reroll Token. A task ativa no momento não é afetada — apenas as 3 ofertas pendentes são substituídas.

- Custo: 1 Reroll Token por reroll.
- Token grátis diário: 1 token pode ser reivindicado gratuitamente uma vez por dia (claim daily). Não acumula entre dias se não for coletado.
- Limite máximo de RT por personagem: 10 tokens.
## **2.5 Preferred List (Lista de Preferências)**
A Preferred List permite ao jogador personalizar quais criaturas têm mais ou menos chance de aparecer nas suas Bounty Tasks. É acessada por um botão dentro do Task Board.
### **2.5.1 Preferred (Criaturas Preferidas)**
Criaturas marcadas como "Preferred" têm chance aumentada (+50%) de aparecer no sorteio das 3 tasks. O jogador começa com 1 slot ativo e pode comprar mais com BP.
### **2.5.2 Unwanted (Criaturas Evitadas)**
Criaturas marcadas como "Unwanted" são completamente excluídas do sorteio — nunca aparecerão como opção de task enquanto estiverem na lista.
### **2.5.3 Slots Extras**
Por padrão cada lista (Preferred e Unwanted) tem 1 slot. O jogador pode comprar slots adicionais de forma permanente:

|**Slot Extra**|**Custo**|
| :-: | :-: |
|Slot 2|300 Bounty Points|
|Slot 3|600 Bounty Points|
|Slot 4|900 Bounty Points|
|Slot 5|1\.200 Bounty Points|

Esses slots se aplicam igualmente para a lista Preferred e para a lista Unwanted. Ou seja, comprando o slot extra 2, o jogador passa a ter 2 slots em cada lista.

|**⚠️ Custo de Reset de Slots**|
| :- |
|Além do custo de compra, limpar/resetar um slot também consome Bounty Points.|
|O custo de reset é definido e configurável no servidor.|
||
## **2.6 Ícone Visual In-Game**
Enquanto o jogador tem uma Bounty Task ativa, um pequeno ícone do Bounty Talisman aparece ao lado do sprite da criatura alvo (visível apenas se a opção de exibir nomes de criaturas estiver ativa no cliente). O ícone desaparece automaticamente quando o número de kills necessário é atingido.


# **3. Bounty Talisman**
O Bounty Talisman é um item equipável no slot extra do inventário, comprado de qualquer ourives (jeweller) por 5.000 gold. Seus upgrades são permanentes e vinculados ao personagem — não se perdem com morte ou troca de equipamento.

O talisman fornece 4 bônus passivos, cada um com sua própria progressão independente. Os bônus só se aplicam enquanto o talisman estiver equipado E o jogador estiver combatendo criaturas da sua Bounty Task ativa.
## **3.1 Os 4 Bônus do Talisman**

|**#**|**Bônus**|**Efeito**|**Valor inicial**|
| :-: | :-: | :-: | :-: |
|1|Damage Against Creatures|Aumenta o dano causado às criaturas da task ativa|2,50%|
|2|Life Leech|Chance de recuperar HP proporcional ao dano causado|2,50%|
|3|More Loot|Chance de um set extra de loot ser gerado|2,50%|
|4|Double Bestiary Progress|Chance de o progresso no bestiary ser contado em dobro|5,00%|
## **3.2 Progressão de Upgrades**
Cada bônus começa no nível 1 e pode ser upgradado indefinidamente. O custo do primeiro upgrade de qualquer bônus é sempre 5 BP. Cada upgrade subsequente custa 12 BP a mais que o anterior:

|**Nível de Upgrade**|**Custo em BP**|**Custo Total Acumulado**|
| :-: | :-: | :-: |
|1 → 2|5 BP|5 BP|
|2 → 3|17 BP|22 BP|
|3 → 4|29 BP|51 BP|
|4 → 5|41 BP|92 BP|
|5 → 6|53 BP|145 BP|
|N → N+1|5 + (N-1) × 12 BP|...|

Fórmula geral: custo(N) = 5 + (N - 1) × 12, onde N é o nível atual (o upgrade que vai do nível N para N+1 custa este valor).

|**📊 Exemplos de Progressão**|
| :- |
|Nível 1 → 2: 5 BP|
|Nível 5 → 6: 5 + (5-1)×12 = 5 + 48 = 53 BP|
|Nível 10 → 11: 5 + (10-1)×12 = 5 + 108 = 113 BP|
|Para chegar ao nível 20 desde 1: soma de 5+17+29+...+(5+19×12) = muito BP|
|Dano máximo documentado na comunidade: +20% (com hunting task points para continuar além disso)|
||
## **3.3 Como Equipar e Usar**
- Compre o talisman em qualquer ourives por 5.000 gold.
- Equipe no slot extra do inventário.
- Os bônus se aplicam automaticamente ao combater criaturas da task ativa.
- Upgrades são feitos dentro do Task Board, na aba Bounty Tasks, seção "Bounty Talisman".
- Todos os upgrades são permanentes e ligados ao personagem (character-bound).


# **4. Weekly Tasks (Tarefas Semanais)**
As Weekly Tasks oferecem uma camada de progressão semanal com dois tipos de desafios: Kill Tasks (matar criaturas) e Delivery Tasks (entregar itens). Elas são completamente independentes das Bounty Tasks, tendo moedas e lógicas próprias.
## **4.1 Estrutura das Tarefas Semanais**

|**Tipo**|**Quantidade (padrão)**|**Quantidade (com expansão)**|**Recompensa**|
| :-: | :-: | :-: | :-: |
|Kill Tasks|6 por semana|9 por semana|XP + HTP + 1 Soulseal|
|Delivery Tasks|6 por semana|9 por semana|XP + HTP + 1 Soulseal|
|Total|12 por semana|18 por semana|—|

A expansão (Permanent Weekly Task Expansion) substituiu o antigo "Permanent Hunting Task Slot" da loja do Tibia. Para servidores privados, pode ser implementada como uma expansão permanente vendida no servidor.
## **4.2 Kill Tasks**
Kill Tasks exigem que o jogador mate um determinado número de uma criatura específica. Diferente das Bounty Tasks, as criaturas das Kill Tasks são fixas para a semana (não há escolha — são atribuídas automaticamente).

O progresso de kills é rastreado automaticamente: qualquer kill da criatura correta conta, independente de ter uma Bounty Task ativa para ela ou não.

Ao completar cada Kill Task, o jogador recebe imediatamente a recompensa de XP.
## **4.3 Delivery Tasks**
Delivery Tasks exigem que o jogador entregue um determinado número de um item específico. O jogador deve ter os itens no inventário e interagir com o NPC do Task Board para realizar a entrega.

Ao completar cada Delivery Task, o jogador recebe imediatamente a recompensa de XP.

|**⚡ XP de Delivery Tasks**|
| :- |
|Jogadores de nível 82 ou abaixo recebem XP equivalente a 50% de um nível ao completar uma delivery task.|
|Para jogadores acima do nível 82, o XP segue uma fórmula baseada no nível do personagem.|
||
## **4.4 Recompensas Semanais: HTP e Soulseals**
Diferente do XP (que é imediato), o HTP e os Soulseals são concedidos apenas no server save da segunda-feira, após o reset semanal. Todos os personagens que completaram pelo menos 1 task na semana recebem seus pontos neste momento.

### **4.4.1 Hunting Task Points (HTP) por Task**

|**Tipo de Task**|**HTP Base**|
| :-: | :-: |
|Kill Task — Beginner|25 HTP|
|Kill Task — Adept|50 HTP|
|Kill Task — Expert|100 HTP|
|Kill Task — Master|110 HTP|
|Delivery Task (qualquer dificuldade)|75 HTP|

### **4.4.2 Multiplicador de HTP (Weekly Progress)**
O total de HTP da semana é multiplicado com base na quantidade total de tasks completadas (kill + delivery somados):

|**Tasks Completadas**|**Multiplicador de HTP**|**Progressão**|
| :-: | :-: | :-: |
|0 a 3 tasks|x1 (sem bônus)|Base|
|4 a 7 tasks|x2|Dobro|
|8 a 11 tasks|x3|Triplo|
|12 a 15 tasks|x5|Quíntuplo|
|16 a 18 tasks|x8|Óctuplo|

|**📊 Exemplos de HTP Máximo (18 tasks completas)**|
| :- |
|Beginner (6 kill × 25 + 6 delivery × 75) × 8 = (150 + 450) × 8 = 4.800... incorreto.|
|Cálculo correto (18 tasks = 9 kill + 9 delivery com expansão):|
|`  `Beginner: (9×25 + 9×75) × 8 = (225 + 675) × 8 = 7.200 HTP|
|`  `Adept:    (9×50 + 9×75) × 8 = (450 + 675) × 8 = 9.000 HTP|
|`  `Expert:   (9×100 + 9×75) × 8 = (900 + 675) × 8 = 12.600 HTP|
|`  `Master:   (9×110 + 9×75) × 8 = (990 + 675) × 8 = 13.320 HTP|
||

### **4.4.3 Soulseals**
O jogador recebe exatamente 1 Soulseal por task completada, sem multiplicador. Com 18 tasks completadas = 18 Soulseals. Soulseals são usados no Soulpit para batalhas solo contra criaturas específicas (custo: 10 a 60 Soulseals por batalha, dependendo da criatura).
## **4.5 Reset Semanal**
O reset ocorre toda segunda-feira no server save (00:00 UTC ou conforme configurado no servidor). No momento do reset:

1. Os HTP e Soulseals acumulados na semana são creditados ao jogador.
1. Uma janela de recompensas aparece no cliente, mostrando o total ganho.
1. O jogador escolhe a dificuldade para o novo ciclo (Beginner, Adept, Expert ou Master).
1. Todas as weekly tasks são substituídas por novas tasks da dificuldade escolhida.
1. Os contadores de progresso (kills/deliveries) são zerados.
## **4.6 Unlock Permanente de Kill/Delivery Tasks**
Por padrão, um personagem tem acesso a 6 Kill Tasks e 6 Delivery Tasks por semana. O jogador pode comprar um "Permanent Weekly Task Expansion" que expande para 9+9. Para implementação em servidores privados, recomenda-se tratar isso como um flag permanente no banco de dados do personagem.


# **5. Hunting Task Shop**
A Hunting Task Shop é a loja onde Hunting Task Points (HTP) podem ser trocados por recompensas cosméticas e funcionais. É acessada pela terceira aba do Task Board.
## **5.1 Categorias de Itens**
- Outfits (base + addons) — outfits exclusivos do sistema de tarefas.
- Mounts — montarias exclusivas.
- Itens decorativos — trofeus e itens para casas.
- Promotion Points — pontos para a Wheel of Destiny (para servidores que implementam esse sistema).
## **5.2 Itens Oficiais Disponíveis na Loja**
Os seguintes itens estão no Task Board oficial do Tibia. Para implementação customizada, o servidor pode adicionar/remover itens conforme desejado:

|**Item**|**Tipo**|**Custo em HTP**|
| :-: | :-: | :-: |
|Feral Trapper (Outfit Base)|Outfit|120\.000 HTP|
|Feral Trapper (Addon 1)|Addon|50\.000 HTP|
|Feral Trapper (Addon 2)|Addon|50\.000 HTP|
|Falconer (Outfit Base)|Outfit|100\.000 HTP|
|Falconer (Addon 1)|Addon|35\.000 HTP|
|Falconer (Addon 2)|Addon|35\.000 HTP|
|Tidal Seawater Predator|Mount|180\.000 HTP|
|Ashen Coast Predator|Mount|180\.000 HTP|
|Crimson Bay Predator|Mount|180\.000 HTP|
|Antelope|Mount|Disponível (preço varia)|
|Promotion Points (Wheel of Destiny)|Funcional|Varia por quantidade|

|**⚙️ Nota para Servidores Privados**|
| :- |
|Os itens e preços acima são da versão oficial do Tibia.|
|Em CrystalServer, os itens e preços podem ser customizados no arquivo taskboard\_config.lua.|
|O sistema suporta qualquer item que tenha um itemId válido no servidor.|
|Outfits e mounts são concedidos diretamente ao personagem como rewards permanentes.|
||

# **6. Interface Gráfica (UI) — Layout Detalhado**
A interface do Task Board é uma janela com 3 abas, acessada via NPC ou atalho de teclado. Todo o layout foi desenvolvido em .otui (OTCRedemption) e controlado pelo taskboard.lua. Esta seção descreve cada elemento visual de forma suficientemente detalhada para que um desenvolvedor sem acesso às imagens possa recriar a UI.
## **6.1 Janela Principal — Dimensões e Estrutura**

|**Propriedade**|**Valor**|
| :-: | :-: |
|Tamanho da janela|720 × 560 pixels|
|Título|"Task Board"|
|Abas|3 abas: "Bounty Tasks" | "Weekly Tasks" | "Hunting Task Shop"|
|Largura de cada aba|180 pixels|
|Barra inferior (moedas)|28 pixels de altura, full-width|
## **6.2 Barra Inferior — Moedas**
A barra inferior é sempre visível em todas as abas e exibe o saldo atual de todas as moedas do jogador, separadas por ícones:

- [RT Tokens] ◆ — cor azul-claro (#60b0e0)
- [Bounty Points] ● — cor laranja (#f09030)
- [Hunting Task Points] ▲ — cor verde (#80d060)
- [Soulseals] ✦ — cor roxa (#b080e0)
- Botão "Close" — alinhado à direita
## **6.3 Aba 1: Bounty Tasks**
Esta aba é dividida em duas seções verticais: a grade de 3 task cards (acima) e a grade de 4 Bounty Talisman upgrades (abaixo).
### **6.3.1 Controles de Setup**
Na parte superior da aba, há uma linha horizontal com os seguintes elementos da esquerda para a direita:

- "Task Difficulty:" — label fixo
- ComboBox com 4 opções: Beginner / Adept / Expert / Master (90px de largura)
- Botão "Preferred List" (100px) — abre a janela de preferred list
- Botão "Reroll Tasks" (90px) — gasta 1 RT para resorteiar
- Label com o saldo atual de RT tokens (número + ◆)
- Botão "Claim Daily" (90px) — reivindica o token diário gratuito
### **6.3.2 Grid de Task Cards (3 cards lado a lado)**
Cada card tem 220px de largura e 215px de altura, com a seguinte estrutura interna de cima para baixo:

- Nome da criatura (alinhado ao centro, cor dourada #f0c060, fonte verdana-11px-rounded)
- Badge de tier: vazio (normal) | "[SILVER 2x]" (cor prata) | "[GOLD 4x]" (cor dourada)
- Sprite da criatura: widget Creature, 64×64px, centralizado, com borda de 1px
- "X / Y kills" — progresso atual/total, cor cinza-claro, centralizado
- Bloco de recompensas (texto multilinha): "Reward (2x):   12.500 XP   14 BP   2 RT" — cor creme (#e8d8b0)
- Botão "Select Task" — full-width, 20px de altura, na parte inferior do card
### **6.3.3 Seção Bounty Talisman (4 painéis lado a lado)**
Abaixo dos 3 task cards, há uma linha com 4 painéis de upgrade do talisman, cada um com:

- Nome do bônus (ex: "Damage Against Creatures") — 2 linhas, cor branca
- "Current: X.XX%" — cor cinza, valor atual do bônus
- Botão "Upgrade to Y.YY%" — full-width, fonte pequena
- "N BP" — custo do próximo upgrade, cor laranja, alinhado abaixo do botão

Os 4 bônus, em ordem: (1) Damage Against Creatures | (2) Life Leech | (3) More Loot | (4) Double Bestiary Progress
## **6.4 Aba 2: Weekly Tasks**
Dividida em 3 zonas verticais: banner de XP (topo), colunas kill/delivery (meio), barra de progresso semanal (baixo).
### **6.4.1 Banner de XP**
"Each task rewards you with X XP." — texto centralizado, atualizado com o XP da semana atual.
### **6.4.2 Colunas Kill e Delivery**
Duas colunas lado a lado (340px + restante), cada uma contendo:

- Título: "Kill Tasks" ou "Delivery Tasks" (centralizado, dourado)
- Grid de cards 3×2 (6 tasks por coluna): cada card 104×104px com sprite, nome, progresso numérico, e botão "Deliver" (apenas nas delivery tasks)
- Botão "Unlock permanently" no rodapé (visível apenas se não foi comprado o unlock)
### **6.4.3 Barra de Progresso Semanal**
Na parte inferior da aba, um painel horizontal mostrando:

- Rótulos de multiplicadores: "x1 | x2 | x3 | x5 | x8" — cor dourada
- ProgressBar horizontal (0 a 18) com marcações nos thresholds 0/4/8/12/16/18
- Números abaixo da barra: "0 | 4 | 8 | 12 | 16 | 18"
- Painel lateral "Weekly Rewards" mostrando o HTP e Soulseals acumulados na semana
## **6.5 Aba 3: Hunting Task Shop**
Um painel com rolagem vertical contendo um grid 3×N de cards de itens. Cada card (220×110px) contém:

- Nome do item no topo (centralizado, cor creme)
- Sprite/ícone do item (34×34px, à esquerda)
- Descrição do item (texto à direita do sprite, cor cinza)
- Botão "Buy" + preço em HTP ▲ (rodapé do card, cor verde)
## **6.6 Janela Secundária: Preferred List**
Uma janela separada (490×400px), dividida em duas colunas por um divisor dourado:
### **6.6.1 Coluna Esquerda — Busca de Criaturas (185px)**
- Campo de texto de busca (TextEdit) com botão "x" para limpar
- Lista rolável de criaturas com sprite (22×22px) + nome, filtrável em tempo real conforme o jogador digita
### **6.6.2 Coluna Direita — Slots Preferred/Unwanted**
- Dois cabeçalhos lado a lado: "Preferred" e "Unwanted" (cor dourada)
- Slot 1 ativo (em cada coluna): sprite 34×34px + nome + botão "Clear" + custo de reset em BP
- 4 painéis de "Additional Slots 🔒": cada um com botão "Unlock" + custo em BP (300/600/900/1.200 BP)
- Botão muda para "Unlocked" (desabilitado) após compra
- Barra inferior idêntica à principal (moedas + botão Close)
## **6.7 Popup: Weekly Progress**
Uma janela modal (320×280px) que aparece no reset semanal ou manualmente pelo jogador:

- "You have completed X / 6 kill tasks." — cor creme
- "You have completed X / 6 delivery tasks." — cor creme
- "Total earned: X HTP  Y Soulseals" — cor verde
- Texto: "Select the difficulty for your next tasks." — cor azul
- 4 botões de seleção de dificuldade: Beginner / Adept / Expert / Master
- "Master" fica desabilitado se o jogador não atender ao requisito (configurável no servidor)


# **7. Protocolo de Comunicação Cliente ↔ Servidor**
A comunicação usa Extended Opcodes (byte 0x32 como header) do protocolo OTCRedemption. Os opcodes 50–57 são enviados pelo servidor ao cliente; os opcodes 60–72 são enviados pelo cliente ao servidor.

|**⚠️ Verificação de Conflito**|
| :- |
|Antes de implementar, verifique se os opcodes 50–72 não conflitam com outros sistemas do servidor.|
|Se houver conflito, ajuste os números simultaneamente no protocolgame.cpp e no taskboard.lua (variável OPCODE).|
|O OTCRedemption usa o byte 0x32 como marcador de extended opcode antes de todos esses pacotes.|
||
## **7.1 Servidor → Cliente (opcodes recebidos pelo cliente)**

|**Opcode**|**Nome**|**Quando Enviar**|
| :-: | :-: | :-: |
|50|OPEN|Jogador interage com NPC/objeto Task Board|
|51|BOUNTY\_DATA|Após OPEN, reroll, seleção de task, atualização de kills|
|52|WEEKLY\_DATA|Após OPEN, conclusão de kill/delivery task|
|53|SHOP\_DATA|Após OPEN (pode ser cacheado — enviar 1x por sessão)|
|54|PREFERRED|Ao abrir a janela de Preferred List|
|55|TALISMAN|Após OPEN e após qualquer upgrade de talisman|
|56|CURRENCIES|Após OPEN e após QUALQUER alteração nas moedas|
|57|RESULT|Resposta a TODA ação do jogador (sucesso ou erro)|
## **7.2 Cliente → Servidor (opcodes enviados pelo cliente)**

|**Opcode**|**Nome**|**Payload (bytes, em ordem)**|
| :-: | :-: | :-: |
|60|SELECT|u8 slot (1, 2 ou 3) — qual das 3 tasks foi escolhida|
|61|REROLL|— (sem payload) — resorteio das tasks|
|62|CLAIM\_DAILY|— (sem payload) — reivindicar token diário|
|63|PREF\_SET|u8 tipo (0=preferred / 1=unwanted) + u32 creatureId|
|64|PREF\_CLEAR|u8 slot — limpar slot preferred|
|65|UNWANT\_CLEAR|u8 slot — limpar slot unwanted|
|66|EXTRA\_SLOT|u8 index (1–4) — comprar slot extra|
|67|TALISM\_UP|u8 slot (1–4) — qual dos 4 bônus do talisman upgradear|
|68|SHOP\_BUY|u16 index — índice do item na lista da loja|
|69|WEEKLY\_DIFF|u8 dificuldade (0=Beginner, 1=Adept, 2=Expert, 3=Master)|
|70|DELIVER|u8 index (1–6) — entrega da delivery task|
|71|UNLOCK\_KILL|— (sem payload) — compra unlock permanente kill tasks|
|72|UNLOCK\_DELIV|— (sem payload) — compra unlock permanente delivery tasks|
## **7.3 Formato Exato dos Pacotes (Servidor → Cliente)**
Os bytes devem ser escritos/lidos NESTA ORDEM EXATA. Qualquer desvio quebra o parser do cliente silenciosamente.
### **Opcode 50 — OPEN**
Sem payload. Apenas abre a janela. O servidor deve enviar imediatamente após: 51 + 52 + 53 + 55 + 56.
### **Opcode 51 — BOUNTY\_DATA**

|**Campo**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|difficulty|u8|0=Beginner 1=Adept 2=Expert 3=Master|
|[repete 3x para slots 1,2,3]|||
|name|string|Nome da criatura|
|creatureId|u32|ID para renderizar sprite no cliente|
|kills|u32|Progresso atual de kills do jogador|
|maxKills|u32|Total de kills necessários para completar|
|xp|u64|Recompensa base de XP (antes do multiplicador de tier)|
|bountyPoints|u16|Recompensa base em BP (antes do multiplicador de tier)|
|rerollTokens|u8|Sempre 1 (sem multiplicador)|
|tier|u8|0=Normal 1=Silver(2x) 2=Gold(4x)|
### **Opcode 52 — WEEKLY\_DATA**

|**Campo**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|rewardXP|u32|XP por task completada nesta semana|
|killUnlocked|u8|0=bloqueado 1=permanentemente desbloqueado|
|delivUnlocked|u8|0=bloqueado 1=permanentemente desbloqueado|
|completedTasks|u8|Total de tasks completadas esta semana (0–18)|
|weeklyHTP|u32|HTP acumulado esta semana (antes do multiplicador)|
|weeklySeals|u32|Soulseals acumulados esta semana|
|[repete 6x — kill tasks]|||
|name|string|Nome da criatura|
|creatureId|u32|ID para sprite|
|kills|u32|Kills feitas nesta task|
|maxKills|u32|Kills totais necessárias|
|[repete 6x — delivery tasks]|||
|name|string|Nome do item a entregar|
|itemId|u32|ID do item|
|count|u32|Quantidade entregue|
|maxCount|u32|Quantidade total necessária|
### **Opcode 53 — SHOP\_DATA**

|**Campo**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|count|u16|Total de itens na loja|
|[repete count vezes]|||
|name|string|Nome do item|
|desc|string|Descrição do item|
|price|u32|Custo em HTP|
|itemId|u32|ID do item para sprite|
|type|u8|0=outfit\_base 1=addon1 2=addon2 3=mount|
### **Opcode 54 — PREFERRED**

|**Campo**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|extraSlots|u8|Bitmask: bit0=slot2 desbloqueado, bit1=slot3, bit2=slot4, bit3=slot5|
|preferredCount|u8|Quantidade de criaturas preferred atualmente (0–5)|
|[repete preferredCount vezes]|||
|name|string|Nome da criatura|
|creatureId|u32|ID da criatura|
|unwantedCount|u8|Quantidade de criaturas unwanted atualmente (0–5)|
|[repete unwantedCount vezes]|||
|name|string|Nome da criatura|
|creatureId|u32|ID da criatura|
|creatureListCount|u16|Total de criaturas disponíveis para escolha|
|[repete creatureListCount vezes]|||
|name|string|Nome da criatura|
|creatureId|u32|ID da criatura|
### **Opcode 55 — TALISMAN**

|**Campo**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|[repete 4x em ordem: Damage, Life Leech, More Loot, Double Bestiary]|||
|current|float|Percentual atual do bônus (ex: 2.50)|
|next|float|Percentual do próximo nível (ex: 3.00)|
|cost|u16|Custo em BP do próximo upgrade|
### **Opcode 56 — CURRENCIES**

|**Campo**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|rerollTokens|u16|Saldo atual de Reroll Tokens|
|bountyPoints|u32|Saldo atual de Bounty Points|
|huntingPoints|u32|Saldo atual de Hunting Task Points|
|soulseals|u32|Saldo atual de Soulseals|
### **Opcode 57 — RESULT**

|**Campo**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|ok|u8|1=sucesso / 0=erro|
|message|string|Mensagem exibida ao jogador (pode ser string vazia)|


# **8. Banco de Dados (MySQL)**
O sistema usa 6 tabelas MySQL dedicadas. Nenhum dado do Task Board deve ser armazenado na tabela player\_storage para facilitar queries e manutenção.
## **8.1 Tabela: player\_bounty\_tasks**
Armazena as 3 bounty tasks ativas de cada jogador.

|**Coluna**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|player\_id|INT UNSIGNED|FK para players.id (CASCADE DELETE)|
|slot|TINYINT|1, 2 ou 3 (as 3 tasks oferecidas)|
|creature\_id|INT UNSIGNED|ID da criatura|
|creature\_name|VARCHAR(64)|Nome da criatura|
|kills|INT UNSIGNED|Kills atuais do jogador nesta task|
|max\_kills|INT UNSIGNED|Kills necessárias para completar|
|xp\_reward|BIGINT UNSIGNED|XP base de recompensa|
|bp\_reward|SMALLINT UNSIGNED|BP base de recompensa|
|rt\_reward|TINYINT UNSIGNED|RT de recompensa (geralmente 1)|
|tier|TINYINT UNSIGNED|0=normal 1=silver 2=gold|
|difficulty|TINYINT UNSIGNED|0=beginner 1=adept 2=expert 3=master|
|completed|TINYINT UNSIGNED|0=ativa 1=concluída (aguardando nova seleção)|

PK: (player\_id, slot)
## **8.2 Tabela: player\_weekly\_tasks**
Armazena as weekly tasks de cada jogador para a semana corrente.

|**Coluna**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|player\_id|INT UNSIGNED|FK para players.id|
|task\_type|TINYINT|0=kill task / 1=delivery task|
|slot|TINYINT|1–6 (ou 1–9 com expansão)|
|target\_name|VARCHAR(64)|Nome da criatura ou item|
|target\_id|INT UNSIGNED|ID da criatura ou item|
|current\_count|INT UNSIGNED|Progresso atual|
|max\_count|INT UNSIGNED|Total necessário|
|completed|TINYINT UNSIGNED|0=pendente 1=concluída|
|week\_number|SMALLINT UNSIGNED|Número da semana ISO (para invalidar dados antigos)|

PK: (player\_id, task\_type, slot)
## **8.3 Tabela: player\_talisman**
Armazena o nível atual de cada um dos 4 bônus do talisman.

|**Coluna**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|player\_id|INT UNSIGNED|FK para players.id|
|slot|TINYINT|1=Damage / 2=Life Leech / 3=More Loot / 4=Double Bestiary|
|level|TINYINT UNSIGNED|Nível atual do bônus (começa em 1)|
|current\_pct|FLOAT|Percentual atual do bônus em float|

PK: (player\_id, slot)
## **8.4 Tabela: player\_task\_preferred**
Armazena criaturas preferidas e evitadas por slot.

|**Coluna**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|player\_id|INT UNSIGNED|FK para players.id|
|list\_type|TINYINT|0=preferred / 1=unwanted|
|slot|TINYINT|1–5 (slot 1 padrão + 4 extras)|
|creature\_id|INT UNSIGNED|ID da criatura (0 se slot vazio)|
|creature\_name|VARCHAR(64)|Nome da criatura|

PK: (player\_id, list\_type, slot)
## **8.5 Tabela: player\_task\_extra\_slots**
Armazena quais slots extras foram desbloqueados (bitmask).

|**Coluna**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|player\_id|INT UNSIGNED|FK para players.id (PK)|
|extra\_slots|TINYINT UNSIGNED|Bitmask: bit0=slot2, bit1=slot3, bit2=slot4, bit3=slot5|
## **8.6 Tabela: player\_task\_currencies**
Armazena as 4 moedas e controle do daily token.

|**Coluna**|**Tipo**|**Descrição**|
| :-: | :-: | :-: |
|player\_id|INT UNSIGNED|FK para players.id (PK)|
|reroll\_tokens|SMALLINT UNSIGNED|Saldo de RT (máx 10)|
|bounty\_points|INT UNSIGNED|Saldo de BP|
|hunting\_points|INT UNSIGNED|Saldo de HTP|
|soulseals|INT UNSIGNED|Saldo de Soulseals|
|last\_daily|DATE|Data do último claim daily (NULL se nunca coletou)|
|kill\_unlocked|TINYINT UNSIGNED|0=6 tasks/semana 1=9 tasks/semana (kill)|
|deliv\_unlocked|TINYINT UNSIGNED|0=6 tasks/semana 1=9 tasks/semana (delivery)|


# **9. Regras de Negócio Completas**
## **9.1 Sorteio das 3 Bounty Tasks**
1. Obter a lista de criaturas elegíveis para a dificuldade selecionada.
1. Remover criaturas que estão na lista "Unwanted" do jogador.
1. Aumentar o peso (chance) das criaturas que estão na lista "Preferred" em +50%.
1. Sortear 3 criaturas sem repetição da lista resultante.
1. Para cada criatura sorteada, sortear o tier: Normal (~75%), Silver (~20%), Gold (~5%).
1. Sortear o número de kills dentro do range da dificuldade.
1. Calcular xp\_reward com base na XP base da criatura × kills × tier\_multiplier.
1. Salvar as 3 tasks no banco e enviar opcode 51 ao cliente.
## **9.2 Seleção de Task pelo Jogador**
1. Jogador clica em "Select Task" no card desejado (opcode 60, payload: u8 slot).
1. Servidor valida: o slot existe e não está ativo/concluído.
1. Marcar a task como ativa. As outras 2 tasks permanecem como "oferta" até o próximo reroll.
1. Enviar RESULT (opcode 57) com mensagem de confirmação.
1. Enviar CURRENCIES atualizado (opcode 56).
## **9.3 Contagem de Kills**
O evento de kill do servidor deve verificar, para cada kill:

1. O jogador tem uma Bounty Task ativa?
1. A criatura morta corresponde à criatura da task ativa?
1. Se sim: incrementar o contador de kills na task ativa.
1. Se kills == maxKills: task concluída — conceder recompensas (XP, BP, RT).
1. Enviar BOUNTY\_DATA atualizado ao cliente.
1. Enviar CURRENCIES atualizado ao cliente.

Também verificar se a kill conta para alguma Weekly Kill Task ativa.
## **9.4 Reroll Tasks**
1. Validar: rerollTokens >= 1.
1. Decrementar 1 RT.
1. Gerar 3 novas tasks (repetir processo do sorteio — seção 9.1).
1. A task ATIVA (se houver) não é afetada — apenas as "ofertas" mudam.
1. Salvar novas tasks. Enviar BOUNTY\_DATA + CURRENCIES.
## **9.5 Claim Daily Token**
1. Validar: last\_daily < data atual UTC.
1. Validar: rerollTokens < 10 (cap máximo).
1. Incrementar rerollTokens em 1. Atualizar last\_daily para hoje.
1. Enviar CURRENCIES + RESULT com mensagem de sucesso.

Se já coletou hoje ou está no cap: enviar RESULT com mensagem de erro adequada.
## **9.6 Upgrade do Talisman**
1. Receber opcode 67 com u8 slot (1–4).
1. Calcular custo: 5 + (level\_atual - 1) × 12 BP.
1. Validar: bountyPoints >= custo.
1. Decrementar BP. Incrementar level do slot. Calcular novo percentual.
1. Enviar TALISMAN + CURRENCIES + RESULT.
## **9.7 Preferred List — Adicionar/Remover**
Adicionar (opcode 63):

1. Validar: slot disponível (não cheio) ou slot existe desbloqueado.
1. Validar: criatura não está já na lista.
1. Inserir no banco. Enviar PREFERRED + RESULT.

Remover (opcodes 64/65):

1. Validar: slot existe e tem criatura.
1. Cobrar custo de reset em BP (se configurado). Decrementar BP.
1. Limpar slot no banco. Enviar PREFERRED + CURRENCIES + RESULT.
## **9.8 Unlock de Slot Extra**
1. Receber opcode 66 com u8 index (1–4).
1. Verificar que o slot ainda não foi desbloqueado (bitmask).
1. Verificar que BP >= custo do slot (300/600/900/1200).
1. Decrementar BP. Atualizar bitmask no banco.
1. Enviar PREFERRED + CURRENCIES + RESULT.
## **9.9 Compra na Hunting Task Shop**
1. Receber opcode 68 com u16 index.
1. Validar: item existe no catálogo.
1. Validar: huntingPoints >= price.
1. Decrementar HTP. Conceder outfit/mount ao personagem.
1. Enviar CURRENCIES + RESULT.
## **9.10 Reset Semanal (Monday Server Save)**
1. Calcular HTP total: somar todos os HTP das tasks concluídas × multiplicador.
1. Calcular Soulseals: 1 × número de tasks concluídas.
1. Creditar HTP e Soulseals ao jogador.
1. Resetar todos os contadores de weekly tasks para 0.
1. Gerar novas weekly tasks conforme a dificuldade escolhida pelo jogador.
1. Atualizar week\_number para a semana atual.
1. O cliente, ao abrir o Task Board na semana seguinte, receberá os dados atualizados.
1. Uma janela popup (opcode 52 especial ou via script Lua) mostra as recompensas recebidas.


# **10. Estrutura de Arquivos da Implementação**
## **10.1 Arquivos do Cliente (OTCRedemption)**

|**Arquivo**|**Localização**|**Função**|
| :-: | :-: | :-: |
|taskboard.otmod|modules/game\_taskboard/|Registro e metadados do módulo|
|taskboard.otui|modules/game\_taskboard/|Layout de todas as janelas e widgets|
|taskboard.lua|modules/game\_taskboard/|Lógica client-side, opcodes, handlers, refresh de UI|
## **10.2 Arquivos do Servidor (Canary)**

|**Arquivo**|**Localização**|**Função**|
| :-: | :-: | :-: |
|protocolgame.cpp|src/server/network/protocol/|Registrar e handler dos opcodes 60–72|
|protocolgame.h|src/server/network/protocol/|Declaração dos métodos handler|
|taskboard\_config.lua|data/scripts/task\_board/|Criaturas por dificuldade, itens da loja, custos|
|taskboard\_db.lua|data/scripts/task\_board/|Funções de leitura/escrita de todas as tabelas|
|taskboard\_manager.lua|data/scripts/task\_board/|Lógica de negócio: sorteio, rewards, validações|
|taskboard\_events.lua|data/scripts/task\_board/|Hook no evento onKill e outros eventos globais|
|task\_board\_npc.lua|data/world/npcs/|NPC que abre o Task Board|
|schema.sql|raiz do projeto|CREATE TABLE das 6 tabelas do sistema|
## **10.3 Funções Lua Obrigatórias (taskboard\_manager.lua)**
Estas funções devem existir com estes nomes exatos, pois são chamadas pelos handlers C++:

|**Função**|**Parâmetros**|**Descrição**|
| :-: | :-: | :-: |
|TaskBoard.open(player)|player: objeto Player|Envia todos os dados iniciais (opcodes 51–56)|
|TaskBoard.selectTask(player, slot)|slot: 1–3|Ativa a task selecionada|
|TaskBoard.rerollTasks(player)|—|Consome 1 RT, gera 3 novas tasks|
|TaskBoard.claimDaily(player)|—|Concede +1 RT se elegível|
|TaskBoard.onCreatureKill(player, name)|name: string|Chamado pelo evento global onKill|
|TaskBoard.onItemDeliver(player, index)|index: 1–6|Entrega item da delivery task|
|TaskBoard.upgradeTalisman(player, slot)|slot: 1–4|Upgrade do bônus do talisman|
|TaskBoard.buyShopItem(player, index)|index: 1–N|Compra item da loja|
|TaskBoard.setPreferred(player, type, id)|type: 0/1|Adiciona criatura à lista|
|TaskBoard.clearPreferred(player, slot)|slot: 1–5|Limpa slot preferred|
|TaskBoard.clearUnwanted(player, slot)|slot: 1–5|Limpa slot unwanted|
|TaskBoard.unlockExtraSlot(player, idx)|idx: 1–4|Desbloqueia slot extra|
|TaskBoard.selectWeeklyDifficulty(player, diff)|diff: 0–3|Define dificuldade do próximo ciclo|
|TaskBoard.unlockKillTasks(player)|—|Desbloqueia 9 kill tasks/semana|
|TaskBoard.unlockDeliveryTasks(player)|—|Desbloqueia 9 delivery tasks/semana|
|TaskBoard.openPreferredList(player)|—|Envia dados da preferred list (opcode 54)|
|TaskBoard.weeklyReset()|—|Chamado pelo scheduler na segunda-feira|


# **11. Pool de Criaturas por Dificuldade**
As criaturas são classificadas pelo nível de dificuldade do Bestiary (Fácil/Médio/Difícil/Desafiador). A lista abaixo representa as criaturas da versão oficial do Tibia. Para implementação em servidor privado, use criaturas equivalentes ou crie uma configuração customizada.
## **11.1 Beginner (151 criaturas — pool "Fácil")**
Exemplos representativos do pool oficial:

Abyssal Calamary, Adventurer, Amazon, Assassin, Azure Frog, Bandit, Barbarian Brutetamer, Barbarian Headsplitter, Barbarian Skullhunter, Bear, Blood Crab, Boar, Bonelord, Calamary, Carrion Worm, Centipede, Chakoya Toolshaper, Cobra, Cyclops, Dark Monk, Deer, Demon Skeleton, Dragon Hatchling, Dwarf, Dwarf Guard, Dwarf Soldier, Elf, Elf Scout, Fire Devil, Frost Troll, Ghoul, Goblin, Grim Reaper (pré-lv), Larva, Lizard Sentinel, Lizard Templar, Minotaur, Minotaur Guard, Minotaur Mage, Mummy, Orc, Orc Leader, Orc Shaman, Orc Warrior, Pig, Pirate Corsair, Pirate Marauder, Poison Spider, Rat, Rotworm, Scarab, Skeleton, Slime, Snake, Stalker, Stone Golem, Swamp Troll, Troll, Valkyrie, Vampire, Wasp, Witch, Wolf, Wyvern, Zombie... (151 total)
## **11.2 Adept — Pool Médio + Fácil Misturados**
Inclui criaturas de dificuldade média do Bestiary, como: Carniphila, Crypt Shambler, Dark Torturer, Deepling Spellsinger, Elder Bonelord, Gaz'haragoth (miniatura), Ghouls avançados, Giant Spider, Hellhound, Hydra, Lancer Beetle, Medusa, Mutated Human, Nightmare, Orshabaal (miniatura), Serpent Spawn, Stalker avançado, Wailing Widow, Werehyaena, Werewolf...
## **11.3 Expert — Pool Difícil + Médio Misturados**
Inclui criaturas de alta dificuldade como: Demon, Dragon Lord, Draken Spellweaver, Frost Dragon, Girtablilu Warrior, Ice Witch, Juggernaut, Lady Bug (rara), Mahrdis, Ogre Shaman, Plaguesmith, Retching Horror, Sea Serpent, Silencer, Soul of Dragonking Zyrtarch, Soul of Goshnar, Thornback Tortoise...
## **11.4 Master — Pool Desafiador + Difícil Misturados**
Inclui as criaturas mais poderosas do jogo: Anomaly, Betrayed Wraith, Breaker, Brachiodemon, Choking Fear, Darkfang, Demon Outcast, Eradicator, Flameborn, Golgordan, Hellflayer, Honour Guard, Inquisition Boss creatures, Lost Soul, Mahrdis, Massacre, Rage Squid, Razovan, Sorc/Druid Soul demons, The Unarmored Voidborn, Undead Dragon, Vipers, World Devourer...

|**⚙️ Configuração do Pool no Servidor**|
| :- |
|O pool de criaturas é definido no arquivo taskboard\_config.lua, campo "difficulties".|
|Use os IDs de criatura do Canary (creatureId conforme registrado no XML de criaturas).|
|As criaturas do pool devem estar presentes no servidor para o sprite ser renderizado.|
|Para o kill range, use pares {min, max}: ex: {50, 100} para Beginner.|
||

# **12. Checklist de Implementação**
## **12.1 Banco de Dados**
- Criar tabela player\_bounty\_tasks
- Criar tabela player\_weekly\_tasks
- Criar tabela player\_talisman
- Criar tabela player\_task\_preferred
- Criar tabela player\_task\_extra\_slots
- Criar tabela player\_task\_currencies
- Verificar que todas as FKs estão corretas (ON DELETE CASCADE para players.id)
## **12.2 Servidor (Canary)**
- Verificar que opcodes 50–72 não conflitam com outros sistemas
- Registrar handlers para opcodes 60–72 no protocolgame.cpp
- Declarar métodos handler em protocolgame.h
- Criar taskboard\_config.lua com criaturas e loja
- Criar taskboard\_db.lua com todas as funções de banco
- Criar taskboard\_manager.lua com todas as funções de lógica
- Criar taskboard\_events.lua e conectar ao evento onKill
- Configurar scheduler para weeklyReset() toda segunda-feira
- Criar NPC Task Board
## **12.3 Cliente (OTCRedemption)**
- Copiar módulo game\_taskboard/ para modules/
- Verificar que taskboard.otmod é carregado corretamente
- Testar abertura da janela via NPC
- Testar todos os 3 tabs (Bounty / Weekly / Shop)
- Testar Preferred List (busca, adição, remoção, slots extras)
- Testar popup de Weekly Progress
## **12.4 Testes de Integração**
- Completar uma Bounty Task e verificar recebimento de XP, BP, RT
- Fazer reroll e verificar desconto de RT
- Fazer claim daily e verificar bloqueio no segundo click no mesmo dia
- Fazer upgrade do talisman e verificar desconto de BP
- Completar Weekly Kill Task e verificar progresso
- Completar Weekly Delivery Task e verificar XP imediato
- Simular reset semanal e verificar crédito de HTP + Soulseals
- Comprar item da loja e verificar desconto de HTP + recebimento do outfit/mount
- Adicionar criatura preferred e verificar que aparece mais frequentemente no sorteio
- Adicionar criatura unwanted e verificar que nunca aparece no sorteio
- Desbloquear slot extra e verificar desconto de BP + slot liberado na UI
- Testar com personagem Free Account e verificar que sistema funciona normalmente
- Testar que opcode 57 (RESULT) é enviado em todos os casos de erro
- Verificar que opcode 56 (CURRENCIES) é enviado após TODA alteração de moeda


# **13. Referências**

|**Fonte**|**URL / Local**|**Conteúdo**|
| :-: | :-: | :-: |
|TibiaWiki (Fandom)|https://tibia.fandom.com/wiki/Task\_Board|Dados oficiais do sistema, pool de criaturas|
|Manual Oficial Tibia|https://www.tibia.com/gameguides/?subtopic=manual&section=combat|Regras de negócio oficiais, fórmulas|
|TibiaWiki.com.br|https://www.tibiawiki.com.br/wiki/Bounty\_Tasks|Fórmula de custo de upgrade do talisman|
|Tibiaroute.com|https://tibiaroute.com/news/|Detalhes das Weekly Tasks e HTP máximo|
|CipSoft Winter 2025|https://www.cipsoft.com/en/413-tibia-winter-update-2025-now-available|Anúncio oficial do sistema|
|Client (OTCRedemption)|modules/game\_taskboard/|Arquivos .otmod, .otui, .lua já implementados|
|Codex Prompt|CODEX\_PROMPT.md|Instruções técnicas para implementação backend|


Documento gerado automaticamente — CrystalServer Task Board System · Fevereiro 2026
