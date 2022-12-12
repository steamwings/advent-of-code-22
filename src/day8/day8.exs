defmodule Main do

  def exploreRight(row, prevValue, maxLeft) do
    [value | tail] = row
    {count, maxRight} = cond do
      tail == [] -> {0,0} # Base case for rightmost value
      value > maxLeft -> exploreRight(tail, value, value)
      true -> exploreRight(tail, value, maxLeft)
    end

    maxRight = max(prevValue, maxRight)
    count = if value > maxRight or value > maxLeft, do: count + 1, else: count

    {count, maxRight}
  end

  def part1() do
    grid = File.stream!("src/day8/input.txt", [])
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Enum.to_list

    leftRightTotal = grid
    |> exploreRight(0, 0)
    |> elem(0)

    upDownTotal = grid
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> exploreRight(0, 0)
    |> elem(0)

    leftRightTotal + upDownTotal
  end

  def run() do
    IO.puts "Part 1: #{part1()}"
  end
end

Main.run()
