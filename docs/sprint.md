# Sprint — criar um link de pagamento

Sete entregas, um pull request por issue, nesta ordem. Cada issue no GitHub traz o contexto, o aceite e a descrição completa do pull request. O pull request seguinte só abre quando o anterior estiver mergeado: a suíte Cucumber fica vermelha na issue 2 e cada cenário fica verde no seu PR.

A documentação deste diretório entra no commit inicial. Não é uma issue da sprint.

| Ordem | Entrega | Resultado ao mergear |
| --- | --- | --- |
| 1 | Ambiente local com Docker Compose | `docker compose up` sobe API, PostgreSQL e Redis |
| 2 | Cucumber com a funcionalidade em Gherkin | Os cinco cenários rodam e falham |
| 3 | Lojista credenciado gera um link ativo | Só esse cenário passa |
| 4 | Valor zero ou negativo não gera link | O cenário de valor passa; os seguintes seguem vermelhos |
| 5 | Descrição vazia não gera link | O cenário de descrição passa |
| 6 | Conta ainda não credenciada não gera link | O cenário de credenciamento passa |
| 7 | Credenciais de uma conta não criam link em outra | O cenário cruzado passa, e Bearer ausente ou inválido responde 401 |

## Fora da sprint

Página do pagador, cartão, Pix, webhook, rascunho, listagem, edição e desativação do link.

## Issues

Os links entram aqui depois que as issues forem abertas no GitHub.
