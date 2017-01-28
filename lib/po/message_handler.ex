defmodule Po.MessageHandler do
  @moduledoc """
  Accepts incoming messages to Po and dispatches handler tasks for them.
  """

  require Logger

  @type tokens :: [String.t]
  @typep command :: String.t
  @typep handler :: {module, [String.t]}

  @doc """
  Handle an incoming message to Po by dispatching a handler task.
  """
  @spec handle_message(tokens, Po.Slack.event, Po.Slack.slack)
        :: {:ok, command} | {:error, {:unrecognized_command, command}}
  def handle_message(tokens, message, slack) do
    tokens
    |> get_message_handler
    |> case do
      {module, args} ->
        Task.Supervisor.async_nolink(
          __MODULE__, module, :run, [args, message, slack])
        {:ok, to_command(tokens)}
      nil ->
        {:error, {:unrecognized_command, to_command(tokens)}}
    end
  end

  @spec get_message_handler(tokens) :: handler | nil
  defp get_message_handler(["ping" | args]),
    do: {Po.Command.Ping, args}
  defp get_message_handler(["register-app" | args]),
    do: {Po.Command.RegisterApp, args}
  defp get_message_handler(_),
    do: nil

  @doc """
  Convert a Slack message text into a tokenized command for Po to execute.
  """
  @spec tokenize_command(String.t) :: tokens
  def tokenize_command(command), do: command |> String.split(" ") |> tl

  @spec to_command(tokens) :: command
  defp to_command(tokens), do: Enum.join(tokens, " ")
end
