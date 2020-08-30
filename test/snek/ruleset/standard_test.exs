defmodule StandardRulesetTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Snek.Board
  alias Snek.Board.{Point, Size, Snake}
  alias Snek.Ruleset.Standard

  doctest Standard, import: true

  @standard_board_sizes [Size.small, Size.medium, Size.large]
  @standard_snakes_per_game 1..8

  @custom_board_size_range 3..25
  @custom_snakes_per_game 1..5

  @fixed_8_snake_ids [
    "snek1",
    "snek2",
    "snek3",
    "snek4",
    "snek5",
    "snek6",
    "snek7",
    "snek8"
  ]

  @snake_move_directions [:north, :south, :east, :west]

  def setup_for_standard_board_sizes(_context) do
    %{
      board_sizes: StreamData.member_of(@standard_board_sizes),
      snake_ids: StreamData.uniq_list_of(StreamData.string(:alphanumeric), length: @standard_snakes_per_game)
    }
  end

  def setup_for_custom_board_sizes(_context) do
    range = StreamData.integer(@custom_board_size_range)

    board_sizes = ExUnitProperties.gen all width <- range, height <- range do
      Size.new(width, height)
    end

    custom_board_sizes = StreamData.filter(board_sizes, &(&1 not in @standard_board_sizes))

    %{
      board_sizes: custom_board_sizes,
      snake_ids: StreamData.uniq_list_of(StreamData.string(:alphanumeric), length: @custom_snakes_per_game)
    }
  end

  describe "init/2 for standard board sizes" do
    setup :setup_for_standard_board_sizes

    property "initializes a board of the given size", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)
        assert board.size == board_size
      end
    end

    property "spawns exactly one snake per snake ID", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)
        assert length(board.snakes) == length(snake_ids)
      end
    end

    property "spawns snakes with unique snake IDs", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        unique_snakes = Enum.uniq_by(board.snakes, &(&1.id))

        assert length(board.snakes) == length(unique_snakes)
      end
    end

    property "all snakes start with a body length of 3", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, fn snake ->
          length(snake.body) == 3
        end)
      end
    end

    property "all snakes start with body parts stacked at the same point", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, fn snake ->
          length(Enum.uniq(snake.body)) == 1
        end)
      end
    end

    property "all snakes start off as alive (not eliminated)", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, &Snake.alive?/1)
      end
    end

    property "spawns at least one apple", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)
        assert Enum.any?(board.apples)
      end
    end

    property "spawns an apple within 2 moves of each snake plus one apple in the center of the board", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        center = Board.center_point(board)

        assert Board.occupied_by_apple?(board, center)
        assert length(board.apples) == 1 + length(board.snakes)

        assert Enum.all?(board.snakes, fn snake ->
          snake_head = Snake.head(snake)
          Enum.any?(board.apples, fn apple ->
            Point.manhattan_distance(snake_head, apple) == 2
          end)
        end)
      end
    end

    property "never spawns snakes or apples such that more than one occupy the same point", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        occupied_points = Board.occupied_points(board)
        unique_occupied_points = Enum.uniq(occupied_points)

        assert length(occupied_points) == length(unique_occupied_points)
      end
    end
  end

  describe "init/2 for custom board sizes" do
    setup :setup_for_custom_board_sizes

    property "initializes a board of the given size", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)
        assert board.size == board_size
      end
    end

    property "spawns exactly one snake per ID", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)
        assert length(board.snakes) == length(snake_ids)
      end
    end

    property "spawns snakes with unique snake IDs", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        unique_snakes = Enum.uniq_by(board.snakes, &(&1.id))

        assert length(board.snakes) == length(unique_snakes)
      end
    end

    property "all snakes start with a body length of 3", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, fn snake ->
          length(snake.body) == 3
        end)
      end
    end

    property "all snakes start with body parts stacked at the same point", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, fn snake ->
          length(Enum.uniq(snake.body)) == 1
        end)
      end
    end

    property "all snakes start off as alive (not eliminated)", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, &Snake.alive?/1)
      end
    end

    property "spawns at least one apple", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)
        assert Enum.any?(board.apples)
      end
    end

    property "spawns a number of apples not exceeding the number of snakes", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)
        assert length(board.apples) <= length(board.snakes)
      end
    end

    property "never spawns snakes or apples such that more than one occupy the same point", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        occupied_points = Board.occupied_points(board)
        unique_occupied_points = Enum.uniq(occupied_points)

        assert length(occupied_points) == length(unique_occupied_points)
      end
    end
  end

  describe "next/2 for standard board sizes with 8 snakes after the first turn" do
    setup :setup_for_standard_board_sizes

    property "all alive snakes still have a body length of at least 3", context do
      check all board_size <- context.board_sizes,
        {:ok, board0} <- StreamData.constant(Standard.init(board_size, @fixed_8_snake_ids)),
        moves1 <- StreamData.list_of(StreamData.member_of(@snake_move_directions), length: 8),
        snake_moves1 <- StreamData.constant(Enum.zip(@fixed_8_snake_ids, moves1)),
        board1 <- StreamData.constant(Standard.next(board0, snake_moves1))
      do
        alive_snakes = Enum.filter(board1.snakes, &Snake.alive?/1)

        assert Enum.all?(alive_snakes, fn snake ->
          length(snake.body) >= 3
        end)
      end
    end

    property "all alive snakes have moved their heads", context do
      check all board_size <- context.board_sizes,
        {:ok, board0} <- StreamData.constant(Standard.init(board_size, @fixed_8_snake_ids)),
        moves1 <- StreamData.list_of(StreamData.member_of(@snake_move_directions), length: 8),
        snake_moves1 <- StreamData.constant(Enum.zip(@fixed_8_snake_ids, moves1)),
        board1 <- StreamData.constant(Standard.next(board0, snake_moves1))
      do
        alive_snakes = Enum.filter(board1.snakes, &Snake.alive?/1)

        assert Enum.all?(alive_snakes, fn snake ->
          previous_snake = Enum.find(board0.snakes, &(&1.id == snake.id))

          Snake.head(snake) != Snake.head(previous_snake)
        end)
      end
    end

    property "all snakes still have the same middle body as they did on the previous turn (only heads/tails may change)", context do
      check all board_size <- context.board_sizes,
        {:ok, board0} <- StreamData.constant(Standard.init(board_size, @fixed_8_snake_ids)),
        moves1 <- StreamData.list_of(StreamData.member_of(@snake_move_directions), length: 8),
        snake_moves1 <- StreamData.constant(Enum.zip(@fixed_8_snake_ids, moves1)),
        board1 <- StreamData.constant(Standard.next(board0, snake_moves1))
      do
        assert Enum.all?(board1.snakes, fn snake ->
          [_head | rest] = snake.body
          middle = Enum.uniq(rest)

          previous_snake = Enum.find(board0.snakes, &(&1.id == snake.id))
          [_previous_head | previous_rest] = previous_snake.body
          previous_middle = Enum.uniq(previous_rest)

          middle == previous_middle
        end)
      end
    end

    property "all alive snakes were also alive on the previous turn (no resurrections)", context do
      check all board_size <- context.board_sizes,
        {:ok, board0} <- StreamData.constant(Standard.init(board_size, @fixed_8_snake_ids)),
        moves1 <- StreamData.list_of(StreamData.member_of(@snake_move_directions), length: 8),
        snake_moves1 <- StreamData.constant(Enum.zip(@fixed_8_snake_ids, moves1)),
        board1 <- StreamData.constant(Standard.next(board0, snake_moves1))
      do
        alive_snakes = Enum.filter(board1.snakes, &Snake.alive?/1)

        assert Enum.all?(alive_snakes, fn snake ->
          previous_snake = Enum.find(board0.snakes, &(&1.id == snake.id))

          Snake.alive?(previous_snake)
        end)
      end
    end
  end

  describe "next/2 for standard board sizes with 8 snakes after the first 2 turns" do
    setup :setup_for_standard_board_sizes

    property "no eliminated snakes have moved since the turn before they were eliminated (no walking dead)", context do
      check all board_size <- context.board_sizes,
        {:ok, board0} <- StreamData.constant(Standard.init(board_size, @fixed_8_snake_ids)),
        moves1 <- StreamData.list_of(StreamData.member_of(@snake_move_directions), length: 8),
        snake_moves1 <- StreamData.constant(Enum.zip(@fixed_8_snake_ids, moves1)),
        board1 <- StreamData.constant(Standard.next(board0, snake_moves1)),
        moves2 <- StreamData.list_of(StreamData.member_of(@snake_move_directions), length: 8),
        snake_moves2 <- StreamData.constant(Enum.zip(@fixed_8_snake_ids, moves2)),
        board2 <- StreamData.constant(Standard.next(board1, snake_moves2))
      do
        snakes_on_board2_eliminated_on_board1 = board1.snakes
        |> Enum.filter(&Snake.eliminated?/1)
        |> Enum.map(fn snake -> Enum.find(board2.snakes, &(&1.id == snake.id)) end)

        assert Enum.all?(snakes_on_board2_eliminated_on_board1, fn snake ->
          previous_snake = Enum.find(board1.snakes, &(&1.id == snake.id))

          snake.body == previous_snake.body
        end)
      end
    end
  end
end
