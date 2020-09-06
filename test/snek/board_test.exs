defmodule BoardTest do
  use ExUnit.Case
  alias Snek.Board
  doctest Board, import: true

  describe "maybe_eliminate_snakes/1" do
    test "does not eliminate snakes when they collide with the body of a dead snake" do
      dead_snake = %Board.Snake{
        id: "deadsnek",
        state: {:eliminated, :starvation},
        health: 0,
        body: [
          Board.Point.new(1, 3),
          Board.Point.new(1, 2),
          Board.Point.new(1, 1)
        ]
      }

      alive_snake = %Board.Snake{
        id: "alivesnek",
        state: :alive,
        health: 100,
        body: [
          Board.Point.new(1, 2),
          Board.Point.new(2, 2),
          Board.Point.new(3, 2)
        ]
      }

      empty_board = Board.new(Board.Size.small)
      board0 = %Board{empty_board | snakes: [alive_snake, dead_snake]}
      board1 = Board.maybe_eliminate_snakes(board0)

      assert board1 == board0
    end

    test "does not eliminate snakes when they collide head to head with a dead snake" do
        dead_snake = %Board.Snake{
          id: "deadsnek",
          state: {:eliminated, :starvation},
          health: 0,
          body: [
            Board.Point.new(1, 3),
            Board.Point.new(1, 2),
            Board.Point.new(1, 1)
          ]
        }

        alive_snake = %Board.Snake{
          id: "alivesnek",
          state: :alive,
          health: 100,
          body: [
            Board.Point.new(1, 3),
            Board.Point.new(2, 3),
            Board.Point.new(3, 3)
          ]
        }

        empty_board = Board.new(Board.Size.small)
        board0 = %Board{empty_board | snakes: [alive_snake, dead_snake]}
        board1 = Board.maybe_eliminate_snakes(board0)

        assert board1 == board0
    end
  end
end
