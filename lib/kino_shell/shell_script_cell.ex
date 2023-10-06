defmodule KinoShell.ShellScriptCell do
  @moduledoc false

  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "Shell Script"

  @impl true
  def init(_attrs, ctx) do
    {:ok, ctx,
     editor: [
       attribute: "source",
       language: "shell",
       default_source: "echo \"Hello world\""
     ]}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{}, ctx}
  end

  @impl true
  def to_attrs(_ctx) do
    %{}
  end

  @impl true
  def to_source(attrs) do
    quote do
      {_, 0} = System.cmd("bash", ["-lc", unquote(quoted_source(attrs["source"]))], into: IO.stream())
      :ok
    end
    |> Kino.SmartCell.quoted_to_string()
  end

  defp quoted_source(query) do
    if String.contains?(query, "\n") do
      {:<<>>, [delimiter: ~s["""]], [query <> "\n"]}
    else
      query
    end
  end

  asset "main.js" do
    """
    export function init() {}
    """
  end
end
