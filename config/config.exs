use Mix.Config

config :po, Po.Slack,
  token: System.get_env("SLACK_TOKEN")

config :logger,
  utc_log: true

config :logger, :console,
  format: "time=$dateT$timeZ level=$level $metadata$message\n"

