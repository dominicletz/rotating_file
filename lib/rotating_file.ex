defmodule RotatingFile do
  @moduledoc """
  A GenServer that rotates a log file when it reaches a certain size.
  It creates a new compressed log file and deletes the oldest ones when the number of files exceeds the limit.

  """

  @compress_cmds [
    {"zstd", ["--rm"]},
    {"xz", []},
    {"gzip", []}
  ]

  defstruct [:cmd, :max_size, :max_files, :log_file]
  use GenServer

  @doc """
  Starts the rotating file server.

  ## Options

  - `:name` - The name of the GenServer process. Defaults to `RotatingFile`.
  - `:max_size` - The maximum size of the log file in bytes. Defaults to `100 * 1024 * 1024`.
  - `:max_files` - The maximum number of log files to keep. Defaults to `10`.
  - `:log_file` - The path to the log file. Defaults to `"output.log"`.

  ## Example

  ```elixir
  RotatingFile.start_link(name: :rotating_file, max_size: 100 * 1024 * 1024, max_files: 10, log_file: "stdout.log")
  ```
  """
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    {max_size, opts} = Keyword.pop(opts, :max_size, 100 * 1024 * 1024)
    {max_files, opts} = Keyword.pop(opts, :max_files, 10)
    {log_file, opts} = Keyword.pop(opts, :log_file, "output.log")

    if length(opts) > 0 do
      raise "Unknown extra options: #{inspect(opts)}"
    end

    cmd =
      Enum.find(@compress_cmds, fn {cmd, _} -> System.find_executable(cmd) end) ||
        raise "No compression tool found"

    state = %RotatingFile{cmd: cmd, max_size: max_size, max_files: max_files, log_file: log_file}
    GenServer.start_link(__MODULE__, state, name: name, hibernate_after: 10_000)
  end

  @doc """
  Adds bytes to the log file. When no pid or name is provided, it will use the default module name.

  ## Example

  ```elixir
  RotatingFile.write(:rotating_file, "Hello, world!\n")
  ```
  """
  def write(pid \\ __MODULE__, bytes) do
    GenServer.cast(pid, {:write, bytes})
  end

  @doc """
  Deletes all log files.
  """
  def delete_all(pid \\ __MODULE__) do
    GenServer.cast(pid, :delete_all)
  end

  @doc """
  Ensures the log file is synced to disk.
  """
  def sync(pid \\ __MODULE__) do
    GenServer.call(pid, :sync)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:write, bytes}, state) do
    {:noreply, write_to_log(state, bytes)}
  end

  @impl true
  def handle_cast(:delete_all, state) do
    {:noreply, do_delete_all(state)}
  end

  @impl true
  def handle_call(:sync, _from, state) do
    {:reply, :ok, state}
  end

  defp write_to_log(state, bytes) do
    File.write!(state.log_file, bytes, [:append])
    rotate_if_needed(state)
    state
  end

  defp rotate_if_needed(state) do
    with {:ok, %{size: size}} when size > state.max_size <- File.stat(state.log_file) do
      rotate_log(state)
    end
  end

  defp rotate_log(state) do
    compressed_name = "#{state.log_file}.#{:os.system_time(:seconds)}"
    File.rename(state.log_file, compressed_name)

    spawn(fn ->
      {cmd, args} = state.cmd
      System.cmd(cmd, args ++ [compressed_name])
      do_delete_old_logs(state)
    end)
  end

  defp do_delete_old_logs(state) do
    File.ls!(Path.dirname(state.log_file))
    |> Enum.sort(:desc)
    |> Enum.filter(&String.starts_with?(&1, state.log_file <> "."))
    |> Enum.drop(state.max_files)
    |> Enum.each(&File.rm/1)
  end

  defp do_delete_all(state) do
    File.ls!(Path.dirname(state.log_file))
    |> Enum.filter(&String.starts_with?(&1, state.log_file))
    |> Enum.each(&File.rm/1)

    state
  end
end
