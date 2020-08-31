# Snek

A framework for defining Battlesnake-compatible rulesets and board positions in
Elixir.

[Battlesnake][battlesnake] is an online competitive take on the classic game of
Snake. `Snek` provides some structure and tooling that developers can use
toward creating Battlesnake AIs in Elixir.

This project is not affiliated with or sponsored by Battlesnake.

## Status

This is an early work in progress, and should be considered experimental,
incomplete, and unstable until v1.0.0, following [Semantic Versioning][semver].

All notable changes will be recorded in the [changelog](CHANGELOG.md).

## Installation

Add `snek` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:snek, "~> 0.1.0"}
  ]
end
```

## Documentation

Documentation can be found [here at Hex.pm][hexdocs] or generated from the
source code using `mix docs`.

## Examples

The following example simulates a couple of game turns using the Standard
ruleset, for a two-player game, on a standard medium (11x11) board size.

```elixir
alias Snek.Ruleset.Standard
alias Snek.Board

# Two-player game
snake_ids = MapSet.new(["snek1", "snek2"])

# Initialize the game
{:ok, turn0} = Standard.init(Board.Size.medium, snake_ids)

# The ruleset emits `Snek.Board` states that you can analyze in various ways:
Board.empty?(turn0) # => false
Board.alive_snakes_remaining(turn0) # => 2

# Apply moves for two turns
turn1 = Standard.next(turn0, [{"snek1", :west}, {"snek2", :north}])
turn2 = Standard.next(turn1, [{"snek1", :south}, {"snek2", :east}])

# Is the game over? (See if you can figure out *why* the game isn't over!)
Standard.done?(turn2) # => false
```

All rulesets implement the same callbacks, so you can perform dynamic dispatch.
In the following example, the `ruleset` variable could be set to any ruleset
module name:

```elixir
ruleset = Snek.Ruleset.Solo

{:ok, turn0} = ruleset.init(Board.Size.medium, snake_ids)
```

## Open Invite

If you have any questions, or just wish to geek out and chat about Battlesnake
or Elixir or programming in general, feel free to reach out! I love talking
with people and sharing tips and tricks.

You can reach me at [xtagon@gmail.com](mailto:xtagon@gmail.com), or catch me in
[Battlesnake Slack][slack] (username: `@xtagon`).

## Development

The following Mix tasks are available to assist in development:

- `mix docs`
- `mix test`
- `mix coveralls`
- `mix credo --strict`

## License

This project is released under the terms of the [MIT License](LICENSE.txt).

[battlesnake]: https://play.battlesnake.com/
[slack]: https://battlesnake.slack.com/
[semver]: https://semver.org/
[hexdocs]: https://hexdocs.pm/snek/
