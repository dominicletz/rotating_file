defmodule RotatingFileTest do
  use ExUnit.Case
  doctest RotatingFile

  test "logs hello world" do
    {:ok, pid} = RotatingFile.start_link(log_file: "test.log")
    RotatingFile.delete_all(pid)
    RotatingFile.write(pid, "hello world\n")
    RotatingFile.sync(pid)
    assert File.read!("test.log") == "hello world\n"
  end

  test "logs in subdir hello world" do
    File.mkdir_p!("subdir")
    {:ok, pid} = RotatingFile.start_link(log_file: "subdir/test.log")
    RotatingFile.delete_all(pid)
    RotatingFile.write(pid, "hello world\n")
    RotatingFile.sync(pid)
    assert File.read!("subdir/test.log") == "hello world\n"
  end
end
