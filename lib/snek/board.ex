defmodule Snek.Board do
  @moduledoc """
  A struct for representing a board position.

  This may be used to keep track of state in a game, each turn of the
  game producing the next board position.
  """
  @moduledoc since: "0.0.1"

  alias __MODULE__
  alias Board.{Point, Size, Snake}

  @typedoc """
  A board position.
  """
  @typedoc since: "0.0.1"
  @type t :: %Board{
    size: Size.t,
    apples: list(Point.t),
    snakes: list(Snake.t)
  }

  @enforce_keys [
    :size,
    :apples,
    :snakes
  ]

  defstruct [
    :size,
    :apples,
    :snakes
  ]

  @snake_default_length 3
  @snake_default_health 100

  @doc """
  Returns a new empty board of a given size.

  ## Examples

      iex> Board.new(Board.Size.small)
      %Board{size: %Board.Size{width: 7, height: 7}, apples: [], snakes: []}

  """
  @doc since: "0.0.1"
  @spec new(Size.t) :: t

  def new(size) do
    %Board{
      size: size,
      apples: [],
      snakes: []
    }
  end

  @doc """
  Returns true if and only if this board is empty, otherwise false.

  The board is considered empty if it does not contain any snakes or
  apples.

  ## Examples

      iex> Board.new(Board.Size.small) |> Board.empty?
      true

      iex> Board.new(Board.Size.small) |> Board.spawn_apple_at_center |> Board.empty?
      false

      iex> Board.new(Board.Size.small) |> Board.spawn_snake_at_center("mysnek") |> Board.empty?
      false

  """
  @doc since: "0.0.1"
  @spec empty?(t) :: boolean

  def empty?(%Board{apples: apples}) when length(apples) > 0, do: false
  def empty?(%Board{snakes: snakes}) when length(snakes) > 0, do: false
  def empty?(%Board{}), do: true

  @doc """
  Spawns an apple in the center of the board.

  Returns the next board position.

  ## Examples

      iex>Board.new(Board.Size.new(3, 3)) |> Board.spawn_apple_at_center()
      %Board{
        apples: [%Board.Point{x: 1, y: 1}],
        size: %Board.Size{height: 3, width: 3},
        snakes: []
      }

  """
  @doc since: "0.0.1"
  @spec spawn_apple_at_center(t) :: t

  def spawn_apple_at_center(board) do
    spawn_apple(board, Board.center_point(board))
  end

  @doc """
  Spawns an apple at the specified point on the board.

  Returns the next board position.

  ## Examples

      iex>Board.new(Board.Size.small) |> Board.spawn_apple(Board.Point.new(1, 1))
      %Board{
        apples: [%Board.Point{x: 1, y: 1}],
        size: %Board.Size{height: 7, width: 7},
        snakes: []
      }

  """
  @doc since: "0.0.1"
  @spec spawn_apple(t, Point.t) :: t

  def spawn_apple(board, point) do
    %Board{board | apples: [point | board.apples]}
  end

  @doc """
  Spawns apples at each of the specified points on the board.

  Returns the next board position.

  ## Examples

      iex>points = [Board.Point.new(1, 1), Board.Point.new(1, 2)]
      iex>Board.new(Board.Size.small) |> Board.spawn_apples(points)
      %Board{
        apples: [
          %Board.Point{x: 1, y: 1},
          %Snek.Board.Point{x: 1, y: 2}
        ],
        size: %Snek.Board.Size{height: 7, width: 7},
        snakes: []
      }

  """
  @doc since: "0.0.1"
  @spec spawn_apples(t, list(Point.t)) :: t

  def spawn_apples(board, points) do
    %Board{board | apples: Enum.concat(points, board.apples)}
  end

  @doc """
  Returns the point at the center of the board.

  If the board width or height are even, the center will be offset because
  boards are a discrete grid.

  ## Examples

      iex>Board.new(Board.Size.new(3, 3)) |> Board.center_point()
      %Board.Point{x: 1, y: 1}

      iex>Board.new(Board.Size.new(8, 8)) |> Board.center_point()
      %Board.Point{x: 3, y: 3}

  """
  @doc since: "0.0.1"
  @spec center_point(t) :: Point.t

  def center_point(%Board{size: %Size{width: width, height: height}}) do
    x = div(width - 1, 2)
    y = div(height - 1, 2)
    %Point{x: x, y: y}
  end

  @doc """
  Spawns a snake in the center of the board.

  Returns the next board position.

  ## Examples

      iex>board = Board.new(Board.Size.small) |> Board.spawn_snake_at_center("mysnek")
      iex>board.snakes
      [
        %Board.Snake{
          body: [%Board.Point{x: 3, y: 3}, %Board.Point{x: 3, y: 3}, %Board.Point{x: 3, y: 3}],
          health: 100,
          id: "mysnek"
        }
      ]

  """
  @doc since: "0.0.1"
  @spec spawn_snake_at_center(t, any, non_neg_integer, non_neg_integer) :: t

  def spawn_snake_at_center(board, id, length \\ @snake_default_length, health \\ @snake_default_health) do
    head = center_point(board)
    spawn_snake(board, id, head, length, health)
  end

  @doc """
  Spawns a snake at the specified point on the board.

  Returns the next board position.

  ## Examples

      iex>board = Board.new(Board.Size.small) |> Board.spawn_snake("mysnek", Board.Point.new(1, 1))
      iex>board.snakes
      [
        %Board.Snake{
          body: [%Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}],
          health: 100,
          id: "mysnek"
        }
      ]

  """
  @doc since: "0.0.1"
  @spec spawn_snake(t, any, Point.t, non_neg_integer, non_neg_integer) :: t

  def spawn_snake(board, id, head, length \\ @snake_default_length, health \\ @snake_default_health) do
    snake = %Snake{
      id: id,
      health: health,
      body: List.duplicate(head, length)
    }

    %Board{board | snakes: [snake | board.snakes]}
  end
end
