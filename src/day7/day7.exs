# Trying to understand this code? Read it from the bottom up.

defmodule Main do
  @eligible_dir_size 100000

  # NOTE: I'm making an assumption about the input data
  # that it does a relatively predictable depth-first traversal
  # and does not revisit directories

  # size("14848514 b.txt") -> 14848514
  def size(file_str) do
    file_str
    |> String.split()
    |> hd()
    |> String.to_integer()
  end

  # returns {total_size, 0}
  def process_files(stream) do
    {Enum.reduce(stream, 0, fn x, acc -> acc + size(x) end), 0}
  end

  def chunk_by_child(x, acc) do
    {current_chunk, depth} = acc
    cond do
      depth == 0 and String.match?(x, ~r/^dir/) ->
        {[], {current_chunk, 0}} # discard (See NOTE above)
      depth == 0 and String.match?(x, ~r/^\$ cd/) ->
        {[Enum.reverse(current_chunk)], {[], 1}} # emit and discard
      depth == 1 and "$ cd .." == x ->
        {[], {current_chunk, 0}} # discard
      "$ cd .." == x -> {[], {[x | current_chunk], depth - 1}} # append, ascend
      String.match?(x, ~r/^\$ cd/) -> {[], {[x | current_chunk], depth + 1}} # append, descend
      true -> {[], {[x | current_chunk], depth}} # append
    end
  end

  def last_child_chunk(acc) do
    case acc do
      {[], _} -> {[], :noop}
      {chunk, _} -> {[Enum.reverse(chunk)], :noop}
    end
  end

  # returns {dir_size, cumulative_eligible_dir_size}
  def process_dir(stream) do
    stream
    |> Stream.drop(1) # drop "ls"
    |> Stream.transform(
      fn -> {[], 0} end,
      &chunk_by_child/2,
      &last_child_chunk/1,
      fn _ -> :noop end)
    |> Stream.with_index()
    |> Stream.map(&(case &1 do
      {x, 0} -> process_files(x)
      {x, _} -> process_dir(x)
    end))
    |> Enum.reduce(fn x, a -> {elem(x, 0) + elem(a, 0), elem(x, 1) + elem(a, 1)} end)
    |> case do
      {size, acc_size} when size <= @eligible_dir_size -> {size, acc_size + size}
      x -> x
    end
  end

  def run do
    File.stream!("src/day7/input.txt", [])
    |> Stream.drop(1) # drop "cd /" at start
    |> Stream.map(&String.trim/1)
    |> process_dir
    |> elem(1)
  end
end

IO.puts Main.run()
