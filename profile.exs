defmodule ProfileRunner do
  import ExProf.Macro

  alias Snek.SmallStaticCycle

  @doc "analyze with profile macro"
  def do_analyze do
    profile do
      _final_board = SmallStaticCycle.run
    end
  end

  @doc "get analysis records and sum them up"
  def run do
    {records, _block_result} = do_analyze()
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.puts "total = #{total_percent}"
  end
end

ProfileRunner.run
