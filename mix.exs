defmodule CloudflareStream.MixProject do
  use Mix.Project

  @description "Collection of functions for working with Cloudflare Stream API"
  @source_url "https://github.com/reetou/cloudflare_stream_ex"

  def project do
    [
      app: :cloudflare_stream,
      version: "0.2.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      package: package(),
      docs: [
        main: "readme",
        extras: [
          "README.md",
        ],
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
      {:httpoison, "~> 1.8"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Vladimir Sinitsyn"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url
      }
    ]
  end
end
