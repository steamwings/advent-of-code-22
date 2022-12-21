Mix.install([])

defmodule Main do
  def pid_atom() do
    self() |> :erlang.pid_to_list() |> to_string() |> String.to_atom()
  end

  def row_get(index) do
    :ets.lookup_element(pid_atom(), index, 2)
  end

  def row_set(index, value) do
    :ets.insert_new(pid_atom(), {index, value}) # won't overwrite!
  end

  # just for debug
  def print_row() do
    #:ets.foldl(fn {i, v}, acc -> ["#{i},#{v} " | acc] end, [], pid_atom())
    :ets.foldl(fn {i, v}, acc -> [[i,v] | acc] end, [], pid_atom())
    |> Enum.sort(fn ([a,_], [c,_]) -> a < c end)
    |> Enum.map(fn [i,v] -> "#{i},#{v} " end)
    |> IO.puts
  end

  def count_exclusions() do
    reducer = fn {_, value}, acc ->
      case value do
        :exclusion -> acc + 1
        _ -> acc + 0
      end
    end
    :ets.foldl(reducer, 0, pid_atom())
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(y1 - y2) + abs(x1 - x2)
  end

  def process_line(coordinates, target_row) do
    [[xs, ys], [xb, yb]] = coordinates
    radius = manhattan_distance({xs, ys}, {xb, yb})

    # test if target_row is informed by the sensor
    if target_row >= ys - radius and target_row <= ys + radius do
      if yb == target_row do
        row_set(xb, :beacon)
      end
      # width of the exclusion zone on this row
      width = radius - abs(ys - target_row)
      Enum.each((xs - width)..(xs + width), fn x -> row_set(x, :exclusion) end)
    end
    #print_row()
  end

  # Each line will be a pair of integer pairs like [[2,18],[-2,15]]
  def parse(filename) do
    File.stream!(filename, [])
    |> Stream.map(fn line -> Regex.scan(~r/x=(?<x>-?\d+), y=(?<y>-?\d+)/, line, capture: :all_names) end)
    |> Stream.map(fn line ->
      Enum.map(line, fn point ->
        Enum.map(point, fn value ->
          String.to_integer(value)
        end)
      end)
    end)
  end

  def check_row(data, row_index) do
    data
    |> Stream.map(&process_line(&1, row_index))
    |> Enum.to_list()
    IO.write(".")
  end

  def runPart1(contents, row_index) do
    :ets.new(pid_atom(), [:named_table])
    check_row(contents, row_index)
    result = count_exclusions()
    :ets.delete(pid_atom())
    IO.puts "Part 1: #{result} exclusions at row #{row_index}"
  end

  def tuning_frequency(x, y) do
    x*4000000 + y
  end

  # Search through the row for a missing entry (non-beacon, non-exclusion spot)
  def find_x(x, max) do
    case :ets.lookup(pid_atom(), x) do
      [] -> [:joy, x]
      _ when x == max -> :no_joy
      _ -> find_x(x + 1, max)
    end
  end

  def check_row_pt2(num_processes, contents, max, row_index) do
    :ets.new(pid_atom(), [:named_table])
    check_row(contents, row_index)
    result = find_x(0, max)
    :ets.delete(pid_atom())
    case result do
      [:joy, x] -> IO.puts "Part 2: beacon frequency is #{tuning_frequency(x, row_index)}"
      _ when row_index + num_processes > max -> IO.puts "HIT MAX"
      _ -> check_row_pt2(num_processes, contents, max, row_index + num_processes)
    end
  end

  # this is embarrasingly inefficient and slow
  # but it was so much easier to use the part 1 solution...
  def runPart2(contents, max) do
    processes = 4
    Enum.each(0..processes, fn i ->
      spawn_monitor(fn -> check_row_pt2(processes, contents, max, i)
    end) end)
    receive do
      {:DOWN, _, _, _, reason} ->
        IO.puts("down #{reason}")
    end
  end

  def run(filename, pt1_target_row, pt2_max) do
    contents = parse(filename)
    #runPart1(contents, pt1_target_row)
    runPart2(contents, pt2_max)
  end
end

#Main.run("src/day15/example.txt", 10, 20)
Main.run("src/day15/input.txt", 2000000, 4000000)
