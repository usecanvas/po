use Mix.Config

config :po, Po.Repo,
  url: {:system, "DATABASE_URL"}

