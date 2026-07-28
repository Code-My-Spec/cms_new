ExUnit.start(exclude: [:phoenix_repo_only, :umbrella])

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
