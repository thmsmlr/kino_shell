defmodule KinoShell.ShellScriptCell do
  @moduledoc false

  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "Shell Script"

  @impl true
  def init(attrs, ctx) do
    ctx =
      assign(ctx,
        in_background: Map.get(attrs, :in_background, false),
        restart: Map.get(attrs, :restart, false)
      )

    {:ok, ctx,
     editor: [
       attribute: "source",
       language: "shell",
       default_source: "echo \"Hello world\""
     ]}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok,
     %{
       in_background: ctx.assigns.in_background,
       restart: ctx.assigns.restart
     }, ctx}
  end

  @impl true
  def handle_event("update", %{"in_background" => in_background}, ctx) do
    broadcast_event(ctx, "update", %{"in_background" => in_background})
    {:noreply, assign(ctx, in_background: in_background)}
  end

  @impl true
  def handle_event("update", %{"restart" => restart}, ctx) do
    broadcast_event(ctx, "update", %{"restart" => restart})
    {:noreply, assign(ctx, restart: restart)}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      in_background: ctx.assigns.in_background,
      restart: ctx.assigns.restart
    }
  end

  @impl true
  def to_source(%{in_background: true, restart: restart} = attrs) do
    r = if restart, do: :permanent, else: :temporary

    quote do
      frame = Kino.Frame.new() |> Kino.render()

      command = unquote(quoted_source(attrs["source"]))

      child_spec =
        Task.child_spec(fn ->
          KinoShell.print_to_frame(frame, "[KinoShell]: Starting - #{command}\n")

          status_code =
            KinoShell.exec(
              "/bin/bash",
              ["-lc", command],
              fn data ->
                KinoShell.print_to_frame(frame, data)
              end
            )

          color = if status_code == 0, do: :yellow, else: :red

          KinoShell.print_to_frame(frame, [
            color,
            "[KinoShell]: Command shutdown with #{status_code}\n"
          ])
        end)

      Kino.start_child(%{child_spec | restart: unquote(r)})
      Kino.nothing()
    end
    |> Kino.SmartCell.quoted_to_string()
  end

  @impl true
  def to_source(attrs) do
    quote do
      {_, 0} =
        System.cmd("bash", ["-lc", unquote(quoted_source(attrs["source"]))], into: IO.stream())

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
    export function init(ctx, payload) {
      ctx.importCSS("main.css");
      ctx.importCSS("https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.min.css");
      ctx.importCSS("https://fonts.googleapis.com/css2?family=Inter:wght@400;500&amp;display=swap");

      ctx.root.innerHTML = `
        <div class="app">
          <div class="header">
            <form style="flex-grow:1;">
              <div class="icon-span" style="color: var(--gray-600);">
                <i class="ri ri-terminal-box-line"></i>
                <span>Shell Script</span>
              </div>
              <div style="flex-grow:1;"></div>
              <label for="in_background">
                <input type="checkbox" name="in_background" id="in_background" />
                Run in background
              </label>
              <label for="restart">
                <input type="checkbox" name="restart" id="restart" />
                Auto Restart
              </label>
            </form>
          </div>
        </div>
      `

      const in_background = ctx.root.querySelector("input[name='in_background']");
      in_background.checked = payload.in_background;

      in_background.addEventListener("change", (event) => {
        ctx.pushEvent("update", { in_background: event.target.checked });
      });

      const restart = ctx.root.querySelector("input[name='restart']");
      restart.checked = payload.restart;

      restart.addEventListener("change", (event) => {
        ctx.pushEvent("update", { restart: event.target.checked });
      });

      ctx.handleEvent("update", ({ in_background, restart }) => {
        in_background.checked = in_background;
        restart.checked = restart;
      });

      ctx.handleSync(() => {
        // Synchronously invokes change listeners
        document.activeElement &&
          document.activeElement.dispatchEvent(new Event("change"));
      });
    }
    """
  end

  asset "main.css" do
    """
    .app {
      font-family: "Inter";
      --gray-50: #f8fafc;
      --gray-100: #f0f5f9;
      --gray-200: #e1e8f0;
      --gray-300: #cad5e0;
      --gray-400: #91a4b7;
      --gray-500: #61758a;
      --gray-600: #445668;
      --gray-800: #1c2a3a;
      --yellow-100: #fff7ec;
      --yellow-600: #ffa83f;
      --blue-100: #ecf0ff;
      --blue-600: #3e64ff;
    }

    .header {
      display: flex;
      flex-wrap: wrap;
      align-items: stretch;
      justify-content: flex-start;
      background-color: var(--blue-100);
      padding: 8px 16px;
      border-left: solid 1px var(--gray-300);
      border-top: solid 1px var(--gray-300);
      border-right: solid 1px var(--gray-300);
      border-bottom: solid 1px var(--gray-200);
      border-radius: 0.5rem 0.5rem 0 0;
      gap: 16px;
    }

    form {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 8px;
    }

    form label {
      display: block;
      margin-bottom: 2px;
      color: var(--gray-600);
      font-weight: 500;
      font-size: 0.875rem;
      text-transform: uppercase;
      position: relative;
      top: 2px;
    }

    form label input {
      padding-right: 4px;
    }

    .icon-span {
      display: flex;
      flex-direction: row;
      align-items: center;
    }
    .icon-span i {
      padding-right: 4px;
    }
    """
  end
end
