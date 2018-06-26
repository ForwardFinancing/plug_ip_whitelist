defmodule Plug.IpWhitelist.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_ip_whitelist,
      version: "1.3.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        test: :test
      ],
      source_url: "https://github.com/ForwardFinancing/plug_ip_whitelist",
      homepage_url: "https://github.com/ForwardFinancing/plug_ip_whitelist",
      package: package()
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
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Zach Cotter", "Forward Financing"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ForwardFinancing/plug_ip_whitelist",
        "Documentation" => "https://hexdocs.pm/plug_ip_whitelist"
      },
      description:
        "Plug to Enforce IP Whitelisting in Elixir/Phoenix applications"
    ]
  end
end
