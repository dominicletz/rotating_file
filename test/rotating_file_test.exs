defmodule RotatingFileTest do
  use ExUnit.Case
  doctest RotatingFile

  test "logs hello world" do
    {:ok, pid} = RotatingFile.start_link(file: "test.log")
    RotatingFile.delete_all(pid)
    RotatingFile.write(pid, "hello world\n")
    RotatingFile.sync(pid)
    assert File.read!("test.log") == "hello world\n"
  end

  test "logs in subdir hello world" do
    File.mkdir_p!("subdir")
    {:ok, pid} = RotatingFile.start_link(file: "subdir/test.log")
    RotatingFile.delete_all(pid)
    RotatingFile.write(pid, "hello world\n")
    RotatingFile.sync(pid)
    assert File.read!("subdir/test.log") == "hello world\n"
  end

  test "old file cleanup" do
    File.mkdir_p!("subdir2")
    {:ok, pid} = RotatingFile.start_link(file: "subdir2/test.log", max_size: 10, max_files: 1)
    RotatingFile.delete_all(pid)
    RotatingFile.write(pid, "hello world 1\n")
    RotatingFile.sync(pid)
    RotatingFile.write(pid, "hello world 2\n")
    RotatingFile.sync(pid)
    RotatingFile.write(pid, "hello world 3\n")
    RotatingFile.sync(pid)
    assert length(File.ls!("subdir2")) == 1
  end
end
