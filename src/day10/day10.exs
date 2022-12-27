defmodule Main do

  def process_command_p1(cmd, {first_20, cycle_count, reg_val}, results \\ []) do
    #IO.puts "Cycle #{cycle_count}; register is #{reg_val}; inc #{List.last(cmd)} "
    {first_20, cycle_count, results} = cond do
      rem(cycle_count+20,40) == 0 or (first_20 == :true and cycle_count == 20) -> {:false, cycle_count + 1, [cycle_count * reg_val | results]}
      true -> {first_20, cycle_count + 1, results}
    end
    case cmd do
      ["noop"] -> {results, {first_20, cycle_count, reg_val}}
      ["addx", inc] -> process_command_p1(["addx_cycle2", String.to_integer(inc)], {first_20, cycle_count, reg_val}, results)
      ["addx_cycle2", inc] -> {results, {first_20, cycle_count, reg_val + inc}}
    end
  end

  def part1(stream) do
    result = stream
    |> Stream.transform({:true, 1, 1}, fn cmd, acc -> process_command_p1(cmd, acc) end)
    |> Enum.to_list
    |> List.flatten
    #|> tap(&Enum.map(&1, fn v -> IO.puts v end))
    |> Enum.reduce(fn signal_str, sum -> signal_str + sum end)

    IO.puts "Part 1: #{result}"
  end

  def process_command_p2(cmd, {cycle, reg_val}, output \\ "") do
    symbol = cond do
      abs(rem(cycle - 1, 40) - reg_val) < 2 -> "#"
      true -> "."
    end

    output = cond do
      rem(cycle, 40) == 0 -> (output <> symbol) <> "\n"
      true -> output <> symbol
    end

    case cmd do
      ["noop"] -> {[output], {cycle+1, reg_val}}
      ["addx", inc] -> process_command_p2(["addx_cycle2", String.to_integer(inc)], {cycle+1, reg_val}, output)
      ["addx_cycle2", inc] -> {[output], {cycle+1, reg_val + inc}}
    end
  end

  def part2(stream) do
    stream
    |> Stream.transform({1, 1}, fn cmd, acc -> process_command_p2(cmd, acc) end)
    |> Enum.to_list
    |> List.flatten
    |> Enum.join
    |> IO.puts
  end

  def run(file) do
    contents = File.stream!(file, [])
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    #part1(contents)
    part2(contents)
  end
end

Main.run("src/day10/input.txt")
