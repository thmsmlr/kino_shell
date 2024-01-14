# KinoShell

[![KinoShell version](https://img.shields.io/hexpm/v/kino_shell.svg)](https://hex.pm/packages/kino_shell)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/kino_shell/)

<img width="1420" alt="kino_shell" src="https://github.com/thmsmlr/kino_shell/assets/167206/b9bb5e61-053f-4f51-80d8-f4f8bfaf13cc">

Just a simple smartcell to run a bash script.
You can run it in the background or as an auto restarting daemon.

Why? Well you see, I use [Livebook](https://livebook.dev) for data analysis for my company.
Yes, eventually I'll have to setup a proper data warehouse and start doing my business intelligence by querying that.
But eventually will come. Today, I just want to rsync my sqlite database from my prod server to backup and do some analysis.
This project makes things like that about 30% nicer. 

You can judge me, or you can be impressed by me.
What you can't do, is deny the usefulness of `kino_shell`.


## Installation

To bring `kino_shell` to Livebook all you need to do is Mix.install/2:

```elixir
Mix.install([
  {:kino_shell, "~> 0.1.1"}
])
```

