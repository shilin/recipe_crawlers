defmodule RecipeCrawlers.MixProject do
  use Mix.Project

  def project do
    [
      app: :recipe_crawlers,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:saxy, "~> 1.1"},
      {:gen_stage, "~> 1.0"},
      {:httpoison, "~> 1.6"},
      {:floki, "~> 0.26.0"},
      {:jason, "~> 1.2"},
      # {:broadway_kafka, "~> 0.1.1"}
      {:kafka_ex, "~> 0.9.0"}
    ]
  end
end
