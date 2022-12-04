import sequtils
import std/os
import std/strutils
import sugar

type
  Sign = enum
    Zero = 0, Negative, Positive

proc sign(n: int): Sign =
  if n == 0: return Zero
  elif n > 0: return Positive
  else: return Negative

proc oneIncludesTheOther(s1: Sign, s2: Sign): bool =
  return Zero in {s1, s2} or s1 != s2

proc solvePart1(filename: string): int =
  for line in filename.lines:
    let numbers = line.split({',','-'}).map((n) => parseInt(n)) 
    if oneIncludesTheOther(
      sign(numbers[3] - numbers[1]), 
      sign(numbers[2] - numbers[0])):
        inc(result)

proc solvePart2(filename: string): int =
  var f = filename.open()
  while not f.endOfFile():
    raise
    
var filename = currentSourcePath.parentDir() & "/input.txt"
echo "Part 1: ", solvePart1(filename)
#echo "Part 2: ", solvePart2(filename)