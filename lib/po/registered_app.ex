defmodule Po.RegisteredApp do
  @moduledoc """
  An alias that has been registered with Po alongside a Heroku app name and a
  GitHub repo name.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "registered_apps" do
    field :alias, :string
    field :heroku_name, :string
    field :github_repo, :string
  end

  @doc """
  Create a changeset from the given `struct` and `params`.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:alias, :heroku_name, :github_repo])
    |> validate_required([:alias, :heroku_name, :github_repo])
    |> unique_constraint(:alias)
    |> unique_constraint(:heroku_name)
    |> unique_constraint(:github_repo)
  end
end
