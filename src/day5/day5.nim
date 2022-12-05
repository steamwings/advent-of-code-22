import std/os
import std/strutils

type
  Instruction = object
    count: int
    source: int
    dest: int

proc getRowsAndCount(file: File): (seq[string], int) =
  var rows = newSeqOfCap[string](8)
  var line: string
  line = file.readLine()
  while not line.startsWith(" 1"):
    rows.add(line)
    line = file.readLine()
  return (rows, parseInt($line[^2]))

proc buildSeqs(file: File): seq[seq[char]] =
  var (rows, count) = getRowsAndCount(file)
  var capacity = len(rows) * count
  result = newSeqofCap[seq[char]](count)
  for i in 0 ..< count:
    result.add(newSeqOfCap[char](capacity))
  for rowIndex in countdown(high(rows), low(rows)):
    var readIndex: int = 1
    for stackIndex in 0 ..< count:
      var crate = rows[rowIndex][readIndex]
      if crate != ' ':
        result[stackIndex].add(crate)
      readIndex += 4

proc getInstr(file: File): Instruction =
  var pieces = file.readLine().split(' ')
  return Instruction(
    count: parseInt(pieces[1]),
    source: parseInt(pieces[3]) - 1,
    dest: parseInt(pieces[5]) - 1
  )

proc getTops(stacks: seq[seq[char]]): string =
  for stack in stacks:
    if len(stack) == 0: continue
    result.add(stack[^1])
  # Not sure why this doesn't work
  # return foldl(stacks, a.add(b[^1]), "")

proc mover9000(inst: Instruction, stacks: var seq[seq[char]]) =
  for i in 0 ..< inst.count:
    stacks[inst.dest].add(stacks[inst.source][^1])
    stacks[inst.source].delete(len(stacks[inst.source]) - 1)

proc mover9001(inst: Instruction, stacks: var seq[seq[char]]) =
  for i in countdown(inst.count,1):
    stacks[inst.dest].add(stacks[inst.source][^i])
  # I'm not proud of the choices I've made
  for i in 0 ..< inst.count:
    stacks[inst.source].delete(len(stacks[inst.source]) - 1)

proc getTopsAtEnd(file: File, stacks: var seq[seq[char]]): string =
  discard file.readLine() # Blank line
  while not file.endOfFile():
    #echo getTops(stacks)
    var inst = getInstr(file)
    # mover9000(inst, stacks) # PART 1
    mover9001(inst, stacks) # PART 2
  file.close()
  getTops(stacks)

proc solve(filename: string): string =
  var file = filename.open()
  var stacks = buildSeqs(file)
  return getTopsAtEnd(file, stacks)

let filename = currentSourcePath.parentDir() & "/input.txt"
let result = solve(filename)
echo result
