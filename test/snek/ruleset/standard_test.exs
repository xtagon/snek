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

    property "all snakes start on even points on the board", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, fn snake ->
          Snake.head(snake) |> Point.even?
        end)
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

    property "all snakes start on even points on the board", context do
      check all board_size <- context.board_sizes, snake_ids <- context.snake_ids do
        assert {:ok, %Board{} = board} = Standard.init(board_size, snake_ids)

        assert Enum.all?(board.snakes, fn snake ->
          Snake.head(snake) |> Point.even?
        end)
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

    property "no eliminated snakes have moved or changed (no zombies)", context do
      check all board_size <- context.board_sizes,
        {:ok, board0} <- StreamData.constant(Standard.init(board_size, @fixed_8_snake_ids))
      do
        # Must move in some direction first before there is a "backward"
        # direction into the snake's own neck
        initial_moves = Enum.map(@fixed_8_snake_ids, fn snake_id ->
          {snake_id, :north}
        end)

        board1 = Standard.next(board0, initial_moves)

        # Move snakes backward into their own necks
        throwing_moves = Enum.map(board1.snakes, fn snake ->
          backward = Enum.find([:north, :south, :east, :west], fn move ->
            Snake.step(snake, move) == Snake.step(snake, :backward)
          end)

          {snake.id, backward}
        end)

        board2 = Standard.next(board1, throwing_moves)

        for snake <- board2.snakes do
          assert {:eliminated, :self_collision} == snake.state
        end

        for [previous_snake, next_snake] <- Enum.zip(board1.snakes, board2.snakes) do
          assert next_snake == previous_snake
        end
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

  describe "next/2 when the entire board is filled" do
    test "continues without error despite being unable to spawn a random apple on this turn" do
      with empty_board <- Board.new(Size.new(2, 1)),
           {:ok, board_with_snake} <- Board.spawn_snake(empty_board, "snek1", Point.new(0, 0)),
           {:ok, full_board} <- Board.spawn_apple(board_with_snake, Point.new(1, 0))
      do
        assert Enum.empty?(Board.unoccupied_points(full_board))

        snake_moves = [{"snek1", :east}]
        apple_spawn_chance = 1.0

        assert %Board{} = Standard.next(full_board, snake_moves, apple_spawn_chance)
      end
    end
  end

  # Added for compatibility with this change to the Battlesnake rules:
  #
  # https://github.com/BattlesnakeOfficial/rules/commit/a342f87ed6c18f16d3d0fc099d94d047e31d4611
  #
  describe "next/2 when a snake eats food on their very last turn before starving" do
    setup do
      snake_length = 3
      snake_health = 3
      food_spawn_chance = 0.0

      empty_board = Board.new(Size.medium)

      {:ok, board_with_snake} = Board.spawn_snake(empty_board, "snek1", Point.new(1, 1), snake_length, snake_health)
      {:ok, board0} = Board.spawn_apple(board_with_snake, Point.new(4, 1))

      repeat_snake_moves = [{"snek1", :east}]

      board1 = Standard.next(board0, repeat_snake_moves, food_spawn_chance)
      board2 = Standard.next(board1, repeat_snake_moves, food_spawn_chance)
      board3 = Standard.next(board2, repeat_snake_moves, food_spawn_chance)

      snake = Enum.find(board3.snakes, &(&1.id == "snek1"))

      %{snake: snake}
    end

    test "stays alive instead of starving", %{snake: snake} do
      assert snake.state == :alive
    end

    test "regains full health instead of starving", %{snake: snake} do
      assert snake.health == 100
    end

    test "grows instead of starving", %{snake: snake} do
      assert length(snake.body) == 4
    end
  end

  # Added for compatibility with this change to the Battlesnake rules:
  #
  # https://github.com/BattlesnakeOfficial/rules/commit/a342f87ed6c18f16d3d0fc099d94d047e31d4611
  #
  describe "next/2 when two snakes eat the same food during a head-to-head collision with each other" do
    setup do
      snake_length = 3
      snake_health = 3
      food_spawn_chance = 0.0

      apple = Point.new(4, 1)

      empty_board = Board.new(Size.medium)

      {:ok, board_with_1_snake} = Board.spawn_snake(empty_board, "snek1", Point.new(1, 1), snake_length, snake_health)
      {:ok, board_with_2_snakes} = Board.spawn_snake(board_with_1_snake, "snek2", Point.new(7, 1), snake_length, snake_health)
      {:ok, board0} = Board.spawn_apple(board_with_2_snakes, apple)

      repeat_snake_moves = [{"snek1", :east}, {"snek2", :west}]

      board1 = Standard.next(board0, repeat_snake_moves, food_spawn_chance)
      board2 = Standard.next(board1, repeat_snake_moves, food_spawn_chance)
      board3 = Standard.next(board2, repeat_snake_moves, food_spawn_chance)

      %{board: board3, apple: apple}
    end

    test "removes the food", %{board: board, apple: apple} do
      assert Board.occupied_by_apple?(board, apple) == false
    end

    test "both snakes are eliminated from the collision", %{board: %{snakes: [snake1, snake2]}} do
      assert snake1.state == {:eliminated, :head_to_head, snake2.id}
      assert snake2.state == {:eliminated, :head_to_head, snake1.id}
    end

    test "both snakes regain full health instead of starving", %{board: %{snakes: snakes}} do
      for snake <- snakes do
        assert snake.health == 100
      end
    end

    test "both snakes grow instead of starving", %{board: %{snakes: snakes}} do
      for snake <- snakes do
        assert length(snake.body) == 4
      end
    end
  end

  describe "done/1" do
    test "continues the game while there are alive snakes remaining, then terminates when only one alive snake remains" do
      with empty_board <- Board.new(Size.small),
           {:ok, board_with_1_snake} <- Board.spawn_snake(empty_board, "snek1", Point.new(0, 0)),
           {:ok, board_with_2_snakes} <- Board.spawn_snake(board_with_1_snake, "snek2", Point.new(2, 0)),
           {:ok, board_with_3_snakes} <- Board.spawn_snake(board_with_2_snakes, "snek3", Point.new(4, 0)),
           board_with_1_snake_eliminated <- Standard.next(board_with_3_snakes, [{"snek1", :north}, {"snek2", :east}, {"snek3", :east}]),
           board_with_2_snakes_eliminated <- Standard.next(board_with_1_snake_eliminated, [{"snek1", nil}, {"snek2", :north}, {"snek3", :south}])
      do
        assert Board.alive_snakes_remaining(board_with_3_snakes) == 3
        assert Board.alive_snakes_remaining(board_with_1_snake_eliminated) == 2
        assert Board.alive_snakes_remaining(board_with_2_snakes_eliminated) == 1

        refute Standard.done?(board_with_3_snakes)
        refute Standard.done?(board_with_1_snake_eliminated)
        assert Standard.done?(board_with_2_snakes_eliminated)
      end
    end
  end
end
