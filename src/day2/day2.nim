import std/os
import std/strutils

type
  Gesture = enum
    Rock = 1, Paper = 2, Scissors = 3
  Outcome = enum
    Loss = 0, Draw = 3, Win = 6

# the "win" or "loss" is that of the second player/gesture
proc resolve(g1: Gesture, g2: Gesture): Outcome =
  case g1
  of Rock:
    case g2
    of Rock: result = Draw
    of Paper: result = Win
    of Scissors: result = Loss
  of Paper:
    case g2
    of Rock: result = Loss
    of Paper: result = Draw
    of Scissors: result = Win
  of Scissors:
    case g2
    of Rock: result = Win
    of Paper: result = Loss
    of Scissors: result = Draw

proc resolve(g: Gesture, o: Outcome): Gesture =
  case g
  of Rock:
    case o
    of Draw: result = Rock
    of Win: result = Paper
    of Loss: result = Scissors
  of Paper:
    case o
    of Loss: result = Rock
    of Draw: result = Paper
    of Win: result = Scissors
  of Scissors:
    case o
    of Win: result = Rock
    of Loss: result = Paper
    of Draw: result = Scissors

proc getGesture(c: char): Gesture =
  case c
  of 'A','X': Rock
  of 'B','Y': Paper
  of 'C','Z': Scissors
  else: echo "Bad input. Exiting."; quit()

proc getOutcome(c: char): Outcome =
  case c
  of 'X': Loss
  of 'Y': Draw
  of 'Z': Win
  else: echo "Bad input. Exiting."; quit()

proc runPart1Round(line: string): int =
  var g1: Gesture = getGesture(line[0])
  var g2: Gesture = getGesture(line[2])
  ord(resolve(g1, g2)) + ord(g2)
  
proc runPart2Round(line: string): int =
  var g1: Gesture = getGesture(line[0])
  var o: Outcome = getOutcome(line[2])
  ord(resolve(g1, o)) + ord(o)

proc runGame(filename: string): (int, int) =
  result = (0,0)
  for line in filename.lines:
    result[0] += runPart1Round(line)
    result[1] += runPart2Round(line)

var filename = currentSourcePath.parentDir() & "/input.txt"
var results = runGame(filename)
echo "Part 1 score: ", results[0]
echo "Part 2 score: ", results[1] 