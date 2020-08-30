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
end
