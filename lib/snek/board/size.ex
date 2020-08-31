defmodule Snek.Board.Size do
  @moduledoc """
  A struct representing the size of a game board.

  A board is always rectangular (or square), and is represented by a width and
  a height.

  Arbitrary board sizes may be created with `new/2`.

  There are some helpers functions for some suggested board sizes, including
  `small/0`, `medium/0`, and `large/0`. These suggestions are based on the
  default board sizes in Battlesnake.
  """
  @moduledoc since: "0.1.0"

  alias __MODULE__

  @type t :: %Size{
    width: non_neg_integer(),
    height: non_neg_integer()
  }

  @enforce_keys [:width, :height]

  defstruct [:width, :height]

  @doc """
  Returns a board size of the specified width and height.
  """
  @doc since: "0.1.0"
  @spec new(non_neg_integer(), non_neg_integer()) :: t

  def new(width, height) when is_integer(width) and is_integer(height) do
    %Size{width: width, height: height}
  end

  @doc """
  Return a small (7x7) board size.

  ## Examples

      iex> Size.small
      %Size{width: 7, height: 7}

  """
  @doc since: "0.1.0"
  @spec small :: t

  def small, do: %Size{width: 7, height: 7}

  @doc """
  Return a medium (11x11) board size.

  ## Examples

      iex> Size.medium
      %Size{width: 11, height: 11}

  """
  @doc since: "0.1.0"
  @spec medium :: t

  def medium, do: %Size{width: 11, height: 11}

  @doc """
  Return a large (19x19) board size.

  ## Examples

      iex> Size.large
      %Size{width: 19, height: 19}

  """
  @doc since: "0.1.0"
  @spec large :: t

  def large, do: %Size{width: 19, height: 19}
end
