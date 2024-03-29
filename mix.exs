defmodule Po.Mixfile do
  use Mix.Project

  def project do
    [app: :po,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     dialyzer: [flags: ~w(-Werror_handling
                          -Wrace_conditions
                          -Wunderspecs)]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Po.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:credo, "~> 0.5", only: [:dev]},
     {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
     {:ecto, "~> 2.1"},
     {:httpoison, "~> 0.11", override: true},
     {:poison, "~> 3.1"},
     {:postgrex, "~> 0.13.0"},
     {:slack, "~> 0.9"}]
  end
end
