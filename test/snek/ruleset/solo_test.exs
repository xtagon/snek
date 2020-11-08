defmodule SoloRulesetTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Snek.Board
  alias Snek.Board.{Point, Size}
  alias Snek.Ruleset.Solo

  doctest Solo, import: true

  describe "done/1" do
    test "continues the game while there are alive snakes remaining, then terminates when all snakes are eliminated" do
      with empty_board <- Board.new(Size.small),
           {:ok, board_with_snake} <- Board.spawn_snake(empty_board, "snek1", Point.new(0, 0)),
           board_with_snake_eliminated <- Solo.next(board_with_snake, [{"snek1", :up}])
      do
        assert Board.alive_snakes_remaining(board_with_snake) == 1
        assert Board.alive_snakes_remaining(board_with_snake_eliminated) == 0

        refute Solo.done?(board_with_snake)
        assert Solo.done?(board_with_snake_eliminated)
      end
    end
  end
end
