# API de pagamentos

API Rails que, nesta fatia, deixa um lojista credenciado criar um link de pagamento com valor e descrição.

A documentação do produto, os modelos C4, o diagrama de dados, o contrato HTTP, o BDD e a ordem dos pull requests estão em [docs/README.md](docs/README.md).

## Ambiente local

O caminho oficial é Docker Compose (`compose.yaml`): API, PostgreSQL e Redis. O primeiro pull request da sprint fecha os comandos e a verificação de `GET /status`.
