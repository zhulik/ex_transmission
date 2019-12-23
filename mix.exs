defmodule Transmission.MixProject do
  use Mix.Project

  def project do
    [
      app: :transmission,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "transmission",
      description: "Elixir client for the Transmission torrent client RPC API",
      package: package(),
      source_url: "https://github.com/zhulik/ex_transmission"
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
      {:tesla, "~> 1.3"},
      {:poison, "~> 4.0"},
      {:credo, "~> 1.1.5", only: [:dev, :test], runtime: false},
      {:exactor, "~> 2.2.4", warn_missing: false},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/zhulik/ex_transmission"}
    ]
  end
end
