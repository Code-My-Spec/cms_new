defmodule Phx.New.Single do
  @moduledoc false
  use Phx.New.Generator
  alias Phx.New.{Project}

  template(:new, [
    {:config, :project,
     "phx_single/config/config.exs.eex": "config/config.exs",
     "phx_single/config/dev.exs.eex": "config/dev.exs",
     "phx_single/config/prod.exs.eex": "config/prod.exs",
     "phx_single/config/runtime.exs.eex": "config/runtime.exs",
     "phx_single/config/test.exs.eex": "config/test.exs"},
    {:eex, :web,
     # CodeMySpec: the Application module supervises both the Repo and the
     # Endpoint, so it belongs to the web namespace, not the app one.
     "phx_single/lib/app_name/application.ex.eex": "lib/:lib_web_name/application.ex",
     "phx_single/lib/app_name.ex.eex": "lib/:app.ex",
     "phx_web/controllers/error_json.ex.eex": "lib/:lib_web_name/controllers/error_json.ex",
     # Health endpoint ships regardless of --no-html: the deploy proxy gates
     # the traffic swap on it either way.
     "phx_web/controllers/health_controller.ex.eex":
       "lib/:lib_web_name/controllers/health_controller.ex",
     "phx_web/endpoint.ex.eex": "lib/:lib_web_name/endpoint.ex",
     "phx_web/router.ex.eex": "lib/:lib_web_name/router.ex",
     "phx_web/telemetry.ex.eex": "lib/:lib_web_name/telemetry.ex",
     "phx_single/lib/app_name_web.ex.eex": "lib/:lib_web_name.ex",
     "phx_single/mix.exs.eex": "mix.exs",
     "phx_single/README.md.eex": "README.md",
     "phx_single/formatter.exs.eex": ".formatter.exs",
     "phx_single/gitignore.eex": ".gitignore",
     "phx_test/support/conn_case.ex.eex": "test/support/conn_case.ex",
     "phx_single/test/test_helper.exs.eex": "test/test_helper.exs",
     "phx_test/controllers/error_json_test.exs.eex":
       "test/:lib_web_name/controllers/error_json_test.exs"},
    {:keep, :web,
     "phx_web/controllers": "lib/:lib_web_name/controllers",
     "phx_test/controllers": "test/:lib_web_name/controllers"}
  ])

  template(:gettext, [
    {:eex, :web,
     "phx_gettext/gettext.ex.eex": "lib/:lib_web_name/gettext.ex",
     "phx_gettext/en/LC_MESSAGES/errors.po.eex": "priv/gettext/en/LC_MESSAGES/errors.po",
     "phx_gettext/errors.pot.eex": "priv/gettext/errors.pot"}
  ])

  template(:html, [
    {:eex, :web,
     "phx_web/controllers/error_html.ex.eex": "lib/:lib_web_name/controllers/error_html.ex",
     "phx_test/controllers/error_html_test.exs.eex":
       "test/:lib_web_name/controllers/error_html_test.exs",
     "phx_web/components/core_components.ex.eex": "lib/:lib_web_name/components/core_components.ex",
     "phx_web/controllers/page_controller.ex.eex": "lib/:lib_web_name/controllers/page_controller.ex",
     "phx_web/controllers/page_html.ex.eex": "lib/:lib_web_name/controllers/page_html.ex",
     "phx_web/controllers/page_html/home.html.heex.eex":
       "lib/:lib_web_name/controllers/page_html/home.html.heex",
     "phx_test/controllers/page_controller_test.exs.eex":
       "test/:lib_web_name/controllers/page_controller_test.exs",
     "phx_web/components/layouts/root.html.heex.eex":
       "lib/:lib_web_name/components/layouts/root.html.heex",
     "phx_web/components/layouts.ex.eex": "lib/:lib_web_name/components/layouts.ex"},
    {:eex, :web, "phx_assets/logo.svg.eex": "priv/static/images/logo.svg"}
  ])

  template(:ecto, [
    {:eex, :app,
     "phx_ecto/repo.ex.eex": "lib/:app/repo.ex",
     "phx_ecto/formatter.exs.eex": "priv/repo/migrations/.formatter.exs",
     "phx_ecto/seeds.exs.eex": "priv/repo/seeds.exs",
     "phx_ecto/data_case.ex.eex": "test/support/data_case.ex"},
    {:keep, :app, "phx_ecto/priv/repo/migrations": "priv/repo/migrations"}
  ])

  template(:css, [
    {:eex, :web,
     "phx_assets/app.css.eex": "assets/css/app.css",
     "phx_assets/heroicons.js.eex": "assets/vendor/heroicons.js",
     "phx_assets/daisyui.js.eex": "assets/vendor/daisyui.js",
     "phx_assets/daisyui-theme.js.eex": "assets/vendor/daisyui-theme.js"}
  ])

  template(:js, [
    {:eex, :web,
     "phx_assets/app.js.eex": "assets/js/app.js",
     "phx_assets/topbar.js.eex": "assets/vendor/topbar.js",
     "phx_assets/tsconfig.json.eex": "assets/tsconfig.json"}
  ])

  template(:no_js, [
    {:text, :web, "phx_static/app.js": "priv/static/assets/js/app.js"}
  ])

  template(:no_css, [
    {
      :text,
      :web,
      # the default.css file can be re-created by using the recreate_default_css.exs file
      # in the installer folder: `elixir installer/recreate_default_css.exs`
      "phx_static/app.css": "priv/static/assets/css/app.css",
      "phx_static/default.css": "priv/static/assets/default.css"
    }
  ])

  template(:static, [
    {:text, :web,
     "phx_static/robots.txt": "priv/static/robots.txt",
     "phx_static/favicon.ico": "priv/static/favicon.ico"}
  ])

  template(:mailer, [
    {:eex, :app, "phx_mailer/lib/app_name/mailer.ex.eex": "lib/:app/mailer.ex"}
  ])

  # CodeMySpec harness files whose target path is a fixed string. The
  # app-name-prefixed ones (test/support/<app>_spex.ex and friends) cannot
  # live here: Project.join_path/3 expands `:key` against the Project struct,
  # and `:app_spex` would be read as one key and blow up. Those are rendered
  # by gen_cms/1 below.
  template(:cms, [
    {:eex, :project, "cms/credo.exs.eex": ".credo.exs"},
    {:eex, :project, "cms/conn_case_compat.ex.eex": "test/support/conn_case_compat.ex"},
    {:eex, :project, "cms/data_case_compat.ex.eex": "test/support/data_case_compat.ex"}
  ])

  # Declared only so __before_compile__ emits render/3 clauses for these
  # sources. gen_cms/1 renders them and writes to app-name-prefixed paths;
  # the targets below are never used and are placeholders.
  template(:cms_extra, [
    {:eex, :project,
     "cms/spex_boundary.ex.eex": "test/support/spex_boundary.ex",
     "cms/test_boundary.ex.eex": "test/support/test_boundary.ex",
     "cms/spex_case.ex.eex": "test/support/spex_case.ex"}
  ])

  # Deploy boilerplate. Always emitted, no flag: the setup routine fills in
  # values and runs commands rather than generating files, so it can assume
  # these exist. A library carries a few files it will never use; that is the
  # accepted cost of removing a code path.
  template(:deploy, [
    {:eex, :project,
     "deploy/Dockerfile.eex": "Dockerfile",
     "deploy/build.yml.eex": ".github/workflows/build.yml",
     "deploy/deploy.yml.eex": "config/deploy.yml",
     "deploy/deploy.uat.yml.eex": "config/deploy.uat.yml",
     "deploy/sops.yaml.eex": ".sops.yaml",
     "deploy/migrate.eex": "rel/overlays/bin/migrate",
     "deploy/server.eex": "rel/overlays/bin/server",
     "deploy/deploy_script.eex": "bin/deploy",
     "deploy/kamal_secrets.eex": ".kamal/secrets",
     "deploy/backup_script.eex": "bin/backup"}
  ])

  # Rendered by gen_deploy/1 into one file per environment; the target below
  # is a placeholder that is never used.
  template(:deploy_envs, [
    {:eex, :project, "deploy/env_placeholder.enc.env.eex": "envs/placeholder.enc.env"}
  ])

  def prepare_project(%Project{app: app, base_path: base_path} = project) when not is_nil(app) do
    if in_umbrella?(base_path) do
      %{project | in_umbrella?: true, project_path: Path.dirname(Path.dirname(base_path))}
    else
      %{project | in_umbrella?: false, project_path: base_path}
    end
    |> put_app()
    |> put_root_app()
    |> put_web_app()
  end

  defp put_app(%Project{base_path: base_path} = project) do
    %{project | app_path: base_path}
  end

  defp put_root_app(%Project{app: app, opts: opts} = project) do
    %{
      project
      | root_app: app,
        root_mod: Module.concat([opts[:module] || Macro.camelize(app)])
    }
  end

  defp put_web_app(%Project{app: app} = project) do
    %{
      project
      | web_app: app,
        lib_web_name: "#{app}_web",
        web_namespace: Module.concat(["#{project.root_mod}Web"]),
        web_path: project.base_path
    }
  end

  def generate(%Project{} = project) do
    copy_from(project, __MODULE__, :new)

    generate_agents_md(project)

    if Project.ecto?(project), do: gen_ecto(project)
    if Project.html?(project), do: gen_html(project)
    if Project.mailer?(project), do: gen_mailer(project)
    if Project.gettext?(project), do: gen_gettext(project)

    gen_assets(project)
    gen_cms(project)
    gen_deploy(project)
    project
  end

  @doc """
  Emits the CodeMySpec harness files.

  Between this and the template edits, a generated project satisfies every
  `CodeMySpec.AgentTasks.ProjectSetup` check on first sync — no agent pass.

  `.code_my_spec/AGENTS.md`, `CLAUDE.md`, and `.code_my_spec/rules/` are
  deliberately absent: the harness owns that content and installs it at
  `cms init`, so it has exactly one source of truth.
  """
  def gen_cms(%Project{} = project) do
    copy_from(project, __MODULE__, :cms)

    app = project.binding[:app_name]

    for {template, target} <- [
          {"cms/spex_boundary.ex.eex", "test/support/#{app}_spex.ex"},
          {"cms/test_boundary.ex.eex", "test/support/#{app}_test_boundary.ex"},
          {"cms/spex_case.ex.eex", "test/support/#{app}_spex_case.ex"}
        ] do
      contents = render(:cms_extra, template, project.binding)
      Mix.Generator.create_file(Path.join(project.project_path, target), contents)
    end

    # Spec directories the harness writes into. `.gitkeep` files rather than
    # bare mkdir: git does not track empty directories, and the structure has
    # to survive a clone for the setup check to keep passing.
    for dir <- [".code_my_spec/rules", ".code_my_spec/spec/#{app}", ".code_my_spec/spec/#{app}_web"] do
      Mix.Generator.create_file(Path.join([project.project_path, dir, ".gitkeep"]), "")
    end

    project
  end

  @doc """
  Emits the deploy boilerplate.

  A generated project is deployable on its first push: the Dockerfile and CI
  workflow build a multi-arch image, one deploy config per environment names
  its own host and APP_ENV, and `bin/deploy` enforces migrate-before-swap.

  The setup routine fills in the placeholder hosts and keys; it does not write
  any of these files, which is what lets it assume they exist.
  """
  def gen_deploy(%Project{} = project) do
    copy_from(project, __MODULE__, :deploy)

    # One encrypted env file per environment. Committed as placeholders so the
    # paths exist and `sops envs/<env>.enc.env` works immediately — the repo is
    # safe to push from the first commit because there is no plaintext env file
    # anywhere in it.
    placeholder = render(:deploy_envs, "deploy/env_placeholder.enc.env.eex", project.binding)

    for env <- ~w(prod uat) do
      Mix.Generator.create_file(
        Path.join([project.project_path, "envs", "#{env}.enc.env"]),
        placeholder
      )
    end

    # Executable: every one of these is run directly, and a non-executable
    # bin/deploy is a confusing first failure on a fresh clone. `server` is
    # the container's CMD, so a non-executable one fails at container start
    # with a permission error rather than anywhere near the cause.
    for script <- [
          "bin/deploy",
          "bin/backup",
          "rel/overlays/bin/migrate",
          "rel/overlays/bin/server"
        ] do
      path = Path.join(project.project_path, script)
      if File.exists?(path), do: File.chmod!(path, 0o755)
    end

    project
  end

  def gen_html(project) do
    copy_from(project, __MODULE__, :html)
  end

  def gen_gettext(project) do
    copy_from(project, __MODULE__, :gettext)
  end

  def gen_ecto(project) do
    copy_from(project, __MODULE__, :ecto)
    gen_ecto_config(project)
  end

  def gen_assets(%Project{} = project) do
    javascript? = Project.javascript?(project)
    css? = Project.css?(project)
    html? = Project.html?(project)

    copy_from(project, __MODULE__, :static)

    if html? or javascript? do
      command = if javascript?, do: :js, else: :no_js
      copy_from(project, __MODULE__, command)
    end

    if html? or css? do
      command = if css?, do: :css, else: :no_css
      copy_from(project, __MODULE__, command)
    end
  end

  def gen_mailer(%Project{} = project) do
    copy_from(project, __MODULE__, :mailer)
  end
end
