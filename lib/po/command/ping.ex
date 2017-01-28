defmodule Po.Command.Ping do
  @moduledoc """
  Handles a "ping" command.
  """

  use Po.Command

  import Slack.Sends

  @doc """
  Send a "pong" back to the user.
  """
  @spec run(Po.MessageHandler.tokens, Po.Slack.event, Po.Slack.slack) :: any
  def run([], message, slack) do
    send_message(
      "#{to_mention(message[:user])} pong",
      message[:channel],
      slack)
  end
end
