defmodule Snek.Board do
  @moduledoc """
  A struct for representing a board position.

  This may be used to keep track of state in a game, each turn of the
  game producing the next board position.
  """
  @moduledoc since: "0.1.0"

  alias __MODULE__
  alias Board.{Point, Size, Snake}

  @typedoc """
  A board position.
  """
  @typedoc since: "0.1.0"
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

  @typedoc """
  When spawning, `{:ok, board}` if there is space available, `{:error, :occupied}` otherwise.
  """
  @type spawn_result :: {:ok, t} | {:error, :occupied}

  @snake_default_length 3
  @snake_default_health 100

  @doc """
  Returns a new empty board of a given size.

  ## Examples

      iex> Board.new(Board.Size.small)
      %Board{size: %Board.Size{width: 7, height: 7}, apples: [], snakes: []}

  """
  @doc since: "0.1.0"
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

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple_at_center
      iex> Board.empty?(board)
      false

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake_at_center("mysnek")
      iex> Board.empty?(board)
      false

  """
  @doc since: "0.1.0"
  @spec empty?(t) :: boolean

  def empty?(%Board{apples: apples}) when length(apples) > 0, do: false
  def empty?(%Board{snakes: snakes}) when length(snakes) > 0, do: false
  def empty?(%Board{}), do: true

  @doc """
  Spawns an apple in the center of the board.

  Returns `{:ok, board}` if there is space available, returns
  `{:error, :occupied}` otherwise.

  ## Examples

      iex> {:ok, board} = Board.new(Board.Size.new(3, 3)) |> Board.spawn_apple_at_center()
      iex> board
      %Board{
        apples: [%Board.Point{x: 1, y: 1}],
        size: %Board.Size{height: 3, width: 3},
        snakes: []
      }

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple_at_center()
      iex> board |> Board.spawn_apple_at_center()
      {:error, :occupied}

  """
  @doc since: "0.1.0"
  @spec spawn_apple_at_center(t) :: spawn_result

  def spawn_apple_at_center(board) do
    spawn_apple(board, Board.center_point(board))
  end

  @doc """
  Spawns an apple at the specified point on the board.

  Returns `{:ok, board}` if there is space available, returns
  `{:error, :occupied}` otherwise.

  ## Examples

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(Board.Point.new(1, 1))
      iex> board
      %Board{
        apples: [%Board.Point{x: 1, y: 1}],
        size: %Board.Size{height: 7, width: 7},
        snakes: []
      }

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(Board.Point.new(1, 1))
      iex> board |> Board.spawn_apple(Board.Point.new(1, 1))
      {:error, :occupied}

  """
  @doc since: "0.1.0"
  @spec spawn_apple(t, Point.t) :: spawn_result

  def spawn_apple(board, point) do
    if occupied?(board, point) do
      {:error, :occupied}
    else
      next_board = %Board{board | apples: [point | board.apples]}
      {:ok, next_board}
    end
  end

  @doc """
  Spawns an apple at the specified point on the board.

  Unlike `spawn_apple/2` this function will not check whether there is space
  available. You are expected to only use this function if you are otherwise
  performing that validation yourself. For example, it may be more efficient to
  precompute available spaces before spawning many apples.

  Returns a board state with the apple added.

  ## Examples

      iex> board = Board.new(Board.Size.small) |> Board.spawn_apple_unchecked(Board.Point.new(1, 1))
      iex> board
      %Board{
        apples: [%Board.Point{x: 1, y: 1}],
        size: %Board.Size{height: 7, width: 7},
        snakes: []
      }

  """
  @doc since: "0.1.0"
  @spec spawn_apple_unchecked(t, Point.t) :: t

  def spawn_apple_unchecked(board, point) do
    %Board{board | apples: [point | board.apples]}
  end

  @doc """
  Spawns apples at each of the specified points on the board.

  Returns `{:ok, board}` if there is space available, returns
  `{:error, :occupied}` otherwise.

  ## Examples

      iex> points = [Board.Point.new(1, 1), Board.Point.new(1, 2)]
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apples(points)
      iex> board
      %Board{
        apples: [
          %Board.Point{x: 1, y: 1},
          %Snek.Board.Point{x: 1, y: 2}
        ],
        size: %Snek.Board.Size{height: 7, width: 7},
        snakes: []
      }

      iex> occupied_point = Board.Point.new(1, 1)
      iex> new_points = [occupied_point, Board.Point.new(1, 2)]
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(occupied_point)
      iex> Board.spawn_apples(board, new_points)
      {:error, :occupied}

  """
  @doc since: "0.1.0"
  @spec spawn_apples(t, list(Point.t)) :: spawn_result

  def spawn_apples(board, points) do
    if any_points_occupied?(board, points) do
      {:error, :occupied}
    else
      board = %Board{board | apples: Enum.concat(points, board.apples)}
      {:ok, board}
    end
  end

  @doc """
  Returns the point at the center of the board.

  If the board width or height are even, the center will be offset because
  boards are a discrete grid.

  ## Examples

      iex> Board.new(Board.Size.new(3, 3)) |> Board.center_point()
      %Board.Point{x: 1, y: 1}

      iex> Board.new(Board.Size.new(8, 8)) |> Board.center_point()
      %Board.Point{x: 3, y: 3}

  """
  @doc since: "0.1.0"
  @spec center_point(t) :: Point.t

  def center_point(%Board{size: %Size{width: width, height: height}}) do
    x = div(width - 1, 2)
    y = div(height - 1, 2)
    %Point{x: x, y: y}
  end

  @doc """
  Spawns a snake in the center of the board.

  Returns `{:ok, board}` if there is space available, returns
  `{:error, :occupied}` otherwise.

  ## Examples

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake_at_center("mysnek")
      iex> board.snakes
      [
        %Board.Snake{
          body: [%Board.Point{x: 3, y: 3}, %Board.Point{x: 3, y: 3}, %Board.Point{x: 3, y: 3}],
          state: :alive,
          health: 100,
          id: "mysnek"
        }
      ]

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake_at_center("mysnek")
      iex> Board.spawn_snake_at_center(board, "mysnek")
      {:error, :occupied}

  """
  @doc since: "0.1.0"
  @spec spawn_snake_at_center(t, any, non_neg_integer, non_neg_integer) :: spawn_result

  def spawn_snake_at_center(board, id, length \\ @snake_default_length, health \\ @snake_default_health) do
    head = center_point(board)
    spawn_snake(board, id, head, length, health)
  end

  @doc """
  Spawns multiple snakes, each at a specified point on the board.

  Returns `{:ok, board}` if there is space available, returns
  `{:error, :occupied}` otherwise.

  ## Examples

      iex> ids_and_heads = [{"snek1", Board.Point.new(1, 1)}, {"snek2", Board.Point.new(5, 5)}]
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snakes(ids_and_heads)
      iex> board.snakes
      [
        %Board.Snake{
          body: [%Board.Point{x: 5, y: 5}, %Board.Point{x: 5, y: 5}, %Board.Point{x: 5, y: 5}],
          state: :alive,
          health: 100,
          id: "snek2"
        },
        %Board.Snake{
          body: [%Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}],
          state: :alive,
          health: 100,
          id: "snek1"
        }
      ]

      iex> ids_and_heads = [{"snek1", Board.Point.new(1, 1)}, {"snek2", Board.Point.new(1, 1)}]
      iex> Board.new(Board.Size.small) |> Board.spawn_snakes(ids_and_heads)
      {:error, :occupied}

  """
  @doc since: "0.1.0"
  @spec spawn_snakes(t, list({Snake.id, Point.t}), non_neg_integer, non_neg_integer) :: spawn_result

  def spawn_snakes(board, ids_and_heads, length \\ @snake_default_length, health \\ @snake_default_health)

  def spawn_snakes(board, [], _length, _health) do
    {:ok, board}
  end

  def spawn_snakes(board, [{snake_id, head} | rest_of_ids_and_heads], length, health) do
    case Board.spawn_snake(board, snake_id, head, length, health) do
      {:ok, next_board} -> spawn_snakes(next_board, rest_of_ids_and_heads, length, health)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Spawns a snake at the specified point on the board.

  Returns `{:ok, board}` if there is space available, returns
  `{:error, :occupied}` otherwise.

  ## Examples

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake("mysnek", Board.Point.new(1, 1))
      iex> board.snakes
      [
        %Board.Snake{
          body: [%Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}],
          state: :alive,
          health: 100,
          id: "mysnek"
        }
      ]

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake("mysnek", Board.Point.new(1, 1))
      iex> Board.spawn_snake(board, "mysnek", Board.Point.new(1, 1))
      {:error, :occupied}

  """
  @doc since: "0.1.0"
  @spec spawn_snake(t, any, Point.t, non_neg_integer, non_neg_integer) :: spawn_result

  def spawn_snake(board, id, head, length \\ @snake_default_length, health \\ @snake_default_health) do
    if occupied?(board, head) do
      {:error, :occupied}
    else
      snake = %Snake{
        id: id,
        state: :alive,
        health: health,
        body: List.duplicate(head, length)
      }

      board = %Board{board | snakes: [snake | board.snakes]}

      {:ok, board}
    end
  end

  @doc """
  Moves each snake on the board according to their respective moves for this
  turn.

  Snakes move by slithering by one space per turn, in other words stepping in
  one direction by adding a new head part and removing a tail part.

  If `nil` is provided as a move, the snake will by default continue moving in
  the last moved direction. If the snake has not yet moved at all since
  spawning, it will default to moving `:north`.

  Snakes that have already been eliminated will not be moved.

  Returns a board with all moves applied.

  ## Examples

      iex> board0 = Board.new(Board.Size.small)
      iex> {:ok, board1} = Board.spawn_snakes(board0, [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(5, 5)}])
      iex> board2 = Board.move_snakes(board1, [{"snek0", :east}, {"snek1", nil}])
      iex> board2.snakes
      [
        %Board.Snake{
          body: [%Board.Point{x: 5, y: 4}, %Board.Point{x: 5, y: 5}, %Board.Point{x: 5, y: 5}],
          state: :alive,
          health: 100,
          id: "snek1"
        },
        %Board.Snake{
          body: [%Board.Point{x: 2, y: 1}, %Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}],
          state: :alive,
          health: 100,
          id: "snek0"
        }
      ]

  """
  @doc since: "0.1.0"
  @spec move_snakes(t, list({Snake.id, Snake.snake_move | nil})) :: t

  def move_snakes(board, snake_moves)

  def move_snakes(board, []) do
    board
  end

  def move_snakes(board, [{snake_id, direction} | rest_of_snake_moves]) do
    next_board = Board.move_snake(board, snake_id, direction)
    move_snakes(next_board, rest_of_snake_moves)
  end

  @doc """
  Moves a snake on the board according to its move for this turn.

  A snake moves by slithering by one space per turn, in other words stepping in
  one direction by adding a new head part and removing a tail part.

  If `nil` is provided as the move, the snake will by default continue moving in
  the last moved direction. If the snake has not yet moved at all since
  spawning, it will default to moving `:north`.

  A snake that is already eliminated will not be moved.

  Returns a board with this snake's move applied.

  ## Examples

      iex> board0 = Board.new(Board.Size.small)
      iex> {:ok, board1} = Board.spawn_snake(board0, "snek0", Board.Point.new(1, 1))
      iex> board2 = Board.move_snake(board1, "snek0", :east)
      iex> board2.snakes
      [
        %Board.Snake{
          body: [%Board.Point{x: 2, y: 1}, %Board.Point{x: 1, y: 1}, %Board.Point{x: 1, y: 1}],
          state: :alive,
          health: 100,
          id: "snek0"
        }
      ]

  """
  @doc since: "0.1.0"
  @spec move_snake(t, Snake.id, Snake.snake_move | nil) :: t

  def move_snake(board, snake_id, direction) do
    next_snakes = Enum.map(board.snakes, fn snake ->
      if snake.id == snake_id do
        Snake.move(snake, direction)
      else
        snake
      end
    end)

    %Board{board | snakes: next_snakes}
  end

  @doc """
  Reduce the health of each snake by one point.

  Does not affect the health of eliminated snakes.

  Returns a board with all snake health reductions applied.

  ## Examples

      iex> apple = Board.Point.new(1, 4)
      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 5)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_apple(apple)
      iex> {:ok, board1} = Board.spawn_snakes(board0, ids_and_heads)
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :north}])
      iex> board3 = Board.maybe_feed_snakes(board2)
      iex> board4 = Board.move_snakes(board3, [{"snek0", :south}, {"snek1", :north}])
      iex> board5 = Board.maybe_eliminate_snakes(board4)
      iex> board6 = Board.reduce_snake_healths(board5)
      iex> snek0 = board6.snakes |> Enum.find(&(&1.id == "snek0"))
      iex> snek1 = board6.snakes |> Enum.find(&(&1.id == "snek1"))
      iex> snek0.health # Eliminated before reducing health
      100
      iex> snek1.health # Not eliminiated
      99

  """
  @doc since: "0.1.0"
  @spec reduce_snake_healths(t) :: t

  def reduce_snake_healths(board) do
    next_snakes = Enum.map(board.snakes, fn snake ->
      if Snake.eliminated?(snake) do
        snake
      else
        Snake.hurt(snake)
      end
    end)

    %Board{board | snakes: next_snakes}
  end

  @doc """
  Eliminate snakes who have moved out of bounds, collided with themselves,
  collided with other snake bodies, or lost in a head-to-head collision.

  Eliminations are decided by `maybe_eliminate_snake/3` for each snake, giving
  priority to longer snakes in in ambiguous collisions.

  Snakes that are already eliminated will remain unchanged, and snakes will not
  be eliminated by colliding with another snake that has previously been
  eliminated itself.

  ## Examples

      iex> apple = Board.Point.new(1, 4)
      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 5)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_apple(apple)
      iex> {:ok, board1} = Board.spawn_snakes(board0, ids_and_heads)
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :north}])
      iex> board3 = Board.maybe_feed_snakes(board2)
      iex> board4 = Board.move_snakes(board3, [{"snek0", :south}, {"snek1", :north}])
      iex> board5 = Board.maybe_eliminate_snakes(board4)
      iex> board6 = Board.reduce_snake_healths(board5)
      iex> snek0 = board6.snakes |> Enum.find(&(&1.id == "snek0"))
      iex> snek1 = board6.snakes |> Enum.find(&(&1.id == "snek1"))
      iex> snek0.state
      {:eliminated, :head_to_head, "snek1"}
      iex> snek1.state
      :alive

  """
  @doc since: "0.1.0"
  @spec maybe_eliminate_snakes(t) :: t

  def maybe_eliminate_snakes(board) do
    alive_snakes = Enum.filter(board.snakes, &Snake.alive?/1)

    snakes_by_length_descending = Enum.sort_by(alive_snakes, fn snake ->
      {length(snake.body), snake.id}
    end)

    next_snakes = Enum.map(board.snakes, fn snake ->
      maybe_eliminate_snake(board, snake, snakes_by_length_descending)
    end)

    %Board{board | snakes: next_snakes}
  end

  @doc """
  Eliminate this snake if it has moved out of bounds, collided with itself,
  collided with another snake body, or lost in a head-to-head collision.

  If the snake is already previously eliminated, it will be returned unchanged
  regardless of any new collisions.

  Pass the `snakes_by_length_descending` argument as an ordered list of all
  snakes such that ambiguous collisions will be tied by snakes which appear
  first in the list. For example, if longer snakes should be considered first,
  pass a list of all snakes ordered by their respective lengths descending.

  Snakes that are already eliminated will remain unchanged, and snakes will not
  be eliminated by colliding with another snake that has previously been
  eliminated itself.

  # Examples

      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 3)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_snakes(ids_and_heads)
      iex> board1 = Board.move_snakes(board0, [{"snek0", :south}, {"snek1", :east}])
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :east}])
      iex> snek0 = board2.snakes |> Enum.find(&(&1.id == "snek0"))
      iex> snek0_eliminated = Board.maybe_eliminate_snake(board2, snek0, board2.snakes)
      iex> snek0_eliminated.state
      {:eliminated, :collision, "snek1"}
      iex> snek0_double_eliminated = Board.maybe_eliminate_snake(board2, snek0_eliminated, board2.snakes)
      iex> snek0_double_eliminated == snek0_eliminated
      true

      iex> start_length = 3
      iex> start_health = 1
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_snake("snek0", Board.Point.new(1, 1), start_length, start_health)
      iex> board1 = Board.reduce_snake_healths(board0)
      iex> [snek0 | _] = board1.snakes
      iex> snek0_eliminated = Board.maybe_eliminate_snake(board1, snek0, board1.snakes)
      iex> snek0_eliminated.state
      {:eliminated, :starvation}

  """
  @doc since: "0.1.0"
  @spec maybe_eliminate_snake(t, Snake.t, list(Snake.t)) :: t

  def maybe_eliminate_snake(_board, %Snake{state: state} = snake, _snakes_by_length_descending) when state != :alive do
    snake
  end

  def maybe_eliminate_snake(_board, %Snake{health: health} = snake, _snakes_by_length_descending) when health <= 0 do
    %Snake{snake | state: {:eliminated, :starvation}}
  end

  def maybe_eliminate_snake(board, snake, snakes_by_length_descending) do
    next_state = cond do
      Board.snake_out_of_bounds?(board, snake) ->
        {:eliminated, :out_of_bounds}
      Board.snake_collides_with_other_snake?(snake, snake) ->
        {:eliminated, :self_collision}
      true ->
        body_collision_other_snake = Enum.find(snakes_by_length_descending, fn other_snake ->
          other_snake.id != snake.id && Board.snake_collides_with_other_snake?(snake, other_snake)
        end)

        if is_nil(body_collision_other_snake) do
          head_collision_other_snake = Enum.find(snakes_by_length_descending, fn other_snake ->
            other_snake.id != snake.id && Board.snake_loses_head_to_head_collision?(snake, other_snake)
          end)

          if is_nil(head_collision_other_snake) do
            snake.state
          else
            {:eliminated, :head_to_head, head_collision_other_snake.id}
          end
        else
          {:eliminated, :collision, body_collision_other_snake.id}
        end
    end

    %Snake{snake | state: next_state}
  end

  @doc """
  Feed snakes who eat an apple.

  For all apples on the board, if any snake eats it, remove the apple from the
  board and feed each snake who ate it.

  A snake eats an apple if the snake's head is at the same position as the
  apple, and the snake is alive (not eliminated), and the snake has at least
  one body part.

  Feeding a snake is defined by `Snek.Board.Snake.feed/2`.

  Returns the modified board state.

  ## Examples

      iex> apple = Board.Point.new(1, 4)
      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 5)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_apple(apple)
      iex> {:ok, board1} = Board.spawn_snakes(board0, ids_and_heads)
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :north}])
      iex> board3 = Board.maybe_feed_snakes(board2)
      iex> snek0 = board3.snakes |> Enum.find(&(&1.id == "snek0"))
      iex> snek1 = board3.snakes |> Enum.find(&(&1.id == "snek1"))
      iex> length(snek0.body)
      3
      iex> length(snek1.body)
      4

      iex> apple = Board.Point.new(1, 4)
      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 5)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_apple(apple)
      iex> {:ok, board1} = Board.spawn_snakes(board0, ids_and_heads)
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :east}])
      iex> board3 = Board.maybe_feed_snakes(board2)
      iex> snek0 = board3.snakes |> Enum.find(&(&1.id == "snek0"))
      iex> snek1 = board3.snakes |> Enum.find(&(&1.id == "snek1"))
      iex> length(snek0.body)
      3
      iex> length(snek1.body)
      3
      iex> board3 == board2
      true

  """
  @doc since: "0.1.0"
  @spec maybe_feed_snakes(t) :: t

  def maybe_feed_snakes(board) do
    alive_snakes = Enum.filter(board.snakes, fn snake ->
      Snake.alive?(snake) && length(snake.body) > 0
    end)

    Enum.reduce(board.apples, board, fn apple, previous_board ->
      snakes_who_ate = Enum.filter(alive_snakes, fn snake ->
        Snake.head(snake) == apple
      end)

      if Enum.empty?(snakes_who_ate) do
        previous_board
      else
        next_apples = List.delete(previous_board.apples, apple)
        next_snakes = Enum.map(previous_board.snakes, fn snake ->
          snake_ate = Enum.any?(snakes_who_ate, fn snake_who_ate ->
            snake.id == snake_who_ate.id
          end)

          if snake_ate do
            Snake.feed(snake, @snake_default_health)
          else
            snake
          end
        end)

        %Board{previous_board | apples: next_apples, snakes: next_snakes}
      end
    end)
  end

  @doc """
  Returns true if and only if the given point on the board is occupied,
  otherwise false.

  A point may be occupied by an apple, or any snake's body part.

  ## Examples

      iex> Board.new(Board.Size.small) |> Board.occupied?(Board.Point.new(1, 3))
      false

      iex> point = Board.Point.new(1, 3)
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(point)
      iex> Board.occupied?(board, point)
      true

      iex> point = Board.Point.new(1, 3)
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake("mysnek", point)
      iex> Board.occupied?(board, point)
      true

  """
  @doc since: "0.1.0"
  @spec occupied?(t, Point.t) :: boolean

  def occupied?(board, point) do
    occupied_by_apple?(board, point) || occupied_by_snake?(board, point)
  end

  @doc """
  Returns true if and only if any of the given points on the board are occupied.

  A point may be occupied by an apple, or any snake's body part.

  ## Examples

      iex> board = Board.new(Board.Size.small)
      iex> board |> Board.any_points_occupied?([Board.Point.new(1, 3), Board.Point.new(0, 0)])
      false

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(Board.Point.new(1, 3))
      iex> board |> Board.any_points_occupied?([Board.Point.new(1, 3), Board.Point.new(0, 0)])
      true

  """
  @doc since: "0.1.0"
  @spec any_points_occupied?(t, list(Point.t)) :: boolean

  def any_points_occupied?(board, points) do
    Enum.any?(points, &(occupied?(board, &1)))
  end

  @doc """
  Returns true if and only if the given point on the board is occupied by an
  apple, otherwise false.

  ## Examples

      iex> Board.new(Board.Size.small) |> Board.occupied_by_apple?(Board.Point.new(1, 3))
      false

      iex> point = Board.Point.new(1, 3)
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(point)
      iex> Board.occupied_by_apple?(board, point)
      true

      iex> point = Board.Point.new(1, 3)
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake("mysnek", point)
      iex> Board.occupied_by_apple?(board, point)
      false

  """
  @doc since: "0.1.0"
  @spec occupied_by_apple?(t, Point.t) :: boolean

  def occupied_by_apple?(board, point) do
    Enum.member?(board.apples, point)
  end

  @doc """
  Returns true if and only if the given point on the board is occupied by a
  snake's body part, otherwise false.

  ## Examples

      iex> Board.new(Board.Size.small) |> Board.occupied_by_snake?(Board.Point.new(1, 3))
      false

      iex> point = Board.Point.new(1, 3)
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(point)
      iex> Board.occupied_by_snake?(board, point)
      false

      iex> point = Board.Point.new(1, 3)
      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_snake("mysnek", point)
      iex> Board.occupied_by_snake?(board, point)
      true

  """
  @doc since: "0.1.0"
  @spec occupied_by_snake?(t, Point.t) :: boolean

  def occupied_by_snake?(board, point) do
    Enum.any?(board.snakes, fn snake ->
      Enum.member?(snake.body, point)
    end)
  end

  @doc """
  Returns a list of all points on the board.

  ## Examples

      iex> Board.new(Board.Size.new(2, 2)) |> Board.all_points
      [
        %Board.Point{x: 0, y: 0},
        %Board.Point{x: 0, y: 1},
        %Board.Point{x: 1, y: 0},
        %Board.Point{x: 1, y: 1}
      ]

  """
  @doc since: "0.1.0"
  @spec all_points(t) :: list(Point.t)

  def all_points(board) do
    xs = 0..board.size.width-1
    ys = 0..board.size.height-1

    for x <- xs, y <- ys do
      %Point{x: x, y: y}
    end
  end

  @doc """
  Returns a list of all even points on the board, alternating like a
  checkerboard.

  ## Examples

      iex> Board.new(Board.Size.new(3, 3)) |> Board.all_even_points
      [
        %Board.Point{x: 0, y: 0},
        %Board.Point{x: 0, y: 2},
        %Board.Point{x: 1, y: 1},
        %Board.Point{x: 2, y: 0},
        %Board.Point{x: 2, y: 2}
      ]

  """
  @doc since: "0.1.0"
  @spec all_even_points(t) :: list(Point.t)

  def all_even_points(board) do
    board
    |> all_points
    |> Enum.filter(&Point.even?/1)
  end

  @doc """
  Returns a list of all unoccupied points on the board.

  ## Examples

      iex> apple = Board.Point.new(0, 1)
      iex> {:ok, board} = Board.new(Board.Size.new(2, 2)) |> Board.spawn_apple(apple)
      iex> Board.unoccupied_points(board)
      [
        %Board.Point{x: 0, y: 0},
        %Board.Point{x: 1, y: 0},
        %Board.Point{x: 1, y: 1}
      ]

  """
  @doc since: "0.1.0"
  @spec unoccupied_points(t) :: list(Point.t)

  def unoccupied_points(board) do
    board
    |> all_points()
    |> Enum.reject(&(occupied?(board, &1)))
  end

  @doc """
  Returns a list of all occupied points on the board.

  ## Examples

      iex> apple = Board.Point.new(0, 1)
      iex> {:ok, board} = Board.new(Board.Size.new(2, 2)) |> Board.spawn_apple(apple)
      iex> Board.occupied_points(board)
      [
        %Board.Point{x: 0, y: 1}
      ]

  """
  @doc since: "0.1.0"
  @spec occupied_points(t) :: list(Point.t)

  def occupied_points(board) do
    board
    |> all_points()
    |> Enum.filter(&(occupied?(board, &1)))
  end

  @doc """
  Returns a list of neighboring points adjascent to a point of origin.

  This excludes points that are outside of the board's boundaries.

  ## Examples

      iex> board = Board.new(Board.Size.small)
      iex> board |> Board.adjascent_neighbors(Board.Point.new(1, 1))
      [
        %Board.Point{x: 1, y: 0},
        %Board.Point{x: 1, y: 2},
        %Board.Point{x: 2, y: 1},
        %Board.Point{x: 0, y: 1}
      ]

      iex> board = Board.new(Board.Size.small)
      iex> board |> Board.adjascent_neighbors(Board.Point.new(0, 0))
      [
        %Board.Point{x: 0, y: 1},
        %Board.Point{x: 1, y: 0}
      ]

      iex> board = Board.new(Board.Size.new(3, 3))
      iex> board |> Board.adjascent_neighbors(Board.Point.new(2, 2))
      [
        %Board.Point{x: 2, y: 1},
        %Board.Point{x: 1, y: 2}
      ]

  """
  @doc since: "0.1.0"
  @spec adjascent_neighbors(t, Point.t) :: list(Point.t)

  def adjascent_neighbors(board, origin) do
    Point.adjascent_neighbors(origin)
    |> Enum.filter(&(within_bounds?(board, &1)))
  end

  @doc """
  Returns a list of unoccupied neighboring points adjascent to a point of
  origin.

  This excludes any points occupied by an apple, or any snake's body part.

  This excludes points that are outside of the board's boundaries.

  ## Examples

      iex> board = Board.new(Board.Size.small)
      iex> board |> Board.unoccupied_adjascent_neighbors(Board.Point.new(1, 1))
      [
        %Board.Point{x: 1, y: 0},
        %Board.Point{x: 1, y: 2},
        %Board.Point{x: 2, y: 1},
        %Board.Point{x: 0, y: 1}
      ]

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(Board.Point.new(1, 2))
      iex> board |> Board.unoccupied_adjascent_neighbors(Board.Point.new(1, 1))
      [
        %Board.Point{x: 1, y: 0},
        %Board.Point{x: 2, y: 1},
        %Board.Point{x: 0, y: 1}
      ]

  """
  @doc since: "0.1.0"
  @spec unoccupied_adjascent_neighbors(t, Point.t) :: list(Point.t)

  def unoccupied_adjascent_neighbors(board, origin) do
    adjascent_neighbors(board, origin)
    |> Enum.reject(&(occupied?(board, &1)))
  end

  @doc """
  Returns a list of neighboring points diagonal to a point of origin.

  This excludes points that are outside of the board's boundaries.

  ## Examples

      iex> board = Board.new(Board.Size.small)
      iex> board |> Board.diagonal_neighbors(Board.Point.new(1, 1))
      [
        %Board.Point{x: 0, y: 0},
        %Board.Point{x: 2, y: 0},
        %Board.Point{x: 2, y: 2},
        %Board.Point{x: 0, y: 2}
      ]

      iex> board = Board.new(Board.Size.small)
      iex> board |> Board.diagonal_neighbors(Board.Point.new(0, 0))
      [%Board.Point{x: 1, y: 1}]

      iex> board = Board.new(Board.Size.new(3, 3))
      iex> board |> Board.diagonal_neighbors(Board.Point.new(2, 2))
      [%Board.Point{x: 1, y: 1}]

  """
  @doc since: "0.1.0"
  @spec diagonal_neighbors(t, Point.t) :: list(Point.t)

  def diagonal_neighbors(board, origin) do
    Point.diagonal_neighbors(origin)
    |> Enum.filter(&(within_bounds?(board, &1)))
  end

  @doc """
  Returns a list of unoccupied neighboring points diagonal to a point of
  origin.

  This excludes any points occupied by an apple, or any snake's body part.

  This excludes points that are outside of the board's boundaries.

  ## Examples

      iex> board = Board.new(Board.Size.small)
      iex> board |> Board.unoccupied_diagonal_neighbors(Board.Point.new(1, 1))
      [
        %Board.Point{x: 0, y: 0},
        %Board.Point{x: 2, y: 0},
        %Board.Point{x: 2, y: 2},
        %Board.Point{x: 0, y: 2}
      ]

      iex> {:ok, board} = Board.new(Board.Size.small) |> Board.spawn_apple(Board.Point.new(0, 0))
      iex> board |> Board.unoccupied_diagonal_neighbors(Board.Point.new(1, 1))
      [
        %Board.Point{x: 2, y: 0},
        %Board.Point{x: 2, y: 2},
        %Board.Point{x: 0, y: 2}
      ]

  """
  @doc since: "0.1.0"
  @spec unoccupied_diagonal_neighbors(t, Point.t) :: list(Point.t)

  def unoccupied_diagonal_neighbors(board, origin) do
    diagonal_neighbors(board, origin)
    |> Enum.reject(&(occupied?(board, &1)))
  end

  @doc """
  Returns true if and only if this point is within the board's boundaries,
  otherwise false.

  ## Examples

      iex> board = Board.new(Board.Size.new(3, 3))
      iex> board |> Board.within_bounds?(Board.Point.new(0, 0))
      true
      iex> board |> Board.within_bounds?(Board.Point.new(1, 2))
      true
      iex> board |> Board.within_bounds?(Board.Point.new(-1, 0))
      false
      iex> board |> Board.within_bounds?(Board.Point.new(0, 3))
      false

  """
  @doc since: "0.1.0"
  @spec within_bounds?(t, Point.t) :: boolean

  def within_bounds?(board, %Point{x: x, y: y}) do
    x_bounds = 0..board.size.width-1
    y_bounds = 0..board.size.height-1
    Enum.member?(x_bounds, x) && Enum.member?(y_bounds, y)
  end

  @doc """
  Returns true if and only if this point is outside of the board's boundaries,
  in other words the opposite of `within_bounds?/2`.

  ## Examples

      iex> board = Board.new(Board.Size.new(3, 3))
      iex> board |> Board.out_of_bounds?(Board.Point.new(0, 0))
      false
      iex> board |> Board.out_of_bounds?(Board.Point.new(1, 2))
      false
      iex> board |> Board.out_of_bounds?(Board.Point.new(-1, 0))
      true
      iex> board |> Board.out_of_bounds?(Board.Point.new(0, 3))
      true

  """
  @doc since: "0.1.0"
  @spec out_of_bounds?(t, Point.t) :: boolean

  def out_of_bounds?(board, point) do
    !within_bounds?(board, point)
  end

  @doc """
  Returns true if and only if this snake has some body part outside of the
  board's boundaries.

  ## Examples

      iex> {:ok, board} = Board.new(Board.Size.new(3, 3)) |> Board.spawn_snake("mysnek", Board.Point.new(1, 1))
      iex> [snake | _] = board.snakes
      iex> Board.snake_out_of_bounds?(board, snake)
      false

      iex> {:ok, board} = Board.new(Board.Size.new(3, 3)) |> Board.spawn_snake("mysnek", Board.Point.new(0, 3))
      iex> [snake | _] = board.snakes
      iex> Board.snake_out_of_bounds?(board, snake)
      true

  """
  @doc since: "0.1.0"
  @spec snake_out_of_bounds?(t, Snake.t) :: boolean

  def snake_out_of_bounds?(board, snake) do
    Enum.any?(snake.body, fn bodypart ->
      out_of_bounds?(board, bodypart)
    end)
  end

  @doc """
  Returns true if and only if `snake_a`'s head is in collision with any of
  `snake_b`'s body parts, excluding `snake_b`'s head. Otherwise, returns false.

  The two snake arguments commutative. One snake my collide with
  another snake's body, and yet the other snake's head may not be in a
  collision.

  As such, head-to-head collisions are not detected this way. For that, use
  `snake_loses_head_to_head_collision?/2` instead.

  ## Examples

      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 3)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_snakes(ids_and_heads)
      iex> board1 = Board.move_snakes(board0, [{"snek0", :south}, {"snek1", :east}])
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :east}])
      iex> snek0 = board2.snakes |> Enum.find(&(&1.id == "snek0"))
      iex> snek1 = board2.snakes |> Enum.find(&(&1.id == "snek1"))
      iex> Board.snake_collides_with_other_snake?(snek0, snek1)
      true
      iex> Board.snake_collides_with_other_snake?(snek1, snek0)
      false

  """
  @doc since: "0.1.0"
  @spec snake_collides_with_other_snake?(Snake.t, Snake.t) :: boolean

  def snake_collides_with_other_snake?(snake_a, snake_b) do
    case Snake.head(snake_a) do
      nil -> false
      head -> Enum.any?(Enum.drop(snake_b.body, 1), &(&1 == head))
    end
  end

  @doc """
  Returns true if and only if there is a head-to-head collision between
  `snake_a` and `snake_b` and `snake_a`'s body length is shorter or equal to
  `snake_b`'s body length, thereby causing `snake_a` to lose the head-to-head.

  ## Examples

      iex> apple = Board.Point.new(1, 4)
      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 5)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_apple(apple)
      iex> {:ok, board1} = Board.spawn_snakes(board0, ids_and_heads)
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :north}])
      iex> board3 = Board.maybe_feed_snakes(board2)
      iex> board4 = Board.move_snakes(board3, [{"snek0", :south}, {"snek1", :north}])
      iex> snek0 = board4.snakes |> Enum.find(&(&1.id == "snek0"))
      iex> snek1 = board4.snakes |> Enum.find(&(&1.id == "snek1"))
      iex> Board.snake_loses_head_to_head_collision?(snek0, snek1)
      true
      iex> Board.snake_loses_head_to_head_collision?(snek1, snek0)
      false

  """
  @doc since: "0.1.0"
  @spec snake_loses_head_to_head_collision?(Snake.t, Snake.t) :: boolean

  def snake_loses_head_to_head_collision?(snake_a, snake_b) do
    if Snake.head(snake_a) == Snake.head(snake_b) do
      length(snake_a.body) <= length(snake_b.body)
    else
      false
    end
  end

  @doc """
  Returns the number of snakes on the board who are still alive (not
  eliminated).

  ## Examples

      iex> apple = Board.Point.new(1, 4)
      iex> ids_and_heads = [{"snek0", Board.Point.new(1, 1)}, {"snek1", Board.Point.new(1, 5)}]
      iex> {:ok, board0} = Board.new(Board.Size.small) |> Board.spawn_apple(apple)
      iex> {:ok, board1} = Board.spawn_snakes(board0, ids_and_heads)
      iex> board2 = Board.move_snakes(board1, [{"snek0", :south}, {"snek1", :north}])
      iex> board3 = Board.maybe_feed_snakes(board2)
      iex> board4 = Board.move_snakes(board3, [{"snek0", :south}, {"snek1", :north}])
      iex> board5 = Board.maybe_eliminate_snakes(board4)
      iex> Board.alive_snakes_remaining(board5)
      1

  """
  @doc since: "0.1.0"
  @spec alive_snakes_remaining(t) :: non_neg_integer

  def alive_snakes_remaining(%Board{snakes: snakes}) do
    snakes
    |> Enum.filter(&Snake.alive?/1)
    |> Enum.count
  end
end
