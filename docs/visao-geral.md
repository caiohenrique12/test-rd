# Visão geral

API de pagamentos. Nesta fatia, um lojista credenciado gera uma URL cobrável com valor e descrição, para enviar ao cliente sem montar um checkout.

## Atores

- **Lojista.** Merchant autenticado, dono de uma conta no produto.
- **Sistema.** API que valida a requisição, persiste o link e devolve a URL.

O pagador não participa desta fatia. Ele só entra quando abrir a URL e pagar, o que fica para a próxima.

## O que esta fatia entrega

O lojista chama `POST /accounts/{account_id}/payment_links` com descrição, valor em centavos e moeda. Se a autenticação passar e os dados forem válidos, o sistema grava um link **ativo**, preso à conta do token, e responde a URL opaca.

## O que fica de fora

- Catálogo de produtos, quantidade, cupom, split e parcelamento.
- Página pública em que o pagador informa cartão ou Pix.
- Webhook `payment.succeeded` e conciliação.
- Link em rascunho, listagem, edição e desativação.
- Emissão de token, cadastro de conta e fluxo de credenciamento. A fatia chama a classe de autenticação; não reconstrói o produto de identidade.

## Estado atual do código

- Rails 8, API-only, PostgreSQL e Redis.
- `GET /status` consulta Postgres e Redis.
- `compose.yaml` descreve os serviços `web`, `db` e `redis`.
- Não há modelo de conta, token nem link de pagamento.
- A especificação executável é `features/criar_link_de_pagamento.feature`.

## Próxima fatia

O pagador abre a URL e conclui um pagamento único com cartão ou Pix. O lojista passa a ver o link como pago.
