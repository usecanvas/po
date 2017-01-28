defmodule Po.MessageHandler do
  @moduledoc """
  Accepts incoming messages to Po and dispatches handler tasks for them.
  """

  require Logger

  @typep command :: String.t
  @typep tokens :: [String.t]

  @doc """
  Handle an incoming message to Po by dispatching a handler task.
  """
  @spec handle_message(tokens, Po.Slack.slack)
        :: {:error, {:unrecognized_command, command}}
  def handle_message(tokens, _slack) do
    {:error, {:unrecognized_command, to_command(tokens)}}
  end

  @doc """
  Convert a Slack message text into a tokenized command for Po to execute.
  """
  @spec tokenize_command(String.t) :: tokens
  def tokenize_command(command), do: command |> String.split(" ") |> tl

  @spec to_command(tokens) :: command
  defp to_command(tokens), do: Enum.join(tokens, " ")
end
