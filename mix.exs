defmodule Atadura.Mixfile do
  use Mix.Project

  @application :atadura

  def project do
    [
      app: @application,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      xref: [exclude: [Atadura.Test.WithoutBinding, Atadura.Test.WithBinding]],
      source_url: "https://github.com/am-kantox/atadura",
      description: description(),
      package: package(),
      deps: deps()
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
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp description do
    """
    Helper tiny module to provide easy binding support as `bind_quoted` does.
    """
  end

  defp package do
    [
     name: @application,
     files: ~w|lib mix.exs README.md|,
     maintainers: ["Aleksei Matiushkin"],
     licenses: ["WTFPL"],
     links: %{"GitHub" => "https://github.com/am-kantox/#{@application}",
              "Docs" => "https://hexdocs.pm/#{@application}"}]
  end
end
