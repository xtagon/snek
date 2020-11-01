alias Snek.Board
alias Snek.Ruleset.Standard

snake_ids_2p = MapSet.new(["p1", "p2"])
snake_ids_6p = MapSet.new(["p1", "p2", "p3", "p4", "p5", "p6"])
snake_ids_8p = MapSet.new(["p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8"])

{:ok, board_2p} = Standard.init(Board.Size.small, snake_ids_2p)
{:ok, board_6p} = Standard.init(Board.Size.medium, snake_ids_6p)
{:ok, board_8p} = Standard.init(Board.Size.large, snake_ids_8p)

snake_moves_2p = [
  {"p1", :up},
  {"p2", :down}
]

snake_moves_6p = [
  {"p1", :up},
  {"p2", :down},
  {"p3", :left},
  {"p4", :right},
  {"p5", :up},
  {"p6", :down}
]

snake_moves_8p = [
  {"p1", :up},
  {"p2", :down},
  {"p3", :left},
  {"p4", :right},
  {"p5", :up},
  {"p6", :down},
  {"p7", :left},
  {"p8", :right}
]

apple_spawn_chance = 0.15
no_apple_spawn_chance = 0.0

Benchee.run(
  %{
    "standard.init.2p" => fn ->
      {:ok, _board} = Standard.init(Board.Size.small, snake_ids_2p)
    end,
    "standard.init.6p" => fn ->
      {:ok, _board} = Standard.init(Board.Size.large, snake_ids_6p)
    end,
    "standard.next.2p" => fn ->
      _next_board = Standard.next(board_2p, snake_moves_2p, apple_spawn_chance)
    end,
    "standard.next.2p.no-apple-spawn" => fn ->
      _next_board = Standard.next(board_2p, snake_moves_2p, no_apple_spawn_chance)
    end,
    "standard.next.6p" => fn ->
      _next_board = Standard.next(board_6p, snake_moves_6p, apple_spawn_chance)
    end,
    "standard.next.6p.no-apple-spawn" => fn ->
      _next_board = Standard.next(board_6p, snake_moves_6p, no_apple_spawn_chance)
    end,
    "standard.next.8p" => fn ->
      _next_board = Standard.next(board_8p, snake_moves_8p, apple_spawn_chance)
    end,
    "standard.next.8p.no-apple-spawn" => fn ->
      _next_board = Standard.next(board_8p, snake_moves_8p, no_apple_spawn_chance)
    end
  }
)
