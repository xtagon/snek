defmodule Snek.MixProject do
  use Mix.Project

  def project do
    [
      app: :snek,
      version: "0.4.0",
      description: "A framework for simulating Battlesnake-compatible game rules in Elixir.",
      package: package(),
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Docs
      name: "Snek",
      source_url: "https://github.com/xtagon/snek",
      homepage_url: "https://github.com/xtagon/snek",
      docs: [
        main: "readme",
        extras: [
          "README.md",
          "CHANGELOG.md",
          "LICENSE.txt"
        ]
      ],

      # Coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
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
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:stream_data, "~> 0.1", only: [:dev, :test]},
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},
      {:exprof, "~> 0.2.0", only: :dev}
    ]
  end

  defp aliases do
    [
      bench: "run -r test/support/small_static_cycle.ex bench.exs",
      profile: "run -r test/support/small_static_cycle.ex profile.exs"
    ]
  end

  def package do
    [
      # These are the default files included in the package
      files: ~w(
        .credo.exs
        .formatter.exs
        CHANGELOG.md
        LICENSE.txt
        README.md
        lib
        mix.exs
      ),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/xtagon/snek",
        "Battlesnake" => "https://play.battlesnake.com/"
      }
    ]
  end
end
