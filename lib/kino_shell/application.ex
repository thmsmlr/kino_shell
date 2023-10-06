defmodule KinoShell.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Kino.SmartCell.register(KinoShell.ShellScriptCell)

    children = []
    opts = [strategy: :one_for_one, name: KinoShell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
