defmodule Snek.Ruleset.Solo do
  @moduledoc """
  The solo ruleset, based on the official Battlesnake solo rules.

  Solo rules are the same as `Snek.Ruleset.Standard`, except standard games end
  when there are fewer than 2 snakes remaining and solo games only end after
  the last remaining snake is eliminated.

  Effort is made to keep this implementation compatible with Battlesnake's
  official rules, so that it may be used for simulating game turns. If there is
  a mistake either in the implementation or the tests/specification, please
  report it as a bug.
  """
  @moduledoc since: "0.1.0"

  @behaviour Snek.Ruleset

  @apple_spawn_chance 0.15

  alias Snek.Board
  alias Snek.Ruleset.Standard

  # coveralls-ignore-start
  defdelegate init(board_size, snake_ids), to: Standard
  defdelegate next(board, snake_moves, apple_spawn_chance \\ @apple_spawn_chance), to: Standard
  # coveralls-ignore-stop

  def done?(board) do
    Board.alive_snakes_remaining(board) <= 0
  end
end
