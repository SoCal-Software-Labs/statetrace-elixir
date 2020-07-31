defmodule StatetraceElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :statetrace_elixir,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      {:phoenix, "~> 1.5.3"}
    ]
  end

  defp package do
    [
      maintainers: ["Kyle Hanson"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/SoCal-Software-Labs/statetrace-elixir"},
      files:
        ~w(assets/js lib priv CHANGELOG.md LICENSE.md mix.exs package.json README.md .formatter.exs)
    ]
  end
end
