# Glossário

| Termo | Significado |
| --- | --- |
| Lojista | Dono da conta que cria o link. No HTTP, é o portador do Bearer token. |
| Conta | Tenant do lojista. O identificador vai na URL da API (`loja-abc`) e no corpo da resposta. Não vai no path da URL de pagamento. |
| Credenciada | Conta pronta para receber. Só essa conta cria link. Quem afirma isso é a classe de autenticação. |
| Link de pagamento | Cobrança reutilizável, com valor, moeda e descrição, nascida ativa. |
| URL opaca | Endereço público do link. O segmento final não revela `account_id`. |
| Amount | Valor em centavos, inteiro. `150.00` BRL no cenário equivale a `15000` no JSON. |
| Bearer | Token da conta, enviado em `Authorization`. A comparação usa o digest; o valor cru não fica gravado. |
