defmodule Po.Slack do
  @moduledoc """
  Handles incoming RTM events, parses them, and dispatches handlers for them.
  """

  use Slack

  alias Po.MessageHandler

  require Logger

  @type event :: %{type: String.t}
  @type slack :: map
  @type state :: []

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
      |> tokenize_command
      |> MessageHandler.handle_message
    end

    {:ok, state}
  end

  @spec po_message?(event, slack) :: boolean
  defp po_message?(%{type: "message", subtype: _}, _slack),
    do: false
  defp po_message?(%{type: "message", text: text}, slack),
    do: Regex.run(~r/^<@#{slack.me.id}>/, text)
  defp po_message?(_event, _slack),
    do: false

  @spec tokenize_command(String.t) :: [String.t]
  defp tokenize_command(command), do: command |> String.split(" ") |> tl
end
