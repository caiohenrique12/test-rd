# Decisões desta fatia

## A suíte de aceite é Cucumber

O caso de uso já está em Gherkin, em português. Os cenários vivem em `features/` e rodam com `cucumber-rails` e Rack::Test. Não há browser: o ator exercita a API.

A especificação é o Cucumber em `features/criar_link_de_pagamento.feature`. O rascunho Minitest `test/integration/payment_links_test.rb` foi removido.

## Amount em centavos

O cenário fala `150.00` BRL. O JSON fala `15000`, no mesmo espírito da Stripe. A coluna persistida é inteira (`amount_cents`). O step de Cucumber faz essa tradução.

## A URL não carrega a conta

A resposta inclui `account_id`. A URL devolvida, não. Forma alvo: `https://pay.example.com/c/{token}`, com o mesmo token que aparece depois de `pl_` no `id` (`pl_8f3a2c` e `/c/8f3a2c`). A base vem de configuração, com esse host como padrão.

## Autenticação é um colaborador da fatia

Bearer ausente ou inválido, conta diferente da do token, e conta sem credenciamento são recusas da classe de autenticação (401 ou 403). A criação do link só roda depois. Esta fatia não abre endpoint de login nem de credenciamento.

No cross-tenant, a resposta não inclui existência nem dados da outra conta.

## Erros

| Situação | Status | Origem |
| --- | --- | --- |
| Bearer ausente ou inválido | 401 | Classe de autenticação |
| Conta do token diferente da URL | 403 | Classe de autenticação |
| Conta sem credenciamento | 403 | Classe de autenticação |
| Valor, descrição ou moeda inválidos | 422 | Criação do link |

Corpo de erro: `{ "error": "..." }`.

## Descrição: até 140 caracteres

A descrição é texto livre curto. O limite é 140 caracteres contados depois do `strip`: exatamente 140 é válido, e 141 responde 422 com `A descrição deve ter no máximo 140 caracteres`, sem persistir link. Espaços nas pontas são removidos antes de gravar. A coluna é `varchar(140)`, o mesmo número da validação, para um texto aceito pela aplicação não estourar o banco.

140 cabe uma linha de descrição no link sem virar um campo de texto longo, e fica alinhado entre a mensagem, o modelo e a coluna.

## O que não foi decidido aqui

Nenhum item em aberto nesta fatia.
