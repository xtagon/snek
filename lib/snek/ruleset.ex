defmodule Snek.Ruleset do
  @moduledoc """
  A behaviour module for implementing variations of game rules.

  Implementations define how a game plays out from start to finish, by
  dynamically specifying:

  1. `c:init/2`: The initial board position
  2. `c:next/2`: Each next turn's board position, after all snakes have made their moves
  3. `c:done?/1`: When the game is considered over
  """
  @moduledoc since: "0.0.1"

  alias Snek.Board
  alias Board.{Size, Snake}

  @type valid_move :: :north | :south | :east | :west

  @callback init(
    board_size :: Size.t,
    snake_ids :: MapSet.t(Snake.id)
  ) :: {:ok, Board.t} | {:error, atom}

  @callback next(
    board :: Board.t,
    snake_moves :: MapSet.t({Snake.id, valid_move})
  ) :: Board.t

  @callback done?(board :: Board.t) :: boolean
end
