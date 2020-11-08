defmodule Snek.SmallStaticCycle do
  @moduledoc false

  # This test is designed to be static/consistent for profiling/benchmarking.
  # It is designed to run a solo game for exactly 147 turns (no randomness)

  alias Snek.Board
  alias Snek.Board.{Point, Size, Snake}
  alias Snek.Ruleset.Solo

  @apple_spawn_chance 0.0

  @snake_id "p1"

  @cycle %{
    {0, 0} => :right,
    {1, 0} => :right,
    {2, 0} => :right,
    {3, 0} => :right,
    {4, 0} => :right,
    {5, 0} => :right,
    {6, 0} => :down,
    {6, 1} => :left,
    {5, 1} => :left,
    {4, 1} => :left,
    {3, 1} => :left,
    {2, 1} => :left,
    {1, 1} => :down,
    {1, 2} => :right,
    {2, 2} => :right,
    {3, 2} => :right,
    {4, 2} => :right,
    {5, 2} => :right,
    {6, 2} => :down,
    {6, 3} => :left,
    {5, 3} => :left,
    {4, 3} => :left,
    {3, 3} => :left,
    {2, 3} => :left,
    {1, 3} => :down,
    {1, 4} => :right,
    {2, 4} => :right,
    {3, 4} => :right,
    {4, 4} => :right,
    {5, 4} => :right,
    {6, 4} => :down,
    {6, 5} => :down,
    {6, 6} => :left,
    {5, 6} => :up,
    {5, 5} => :left,
    {4, 5} => :down,
    {4, 6} => :left,
    {3, 6} => :up,
    {3, 5} => :left,
    {2, 5} => :down,
    {2, 6} => :left,
    {1, 6} => :up,
    {1, 5} => :left,
    {0, 5} => :up,
    {0, 4} => :up,
    {0, 3} => :up,
    {0, 2} => :up,
    {0, 1} => :up,
    {0, 6} => :up
  }

  def run do
    stream = Stream.iterate({:ok, init()}, fn {:ok, board} ->
      if Solo.done?(board) do
        {:error, :game_over}
      else
        snake_moves = %{@snake_id => get(board)}
        next_board = Solo.next(board, snake_moves, @apple_spawn_chance)
        {:ok, next_board}
      end
    end)

    stream_until_end = Stream.take_while(stream, fn
      {:ok, %Board{}} -> true
      {:error, :game_over} -> false
    end)

    {:ok, final_board} = Enum.at(stream_until_end, -1)

    final_board
  end

  defp init do
    start = Point.new(1, 3)
    apples = [Point.new(0, 4), Point.new(3, 3)]

    with board <- Board.new(Size.small),
      {:ok, board} <- Board.spawn_snake(board, @snake_id, start),
      {:ok, board} <- Board.spawn_apples(board, apples) do
      board
    end
  end

  defp get(%Board{snakes: [%Snake{body: [%Point{x: x, y: y} | _]} | _]}) do
    @cycle[{x, y}]
  end
end
