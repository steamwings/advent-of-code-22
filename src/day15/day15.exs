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

  def row_delete(index) do
    :ets.delete(pid_atom(), index)
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

  def tuning_frequency({x,y}) do
    x*4000000 + y
  end

  def with_radius(line) do
    [[xs, ys], [xb, yb]] = line
    radius = manhattan_distance({xs, ys}, {xb, yb})
    {xs, ys, radius}
  end

  def is_in_zone(zone, point) do
    {xz, yz, radius} = zone
    manhattan_distance({xz, yz}, point) <= radius
  end

  def find_point({x,y}, zones, max) do
    case Enum.any?(zones, fn zone -> is_in_zone(zone, {x,y}) end) do
      false -> {x,y}
      _ when y == max and x == max -> IO.puts "FAIL"
      _ when y == max -> IO.write("."); find_point({x+1,0}, zones, max)
      _ -> find_point({x,y+1}, zones, max)
    end
  end

  # I estimate this will take about 2000 hours to finish on my present VM, should probably do better...
  def runPart2(contents, max) do
    zones = Enum.map(contents, &with_radius/1)
    freq = tuning_frequency(find_point({0,0}, zones, max))
    IO.puts "Part 2: frequency #{freq}"
  end

  def run(filename, pt1_target_row, pt2_max) do
    contents = parse(filename)
    #runPart1(contents, pt1_target_row)
    runPart2(contents, pt2_max)
  end
end

#Main.run("src/day15/example.txt", 10, 20)
Main.run("src/day15/input.txt", 2000000, 4000000)
