import std/os
import std/strutils

var input = readFile(getCurrentDir() & "/src/day1/input.txt")

var cur_max, sum: int
for line in input.split("\n"):
  if line == "":
    cur_max = max(cur_max, sum)
    sum = 0
  else:
    sum = sum + parseInt(line)

echo "answer: ", cur_max