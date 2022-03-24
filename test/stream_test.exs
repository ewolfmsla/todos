defmodule MyTest do
  use ExUnit.Case, async: true

  @target_len 6
  @target_file "./foo.txt"

  setup_all do
    text = """
    this is line one
    test
    this is another line
    hello
    that's weird
    """

    {:ok, text: text}
  end

  test "return number of words per line", %{text: text} do
    {:ok, stream} =
      text
      |> StringIO.open()

    words_per_line =
      stream
      |> IO.binstream(:line)
      |> Stream.map(&String.split(&1, " "))
      |> Enum.map(&Kernel.length(&1))

    assert [4, 1, 4, 1, 2] == words_per_line
  end

  test "return lines having 4 words", %{text: text} do
    {:ok, stream} =
      text
      |> StringIO.open()

    four_word_lines =
      stream
      |> IO.binstream(:line)
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Stream.map(&String.split(&1, " "))
      |> Stream.filter(&(length(&1) == 4))
      |> Stream.map(&Enum.join(&1, " "))
      |> Enum.reduce([], fn elem, acc -> acc ++ [elem] end)

    assert ["this is line one", "this is another line"] == four_word_lines
  end

  test "returns lines from file where line length < #{@target_len}" do
    filtered_lines =
      File.stream!(@target_file)
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Stream.filter(&(String.length(&1) < @target_len))
      |> Stream.map(&("-" <> &1 <> "-"))
      |> Enum.map(& &1)

    assert ["-hello-"] == filtered_lines
  end

  test "returns lines from text where line length < #{@target_len}", %{text: text} do
    {:ok, stream} =
      text
      |> StringIO.open()

    filtered_lines =
      stream
      |> IO.binstream(:line)
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Stream.filter(&(String.length(&1) < @target_len))
      |> Enum.map(& &1)

    assert ["test", "hello"] == filtered_lines
  end
end
