defmodule Mix.Tasks.Cms.New do
  @moduledoc """
  Creates a new Phoenix project that already satisfies every CodeMySpec
  harness convention.

      $ mix cms.new PATH [--module MODULE] [--app APP]

  This is `mix phx.new` with the CodeMySpec conventions baked into the
  templates rather than applied afterwards by an agent. A project generated
  here passes all of `CodeMySpec.AgentTasks.ProjectSetup`'s checks on first
  sync, with zero model turns:

    * `mix.exs` carries the harness deps, the `boundary`/`spex` compilers,
      and `preferred_envs: [spex: :test]`
    * the Application module is emitted into the web namespace
    * `ConnCase`/`DataCase` live in the `<App>Test` namespace, with
      `__using__` shims so stock `mix phx.gen.*` output still compiles
    * boundary modules, the `<App>Spex.Case` base case, `.credo.exs`, and
      the `.code_my_spec/` skeleton all exist

  `AGENTS.md`, `CLAUDE.md`, and `.code_my_spec/rules/` are deliberately NOT
  emitted here — the harness owns that content and installs it at
  `cms init`, so there is exactly one source of truth for it.

  Every flag `mix phx.new` accepts is accepted here and behaves identically;
  see `mix help phx.new` for the full list.
  """

  @shortdoc "Creates a new CodeMySpec-ready Phoenix application"

  use Mix.Task

  @impl true
  def run(argv) do
    if "--umbrella" in argv do
      Mix.raise("""
      mix cms.new does not support --umbrella.

      The CodeMySpec harness assumes a single OTP app: its setup checks,
      boundary layout (<App> / <App>Web / <App>Test / <App>Spex), and
      `.code_my_spec/spec/<app>` structure are all derived from one app name.
      Generating an umbrella here would produce a project that cannot satisfy
      `project_setup`.

      Use `mix phx.new --umbrella` if you want a stock umbrella without the
      harness.
      """)
    end

    Mix.Tasks.Phx.New.run(argv)
  end
end
