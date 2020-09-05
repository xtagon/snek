# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][keepachangelog], and this project
adheres to [Semantic Versioning][semver].

Changes to this project which track compatibility with changes to the official
Battlesnake rules, which may change frequently, will not be considered a
breaking change unless it also affects the public API of this project (public
modules and functions).

This means that as long as all official changes to the rules are eventually
reflected in a new version of this project (no guarentees), then it will be
made available as either a patch- or minor-level release to help you stay up to
date automatically without updating your code. If this rule is violated, or if
there is a new official change to the rules that has not been corrected, please
[report it][issues].

## [Unreleased]

### Fixed

- Corrected typespec for `Snek.Board.move_snake/3`.

## [0.3.0] - 2020-09-05

### Changed

- In the `Snek.Ruleset.Standard` rules, snakes eating on their
  last turn will survive now. Previously they would be eliminated from
  starvation despite the food being eaten. This change also makes it so that
  head-to-head collisions on food still remove the food. This updates
  compatibility with [this change in the official Battlesnake
  rules.](https://github.com/BattlesnakeOfficial/rules/commit/a342f87ed6c18f16d3d0fc099d94d047e31d4611)

## [0.2.0] - 2020-08-30

### Added

- A `Snek.Board.Snake.step/2` function for finding points relative to a snake's
  last moved direction, but without moving the snake.

## [0.1.0] - 2020-08-30

### Added

- A `Snek.Board` module (and submodules) for representing board positions.
- A `Snek.Ruleset` behaviour module for implementing variations of game rules.
- A `Snek.Ruleset.Standard` module implementing the Battlesnake Standard rules.
- A `Snek.Ruleset.Solo` module implementing the Battlesnake Solo rules.

[Unreleased]: https://github.com/xtagon/snek/compare/v0.3.0...edge
[0.3.0]: https://github.com/xtagon/snek/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/xtagon/snek/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/xtagon/snek/releases/tag/v0.1.0

[keepachangelog]: https://keepachangelog.com/en/1.0.0/
[semver]: https://semver.org/spec/v2.0.0.html
[issues]: https://github.com/xtagon/snek/issues
