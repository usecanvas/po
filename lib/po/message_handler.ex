defmodule Po.MessageHandler do
  @moduledoc """
  Accepts incoming messages to Po and dispatches handler tasks for them.
  """

  require Logger

  @type command :: String.t
  @type tokens :: [String.t]

  @doc """
  Handle an incoming message to Po by dispatching a handler task.
  """
  @spec handle_message(tokens) :: :ok | {:error, :unrecognized_command}
  def handle_message(tokens) do
    Logger.error(~s(evt=unrecognized_command command="#{to_command(tokens)}"))
    {:error, :unrecognized_command}
  end

  @spec to_command(tokens) :: command
  defp to_command(tokens), do: Enum.join(tokens, " ")
end
