# cms_new

`mix cms.new` — a Phoenix project generator that emits projects already
conforming to the [CodeMySpec](https://codemyspec.com) harness conventions.

This is a fork of the [Phoenix](https://github.com/phoenixframework/phoenix)
installer (`installer/`, MIT — see `LICENSE.md`). Everything `mix phx.new`
does, `mix cms.new` does; the difference is what comes out.

## Why

Setting up a CodeMySpec project used to mean running `mix phx.new` and then
walking an agent through twelve mechanical edits — moving the Application
module, renaming case modules, adding compilers, writing boundary modules.
Every one of those is a pure function of the app name, so a model should
never have been in that loop. A project generated here satisfies all twelve
`ProjectSetup` checks on first sync, with zero model turns.

## What differs from `phx.new`

| | |
|---|---|
| `mix.exs` | harness deps, `compilers/1` (`:boundary` + `:spex`), `preferred_envs: [spex: :test]`, `spex:` project key |
| `application.ex` | emitted at `lib/<app>_web/` as `<App>Web.Application` — it supervises both the Repo and the Endpoint, so it cannot sit in the core namespace without inverting the boundary |
| `lib/<app>.ex`, `lib/<app>_web.ex` | `use Boundary` on both root modules |
| `conn_case` / `data_case` | `<App>Test` namespace, plus `__using__` shims at the old names so stock `mix phx.gen.*` output still compiles |
| new files | `<App>Spex` / `<App>Test` boundary modules, `<App>Spex.Case`, `.credo.exs`, `.code_my_spec/` skeleton |

`AGENTS.md`, `CLAUDE.md` and `.code_my_spec/rules/` are deliberately **not**
emitted here — the harness owns that content and installs it at `cms init`,
so there is exactly one source of truth for it.

Umbrella projects are not supported: the harness derives its boundary layout
and spec paths from a single app name. `mix cms.new --umbrella` refuses
rather than producing a project that cannot satisfy setup.

## Install

    $ mix archive.install github Code-My-Spec/cms_new

Or from source:

    $ MIX_ENV=prod mix do archive.build + archive.install

## Usage

    $ mix cms.new my_app

Every flag `mix phx.new` accepts is accepted here and behaves identically;
see `mix help phx.new`.

## Tracking upstream

Two branches, so taking a new Phoenix release stays a rebase rather than an
exercise in merge-conflict archaeology:

- **`vendor`** — pure upstream snapshots only, never our changes. The
  Phoenix `installer/` tree at a tag, plus `usage-rules/` copied to
  `templates/phoenix-usage-rules/` (upstream gitignores that directory
  because it regenerates it at publish time; there is no phoenix sibling
  here to regenerate it from, so it is committed).
- **`main`** — `vendor` plus a single squashed patch commit.

To take a new release:

    $ git checkout vendor
    $ # drop the new installer/ and usage-rules/ trees over the working tree
    $ git commit -am "vendor phx_new <version>"
    $ git checkout main && git rebase vendor

Modules stay namespaced `Phx.New.*` on purpose — it keeps the diff against
upstream small and the rebase clean.

## Tests

    $ mix test

`test/cms_new_test.exs` asserts the generated output against the *same*
predicates CodeMySpec applies at sync time in `Files.FileSync` — the regexes
are copied from its validators — so drift between generator and harness
fails a test instead of quietly producing projects that need a manual setup
pass.

Two groups of inherited upstream tests are excluded by default and tagged
with why (see `test/test_helper.exs`): `:phoenix_repo_only` needs Phoenix's
`priv/`, which lives outside the vendored `installer/`, and `:umbrella` is
unsupported.

---

Upstream Phoenix installer documentation follows.

## mix phx.new

Provides `phx.new` installer as an archive.

To install from Hex, run:

    $ mix archive.install hex phx_new

To build and install it locally,
ensure any previous archive versions are removed:

    $ mix archive.uninstall phx_new

Then run:

    $ cd installer
    $ MIX_ENV=prod mix do archive.build + archive.install
