defmodule KinoShell do
  @doc """
  Executes a shell command and returns the result.

  ## Examples

      iex> KinoShell.exec("echo", ["Hello world"], fn output -> IO.puts(output) end)
      Hello world
      0
  """
  def exec(exe, args, on_stdout_stderr, opts \\ [:stream]) do
    wrapper_path = Application.app_dir(:kino_shell, "priv/run_command.sh")
    port =
      Port.open(
        {:spawn_executable, wrapper_path},
        opts ++ [{:args, [exe | args]}, :binary, :exit_status, :hide, :use_stdio, :stderr_to_stdout]
      )

    handle_output(port, on_stdout_stderr)
  end

  @doc """
    Helper function to print Terminal output using a Kino frame.

    ## Examples

    ```elixir
      frame = Kino.Frame.new() |> Kino.render()
      KinoShell.print_to_frame(frame, "hello")
      KinoShell.print_to_frame(frame, [:green, " world"])
    ```
  """
  def print_to_frame(frame, text) do
    text
    |> IO.ANSI.format()
    |> IO.iodata_to_binary()
    |> Kino.Text.new(terminal: true, chunk: true)
    |> then(&Kino.Frame.append(frame, &1))
  end

  defp handle_output(port, on_stdout_stderr) do
    receive do
      {^port, {:data, data}} ->
        on_stdout_stderr.(data)
        handle_output(port, on_stdout_stderr)

      {^port, {:exit_status, status}} ->
        status

      {^port, {:exit_signal, signal}} ->
        signal

      {^port, {:error, reason}} ->
        raise reason
    end
  end
end
