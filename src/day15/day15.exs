Mix.install([])

defmodule Main do
  def row_get(index) do
    :ets.lookup_element(:row, index, 2)
  end

  def row_set(index, value) do
    :ets.insert_new(:row, {index, value}) # won't overwrite!
  end

  # just for debug
  def print_row() do
    :ets.foldl(fn {i, v}, acc -> ["#{i},#{v} " | acc] end, [], :row)
    |> IO.puts
  end

  def count_exclusions() do
    reducer = fn {_, value}, acc ->
      case value do
        :exclusion -> acc + 1
        _ -> acc + 0
      end
    end
    :ets.foldl(reducer, 0, :row)
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

  def run(filename, row_index) do
    :ets.new(:row, [:named_table])

    File.stream!(filename, [])
    |> Stream.map(fn line -> Regex.scan(~r/x=(?<x>-?\d+), y=(?<y>-?\d+)/, line, capture: :all_names) end)
    |> Stream.map(fn line ->
      Enum.map(line, fn point ->
        Enum.map(point, fn value ->
          String.to_integer(value)
        end)
      end)
    end)
    |> Stream.map(&process_line(&1, row_index))
    |> Enum.to_list()

    IO.puts "Part 1: #{count_exclusions()} exclusions at row #{row_index}"
    :ets.delete(:row)
  end
end

#Main.run("src/day15/example.txt", 10)
Main.run("src/day15/input.txt", 2000000)
