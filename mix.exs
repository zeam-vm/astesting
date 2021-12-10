defmodule Astesting.MixProject do
  use Mix.Project

  def project do
    [
      app: :astesting,
      version: "0.1.5",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        api_reference: false,
        main: "Mix.Tasks.Test.Astesting"
      ],
      package: package(),
      description: description()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.26", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "astesting",
      maintainers: [
        "Susumu Yamazaki"
      ],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/zeam-vm/astesting"},
      files: [
        # These are the default files
        "lib",
        "LICENSE",
        "mix.exs",
        "README.md",
        "priv/Dockerfile.template"
      ]
    ]
  end

  defp description() do
    """
    Testing x86_64 macOS and aarch64 Linux by Apple Silicon Mac with Rosetta 2 and Docker Desktop for Mac,
    or x86_64 macOS and Linux by Intel x86_64 Mac and Docker Desktop for Mac.
    """
  end
end
