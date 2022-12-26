defmodule Main do

  def process_command(cmd, {first_20, cycle_count, reg_val}, results \\ []) do
    #IO.puts "Cycle #{cycle_count}; register is #{reg_val}; inc #{List.last(cmd)} "
    {first_20, cycle_count, results} = cond do
      rem(cycle_count+20,40) == 0 or (first_20 == :true and cycle_count == 20) -> {:false, cycle_count + 1, [cycle_count * reg_val | results]}
      true -> {first_20, cycle_count + 1, results}
    end
    case cmd do
      ["noop"] -> {results, {first_20, cycle_count, reg_val}}
      ["addx", inc] -> process_command(["addx_cycle2", String.to_integer(inc)], {first_20, cycle_count, reg_val}, results)
      ["addx_cycle2", inc] -> {results, {first_20, cycle_count, reg_val + inc},}
    end
  end

  def run(file) do
    File.stream!(file, [])
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.split/1)
      |> Stream.transform({:true, 1, 1}, fn cmd, acc -> process_command(cmd, acc) end)
      |> Enum.to_list
      |> List.flatten
      #|> tap(&Enum.map(&1, fn v -> IO.puts v end))
      |> Enum.reduce(fn signal_str, sum -> signal_str + sum end)
      |> IO.puts
  end
end

Main.run("src/day10/input.txt")
