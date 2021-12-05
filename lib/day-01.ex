defmodule Day01 do
  def answer_part_1_example, do: answer_part_1("inputs/01/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/01/input.txt")

  def answer_part_1(file_path), do: get_items_from_file(file_path) |> count_increases(0)

  def get_items_from_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def count_increases([first | [second | tail]], accumulator) when second > first,
    do: count_increases([second | tail], accumulator + 1)

  def count_increases([_first | [second | tail]], accumulator),
    do: count_increases([second | tail], accumulator)

  def count_increases([_last], accumulator), do: accumulator

  def answer_part_2_example, do: answer_part_2("inputs/01/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/01/input.txt")

  def answer_part_2(file_path), do: get_items_from_file(file_path) |> count_3_increases(0)

  def count_3_increases([head | tail], accumulator) when length(tail) >= 3 do
    window_1 = head + Enum.at(tail, 0) + Enum.at(tail, 1)
    window_2 = Enum.at(tail, 0) + Enum.at(tail, 1) + Enum.at(tail, 2)

    if window_2 > window_1 do
      count_3_increases(tail, accumulator + 1)
    else
      count_3_increases(tail, accumulator)
    end
  end

  def count_3_increases(_last, accumulator), do: accumulator
end
