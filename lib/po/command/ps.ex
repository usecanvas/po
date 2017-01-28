defmodule Po.Command.PS do
  @moduledoc """
  Handles a "ps" command.
  """

  use Po.Command

  import Ecto.Query, only: [where: 2]

  alias Po.{RegisteredApp, Repo}
  alias Slack.Web.Chat

  @doc """
  Retrieve the formation of an app's dynos.
  """
  @spec run(Po.MessageHandler.tokens, Po.Slack.event, Po.Slack.slack) :: any
  def run([app_name, env], message, slack) do
    RegisteredApp
    |> where(alias: ^app_name)
    |> Repo.one
    |> case do
      app = %RegisteredApp{} ->
        {:ok, formation} = do_run(app.heroku_name, env)
        Chat.post_message(
          message[:channel],
          "#{to_mention(message[:user])} Formation for *#{app.heroku_name}-#{env}*:",
          %{attachments: Poison.encode!(formation_attachments(formation)),
            as_user: true})
      nil ->
        send_message(
          ~s(#{to_mention(message[:user])} alias not found.),
          message[:channel],
          slack)
    end
  end

  @spec do_run(app_name :: String.t, env :: String.t) :: {:ok, [map]}
  defp do_run(app_name, env) do
    "/apps/#{app_name}-#{env}/formation"
    |> Heroku.get
    |> case do
      {:ok, %{body: body, status_code: 200}} ->
        {:ok, body}
    end
  end

  @spec formation_attachments([map]) :: [map]
  defp formation_attachments(formations) do
    formations
    |> Enum.map(&formation_attachment/1)
    |> Enum.sort(&sort_formations/2)
  end

  @spec formation_attachment(map) :: map
  defp formation_attachment(formation) do
    %{
      title: formation["type"],
      text: ~s(`#{formation["command"]}`),
      color: color(formation["type"]),
      mrkdwn_in: ["text"],
      fields: [%{
        title: "Quantity",
        value: formation["quantity"],
        short: true
      }, %{
        title: "Size",
        value: formation["size"],
        short: true
      }]
    }
  end

  @spec sort_formations(map, map) :: boolean
  defp sort_formations(fm_a, fm_b) do
    cond do
      fm_a["type"] == "web" -> true
      fm_a["type"] == "worker" -> true
      fm_a["type"] < fm_b["type"] -> true
      true -> false
    end
  end

  @spec color(String.t) :: String.t
  defp color("web"), do: "good"
  defp color(_), do: "#439FE0"
end
