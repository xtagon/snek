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

  @impl Snek.Ruleset
  def init(board_size, snake_ids) do
    Standard.init(board_size, snake_ids)
  end

  @impl Snek.Ruleset
  def next(board, snake_moves, apple_spawn_chance) do
    Standard.next(board, snake_moves, apple_spawn_chance)
  end

  def next(board, snake_moves) do
    Standard.next(board, snake_moves)
  end

  @impl Snek.Ruleset
  def done?(board) do
    Board.alive_snakes_remaining(board) <= 0
  end
end
