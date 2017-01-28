defmodule Po.LogStreamer do
  @moduledoc """
  Reads logs from a URL and streams them to Slack.
  """

  alias Slack.Web.Chat

  @spec stream(String.t, String.t) :: any
  def stream(url, channel) do
    HTTPoison.get!(url,
                   %{},
                   stream_to: Task.async(fn -> handle_stream(channel) end).pid,
                   recv_timeout: 60_000)
  end

  @spec handle_stream(String.t) :: :ok
  def handle_stream(channel) do
    %{"ok" => true, "message" => %{"ts" => message_ts}} =
      Chat.post_message(channel, "Deploying", %{as_user: true})

    do_handle_stream(channel, message_ts)

    Chat.post_message(channel, "All Done :cool: :cool: :cool:", %{as_user: true})
  end

  defp do_handle_stream(channel, message_ts, lines \\ []) do
    receive do
      %HTTPoison.AsyncChunk{chunk: chunk_text} ->
        new_lines =
          chunk_text
          |> String.split("\n")
          |> Enum.reduce(lines, fn (chunk_line, new_lines) ->
            new_lines = new_lines ++ [chunk_line]
            update_message(channel, message_ts, new_lines)
            new_lines
          end)

        do_handle_stream(channel, message_ts, new_lines)
      %HTTPoison.AsyncEnd{} ->
        :ok
      _ ->
        do_handle_stream(channel, message_ts, lines)
    end
  end

  defp update_message(channel, message_ts, lines) do
    Chat.update(
      channel,
      "```\n#{lines |> Enum.take(-20) |> Enum.join("\n")}\n```",
      message_ts,
      %{as_user: true})
  end
end
