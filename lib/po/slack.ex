defmodule Po.Slack do
  @moduledoc """
  Handles incoming RTM events, parses them, and dispatches handlers for them.
  """

  use Slack

  alias Po.MessageHandler

  require Logger

  @type slack :: map
  @typep event :: %{type: String.t}
  @typep state :: []

  @doc """
  Log an event when Po first connects to Slack.
  """
  @spec handle_connect(slack, state) :: {:ok, map}
  def handle_connect(slack, state) do
    Logger.info("evt=connected id=#{slack.me.id} name=#{slack.me.name}")
    {:ok, state}
  end

  @doc """
  Handle an incoming event from Slack.
  """
  @spec handle_event(event, slack, state) :: {:ok, state}
  def handle_event(event, slack, state) do
    if po_message?(event, slack) do
      event
      |> Map.get(:text)
      |> MessageHandler.tokenize_command
      |> MessageHandler.handle_message(slack)
      |> case do
        {:error, {:unrecognized_command, command}} ->
          Logger.error(~s(evt=unrecognized_command command="#{command}"))
      end
    end

    {:ok, state}
  end

  @spec po_message?(event, slack) :: boolean
  defp po_message?(%{type: "message", subtype: _}, _slack),
    do: false
  defp po_message?(%{type: "message", text: text}, slack),
    do: Regex.match?(~r/^<@#{slack.me.id}>/, text)
  defp po_message?(_event, _slack),
    do: false
end
