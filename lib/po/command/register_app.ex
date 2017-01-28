defmodule Po.Command.RegisterApp do
  @moduledoc """
  Handles a "register-app" command.
  """

  use Po.Command

  import Slack.Sends

  alias Po.{RegisteredApp, Repo}

  @doc """
  Register an app reference alongside its Heroku app name and GitHub repo.
  """
  @spec run(Po.MessageHandler.tokens, Po.Slack.event, Po.Slack.slack) :: any
  def run([alias, heroku_name, github_repo], message, slack) do
    %RegisteredApp{}
    |> RegisteredApp.changeset(%{alias: alias,
                                 heroku_name: heroku_name,
                                 github_repo: github_repo})
    |> Repo.insert
    |> case do
      {:ok, _} ->
        send_message(
          ~s(#{to_mention(message[:user])} Registered "#{alias}"!),
          message[:channel],
          slack)
      {:error, _} ->
        send_message(
          ~s(#{to_mention(message[:user])} Failed to register "#{alias}".),
          message[:channel],
          slack)
    end
  end
end
