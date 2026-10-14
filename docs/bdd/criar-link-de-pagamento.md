# Funcionalidade: Criar um link de pagamento

Fonte do caso de uso. A issue 2 da sprint copia este texto para `features/criar_link_de_pagamento.feature`.

```gherkin
# language: pt
Funcionalidade: Criar um link de pagamento
  Como um lojista credenciado
  Quero gerar um link com valor e descrição
  Para enviar ao cliente e receber sem montar um checkout completo

  Contexto:
    Dado que o produto de pagamentos aceita a moeda "BRL"
    E a classe de autenticação valida Bearer, conta e se a conta está credenciada

  Cenário: Lojista credenciado gera um link ativo
    Dado que o lojista da conta "loja-abc" está autenticado
    E a conta "loja-abc" está credenciada para receber
    Quando ele solicita um link de pagamento com:
      | descrição | Consultoria 1 hora |
      | valor     | 150.00             |
      | moeda     | BRL                |
    Então o sistema cria um link ativo pertencente à conta "loja-abc"
    E devolve uma URL única e opaca para esse link
    E o valor cobrável do link é 150.00 BRL
    E a descrição do link é "Consultoria 1 hora"

  Cenário: Valor zero ou negativo não gera link
    Dado que o lojista da conta "loja-abc" está autenticado
    E a conta "loja-abc" está credenciada para receber
    Quando ele solicita um link de pagamento com:
      | descrição | Consultoria 1 hora |
      | valor     | 0.00               |
      | moeda     | BRL                |
    Então o sistema recusa a criação
    E não persiste link
    E informa que o valor deve ser maior que zero

  Cenário: Descrição vazia não gera link
    Dado que o lojista da conta "loja-abc" está autenticado
    E a conta "loja-abc" está credenciada para receber
    Quando ele solicita um link de pagamento com:
      | descrição |                    |
      | valor     | 150.00             |
      | moeda     | BRL                |
    Então o sistema recusa a criação
    E não persiste link
    E informa que a descrição é obrigatória

  Cenário: Conta ainda não credenciada não gera link
    Dado que o lojista da conta "loja-abc" está autenticado
    E a conta "loja-abc" ainda não está credenciada para receber
    Quando ele solicita um link de pagamento com:
      | descrição | Consultoria 1 hora |
      | valor     | 150.00             |
      | moeda     | BRL                |
    Então o sistema recusa a criação
    E não persiste link
    E informa que a conta precisa estar credenciada

  Cenário: Credenciais de uma conta não criam link em outra
    Dado que o lojista autenticado pertence somente à conta "loja-abc"
    Quando ele solicita um link de pagamento informando a conta "loja-xyz"
    Então o sistema recusa a criação
    E não persiste link na conta "loja-xyz"
    E não vaza existência ou dados da conta "loja-xyz"
```

O cenário de valor cita zero ou negativo no título e usa `0.00` na tabela. O pull request desse cenário também recusa valor negativo, com a mesma mensagem e sem persistir.

Bearer ausente ou inválido não tem cenário próprio. O contexto atribui essa recusa à classe de autenticação, e o último pull request da sprint a cobre com 401.
