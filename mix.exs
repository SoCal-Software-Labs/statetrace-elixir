defmodule StatetraceElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :statetrace_elixir,
      source_url: "https://github.com/SoCal-Software-Labs/statetrace-elixir",
      description: "Elixir implementation for https://www.statetrace.com",
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        main: "readme",
        logo: "./logo.svg",
        extras: ["README.md"]
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
      {:ecto_sql, "~> 3.4"},
      {:phoenix, "~> 1.5.3"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Kyle Hanson"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/SoCal-Software-Labs/statetrace-elixir"},
      files: ~w(lib LICENSE.md mix.exs README.md .formatter.exs)
    ]
  end
end
