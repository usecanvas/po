<h1 align="center">:panda_face: Po</h1>

Po is Canvas's ops panda. In early 2017, upon his passing, his consciousness
was uploaded to Heroku where he happily continues to help Canvas deploy and 
monitor their apps.

#### Requirements

- Erlang 19.2
- Elixir 1.4.1
- PostgreSQL

#### Running

- `git clone https://github.com/usecanvas/po`
- `cd po`
- `mix deps.get`
- `heroku config -s -a po-prod > .env`
- `mix ecto.create`
- `mix ecto.migrate`
- `foreman run mix run --no-halt`

#### Tests

There aren't currently any substantial tests in Po, but we do have Credo and
Dialyzer in place. Credo only checks that public functions are `@spec`d, but
please `@spec` every public and private function.

- `bin/test`

#### Issues

Sometimes things may get compiled without your environment, and Po won't even
start. To fix this;

- `foreman run mix compile --force`
