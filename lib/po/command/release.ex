defmodule Po.Command.Release do
  @moduledoc """
  Handles a "release" command.
  """

  use Po.Command

  import Ecto.Query, only: [where: 2]

  alias Po.{LogStreamer, RegisteredApp, Repo}

  @github_token Application.get_env(:po, :github_token)
  @github_username Application.get_env(:po, :github_username)

  @doc """
  Triggers a release from GitHub.
  """
  @spec run(Po.MessageHandler.tokens, Po.Slack.event, Po.Slack.slack) :: any
  def run([app_name, env], message, slack) do
    RegisteredApp
    |> where(alias: ^app_name)
    |> Repo.one
    |> case do
      app = %RegisteredApp{} ->
        {:ok, build} = create_build(app, env)

        build["output_stream_url"]
        |> LogStreamer.stream(message.channel, window_size: 20)
      nil ->
        send_message(
          ~s(#{to_mention(message[:user])} alias not found.),
          message[:channel],
          slack)
    end
  end

  @spec create_build(RegisteredApp.t, String.t) :: {:ok, map}
  defp create_build(app, env) do
    url = tarball_url(app)

    "/apps/#{app.heroku_name}-#{env}/builds"
    |> Heroku.post(%{source_blob: %{url: url}})
    |> case do
      {:ok, %{body: body, status_code: 201}} ->
        {:ok, body}
    end
  end

  @spec tarball_url(RegisteredApp.t) :: String.t
  defp tarball_url(%{github_repo: name}),
    do: "https://#{@github_username}:#{@github_token}@github.com/usecanvas/#{name}/archive/master.tar.gz"
end
