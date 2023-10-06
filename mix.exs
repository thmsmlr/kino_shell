defmodule KinoShell.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_shell,
      version: "0.1.0",
      description: "Just a SmartCell to run bash scripts in Livebook",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {KinoShell.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kino, "~> 0.10.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      maintainers: ["Thomas Millar"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/thmsmlr/kino_shell"
      }
    ]
  end
end
