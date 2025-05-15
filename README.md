# RotatingFile

Simple rotating file writer for additional logs that shouldn't go into the main application log.

```elixir
# Rotate every 10mb, don't keep more than 10 files
{:ok, pid} = RotatingFile.start_link(log_file: "test.log", max_size: 10*1024*1024, max_files: 10)
RotatingFile.write(pid, "hello world\n")
```

This will create a `test.log` file and also `test.log.<timestamp>.(zstd|xz|gz)`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rotating_file` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rotating_file, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/rotating_file>.

