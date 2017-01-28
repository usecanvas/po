defmodule Po.Application do
  @moduledoc false

  use Application

  @slack_token Application.get_env(:po, Po.Slack)[:token]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Slack.Bot, [Po.Slack, [], @slack_token])
    ]

    opts = [strategy: :one_for_one, name: Po.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
