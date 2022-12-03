import std/os
import std/sequtils
import std/strformat
import sort

proc itemValue(c: char): int =
  var o = ord(c)
  case o
  of 65..90: result = o - 38
  of 97..122: result = o - 96
  else: echo fmt("Bad character input '{cast[char](o)}'. Exiting."); quit()
  
proc findMatch[T](a: openArray[T], b: openArray[T]): T =
  var j = 0
  for i in 0 ..< len(a):
    while b[j] < a[i]:
      inc(j)
    if a[i] == b[j]: return a[i]
  raise

proc findMatch[T](a: openArray[T], b: openArray[T], c: openArray[T]): T =
  var j, k: int
  for i in 0 ..< len(a):
    while b[j] < a[i]:
      inc(j)
    while c[k] < a[i]:
      inc(k)
    if a[i] == b[j] and a[i] == c[k]: return a[i]
  raise

proc dedup_sort(s: var seq[char]) =
  let new_len = dedup_selection_sort(s)
  if new_len < len(s): s.delete(new_len ..< len(s))

proc solvePart1(filename: string): int =
  for line in filename.lines:
    # echo line
    let mid = len(line) div 2
    var half1 = cast[seq[char]](line[0 ..< mid])
    var half2 = cast[seq[char]](line[mid .. ^1])
    dedup_sort(half1)
    dedup_sort(half2)
    let match = findMatch(half1, half2)
    # echo "match: ", match
    result += itemValue(match)

proc solvePart2(filename: string): int =
  var f = filename.open()
  while not f.endOfFile():
    var line1 = cast[seq[char]](f.readLine())
    var line2 = cast[seq[char]](f.readLine())
    var line3 = cast[seq[char]](f.readLine())
    dedup_sort(line1)
    dedup_sort(line2)
    dedup_sort(line3)
    result += itemValue(findMatch(line1, line2, line3))
    

var filename = currentSourcePath.parentDir() & "/input.txt"
echo "Part 1: ", solvePart1(filename)
echo "Part 2: ", solvePart2(filename)