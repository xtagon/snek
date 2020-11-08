defmodule Snek.Board.Point do
  @moduledoc """
  A struct for representing points on a board's grid.
  """
  @moduledoc since: "0.1.0"

  alias __MODULE__

  @typedoc """
  A point on a board.

  May be relative or absolute.
  """
  @typedoc since: "0.1.0"
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
  @typedoc since: "0.1.0"
  @type x :: integer()

  @typedoc """
  A point's Y coordinate.

  Smaller values are toward the north side of the board, larger are toward the
  south.

  For absolute coordinates on a board, use an integer between zero and the
  board height minus one.

  For relative points, you may use a negative integer.
  """
  @typedoc since: "0.1.0"
  @type y :: integer()

  @typedoc """
  A direction from a point toward its adjascent or diagonal neighbor.
  """
  @typedoc since: "0.1.0"
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
  @doc since: "0.1.0"
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
  @doc since: "0.1.0"
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
  @doc since: "0.1.0"
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
  @doc since: "0.1.0"
  @spec diagonal_neighbors(t) :: list(t)

  def diagonal_neighbors(origin) do
    [
      step(origin, :northwest),
      step(origin, :northeast),
      step(origin, :southeast),
      step(origin, :southwest)
    ]
  end

  @doc """
  Returns the difference between two points, which could be used to find a
  vector between points, such as when using the neck and head of a snake to
  determine the point continuing in the last moved direction.

  ## Examples

      iex> Point.difference(Point.new(1, 2), Point.new(1, 3))
      %Point{x: 0, y: -1}

      iex> Point.difference(Point.new(4, 4), Point.new(5, 4))
      %Point{x: -1, y: 0}

  """
  @doc since: "0.1.0"
  @spec difference(t, t) :: t

  def difference(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}) do
    %Point{
      x: x1 - x2,
      y: y1 - y2
    }
  end

  @doc """
  Returns the sum of two points, which could be used to apply a vector point to
  a fixed points, such as when using the neck and head of a snake to determine
  the point continuing in the last moved direction.

  ## Examples

      iex> Point.sum(Point.new(1, 2), Point.new(1, 0))
      %Point{x: 2, y: 2}

      iex> Point.sum(Point.new(4, 4), Point.new(-1, 1))
      %Point{x: 3, y: 5}

  """
  @doc since: "0.1.0"
  @spec sum(t, t) :: t

  def sum(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}) do
    %Point{
      x: x1 + x2,
      y: y1 + y2
    }
  end

  @doc """
  Returns true if and only if both X and Y are zero, which could be used to
  determine if a point is a null vector.

  ## Examples

      iex> Point.zero?(Point.new(0, 0))
      true

      iex> Point.zero?(Point.new(0, 1))
      false

  """
  @doc since: "0.1.0"
  @spec zero?(t) :: boolean

  def zero?(%Point{x: 0, y: 0}), do: true
  def zero?(%Point{}), do: false

  @doc """
  Returns true if and only if this point falls on an even square for an board,
  alternating like a checkerboard.

  ## Examples

      iex> Point.even?(Point.new(0, 0))
      true

      iex> Point.even?(Point.new(0, 1))
      false

      iex> Point.even?(Point.new(0, 2))
      true

      iex> Point.even?(Point.new(1, 0))
      false

      iex> Point.even?(Point.new(1, 1))
      true

      iex> Point.even?(Point.new(1, 2))
      false

  """
  @doc since: "0.1.0"
  @spec even?(t) :: boolean

  def even?(%Point{x: x, y: y}) do
    rem(x + y, 2) == 0
  end

  @doc """
  Returns the Manhattan distance between two points.

  ## Examples

      iex> Point.manhattan_distance(Point.new(0, 0), Point.new(1, 2))
      3

  """
  @doc since: "0.1.0"
  @spec manhattan_distance(t, t) :: integer

  def manhattan_distance(point_a, point_b)

  def manhattan_distance(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  @doc """
  Rotates a point 90 degrees clockwise.

  This is useful for rotating vectors, which can help find relative directions.

  ## Examples

      iex> Point.rotate_clockwise(Point.new(0, 1))
      %Point{x: -1, y: 0}

  """
  @doc since: "0.1.0"
  @spec rotate_clockwise(t) :: t

  def rotate_clockwise(%Point{x: x, y: y}), do: %Point{x: -y, y: x}

  @doc """
  Rotates a point 90 degrees counter-clockwise.

  This is useful for rotating vectors, which can help find relative directions.

  ## Examples

      iex> Point.rotate_counterclockwise(Point.new(-1, 0))
      %Point{x: 0, y: 1}

  """
  @doc since: "0.1.0"
  @spec rotate_counterclockwise(t) :: t

  def rotate_counterclockwise(%Point{x: x, y: y}), do: %Point{x: y, y: -x}
end
