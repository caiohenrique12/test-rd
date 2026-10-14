# Decisões desta fatia

## A suíte de aceite é Cucumber

O caso de uso já está em Gherkin, em português. Os cenários vivem em `features/` e rodam com `cucumber-rails` e Rack::Test. Não há browser: o ator exercita a API.

O arquivo Minitest `test/integration/payment_links_test.rb` deixa de ser a especificação quando o Cucumber entrar.

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

## O que não foi decidido aqui

Limite exato do “texto livre curto”, além de descrição obrigatória depois do `strip`. O cenário cobre descrição vazia. O tamanho máximo entra na implementação do cenário de descrição se for necessário para persistir a coluna, e fica registrado no pull request correspondente.
