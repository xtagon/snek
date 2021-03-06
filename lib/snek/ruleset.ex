defmodule Snek.Ruleset do
  @moduledoc """
  A behaviour module for implementing variations of game rules.

  Implementations define how a game plays out from start to finish, by
  dynamically specifying:

  1. `c:init/2`: The initial board position
  2. `c:next/3`: Each next turn's board position after moves are applied
  3. `c:done?/1`: When the game is considered over
  """
  @moduledoc since: "0.1.0"

  alias Snek.Board
  alias Board.{Size, Snake}

  @doc """
  Decide the initial board position for a new game.
  """
  @doc since: "0.1.0"
  @callback init(
    board_size :: Size.t,
    snake_ids :: MapSet.t(Snake.id)
  ) :: {:ok, Board.t} | {:error, atom}

  @doc """
  Apply moves and decide the next turn's board position.
  """
  @doc since: "0.1.0"
  @callback next(
    board :: Board.t,
    snake_moves :: %{required(Snake.id) => Snake.snake_move | nil} | list({Snake.id, Snake.snake_move | nil}),
    apple_spawn_chance :: float
  ) :: Board.t

  @doc """
  Decide whether the game is over at this board position.
  """
  @doc since: "0.1.0"
  @callback done?(board :: Board.t) :: boolean
end
