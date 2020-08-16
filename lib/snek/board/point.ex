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

      iex> Point.new(0, 0)
      %Point{x: 0, y: 0}

      iex> Point.new(3, 1)
      %Point{x: 3, y: 1}

      iex> Point.new(-2, 0)
      %Point{x: -2, y: 0}

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

      iex> Point.new(5, 5) |> Point.step(:north)
      %Point{x: 5, y: 4}

      iex> Point.new(5, 5) |> Point.step(:south)
      %Point{x: 5, y: 6}

      iex> Point.new(5, 5) |> Point.step(:east)
      %Point{x: 6, y: 5}

      iex> Point.new(5, 5) |> Point.step(:west)
      %Point{x: 4, y: 5}

      iex> Point.new(5, 5) |> Point.step(:northwest)
      %Point{x: 4, y: 4}

      iex> Point.new(5, 5) |> Point.step(:northeast)
      %Point{x: 6, y: 4}

      iex> Point.new(5, 5) |> Point.step(:southeast)
      %Point{x: 6, y: 6}

      iex> Point.new(5, 5) |> Point.step(:southwest)
      %Point{x: 4, y: 6}

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

  @doc """
  Returns a list of neighboring points adjascent to a point of origin.

  ## Examples

      iex> Point.adjascent_neighbors(Point.new(1, 1))
      [
        %Point{x: 1, y: 0},
        %Point{x: 1, y: 2},
        %Point{x: 2, y: 1},
        %Point{x: 0, y: 1}
      ]

      iex> Point.adjascent_neighbors(Point.new(0, 0))
      [
        %Point{x: 0, y: -1},
        %Point{x: 0, y: 1},
        %Point{x: 1, y: 0},
        %Point{x: -1, y: 0}
      ]

  """
  @doc since: "0.0.1"
  @spec adjascent_neighbors(t) :: list(t)

  def adjascent_neighbors(origin) do
    [
      step(origin, :north),
      step(origin, :south),
      step(origin, :east),
      step(origin, :west)
    ]
  end

  @doc """
  Returns a list of neighboring points diagonal to a point of origin.

  ## Examples

      iex> Point.diagonal_neighbors(Point.new(1, 1))
      [
        %Point{x: 0, y: 0},
        %Point{x: 2, y: 0},
        %Point{x: 2, y: 2},
        %Point{x: 0, y: 2}
      ]

      iex> Point.diagonal_neighbors(Point.new(0, 0))
      [
        %Point{x: -1, y: -1},
        %Point{x: 1, y: -1},
        %Point{x: 1, y: 1},
        %Point{x: -1, y: 1}
      ]

  """
  @doc since: "0.0.1"
  @spec diagonal_neighbors(t) :: list(t)

  def diagonal_neighbors(origin) do
    [
      step(origin, :northwest),
      step(origin, :northeast),
      step(origin, :southeast),
      step(origin, :southwest)
    ]
  end
end
