# Documentação

Índice do que este repositório é, do que esta fatia entrega e da ordem em que os pull requests entram.

| Documento | Conteúdo |
| --- | --- |
| [Visão geral](visao-geral.md) | Produto, atores, fatia atual e o que fica de fora |
| [Glossário](glossario.md) | Termos usados no caso de uso e na API |
| [Decisões](decisoes.md) | Escolhas já fechadas para esta fatia |
| [C4 — Contexto](arquitetura/c4-contexto.md) | Sistema e quem fala com ele |
| [C4 — Contêineres](arquitetura/c4-containers.md) | API, PostgreSQL e Redis |
| [C4 — Componentes](arquitetura/c4-componentes.md) | Peças da criação do link |
| [Modelo de dados](arquitetura/modelo-de-dados.md) | Diagrama entidade-relacionamento |
| [Contrato HTTP](contrato/criar-link-de-pagamento.md) | Pedido, resposta e erros |
| [BDD](bdd/criar-link-de-pagamento.md) | Funcionalidade em Gherkin |
| [Sprint](sprint.md) | Issues e pull requests, na ordem de implementação |

Hoje a API expõe `GET /up` e `GET /status`. O link de pagamento ainda não existe: a sprint abaixo é o plano para construí-lo.
