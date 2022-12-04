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

proc solve(filename: string): (int,int) =
  result = (0,0)
  for line in filename.lines:
    let numbers = line.split({',','-'}).map((n) => parseInt(n)) 
    # Part 1
    if oneIncludesTheOther(
      sign(numbers[3] - numbers[1]), 
      sign(numbers[2] - numbers[0])):
        inc(result[0])
    # Part 2
    var overlap_diff = 
      if numbers[0] < numbers[2]:
        numbers[2] - numbers[1]
      else:
        numbers[0] - numbers[3]
    if overlap_diff <= 0:
      inc(result[1])
    
let filename = currentSourcePath.parentDir() & "/input.txt"
let result = solve(filename)
echo "Part 1: ", result[0]
echo "Part 2: ", result[1]