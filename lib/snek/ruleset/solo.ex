defmodule Snek.Ruleset.Solo do
  @moduledoc """
  The solo ruleset, based on the official Battlesnake solo rules.

  Effort is made to keep this implementation compatible with Battlesnake's
  official rules, so that it may be used for simulating game turns. If there is
  a mistake either in the implementation or the tests/specification, please
  report it as a bug.
  """
  @moduledoc since: "0.0.1"

  @behaviour Snek.Ruleset

  alias Snek.Board
  alias Snek.Ruleset.Standard

  # coveralls-ignore-start
  defdelegate init(board_size, snake_ids), to: Standard
  defdelegate next(board, snake_moves), to: Standard
  defdelegate next(board, snake_moves, apple_spawn_chance), to: Standard
  # coveralls-ignore-stop

  @impl Snek.Ruleset
  def done?(board) do
    Board.alive_snakes_remaining(board) <= 0
  end
end
