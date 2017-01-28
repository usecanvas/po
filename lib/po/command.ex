defmodule Po.Command do
  @moduledoc """
  A handler for a specific Po command.
  """

  @callback run(Po.MessageHandler.tokens, Po.Slack.event, Po.Slack.slack) :: any

  defmacro __using__(_) do
    quote do
      import Po.Command
      import Slack.Sends

      @behaviour Po.Command
    end
  end

  @doc """
  Turn a user into an @ mention.
  """
  @spec to_mention(String.t) :: String.t
  def to_mention(user_id), do: "<@#{user_id}>"
end
