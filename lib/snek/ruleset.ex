defmodule Snek.Ruleset do
  @moduledoc """
  A behaviour module for implementing variations of game rules.

  Implementations define how a game plays out from start to finish, by
  dynamically specifying:

  1. `c:init/2`: The initial board position
  2. `c:next/2`: Each next turn's board position after moves are applied
  3. `c:done?/1`: When the game is considered over
  """
  @moduledoc since: "0.0.1"

  alias Snek.Board
  alias Board.{Size, Snake}

  @typedoc """
  Valid moves for a snake to play.
  """
  @type valid_move :: :north | :south | :east | :west

  @doc """
  Decide the initial board position for a new game.
  """
  @doc since: "0.0.1"
  @callback init(
    board_size :: Size.t,
    snake_ids :: MapSet.t(Snake.id)
  ) :: {:ok, Board.t} | {:error, atom}

  @doc """
  Apply moves and decide the next turn's board position.
  """
  @doc since: "0.0.1"
  @callback next(
    board :: Board.t,
    snake_moves :: list({Snake.id, valid_move}),
    apple_spawn_chance :: float
  ) :: Board.t

  @doc """
  Decide whether the game is over at this board position.
  """
  @doc since: "0.0.1"
  @callback done?(board :: Board.t) :: boolean
end
