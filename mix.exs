defmodule Plug.IpWhitelist.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_ip_whitelist,
      version: "1.0.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:pre_commit, "~> 0.2.4", only: :dev},
      {:plug, "~> 1.5"},
      {:excoveralls, "~> 0.8", only: :test}
    ]
  end
end
