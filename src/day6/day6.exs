Mix.install([])

defmodule Main do
  defp all_uniq(enum) do
    Enum.uniq(enum) === enum
  end

  defp magic({x, index}, acc) do
    seq = Enum.take(acc,-3) ++ [x]
    if length(seq) == 4 and all_uniq(seq) do
      {:halt, index}
    else
      {[x], seq}
    end
  end

  def run do
    File.stream!("src/day6/input.txt", [], 1)
    |> Stream.with_index(1)
    |> Enum.flat_map_reduce([], &magic/2)
    #|> Stream.run
    |> elem(1)
  end
end

IO.puts Main.run()
