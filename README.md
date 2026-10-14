# API de pagamentos

API Rails que, nesta fatia, deixa um lojista credenciado criar um link de pagamento com valor e descrição.

A documentação do produto, os modelos C4, o diagrama de dados, o contrato HTTP, o BDD e a ordem dos pull requests estão em [docs/README.md](docs/README.md).

## Ambiente local

O caminho oficial é Docker Compose (`compose.yaml`): API, PostgreSQL e Redis.

```bash
docker compose up --build
docker compose down
```

Com a stack no ar, prepare o banco e abra o console:

```bash
docker compose exec web bin/rails db:prepare
docker compose exec web bin/rails console
```

## Testes

`bin/rails test` e `bundle exec rspec` executam a mesma suíte em `spec/`. Use `run` para subir as dependências e rodar os testes; use `exec` quando a stack já estiver no ar.

```bash
docker compose run --rm web bin/rails test
docker compose exec web bundle exec rspec
```

O aceite de criar o link de pagamento é Cucumber:

```bash
docker compose run --rm web bundle exec cucumber
```
