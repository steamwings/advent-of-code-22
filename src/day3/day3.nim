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

proc dedup_sort(s: var seq[char]) =
  let new_len = dedup_selection_sort(s)
  if new_len < len(s): s.delete(new_len ..< len(s))

proc solve(filename: string): int =
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


var filename = currentSourcePath.parentDir() & "/input.txt"
echo solve(filename)