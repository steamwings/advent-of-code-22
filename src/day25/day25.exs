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

  def part1(stream) do
    stream
    |> Stream.map(&snafu_to_decimal(&1))
    |> Enum.reduce(fn x, sum -> x + sum end)
    |> decimal_to_snafu
    |> IO.puts
  end

  defp decimal_digit(snafu_digit_ascii) do
    case snafu_digit_ascii do
      ?= -> -2
      ?- -> -1
      _ -> snafu_digit_ascii - ?0
    end
  end

  # single digits only
  defp _snafu_add(x,y,z) do
    [x,y,z]
    |> Enum.map(&decimal_digit(&1))
    #|> Enum.map(&tap(&1, fn x -> IO.puts(x) end))
    |> Enum.reduce(&(&1 + &2))
    |> case do
      -6 -> "--"
      -5 -> "-0"
      -4 -> "-1"
      -3 -> "-2"
      -2 -> "0="
      -1 -> "0-"
      0 -> "00"
      1 -> "01"
      2 -> "02"
      3 -> "1="
      4 -> "1-"
      5 -> "10"
      6 -> "11"
    end
  end

  defp _snafu_add(x, y) do
    #IO.puts "x: #{x}, y: #{y}"
    case x do # x and y should have equal length
      <<x1>> ->
        <<y1>> = y
        _snafu_add(x1,y1,?0)
      <<x1, xrest::binary>> ->
        <<y1, yrest::binary>> = y
        <<z, rest::binary>> = _snafu_add(xrest, yrest)
        _snafu_add(x1,y1,z) <> rest
    end
  end

  def snafu_add(x, y) do
    lx = String.length(x)
    ly = String.length(y)
    len_result = max(lx,ly) + 1
    _snafu_add(
      String.pad_leading(x, len_result, ["0"]),
      String.pad_leading(y, len_result, ["0"])
    )
    |> String.trim_leading("0")
  end

  def part1_alt(stream) do
    stream
    |> Enum.reduce(fn x, sum -> snafu_add(x,sum) end)
    |> IO.puts
  end

  def run(file) do
    contents = File.stream!(file, [])
    |> Stream.map(&String.trim/1)
    #|> Stream.map(&tap(&1,fn x -> IO.puts "line: #{x}" end))

    # Examples
    # snafu_to_decimal("1=11-2")
    # |> IO.puts

    # snafu_to_decimal("20-0=1-=2=")
    # |> IO.puts

    # decimal_to_snafu(2022)
    # |> IO.puts

    # answer: 20-0--0-10
    # snafu_add("1=11-2", "20-0=1-=2=")
    # |> IO.puts

    # Actually run it
    #part1(contents) # Convert to quintary, sum, convert back
    part1_alt(contents) # Do sum with snafu numbers directly
  end
end

Main.run("src/day25/example.txt")
