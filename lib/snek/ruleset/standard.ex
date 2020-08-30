defmodule Snek.Ruleset.Standard do
  @moduledoc """
  The standard ruleset, based on the official Battlesnake rules.

  Effort is made to keep this implementation compatible with Battlesnake's
  official rules, so that it may be used for simulating game turns. If there is
  a mistake either in the implementation or the tests/specification, please
  report it as a bug.
  """
  @moduledoc since: "0.0.1"

  @behaviour Snek.Ruleset

  @apple_spawn_chance 0.15

  alias Snek.Board
  alias Snek.Board.{Point, Size, Snake}

  @spec init(Board.Size.t, MapSet.t(Snake.id)) :: {:ok, Board.t} | {:error, atom}

  @impl Snek.Ruleset
  def init(board_size, snake_ids) do
    empty_board = Board.new(board_size)
    snake_ids = Enum.to_list(snake_ids)

    with {:ok, board_with_snakes} <- spawn_snakes(empty_board, snake_ids),
         {:ok, board_with_snakes_and_apples} <- spawn_apples(board_with_snakes)
    do
      {:ok, board_with_snakes_and_apples}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @impl Snek.Ruleset
  def next(board, snake_moves) do
    board
    |> Board.move_snakes(snake_moves)
    |> Board.reduce_snake_healths
    |> Board.maybe_eliminate_snakes
    |> Board.maybe_feed_snakes
    |> maybe_spawn_apple
  end

  @impl Snek.Ruleset
  def done?(board) do
    Board.alive_snakes_remaining(board) <= 1
  end

  defp known_board_size?(%Size{width: 7, height: 7}), do: true
  defp known_board_size?(%Size{width: 11, height: 11}), do: true
  defp known_board_size?(%Size{width: 19, height: 19}), do: true
  defp known_board_size?(_board), do: false

  defp spawn_snakes(board, snake_ids) do
    snakes_count = length(snake_ids)
    start_points = snake_start_points(board)
    start_points_count = length(start_points)
    not_enough_space_for_snakes = snakes_count > start_points_count

    if not_enough_space_for_snakes do
      {:error, :not_enough_space_for_snakes}
    else
      random_start_points = Enum.take_random(start_points, snakes_count)

      ids_and_heads = snake_ids
      |> Enum.sort
      |> Enum.shuffle
      |> Enum.zip(random_start_points)

      case Board.spawn_snakes(board, ids_and_heads) do
        {:ok, board_with_snakes} -> {:ok, board_with_snakes}
        {:error, :occupied} ->
          {:error, :not_enough_space_for_snakes}
      end
    end
  end

  defp snake_start_points(board) do
    if known_board_size?(board.size) do
      fixed_snake_start_points(board.size)
    else
      Board.all_even_points(board)
    end
  end

  defp fixed_snake_start_points(board_size) do
    mn = 1
    md = div(board_size.width-1, 2)
    mx = board_size.width - 2

    [
      %Point{x: mn, y: mn},
      %Point{x: mn, y: md},
      %Point{x: mn, y: mx},
      %Point{x: md, y: mn},
      %Point{x: md, y: mx},
      %Point{x: mx, y: mn},
      %Point{x: mx, y: md},
      %Point{x: mx, y: mx}
    ]
  end

  defp spawn_apples(board) do
    if known_board_size?(board.size) do
      spawn_apples_fixed(board)
    else
      spawn_apples_randomly(board)
    end
  end

  defp spawn_apples_fixed(board) do
    with {:ok, board_with_center_apple} <- Board.spawn_apple_at_center(board),
         {:ok, board_with_apples} <- spawn_apples_near_snakes(board_with_center_apple)
    do
      {:ok, board_with_apples}
    else
      {:error, :occupied} -> {:error, :not_enough_space_for_apples}
      {:error, reason} -> {:error, reason}
    end
  end

  defp spawn_apples_near_snakes(board) do
    points_near_snakes = Enum.flat_map(board.snakes, fn snake ->
      head = Snake.head(snake)
      candidates = Board.unoccupied_diagonal_neighbors(board, head)

      if length(candidates) > 0 do
        random_apple = candidates
        |> Enum.sort
        |> Enum.random

        [random_apple]
      else
        []
      end
    end)

    Board.spawn_apples(board, points_near_snakes)
  end

  defp spawn_apples_randomly(board) do
    count = length(board.snakes)
    unoccupied_points = Board.unoccupied_points(board)

    random_apples = unoccupied_points
             |> Enum.sort
             |> Enum.take_random(count)

    Board.spawn_apples(board, random_apples)
  end

  defp maybe_spawn_apple(board) do
    if Enum.empty?(board.apples) || :random.uniform <= @apple_spawn_chance do
      new_apple = Board.unoccupied_points(board)
      |> Enum.sort
      |> Enum.random

      Board.spawn_apple_unchecked(board, new_apple)
    else
      board
    end
  end
end
