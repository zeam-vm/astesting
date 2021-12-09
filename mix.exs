defmodule Astesting.MixProject do
  use Mix.Project

  def project do
    [
      app: :astesting,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        api_reference: false,
        main: "Mix.Tasks.Test.Astesting"
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
      {:ex_doc, "~> 0.26", only: :dev, runtime: false}
    ]
  end
end
