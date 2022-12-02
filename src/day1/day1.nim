import std/os
import std/strutils
import std/math

var top = [0,0,0]
var sum: int

proc challengeTheTop(value: int, top: var array[0..2, int]) =
  # this is gross but oh well
  if value > top[1]:
    top[0] = top[1]
    if value > top[2]:
      top[1] = top[2]
      top[2] = value
    else:
      top[1] = value
  elif value > top[0]:
    top[0] = value

proc processLine(line: string) =
  # echo "processing ", line
  if line == "":
    challengeTheTop(sum, top)
    sum = 0
  else:
    sum = sum + parseInt(line)
  # for v in top:
  #   echo v
  # echo "\n"  

var input = readFile(getCurrentDir() & "/src/day1/input.txt")

for line in input.split("\n"):
  processLine(line)

processLine("")

echo "Top value: ", top[2]
echo "Top 3 sum: ", sum(top)