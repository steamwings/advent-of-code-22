defmodule Main do

  defp decrement(a) do
    case a do
      # ?= -> ?+
      # ?- -> ?=
      ?0 -> ?-
      _ -> a-1
    end
  end

  # Strategy: recursive convert into quintary from MSD to LSD then parse
  # ex: "1=11-2" => "31042" => 2022
  # ex2: "1=-0-2" => "1=--42" => "1=="
  defp snafu_to_quintary(snafu) do
    case snafu do
      <<_>> -> IO.puts "og: #{snafu}"; snafu
      <<a,b>> ->
        #IO.puts "a,b: #{<<a,b>>} (#{a},#{b})"
        case b do
          #?+ -> << decrement(a), ?2 >>
          ?= -> << decrement(a), ?3 >>
          ?- -> << decrement(a), ?4 >>
          _ -> snafu
        end
      <<a,b,tail::binary>> ->
        <<c,d>> = snafu_to_quintary(<<a,b>>)
        #IO.puts "a,b: #{<<a,b>>}, tail: #{tail}, c,d: #{<<c,d>>}"
        <<e,tail2::binary>> = snafu_to_quintary(<<d>> <> tail)
        cond do
          e in ?0..?9 -> <<c,e>> <> tail2
          # If the next digit got decremented below 0
          true -> snafu_to_quintary(<<c,e>>) <> tail2
        end
    end
  end

  defp quintary_to_snafu(num) do
    case num do
      <<_>> -> num
      <<a,b>> ->
        case b do
          ?5 -> << (a+1), ?0 >>
          ?4 -> << (a+1), ?- >>
          ?3 -> << (a+1), ?= >>
          _ -> num
        end
      <<a,tail::binary>> ->
        <<b,rest::binary>> = quintary_to_snafu(tail)
        quintary_to_snafu(<<a,b>>) <> rest
    end
  end

  def snafu_to_decimal(snafu) do
    snafu_to_quintary(snafu)
    |> String.to_integer(5)
  end

  defp decimal_to_snafu(num) do
    quintary_to_snafu("0" <> Integer.to_string(num, 5))
    |> String.trim_leading("0")
  end

  # NOTE: A better strategy is probably just to add the snafu numbers
  # and never convert at all. I may implement this later...
  def part1(stream) do
    stream
    |> Stream.map(&snafu_to_decimal(&1))
    |> Enum.reduce(fn x, sum -> x + sum end)
    |> decimal_to_snafu
    |> IO.puts
  end

  def run(file) do
    contents = File.stream!(file, [])
    |> Stream.map(&String.trim/1)
    #|> Stream.map(&tap(&1,fn x -> IO.puts "line: #{x}" end))

    # Examples
    # snafu_to_decimal("1=11-2")
    # |> IO.puts

    # decimal_to_snafu(2022)
    # |> IO.puts

    part1(contents)
  end
end

Main.run("src/day25/input.txt")
