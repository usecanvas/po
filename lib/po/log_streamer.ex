defmodule Po.LogStreamer do
  @moduledoc """
  Reads logs from a URL and streams them to Slack.
  """

  alias Slack.Web.Chat

  @doc """
  Stream logs from `url` to a new message in `channel`.

  This function works by making an async HTTPoison request. The function spawns
  a new process whose purpose is to receive messages from the async request and
  send each log line in each response chunk to Slack.

  The log lines kept inside a bounded window, whose default size is 50 lines
  long. Each new line is sent to Slack individually, creating the effect of
  a smooth-scrolling log of the deploy.
  """
  @spec stream(String.t, String.t, Keyword.t)
        :: {:ok, HTTPoison.AsyncResponse.t} | {:error, HTTPoison.Error.t}
  def stream(url, channel, opts \\ []) do
    url
    |> HTTPoison.get(
      %{},
      stream_to: Task.async(fn -> handle_stream(channel, opts) end).pid,
      recv_timeout: 60_000)
    |> case do
      ok = {:ok, _} ->
        ok
      error = {:error, _} ->
        send_could_not_fetch(channel)
        error
    end
  end

  @spec handle_stream(String.t, Keyword.t) :: :ok
  defp handle_stream(channel, opts) do
    %{"ok" => true, "message" => %{"ts" => message_ts}} =
      Chat.post_message(channel, "Deploying...", %{as_user: true})
    do_handle_stream(channel, message_ts, [], opts)
  end

  @spec do_handle_stream(String.t, String.t, [String.t], Keyword.t)
        :: :ok | :error
  defp do_handle_stream(channel, message_ts, lines, opts) do
    receive do
      %HTTPoison.AsyncStatus{code: 200} ->
        do_handle_stream(channel, message_ts, lines, opts)
      %HTTPoison.AsyncStatus{code: _} ->
        send_could_not_fetch(channel)
        :error
      %HTTPoison.AsyncChunk{chunk: chunk} ->
        new_lines = send_lines(chunk, channel, message_ts, lines, opts)
        do_handle_stream(channel, message_ts, new_lines, opts)
      %HTTPoison.AsyncEnd{} ->
        end_stream(channel, message_ts, lines)
        :ok
      _async_struct ->
        do_handle_stream(channel, message_ts, lines, opts)
    end
  end

  @spec send_could_not_fetch(String.t) :: map
  defp send_could_not_fetch(channel) do
    Chat.post_message(
      channel, "I had trouble fetching the deploy logs :cry:",
      %{as_user: true})
  end

  @spec send_lines(String.t, String.t, String.t, [String.t], Keyword.t)
        :: [String.t]
  defp send_lines(chunk, channel, message_ts, lines, opts) do
    size = opts[:window_size] || 50

    chunk
    |> String.split("\n")
    |> Enum.reduce(lines, fn (chunk_line, new_lines) ->
      new_lines = [chunk_line | new_lines] |> Enum.slice(0..size - 1)
      update_message(channel, message_ts, new_lines)
      new_lines
    end)
  end

  @spec end_stream(String.t, String.t, [String.t]) :: any
  defp end_stream(channel, message_ts, lines) do
    Chat.update(
      channel,
      log_lines(lines) <> "\nAll Done :cool: :cool: :cool:",
      message_ts,
      %{as_user: true})
  end

  @spec update_message(String.t, String.t, [String.t]) :: any
  defp update_message(channel, message_ts, lines),
    do: Chat.update(channel, log_lines(lines), message_ts, %{as_user: true})

  @spec log_lines([String.t]) :: String.t
  defp log_lines(lines) do
    """
    ```
    #{lines |> Enum.reverse |> Enum.join("\n")}
    ```\
    """
  end
end
