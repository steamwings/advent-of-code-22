defmodule Main do

  def exploreRight(row, maxLeft) do
    [{value, counted} | tail] = row
    {count, maxRight, row} = cond do
      tail == [] -> {0,0,[]} # Base case for rightmost value
      value > maxLeft -> exploreRight(tail, value)
      true -> exploreRight(tail, maxLeft)
    end

    nowCounted = if counted == :false and (value > maxRight or value > maxLeft) do
      true
    else
      false
    end
    count = if !counted and nowCounted, do: count + 1, else: count
    maxRight = max(value, maxRight)

    {count, maxRight, [{value, nowCounted} | row]}
  end

  def part1() do
    grid = File.stream!("src/day8/example.txt", [])
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Enum.to_list
    |> Enum.map(fn x -> Enum.map(x, fn val -> {val, :false} end) end)

    {leftRightTotal, grid} = grid
    |> Enum.map(&exploreRight(&1, 0))
    |> Enum.reverse # Since we're about to manually construct a list which will reverse them back
    |> Enum.reduce({0, []}, fn {count, _, row},{sum, grid} -> {sum + count, [row | grid]} end)

    upDownTotal = grid
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&exploreRight(&1, 0))
    #|> tap(&IO.puts/1)
    |> Enum.map(fn {count, _, _} -> count end)
    |> Enum.sum

    leftRightTotal + upDownTotal
  end

  def run() do
    IO.puts "Part 1: #{part1()}"
  end
end

Main.run()
