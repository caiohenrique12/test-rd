# Sprint 1 — criar um link de pagamento

Nove entregas, um pull request por issue, nesta ordem. Todas estão no milestone **Sprint 1 — Criar link de pagamento**. Cada issue traz o contexto, o aceite e a descrição do pull request. O pull request seguinte só abre quando o anterior estiver mergeado.

| Ordem | Issue | Resultado ao mergear |
| --- | --- | --- |
| 1 | [#2 — Ambiente local com Docker Compose](https://github.com/caiohenrique12/test-rd/issues/2) | `docker compose up` sobe API, PostgreSQL e Redis |
| 2 | [#11 — Remover a gem image_processing](https://github.com/caiohenrique12/test-rd/issues/11) | A API não depende de processamento de imagem |
| 3 | [#12 — Usar RSpec no lugar de Minitest](https://github.com/caiohenrique12/test-rd/issues/12) | A suíte do backend roda com RSpec |
| 4 | [#3 — Cucumber com a funcionalidade em Gherkin](https://github.com/caiohenrique12/test-rd/issues/3) | Os cinco cenários rodam e falham |
| 5 | [#4 — Lojista credenciado gera um link ativo](https://github.com/caiohenrique12/test-rd/issues/4) | Só esse cenário passa |
| 6 | [#5 — Valor zero ou negativo não gera link](https://github.com/caiohenrique12/test-rd/issues/5) | O cenário de valor passa; os seguintes seguem vermelhos |
| 7 | [#6 — Descrição vazia não gera link](https://github.com/caiohenrique12/test-rd/issues/6) | O cenário de descrição passa |
| 8 | [#7 — Conta ainda não credenciada não gera link](https://github.com/caiohenrique12/test-rd/issues/7) | O cenário de credenciamento passa |
| 9 | [#8 — Credenciais de uma conta não criam link em outra](https://github.com/caiohenrique12/test-rd/issues/8) | O cenário cruzado passa, e Bearer ausente ou inválido responde 401 |

## Fora da sprint

Página do pagador, cartão, Pix, webhook, rascunho, listagem, edição e desativação do link.

## Pull requests

Cada issue já traz o título, o resumo e o plano de teste do pull request. O PR abre na ordem da tabela, com `Fixes` apontando para a issue, e só depois que o anterior entrou em `main`.

O [pull request #1](https://github.com/caiohenrique12/test-rd/pull/1) é o bump do Dependabot para `image_processing`. Ele não entra na sequência: a issue #11 remove a gem e fecha esse pull request sem mergear o bump.
