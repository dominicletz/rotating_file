defmodule RotatingFile.MixProject do
  use Mix.Project

  @url "https://github.com/dominicletz/rotating_file"
  def project do
    [
      app: :rotating_file,
      version: "0.1.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Hex
      description: "GenServer that writes to rotating compressed files for archival and logging.",
      package: [
        licenses: ["Apache-2.0"],
        maintainers: ["Dominic Letz"],
        links: %{"GitHub" => @url}
      ],
      # Docs
      name: "RotatingFile",
      source_url: @url,
      docs: [
        # The main page in the docs
        main: "RotatingFile",
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

  def aliases do
    [lint: ["credo --strict", "format --check-formatted"]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev, runtime: false}
    ]
  end
end
