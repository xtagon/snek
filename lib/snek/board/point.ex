defmodule Snek.Board.Point do
  @moduledoc """
  A struct for representing points on a board's grid.
  """
  @moduledoc since: "0.0.1"

  alias __MODULE__

  @typedoc """
  A point on a board.

  May be relative or absolute.
  """
  @typedoc since: "0.0.1"
  @type t :: %Point{
    x: x,
    y: y
  }

  @typedoc """
  A point's X coordinate.

  Smaller values are toward the west side of the board, larger are toward the
  east.

  For absolute coordinates on a board, use an integer between zero and the
  board width minus one.

  For relative points, you may use a negative integer.
  """
  @typedoc since: "0.0.1"
  @type x :: integer()

  @typedoc """
  A point's Y coordinate.

  Smaller values are toward the north side of the board, larger are toward the
  south.

  For absolute coordinates on a board, use an integer between zero and the
  board height minus one.

  For relative points, you may use a negative integer.
  """
  @typedoc since: "0.0.1"
  @type y :: integer()

  @typedoc """
  A direction from a point toward its adjascent or diagonal neighbor.
  """
  @typedoc since: "0.0.1"
  @type direction :: :north | :south | :east | :west | :northwest | :northeast | :southeast | :southwest

  @enforce_keys [:x, :y]

  defstruct [:x, :y]

  @doc """
  Returns a new point at the given X and Y coordinates.

  ## Examples

      iex> Snek.Board.Point.new(0, 0)
      %Snek.Board.Point{x: 0, y: 0}

      iex> Snek.Board.Point.new(3, 1)
      %Snek.Board.Point{x: 3, y: 1}

      iex> Snek.Board.Point.new(-2, 0)
      %Snek.Board.Point{x: -2, y: 0}

  """
  @doc since: "0.0.1"
  @spec new(x, y) :: t

  def new(x, y) when is_integer(x) and is_integer(y) do
    %Point{x: x, y: y}
  end

  @doc """
  Returns the point that is one step toward a given direction from a point of
  origin.

  ## Examples

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:north)
      %Snek.Board.Point{x: 5, y: 4}

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:south)
      %Snek.Board.Point{x: 5, y: 6}

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:east)
      %Snek.Board.Point{x: 6, y: 5}

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:west)
      %Snek.Board.Point{x: 4, y: 5}

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:northwest)
      %Snek.Board.Point{x: 4, y: 4}

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:northeast)
      %Snek.Board.Point{x: 6, y: 4}

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:southeast)
      %Snek.Board.Point{x: 6, y: 6}

      iex> Snek.Board.Point.new(5, 5) |> Snek.Board.Point.step(:southwest)
      %Snek.Board.Point{x: 4, y: 6}

  """
  @doc since: "0.0.1"
  @spec step(t, direction) :: t

  def step(origin, direction)

  def step(%Point{x: x, y: y}, :north) when is_integer(x) and is_integer(y) do
    %Point{x: x, y: y - 1}
  end

  def step(%Point{x: x, y: y}, :south) when is_integer(x) and is_integer(y) do
    %Point{x: x, y: y + 1}
  end

  def step(%Point{x: x, y: y}, :east) when is_integer(x) and is_integer(y) do
    %Point{x: x + 1, y: y}
  end

  def step(%Point{x: x, y: y}, :west) when is_integer(x) and is_integer(y) do
    %Point{x: x - 1, y: y}
  end

  def step(%Point{x: x, y: y}, :northwest) when is_integer(x) and is_integer(y) do
    %Point{x: x - 1, y: y - 1}
  end

  def step(%Point{x: x, y: y}, :northeast) when is_integer(x) and is_integer(y) do
    %Point{x: x + 1, y: y - 1}
  end

  def step(%Point{x: x, y: y}, :southeast) when is_integer(x) and is_integer(y) do
    %Point{x: x + 1, y: y + 1}
  end

  def step(%Point{x: x, y: y}, :southwest) when is_integer(x) and is_integer(y) do
    %Point{x: x - 1, y: y + 1}
  end
end
