# Extracao.md — Prompt Padrão de Extração (CrystalServer + OTCClient)

## Objetivo

Extrair **tudo que for relevante** sobre um elemento específico (função, classe, método, evento, opcode, packet, UI, sistema etc.) dentro dos projetos **CrystalServer** (servidor) e **OTCClient** (cliente), criando um relatório técnico completo, rastreável e útil para desenvolvimento.

---

## Instruções Gerais

Quando este arquivo for utilizado como base:

1. Analise **todo o workspace aberto** (CrystalServer e OTCClient).
2. Localize **todas as ocorrências** relacionadas ao termo solicitado.
3. Produza uma extração **profunda e estruturada**, não superficial.
4. Priorize:

   * Fluxo de execução
   * Dependências
   * Chamadas cruzadas (server ↔ client)
   * Arquivos envolvidos
   * Possíveis impactos de alteração

Se algo não existir no projeto, informe explicitamente:

> “Não encontrado no código”.

---

## Estrutura da Resposta

### 1. Visão Geral

* O que é o elemento solicitado.
* Para que serve no sistema.
* Em qual lado atua:

  * ( ) Servidor
  * ( ) Cliente
  * ( ) Ambos

---

### 2. Localização no Código

Liste todos os arquivos:

```
caminho/arquivo.ext:linha
```

Inclua múltiplas ocorrências.

---

### 3. Código Extraído

Copie os trechos relevantes completos (sem cortar contexto importante).

Separe por arquivo.

---

### 4. Fluxo de Execução

Explique passo a passo:

* Quem chama
* Quando é chamado
* O que acontece internamente
* O que é retornado/modificado

Se possível, use setas:

```
Player::login()
   ↓
Game::placeCreature()
   ↓
ProtocolGame::sendAddCreature()
```

---

### 5. Dependências

Liste tudo que o elemento depende:

* Classes
* Structs
* Enums
* Configs
* Scripts
* Eventos
* Pacotes de rede
* UI

---

### 6. Integração Server ↔ Client (se existir)

Explique:

* Opcode envolvido
* Packet enviado
* Onde o client recebe
* Como o client processa
* Arquivos OTClient relacionados

---

### 7. Pontos de Modificação

Onde alterar caso queira:

* Mudar comportamento
* Adicionar lógica
* Debugar
* Otimizar

---

### 8. Riscos e Efeitos Colaterais

Possíveis problemas ao modificar:

* Quebra de sincronização
* Bugs de estado
* Crash
* Dessync client/server
* Performance

---

### 9. Resumo Técnico

Resumo curto e direto do funcionamento interno.

---

### 10. Sugestões (Opcional)

Melhorias possíveis ou boas práticas.

---

## Comando de Uso

Sempre que solicitado:

> “Utilize o Extracao.md para extrair sobre: X”

Interpretar **X** como alvo principal e executar todas as etapas acima.

---

## Regras Importantes

* Nunca responder superficialmente.
* Sempre buscar no projeto inteiro.
* Sempre mostrar caminhos de arquivos.
* Sempre explicar fluxo.
* Sempre indicar dependências.
* Se houver dúvida, investigar antes de concluir.

---