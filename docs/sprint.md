# Sprint — criar um link de pagamento

Sete entregas, um pull request por issue, nesta ordem. Cada issue no GitHub traz o contexto, o aceite e a descrição completa do pull request. O pull request seguinte só abre quando o anterior estiver mergeado: a suíte Cucumber fica vermelha na issue 2 e cada cenário fica verde no seu PR.

A documentação deste diretório entra no commit inicial. Não é uma issue da sprint.

| Ordem | Issue | Resultado ao mergear |
| --- | --- | --- |
| 1 | [#2 — Ambiente local com Docker Compose](https://github.com/caiohenrique12/test-rd/issues/2) | `docker compose up` sobe API, PostgreSQL e Redis |
| 2 | [#3 — Cucumber com a funcionalidade em Gherkin](https://github.com/caiohenrique12/test-rd/issues/3) | Os cinco cenários rodam e falham |
| 3 | [#4 — Lojista credenciado gera um link ativo](https://github.com/caiohenrique12/test-rd/issues/4) | Só esse cenário passa |
| 4 | [#5 — Valor zero ou negativo não gera link](https://github.com/caiohenrique12/test-rd/issues/5) | O cenário de valor passa; os seguintes seguem vermelhos |
| 5 | [#6 — Descrição vazia não gera link](https://github.com/caiohenrique12/test-rd/issues/6) | O cenário de descrição passa |
| 6 | [#7 — Conta ainda não credenciada não gera link](https://github.com/caiohenrique12/test-rd/issues/7) | O cenário de credenciamento passa |
| 7 | [#8 — Credenciais de uma conta não criam link em outra](https://github.com/caiohenrique12/test-rd/issues/8) | O cenário cruzado passa, e Bearer ausente ou inválido responde 401 |

## Fora da sprint

Página do pagador, cartão, Pix, webhook, rascunho, listagem, edição e desativação do link.

## Pull requests

Cada issue já traz o título, o resumo e o plano de teste do pull request. O PR abre na ordem da tabela, com `Fixes` apontando para a issue, e só depois que o anterior entrou em `main`.

O [pull request #1](https://github.com/caiohenrique12/test-rd/pull/1) é do Dependabot (`image_processing`) e não faz parte desta sprint.
