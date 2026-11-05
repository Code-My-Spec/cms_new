defmodule Phx.New.Toolchain do
  @moduledoc """
  The Elixir and OTP every generated app targets: its `.tool-versions` and its
  Dockerfile's build image name the same pair, so a dev box, CI and the deploy
  image all run one toolchain.

  Kept equal to CodeMySpec's own `.tool-versions` (its `CodeMySpec.Toolchain`
  and `ToolchainTest`); bump both together, by hand. Track the latest Elixir and
  OTP: the progressive type system lands release by release.

  `image_date/0` is the date suffix of the hexpm/elixir image built for this
  pair, and the Debian bookworm snapshot the release image runs on.
  """

  @elixir "1.20.5"
  @otp "29.1.2"
  @image_date "20261027"

  @doc "The Elixir version, e.g. `\"1.20.5\"`."
  def elixir, do: @elixir

  @doc "The full OTP version, e.g. `\"29.1.2\"`."
  def otp, do: @otp

  @doc "The OTP major, e.g. `\"29\"`."
  def otp_major, do: @otp |> String.split(".") |> hd()

  @doc "The hexpm/elixir image date suffix for this pair."
  def image_date, do: @image_date

  @doc "The `.tool-versions` contents a generated app carries."
  def tool_versions, do: "erlang #{@otp}\nelixir #{@elixir}-otp-#{otp_major()}\n"
end
