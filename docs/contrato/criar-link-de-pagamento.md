# Contrato HTTP — criar link de pagamento

O path abaixo é o contrato desta API. O documento de produto o trata como exemplo; aqui ele fica fechado.

## Pedido

```http
POST /accounts/loja-abc/payment_links
Authorization: Bearer <token da loja-abc>
Content-Type: application/json
```

```json
{
  "description": "Consultoria 1 hora",
  "amount": 15000,
  "currency": "BRL"
}
```

`amount` é inteiro, em centavos. `150.00` BRL no cenário BDD corresponde a `15000`.

## Resposta `201`

```json
{
  "id": "pl_8f3a2c",
  "account_id": "loja-abc",
  "status": "active",
  "description": "Consultoria 1 hora",
  "amount": 15000,
  "currency": "BRL",
  "url": "https://pay.example.com/c/8f3a2c"
}
```

`id` e o segmento da `url` compartilham o token opaco. A `url` não contém `account_id`.

## Erros

```json
{ "error": "O valor deve ser maior que zero" }
```

| Status | Quando | Mensagem que o cenário exige |
| --- | --- | --- |
| 401 | Bearer ausente ou desconhecido | A classe de autenticação recusa antes de criar. |
| 403 | Conta sem credenciamento | A conta precisa estar credenciada. |
| 403 | Token de uma conta usado na URL de outra | Mensagem genérica, sem o id nem dados da outra conta. |
| 422 | Valor zero, negativo ou não inteiro | O valor deve ser maior que zero. |
| 422 | Descrição vazia ou só com espaços | A descrição é obrigatória. |
| 422 | Moeda diferente de `BRL` | A moeda não é suportada. |

Nenhuma dessas respostas persiste link.
