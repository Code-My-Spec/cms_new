Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Cms.NewTest do
  @moduledoc """
  Asserts that a generated project satisfies every
  `CodeMySpec.AgentTasks.ProjectSetup` step without an agent touching it.

  The assertions below are deliberately written as the *same predicates*
  CodeMySpec applies at sync time in `Files.FileSync` — the regexes and
  string checks are copied from `validate_mix_exs/1`, `validate_credo_exs/1`,
  and friends. That is the point of this file: if either side changes, this
  test fails, instead of the drift only showing up as a project that quietly
  needs a manual setup pass.

  Four steps are NOT covered here (AgentsMd, ClaudeMd, Rules, CredoChecks).
  Those are installed by the harness at `cms init` from content it owns, so
  they are tested on the CodeMySpec side in
  `test/code_my_spec/mcp_servers/bootstrap/installers_test.exs`.
  """
  use ExUnit.Case, async: false
  import MixHelper

  @app_name "cms_blog"

  setup do
    send(self(), {:mix_shell_input, :yes?, false})
    :ok
  end

  # Templates explain their design choices in comments, which means a comment
  # can legitimately name the very thing the code must not do. Assertions
  # about behaviour should look at code.
  defp strip_comments(source) do
    source
    |> String.split("\n")
    |> Enum.reject(&String.starts_with?(String.trim(&1), "#"))
    |> Enum.join("\n")
  end

  test "generated project satisfies the ProjectSetup steps" do
    in_tmp("cms new", fn ->
      Mix.Tasks.Cms.New.run([@app_name])

      # --- ApplicationInWeb ------------------------------------------------
      refute File.exists?("cms_blog/lib/cms_blog/application.ex"),
             "Application must not remain in the core namespace"

      assert_file("cms_blog/lib/cms_blog_web/application.ex", fn file ->
        assert file =~ "defmodule CmsBlogWeb.Application do"
        assert file =~ "name: CmsBlogWeb.Supervisor"
      end)

      assert_file("cms_blog/mix.exs", fn file ->
        # validate_codemyspec_deps/1
        for dep <- ~w(credo client_utils sobelow sexy_spex boundary code_my_spec_generators) do
          assert Regex.match?(~r/\{:#{dep}[,\s]/, file), "missing dep :#{dep} in mix.exs"
        end

        # validate_compilers/1
        assert Regex.match?(~r/compilers.*:boundary/s, file)
        assert Regex.match?(~r/compilers.*:spex/s, file)

        # validate_spex_config/1
        assert Regex.match?(~r/spex:\s*:test/, file)

        # extract_app_name_result/1
        assert Regex.match?(~r/app:\s*:(\w+)/, file)

        # mod: must follow the Application module into the web namespace
        assert file =~ "mod: {CmsBlogWeb.Application, []}"

        # :diagnostics comes from :client_utils and :boundary from :boundary;
        # neither may be dev-only or the compiler is absent in test/prod
        refute Regex.match?(~r/\{:boundary,[^}]*only:/, file)
        refute Regex.match?(~r/\{:client_utils,[^}]*only:/, file)
      end)

      # --- TestSupportNamespace --------------------------------------------
      assert_file("cms_blog/test/support/conn_case.ex", fn file ->
        assert file =~ "defmodule CmsBlogTest.ConnCase do"
      end)

      assert_file("cms_blog/test/support/data_case.ex", fn file ->
        assert file =~ "defmodule CmsBlogTest.DataCase do"
      end)

      # Shims so stock `mix phx.gen.*` output still compiles
      assert_file("cms_blog/test/support/conn_case_compat.ex", fn file ->
        assert file =~ "defmodule CmsBlogWeb.ConnCase do"
        assert file =~ "use CmsBlogTest.ConnCase, unquote(opts)"
      end)

      assert_file("cms_blog/test/support/data_case_compat.ex", fn file ->
        assert file =~ "defmodule CmsBlog.DataCase do"
        assert file =~ "use CmsBlogTest.DataCase, unquote(opts)"
      end)

      # --- TestBoundaries ---------------------------------------------------
      assert_file("cms_blog/test/support/cms_blog_spex.ex", fn file ->
        assert file =~ "defmodule CmsBlogSpex do"
        # Must NOT depend on the test-support boundary; spex own their
        # sandbox. Assert on the deps list itself, not the whole file.
        assert file =~ "deps: [CmsBlog, CmsBlogWeb]"
      end)

      assert_file("cms_blog/test/support/cms_blog_test_boundary.ex", fn file ->
        assert file =~ "defmodule CmsBlogTest do"
        assert file =~ "use Boundary"
      end)

      # Root modules must be claimed, or every module warns "not included in
      # any boundary"
      assert_file("cms_blog/lib/cms_blog.ex", fn file ->
        assert file =~ "use Boundary"
      end)

      assert_file("cms_blog/lib/cms_blog_web.ex", fn file ->
        assert file =~ "use Boundary"
        assert file =~ "deps: [CmsBlog]"
      end)

      # --- SpexCase ---------------------------------------------------------
      assert_file("cms_blog/test/support/cms_blog_spex_case.ex", fn file ->
        assert file =~ "defmodule CmsBlogSpex.Case do"
        assert file =~ "use SexySpex"
        # Owns its sandbox rather than reaching into CmsBlogTest.DataCase.
        # Assert against CODE only: the template carries a comment explaining
        # why it doesn't delegate, and that comment necessarily names the
        # call it is declining to make.
        assert file =~ "Sandbox.start_owner!(CmsBlog.Repo"
        refute strip_comments(file) =~ "CmsBlogTest.DataCase"
      end)

      # --- CredoChecks ------------------------------------------------------
      # validate_credo_exs/1 wants both requires plus the eval_file
      assert_file("cms_blog/.credo.exs", fn file ->
        assert file =~ "credo_checks/framework"
        assert file =~ "credo_checks/local"
        assert file =~ "credo_checks/framework/checks.exs"
      end)

      # --- ProjectStructure -------------------------------------------------
      for dir <- ~w(rules spec/cms_blog spec/cms_blog_web) do
        assert File.dir?("cms_blog/.code_my_spec/#{dir}"),
               "missing .code_my_spec/#{dir}"

        assert File.exists?("cms_blog/.code_my_spec/#{dir}/.gitkeep"),
               ".code_my_spec/#{dir} needs a .gitkeep — git does not track empty dirs, " <>
                 "so the structure would not survive a clone"
      end
    end)
  end

  test "harness content the generator must NOT emit" do
    in_tmp("cms new no harness content", fn ->
      Mix.Tasks.Cms.New.run([@app_name])

      # These are installed by `cms init` from content the harness owns.
      # Emitting them here would create a second source of truth that
      # silently goes stale.
      refute File.exists?("cms_blog/.code_my_spec/AGENTS.md")
      refute File.exists?("cms_blog/CLAUDE.md")
      assert File.ls!("cms_blog/.code_my_spec/rules") == [".gitkeep"]
    end)
  end

  test "a generated project carries the deploy boilerplate and a health check that needs no database" do
    in_tmp("cms new deploy", fn ->
      Mix.Tasks.Cms.New.run(["cms_blog", "--no-install"])

      # Story 970: the setup routine fills in values and runs commands, so it
      # can assume these exist rather than generating them.
      for path <- ~w(Dockerfile .github/workflows/build.yml config/deploy.yml
                     config/deploy.uat.yml .sops.yaml rel/overlays/bin/migrate
                     bin/deploy bin/backup) do
        assert File.exists?("cms_blog/#{path}"), "expected the generator to emit #{path}"
      end

      # One encrypted env per environment, because story 967 keys them per
      # environment too.
      assert File.exists?("cms_blog/envs/prod.enc.env")
      assert File.exists?("cms_blog/envs/uat.enc.env")

      # The health check answers above the router. A route alone is not
      # enough: in dev `Phoenix.Ecto.CheckRepoStatus` sits between the
      # endpoint and the router and answers 503 when the database is absent,
      # so the probe got a 503 exactly when it most wanted an answer — and the
      # deploy proxy reads that as an unhealthy container.
      assert_file("cms_blog/lib/cms_blog_web/endpoint.ex", fn file ->
        assert file =~ "plug :health_check"
        assert file =~ ~s|request_path: "/health"|

        assert String.contains?(
                 String.split(file, "plug :health_check") |> hd(),
                 "Plug.Static"
               ),
               "expected the health plug above the database-aware plugs"
      end)

      # And the proxy probes over plain HTTP, so force_ssl must not redirect it.
      assert_file("cms_blog/config/runtime.exs", fn file ->
        assert file =~ ~s|exclude: ["/health"|
      end)
    end)
  end

  @tag :boot
  @tag timeout: 600_000
  test "a generated project boots and serves before Sam owns any infrastructure" do
    in_tmp("cms new boot", fn ->
      Mix.Tasks.Cms.New.run(["cms_blog", "--no-install"])

      # Story 970 criterion 7980. The claim is that Sam can work locally
      # before he has a Hetzner account, a domain or a registry — so this
      # generates a project, builds it and asks it for a response, with no
      # provider credentials configured and no database created.
      File.cd!("cms_blog", fn ->
        {_, 0} = System.cmd("mix", ["deps.get"], stderr_to_stdout: true)
        {out, status} = System.cmd("mix", ["compile"], stderr_to_stdout: true)
        assert status == 0, "generated project did not compile:\n#{out}"

        port = "4399"

        # Killing the spawning Elixir process would not kill the OS process it
        # started — that leaves a server holding the port after the suite
        # exits, which is its own kind of mess. Kill by port instead.
        spawn(fn ->
          System.cmd("mix", ["phx.server"],
            env: [{"PORT", port}, {"MIX_ENV", "dev"}],
            stderr_to_stdout: true
          )
        end)

        on_exit(fn ->
          System.cmd("sh", ["-c", "lsof -ti tcp:#{port} | xargs kill -9 2>/dev/null || true"])
        end)

        # The health path specifically, because it is the one that must answer
        # without a session, without auth and without a database — and there
        # is no database here.
        body = await_health(port, 60)

        assert body == "ok",
               "expected the generated project to serve /health with no database, got: #{inspect(body)}"
      end)
    end)
  end

  defp await_health(_port, 0), do: :never_answered

  defp await_health(port, attempts) do
    case System.cmd("curl", ["-s", "http://127.0.0.1:#{port}/health"], stderr_to_stdout: true) do
      {body, 0} when body != "" -> String.trim(body)
      _ -> Process.sleep(1_000) && await_health(port, attempts - 1)
    end
  end
end
