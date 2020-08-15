defmodule Snek.MixProject do
  use Mix.Project

  def project do
    [
      app: :snek,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Snek",
      source_url: "https://github.com/xtagon/snek",
      homepage_url: "https://github.com/xtagon/snek",
      docs: [
        main: "Snek",
        extras: ["README.md", "LICENSE.txt"]
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
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end
end
