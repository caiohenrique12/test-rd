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

### 5. Abrir a documentação da API

Com a stack no ar, abra a UI no navegador:

http://localhost:3000/api-docs

O JSON OpenAPI fica em http://localhost:3000/api-docs/v1/swagger.json. Ele descreve `GET /up`, `GET /status` e `POST /accounts/{account_id}/payment_links`.

Esses endereços existem no servidor local (development). Para regenerar o arquivo `swagger/v1/swagger.json`:

```bash
docker compose run --rm web bundle exec rake rswag:specs:swaggerize
```

### 6. Testar com curl

Com a stack no ar (`http://localhost:3000`), estes comandos rodam no host.

Health check do Rails (JSON):

```bash
curl -sf -H 'Accept: application/json' http://localhost:3000/up
```

Dependências (Postgres e Redis):

```bash
curl -sf http://localhost:3000/status
```

Contrato OpenAPI:

```bash
curl -sf http://localhost:3000/api-docs/v1/swagger.json
```

Criar um link exige conta credenciada e token Bearer. Não há endpoint para emitir token nesta fatia; use o console uma vez para preparar `loja-abc` e o token de exemplo do contrato (`token-loja-abc`):

```bash
docker compose exec web bin/rails runner "
raw = 'token-loja-abc'
account = Account.find_or_create_by!(id: 'loja-abc') { |a| a.credentialed = true }
account.update!(credentialed: true)
digest = Digest::SHA256.hexdigest(raw)
AccessToken.find_or_create_by!(token_digest: digest) { |t| t.account = account }
"
```

Pedido (`amount` em centavos):

```bash
curl -sf -X POST http://localhost:3000/accounts/loja-abc/payment_links \
  -H 'Authorization: Bearer token-loja-abc' \
  -H 'Content-Type: application/json' \
  -d '{"description":"Consultoria 1 hora","amount":15000,"currency":"BRL"}'
```

Resposta esperada: HTTP `201` e JSON com `status` `active`, `amount` `15000`, `currency` `BRL` e uma `url` opaca. Sem `Authorization`, a API responde `401` com `{"error":"Não autorizado"}`.

Detalhes dos erros `403` e `422` estão em [docs/contrato/criar-link-de-pagamento.md](docs/contrato/criar-link-de-pagamento.md).

### 7. Rodar a suíte

A stack já está no ar (`exec`). O entrypoint prepara o banco de test quando o comando é RSpec ou Cucumber.

```bash
docker compose exec web bundle exec rspec
docker compose exec web bundle exec cucumber
```

Equivalentes: `make tests` e `make cucumber`.

### 8. Console e shell

```bash
docker compose exec web bin/rails console
make bash
```

`make bash` executa `docker compose exec web bash`. O console não dispara `db:prepare`; o banco já foi preparado na subida do servidor.

### 9. Derrubar

```bash
docker compose down
```

`make down` é o mesmo comando (`docker compose down`).
