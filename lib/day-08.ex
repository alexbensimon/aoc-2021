defmodule Day08 do
  def answer_part_1_example, do: answer_part_1("inputs/08/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/08/input.txt")

  def answer_part_1(file_path) do
    file_path |> read_file |> get_ouputs |> count_easy_digits
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1, " | ") |> List.to_tuple()))
  end

  def get_ouputs(entries) do
    entries |> Enum.flat_map(fn {_input, output} -> output |> String.split() end)
  end

  def count_easy_digits(outputs) do
    outputs
    |> Enum.count(fn output ->
      String.length(output) === 2 or
        String.length(output) === 3 or
        String.length(output) === 4 or
        String.length(output) === 7
    end)
  end

  def answer_part_2_example, do: answer_part_2("inputs/08/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/08/input.txt")

  def answer_part_2(file_path) do
    file_path |> read_file |> Enum.map(&analyse_entry/1) |> Enum.sum()
  end

  def analyse_entry({input, output}) do
    map = input |> find_input_digits

    output
    |> String.split()
    |> Enum.map(fn pattern -> pattern |> String.graphemes() |> Enum.sort() end)
    |> Enum.reduce([], fn pattern, acc -> acc ++ [map[pattern]] end)
    |> Enum.join()
    |> String.to_integer()
  end

  def find_input_digits(input) do
    patterns =
      input
      |> String.split()
      |> Enum.map(fn pattern -> pattern |> String.graphemes() |> Enum.sort() end)

    patterns |> find_easy_digits |> find_6 |> find_0_9 |> find_5 |> find_2_3
  end

  def find_easy_digits(patterns) do
    length_to_digit = %{
      2 => 1,
      3 => 7,
      4 => 4,
      7 => 8
    }

    patterns
    |> Enum.reduce(%{patterns: patterns}, fn pattern, map ->
      digit = length_to_digit[length(pattern)]

      if digit do
        map
        |> Map.put(pattern, digit)
        |> Map.put(digit, pattern)
        # We only keep the remaining patterns in the map for easy access
        |> Map.update!(:patterns, fn patterns -> patterns -- [pattern] end)
      else
        map
      end
    end)
  end

  def find_6(map) do
    pattern_6 =
      map[:patterns]
      |> Enum.filter(fn pattern -> length(pattern) === 6 end)
      # Of all the 6-segment digits, 6 is the only one not to contain all of the segments of 1
      |> Enum.find(fn pattern -> length(map[1] -- pattern) === 1 end)

    map
    |> Map.put(pattern_6, 6)
    |> Map.put(6, pattern_6)
    |> Map.update!(:patterns, fn patterns -> patterns -- [pattern_6] end)
  end

  def find_0_9(map) do
    pattern_0_or_9 =
      map[:patterns]
      |> Enum.filter(fn pattern -> length(pattern) === 6 end)

    # 9 contains all the segments of 4 so we know that this is 0
    pattern_0 = pattern_0_or_9 |> Enum.find(fn pattern -> length(map[4] -- pattern) === 1 end)
    pattern_9 = (pattern_0_or_9 -- [pattern_0]) |> List.flatten()

    map
    |> Map.put(pattern_0, 0)
    |> Map.put(0, pattern_0)
    |> Map.put(pattern_9, 9)
    |> Map.put(9, pattern_9)
    |> Map.update!(:patterns, fn patterns -> patterns -- [pattern_0, pattern_9] end)
  end

  def find_5(map) do
    pattern_5 =
      map[:patterns]
      |> Enum.filter(fn pattern -> length(pattern) === 5 end)
      # 5 and 6 only have 1 segment not in common
      |> Enum.find(fn pattern -> length(map[6] -- pattern) === 1 end)

    map
    |> Map.put(pattern_5, 5)
    |> Map.put(5, pattern_5)
    |> Map.update!(:patterns, fn patterns -> patterns -- [pattern_5] end)
  end

  def find_2_3(map) do
    pattern_2_or_3 =
      map[:patterns]
      |> Enum.filter(fn pattern -> length(pattern) === 5 end)

    # 3 contains all the segments of 1 so we know that this is 2
    pattern_2 = pattern_2_or_3 |> Enum.find(fn pattern -> length(map[1] -- pattern) === 1 end)
    pattern_3 = (pattern_2_or_3 -- [pattern_2]) |> List.flatten()

    map
    |> Map.put(pattern_2, 2)
    |> Map.put(2, pattern_2)
    |> Map.put(pattern_3, 3)
    |> Map.put(3, pattern_3)
    |> Map.update!(:patterns, fn patterns -> patterns -- [pattern_2, pattern_3] end)
  end
end
