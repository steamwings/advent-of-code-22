# 🎄 Advent of Code 2022 🎄

https://adventofcode.com/

I try to push solutions right after submitting my answer. My goals:
1. ~~Learn some nim~~
2. Learn some elixir
3. Maybe sometimes attempt a mildly interesting (if inefficient) algorithm

## Run it
Run day X code:

```sh
./run.sh X
```
For days 1-5, [nim](https://nim-lang.org/install.html) is used. (I used `1.6.10`.)
For days 6+, [elixir](https://elixir-lang.org/install.html) is used. (I have `1.14.1`.)

## Installing Elixir

This was a bit more complicated than installing nim, so here were my steps:
- Install [asdf](https://github.com/asdf-vm/asdf)
- Install the asdf plugins for [erlang](https://github.com/asdf-vm/asdf-erlang) and [elixir](https://github.com/asdf-vm/asdf-elixir).
- `sudo apt install libncurses5-dev automake autoconf`: You may not need this. I needed this for the next step to work. (I'm using Ubuntu 20.04 WSL.)
- `asdf install erlang 25.1.2`
- `asdf install elixir 1.14.1-otp-25`
- Added the .tool-versions file to this repo for `asdf`