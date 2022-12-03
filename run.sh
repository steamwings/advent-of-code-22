#!/bin/bash
eval "nim c -o:bin/day$1 -p:lib -d:release --verbosity:0 -r src/day$1/day$1.nim"
