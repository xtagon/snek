defmodule Snek.Board.Snake do
  @moduledoc """
  Represents a snake on a board.

  You may also refer to it as a "snake on a plane", as the joke
  goes in the Battlesnake community. 😎
  """
  @moduledoc since: "0.0.1"

  alias __MODULE__
  alias Snek.Board.Point

  @typedoc """
  A unique ID to differentiate between snakes on a board
  """
  @typedoc since: "0.0.1"
  @type id :: any

  @typedoc """
  A snake on a board.
  """
  @typedoc since: "0.0.1"
  @type t :: %Snake{
    id: any,
    health: non_neg_integer,
    body: list(Point.t)
  }

  @enforce_keys [:id, :health, :body]

  defstruct [:id, :health, :body]
end
