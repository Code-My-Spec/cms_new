ExUnit.start(exclude: [:phoenix_repo_only, :umbrella, :boot])

# :boot — generates a project, fetches its dependencies, compiles it and
# starts it. That is minutes and a network round trip, which does not belong
# in the suite people run while working. Run it with `mix test --include boot`
# when the templates that decide whether a generated project actually runs
# have changed.

# Two groups of upstream tests cannot pass in this vendored fork, and are
# excluded by default rather than left red:
#
#   :phoenix_repo_only — asserts installer templates stay in sync with
#     phoenix's own `priv/static/`. That directory lives outside `installer/`,
#     which is all we vendor, so the test has nothing to compare against.
#     Run it in the phoenix repo, not here.
#
#   :umbrella — `mix cms.new` rejects --umbrella outright (see
#     Mix.Tasks.Cms.New). The harness assumes a single OTP app; its boundary
#     layout and `.code_my_spec/spec/<app>` structure are derived from one app
#     name. The umbrella generator is still present because it comes from
#     upstream, but its output is not a supported CodeMySpec project and the
#     shared conn_case/data_case templates no longer match its assertions.
#
# Run them explicitly with:
#   mix test --include umbrella --include phoenix_repo_only
