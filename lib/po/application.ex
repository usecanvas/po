defmodule Po.Application do
  @moduledoc false

  use Application

  @slack_token Application.get_env(:po, Po.Slack)[:token]

  @spec start(Application.start_type, any)
        :: {:ok, pid} | {:ok, pid, Application.state} | {:error, any}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Slack.Bot, [Po.Slack, [], @slack_token]),
      supervisor(Task.Supervisor, [[name: Po.MessageHandler]]),
      supervisor(Po.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Po.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
