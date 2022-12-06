Mix.install([])

defmodule Main do
  defp all_uniq(enum) do
    Enum.uniq(enum) === enum
  end

  # Check the previous commit for part 1--I was busy today
  defp magic2({x, index}, acc) do
    seq = Enum.take(acc,-13) ++ [x]
    if length(seq) == 14 and all_uniq(seq) do
      {:halt, index}
    else
      {[x], seq}
    end
  end

  def run do
    File.stream!("src/day6/input.txt", [], 1)
    |> Stream.with_index(1)
    |> Enum.flat_map_reduce([], &magic2/2)
    |> elem(1)
  end
end

IO.puts Main.run()
