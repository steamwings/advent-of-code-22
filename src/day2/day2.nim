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

proc getGesture(c: char): Gesture =
  case c
  of 'A','X': Rock
  of 'B','Y': Paper
  of 'C','Z': Scissors
  else: echo "Bad input. Exiting."; quit()

proc runRound(line: string): int =
  var g1: Gesture = getGesture(line[0])
  var g2: Gesture = getGesture(line[2])
  ord(resolve(g1, g2)) + ord(g2)

proc runGame(filename: string): int =
  for line in filename.lines:
    result += runRound(line)

var filename = currentSourcePath.parentDir() & "/input.txt"
echo "My score: ", runGame(filename)