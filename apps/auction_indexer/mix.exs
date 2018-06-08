defmodule AuctionIndexer.Mixfile do

  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :auction_indexer,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex],
      mod: {AuctionIndexer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 1.5"},
      {:poison, "~> 3.1"},
      {:database, in_umbrella: true},
      {:timex, "~> 3.1"}
    ]
  end
end
