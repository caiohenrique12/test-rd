# API de pagamentos

API Rails que, nesta fatia, deixa um lojista credenciado criar um link de pagamento com valor e descrição.

A documentação do produto, os modelos C4, o diagrama de dados, o contrato HTTP, o BDD e a ordem dos pull requests estão em [docs/README.md](docs/README.md).

## Ambiente local

### 1. Pré-requisitos

Docker e Docker Compose. Não é preciso Ruby, PostgreSQL ou Redis na máquina. O `curl` do passo 4 é só a verificação no host.

### 2. Clonar

```bash
git clone https://github.com/caiohenrique12/test-rd.git
cd test-rd
```

### 3. Subir a stack

Há dois caminhos equivalentes.

No primeiro plano, com build. Os comandos seguintes precisam de outro terminal:

```bash
docker compose up --build
```

Pelo Makefile, em segundo plano. `make up` sozinho não constrói a imagem (`docker compose up -d`):

```bash
make build
make up
```

As gems entram na imagem no build; a subida do container não roda o Bundler. O entrypoint (`bin/docker-entrypoint`) prepara o banco quando o servidor sobe (`db:prepare` em development e em test, porque o comando do Compose é `./bin/rails server`).

### 4. Conferir a saúde

Espere o healthcheck do serviço `web` e, no host, rode:

```bash
curl -f http://localhost:3000/status
```

A resposta saudável tem `status` `ok` e `checks.postgres` e `checks.redis` em `ok`.

### 5. Rodar a suíte

A stack já está no ar (`exec`). O entrypoint prepara o banco de test quando o comando é RSpec ou Cucumber.

```bash
docker compose exec web bundle exec rspec
docker compose exec web bundle exec cucumber
```

Equivalentes: `make tests` e `make cucumber`.

### 6. Console e shell

```bash
docker compose exec web bin/rails console
make bash
```

`make bash` executa `docker compose exec web bash`. O console não dispara `db:prepare`; o banco já foi preparado na subida do servidor.

### 7. Derrubar

```bash
docker compose down
```

`make down` é o mesmo comando (`docker compose down`).
