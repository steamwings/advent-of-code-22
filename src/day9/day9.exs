
defmodule Main do
  defp pid_atom() do
    self() |> :erlang.pid_to_list() |> to_string() |> String.to_atom()
  end

  defp set(index, value \\ :true) do
    :ets.insert_new(pid_atom(), {index, value}) # won't overwrite!
    index
  end

  defp count(value \\ :true) do
    reducer = fn {_, x}, acc ->
      case x do
        ^value -> acc + 1
        _ -> acc + 0
      end
    end
    :ets.foldl(reducer, 0, pid_atom())
  end

  defp parse(file) do
    File.stream!(file, [])
    |> Stream.map(fn line -> Regex.scan(~r/(?<d>\w) (?<n>\d{1,2})/, line, capture: :all_names) end)
    |> Stream.map(fn [[direction, count]] ->
      {direction, String.to_integer(count)}
    end)
  end

  # for debug
  defp print_points(points) do
    Enum.reduce(points, "", fn {x,y}, acc -> acc <> "(#{x},#{y}), " end)
    |> IO.puts
  end

  defp next_tail({xh, yh}, {xt, yt}) do
    dx = xh - xt
    dy = yh - yt
    adx = abs(dx)
    ady = abs(dy)
    #IO.puts "dx: #{dx}, dy: #{dy}, adx: #{adx}, ady: #{ady}"
    cond do
      adx < 2 and ady < 2 -> {xt, yt} # no move
      adx + ady == 2 or (adx == 2 and ady == 2) ->
        {xt + div(dx,2), yt + div(dy,2)} # vert/horiz move or double diag
      adx == 2 -> {xt + div(dx,2), yt + dy} # diagonal
      ady == 2 -> {xt + dx, yt + div(dy,2)} # diagonal
      true -> # panic
        print_points([{xh, yh}, {xt, yt}])
        IO.puts "dx: #{dx}, dy: #{dy}, adx: #{adx}, ady: #{ady}"
        exit(1)
    end
  end

  defp move_tails(head, [tail | tails]) when tails == [] do
    [head | [set(next_tail(head, tail))]]
  end

  defp move_tails(head, [tail | tails]) do
    [head | move_tails(next_tail(head, tail), tails)]
  end

  defp next_move(direction, [{x_head, y_head} | tails]) do
    new_head = case direction do
      "U" -> {x_head, y_head + 1}
      "D" -> {x_head, y_head - 1}
      "R" -> {x_head + 1, y_head}
      "L" -> {x_head - 1, y_head}
    end

    move_tails(new_head, tails)
      #|> tap(&print_points/1) # Uncomment to see each movement
  end

  defp next_line({direction, count}, coordinates) when count == 1 do
    next_move(direction, coordinates)
  end

  defp next_line({direction, count}, coordinates) do
    next_line({direction, count - 1}, next_move(direction, coordinates))
  end

  defp run_for_knots(stream, knots) do
    :ets.new(pid_atom(), [:named_table])
    set({0,0})
    init_acc = for _ <- 1..knots, do: {0,0}
    Enum.reduce(stream, init_acc, &next_line(&1,&2))
    count = count()
    :ets.delete(pid_atom())
    count
  end

  def run(file) do
    stream = parse(file)
    IO.puts "Part 1: #{run_for_knots(stream, 2)}"
    IO.puts "Part 2: #{run_for_knots(stream, 10)}"
  end
end

Main.run("src/day9/input.txt")
