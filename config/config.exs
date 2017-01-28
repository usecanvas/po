use Mix.Config

config :po,
  ecto_repos: [Po.Repo]

config :po, Heroku,
  token: System.get_env("HEROKU_TOKEN")

config :po, Po.Repo,
  adapter: Ecto.Adapters.Postgres

config :po, Po.Slack,
  token: System.get_env("SLACK_TOKEN")

config :slack,
  api_token: System.get_env("SLACK_TOKEN")

config :logger,
  utc_log: true

config :logger, :console,
  format: "time=$dateT$timeZ level=$level $metadata$message\n"

import_config "#{Mix.env}.exs"
