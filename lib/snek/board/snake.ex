defmodule Snek.Board.Snake do
  @moduledoc """
  Represents a snake on a board.

  You may also refer to it as a "snake on a plane", as the joke
  goes in the Battlesnake community. 😎
  """
  @moduledoc since: "0.1.0"

  alias __MODULE__
  alias Snek.Board.Point

  @typedoc """
  A unique ID to differentiate between snakes on a board
  """
  @typedoc since: "0.1.0"
  @type id :: any

  @typedoc """
  A valid direction for a snake to move according to the game rules.
  """
  @typedoc since: "0.1.0"
  @type snake_move :: :north | :south | :east | :west | :forward | :left | :right

  @typedoc """
  Whether a snake is currently alive, or has been eliminated.

  If eliminated, the reason is encoded. If the elimination was caused by an
  opponent, the opponent's snake ID is also specified.
  """
  @typedoc since: "0.1.0"
  @type state :: :alive
  | {:eliminated, :starvation}
  | {:eliminated, :out_of_bounds}
  | {:eliminated, :self_collision}
  | {:eliminated, :collision, id}
  | {:eliminated, :head_to_head, id}

  @typedoc """
  A snake on a board.
  """
  @typedoc since: "0.1.0"
  @type t :: %Snake{
    id: any,
    state: state,
    health: non_neg_integer,
    body: list(Point.t)
  }

  @enforce_keys [:id, :state, :health, :body]

  defstruct [:id, :state, :health, :body]

  @doc """
  Returns the head of a snake.

  If the snake has at least one body part, the first body part (the head) is
  returned. Otherwise, `nil` is returned.

  ## Examples

      iex> body = [Snek.Board.Point.new(1, 2), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: body}
      iex> Snake.head(snake)
      %Snek.Board.Point{x: 1, y: 2}

      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: []}
      iex> Snake.head(snake)
      nil

  """
  @doc since: "0.1.0"

  @spec head(t) :: Point.t | nil

  def head(%Snake{body: [head | _]}), do: head
  def head(%Snake{}), do: nil

  @doc """
  Moves the snake one space in a given direction.

  Moving consists of adding a body part to the head of the snake in the given
  direction, and also removing the tail body part. The snake's body length
  remains unchanged.

  If the snake is already eliminated or the snake does not have any body parts,
  no move will be applied and the snake will remain unchanged.

  If the direction given is `:left`, `:right`, or `:forward` then the snake is
  moved in that direction relative to the snake's last moved direction.

  If the direction given is `nil`, or not a valid direction in which to move,
  the snake will be moved in the `:forward` direction. If the snake does not
  have both head and neck body parts, or the head and neck are at teh same
  position, the snake will default to moving `:north` instead, as in that case
  the last moved direction cannot be extrapolated.

  Returns the modified snake.

  ## Examples

      iex> body = [Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: body}
      iex> Snake.move(snake, :north)
      %Snake{
        id: "mysnek",
        state: :alive,
        health: 100,
        body: [Snek.Board.Point.new(1, 0), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      }

      iex> body = [Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "mysnek", state: {:eliminated, :starvation}, health: 0, body: body}
      iex> snake == Snake.move(snake, :north)
      true

      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: []}
      iex> snake == Snake.move(snake, :north)
      true

      iex> body = [Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: body}
      iex> snake |> Snake.move(:east) |> Snake.move(nil)
      %Snake{
        id: "mysnek",
        state: :alive,
        health: 100,
        body: [Snek.Board.Point.new(3, 1), Snek.Board.Point.new(2, 1), Snek.Board.Point.new(1, 1)]
      }

      iex> body = [Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: body}
      iex> snake |> Snake.move(:east) |> Snake.move(:left) |> Snake.move(:right)
      %Snake{
        id: "mysnek",
        state: :alive,
        health: 100,
        body: [Snek.Board.Point.new(3, 0), Snek.Board.Point.new(2, 0), Snek.Board.Point.new(2, 1)]
      }

  """
  @doc since: "0.1.0"

  @spec move(t, snake_move | nil) :: t

  def move(%Snake{state: state} = snake, _direction) when state != :alive do
    snake
  end

  def move(%Snake{body: body} = snake, _direction) when length(body) < 1 do
    snake
  end

  def move(%Snake{body: [head | _rest]} = snake, direction) when direction in [:north, :south, :east, :west] do
    slither(snake, Point.step(head, direction))
  end

  def move(%Snake{body: [head, neck | _rest]} = snake, direction) when direction in [:forward, :left, :right] and head != neck do
    slither(snake, step(snake, direction))
  end

  def move(%Snake{body: [head, neck | _rest]} = snake, nil) when head != neck do
    slither(snake, step(snake, :forward))
  end

  def move(%Snake{body: [head | _rest]} = snake, _direction) do
    slither(snake, Point.step(head, :north))
  end

  defp slither(snake, new_head) do
    new_body = [new_head | Enum.drop(snake.body, -1)]
    %Snake{snake | body: new_body}
  end

  @doc """
  Returns the point that is one step toward a given direction from this snake's
  perspective.

  If the snake has no body parts, `nil` is returned instead of a point.

  If the direction given is `:left`, `:right`, or `:forward` then the point
  returned will be in that direction relative to the snake's last moved
  direction. If the snake does not have both head and neck body parts, or the
  head and neck are at the same position, then `nil` will be returned instead
  of a point, as in that case the last moved direction cannot be extrapolated.

  ## Examples

      iex> body = [Snek.Board.Point.new(2, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "snek0", state: :alive, health: 99, body: body}
      iex> Snake.step(snake, :north)
      %Snek.Board.Point{x: 2, y: 0}

      iex> body = [Snek.Board.Point.new(2, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "snek0", state: :alive, health: 99, body: body}
      iex> Snake.step(snake, :left)
      %Snek.Board.Point{x: 2, y: 0}

      iex> body = [Snek.Board.Point.new(2, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "snek0", state: :alive, health: 99, body: body}
      iex> Snake.step(snake, :east)
      %Snek.Board.Point{x: 3, y: 1}

      iex> body = [Snek.Board.Point.new(2, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "snek0", state: :alive, health: 99, body: body}
      iex> Snake.step(snake, :forward)
      %Snek.Board.Point{x: 3, y: 1}

      iex> body = [Snek.Board.Point.new(2, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "snek0", state: :alive, health: 99, body: body}
      iex> Snake.step(snake, :right)
      %Snek.Board.Point{x: 2, y: 2}

      iex> body = [Snek.Board.Point.new(2, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "snek0", state: :alive, health: 99, body: body}
      iex> Snake.step(snake, :south)
      %Snek.Board.Point{x: 2, y: 2}

      iex> snake = %Snake{id: "snek0", state: :alive, health: 0, body: []}
      iex> Snake.step(snake, :south)
      nil

      iex> body = [Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 1)]
      iex> snake = %Snake{id: "snek0", state: :alive, health: 100, body: body}
      iex> Snake.step(snake, :forward)
      nil

  """
  @doc since: "0.1.0-dev"
  @spec step(t, Point.direction | snake_move) :: Point.t

  def step(%Snake{body: [head, neck | _rest]}, :forward) when head != neck do
    vector = Point.difference(head, neck)
    Point.sum(head, vector)
  end

  def step(%Snake{body: [head, neck | _rest]}, :left) when head != neck do
    vector = Point.difference(head, neck) |> Point.rotate_counterclockwise
    Point.sum(head, vector)
  end

  def step(%Snake{body: [head, neck | _rest]}, :right) when head != neck do
    vector = Point.difference(head, neck) |> Point.rotate_clockwise
    Point.sum(head, vector)
  end

  def step(_snake, direction) when direction in [:forward, :left, :right] do
    nil
  end

  def step(%Snake{body: [head | _rest]}, direction) when not is_nil(head) do
    Point.step(head, direction)
  end

  def step(_snake, _direction), do: nil

  @doc """
  Decrements the snake's health by 1 point.

  Returns the modified snake.

  ## Examples

      iex> body = List.duplicate(Snek.Board.Point.new(1, 1), 3)
      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: body}
      iex> Snake.hurt(snake).health
      99

  """
  @doc since: "0.1.0"

  @spec hurt(t) :: t

  def hurt(snake) do
    %Snake{snake | health: snake.health - 1}
  end

  @doc """
  Feed a snake and grow its tail.

  A snake is fed by restoring its health to a given value, and adding a part to
  its tail. The new tail part is added in the same position as the current tail
  (the last body part). Tail body parts may overlap until the snake moves.

  Returns the modified snake.

  ## Examples

      iex> body = [Snek.Board.Point.new(1, 0), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 2)]
      iex> snake = %Snake{id: "mysnek", state: :alive, health: 98, body: body}
      iex> Snake.feed(snake, 100)
      %Snake{
        id: "mysnek",
        state: :alive,
        health: 100,
        body: [
          Snek.Board.Point.new(1, 0),
          Snek.Board.Point.new(1, 1),
          Snek.Board.Point.new(1, 2),
          Snek.Board.Point.new(1, 2)
        ]
      }

  """
  @doc since: "0.1.0"

  @spec feed(t, non_neg_integer) :: t

  def feed(snake, new_health) do
    %Snake{snake | health: new_health}
    |> grow
  end

  @doc """
  Grow a snake's tail.

  Adds a part to the snake's tail.  The new tail part is added in the same
  position as the current tail (the last body part). Tail body parts may
  overlap until the snake moves.

  This is equivelent to the tail growth in `feed/2` but without affecting the
  snake's health.

  Returns the modified snake.

  ## Examples

      iex> body = [Snek.Board.Point.new(1, 0), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 2)]
      iex> snake = %Snake{id: "mysnek", state: :alive, health: 98, body: body}
      iex> Snake.grow(snake)
      %Snake{
        id: "mysnek",
        state: :alive,
        health: 98,
        body: [
          Snek.Board.Point.new(1, 0),
          Snek.Board.Point.new(1, 1),
          Snek.Board.Point.new(1, 2),
          Snek.Board.Point.new(1, 2)
        ]
      }

      iex> snake = %Snake{id: "mysnek", state: :alive, health: 100, body: []}
      iex> snake == Snake.grow(snake)
      true

  """
  @doc since: "0.1.0"

  @spec grow(t) :: t

  def grow(snake) do
    if length(snake.body) > 0 do
      tail = Enum.at(snake.body, -1)
      new_body = snake.body ++ [tail]
      %Snake{snake | body: new_body}
    else
      snake
    end
  end

  @doc """
  Returns true if and only if the snake is alive (not eliminated).

  This does not check whether the snake's elimination status should be changed,
  it is just a helper to check current state.

  ## Examples

      iex> body = [Snek.Board.Point.new(1, 0), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 2)]
      iex> Snake.alive?(%Snake{id: "mysnek", state: :alive, health: 98, body: body})
      true

      iex> body = [Snek.Board.Point.new(1, 0), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 2)]
      iex> Snake.alive?(%Snake{id: "mysnek", state: {:eliminated, :starvation}, health: 0, body: body})
      false

  """
  @doc since: "0.1.0"

  @spec alive?(t) :: boolean

  def alive?(%Snake{state: :alive}), do: true
  def alive?(%Snake{}), do: false

  @doc """
  Returns true if and only if the snake is eliminated.

  This does not check whether the snake's elimination status should be changed,
  it is just a helper to check current state.

  ## Examples

      iex> body = [Snek.Board.Point.new(1, 0), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 2)]
      iex> Snake.eliminated?(%Snake{id: "mysnek", state: :alive, health: 98, body: body})
      false

      iex> body = [Snek.Board.Point.new(1, 0), Snek.Board.Point.new(1, 1), Snek.Board.Point.new(1, 2)]
      iex> Snake.eliminated?(%Snake{id: "mysnek", state: {:eliminated, :starvation}, health: 0, body: body})
      true

  """

  @doc since: "0.1.0"

  @spec eliminated?(t) :: boolean

  def eliminated?(%Snake{state: :alive}), do: false
  def eliminated?(%Snake{}), do: true
end
