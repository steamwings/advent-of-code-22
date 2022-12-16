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

  def part1(grid) do
    {leftRightTotal, grid} = grid
    |> Enum.map(fn x -> Enum.map(x, fn val -> {val, :false} end) end)
    |> Enum.map(&exploreRight(&1, 0))
    |> Enum.reverse # Since we're about to manually construct a list which will reverse them back
    |> Enum.reduce({0, []}, fn {count, _, row},{sum, grid} -> {sum + count, [row | grid]} end)

    upDownTotal = grid
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&exploreRight(&1, 0))
    |> Enum.map(fn {count, _, _} -> count end)
    |> Enum.sum

    leftRightTotal + upDownTotal
  end

  def treesVisible(ahead, value) do
    case ahead do
      [height | tail] when height < value -> 1 + treesVisible(tail, value)
      [] -> 0
      _ -> 1
    end
  end

  # rowAcc contains the scores; rowAhead
  def exploreRight2(rowAcc, rowBehind) do
    [{value, {top, bottom}} | tail] = rowAcc

    {acc, rowAhead} = cond do
      tail == [] -> {[], []} # Base case for rightmost value
      true -> exploreRight2(tail, [value | rowBehind])
    end

    # Find scores
    left = treesVisible(rowBehind, value)
    right = treesVisible(rowAhead, value)

    cond do
      top == :empty -> {[{value, {left, right}} | acc], [value | rowAhead]} # first pass
      true -> {[top * bottom * left * right | acc], [value | rowAhead]} # second pass
    end
  end

  # There are many better ways of doing this...
  def part2(grid) do
    grid
    |> Enum.map(fn x -> Enum.map(x, fn val -> {val, {:empty, :empty}} end) end)
    |> Enum.map(&exploreRight2(&1, []))
    |> Enum.map(fn {acc, _} -> acc end)
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&exploreRight2(&1, []))
    |> Enum.map(fn {acc, _} -> acc end)
    |> List.flatten
    |> Enum.max
  end

  def run() do
    grid = File.stream!("src/day8/input.txt", [])
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Enum.to_list

    IO.puts "Part 1: #{part1(grid)}"
    IO.puts "Part 2: #{part2(grid)}"
  end
end

Main.run()
