defmodule Day09 do
  def answer_part_1_example, do: answer_part_1("inputs/09/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/09/input.txt")

  def answer_part_1(file_path) do
    matrix = file_path |> read_file

    matrix
    |> get_low_points_coords
    |> Enum.map(fn {i, j} -> elem(elem(matrix, i), j) end)
    |> Enum.map(&(&1 + 1))
    |> Enum.sum()
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(fn number -> number |> String.to_integer() end)
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  def get_low_points_coords(matrix) do
    0..(tuple_size(matrix) - 1)
    |> Enum.reduce([], fn i, acc ->
      (0..(tuple_size(elem(matrix, i)) - 1)
       |> Enum.reduce([], fn j, acc ->
         point = elem(elem(matrix, i), j)

         left =
           if j - 1 < 0 do
             # a bigger number that won't interfere with the minimum computation
             10
           else
             elem(elem(matrix, i), j - 1)
           end

         right =
           if j + 1 > tuple_size(elem(matrix, i)) - 1 do
             10
           else
             elem(elem(matrix, i), j + 1)
           end

         top =
           if i - 1 < 0 do
             10
           else
             elem(elem(matrix, i - 1), j)
           end

         bottom =
           if i + 1 > tuple_size(matrix) - 1 do
             10
           else
             elem(elem(matrix, i + 1), j)
           end

         if point < left and point < right and point < top and point < bottom do
           [{i, j} | acc]
         else
           acc
         end
       end)) ++ acc
    end)
  end

  def answer_part_2_example, do: answer_part_2("inputs/09/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/09/input.txt")

  def answer_part_2(file_path) do
    matrix = file_path |> read_file

    matrix
    |> get_low_points_coords
    |> Enum.map(fn point -> look_around([], point, matrix) |> Enum.count() end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def look_around(basin, {i, j}, matrix) do
    cond do
      i < 0 or i > tuple_size(matrix) - 1 ->
        basin

      j < 0 or j > tuple_size(elem(matrix, i)) - 1 ->
        basin

      elem(elem(matrix, i), j) === 9 ->
        basin

      basin |> Enum.member?({i, j}) ->
        basin

      true ->
        [{i, j} | basin]
        |> look_around({i - 1, j}, matrix)
        |> look_around({i + 1, j}, matrix)
        |> look_around({i, j - 1}, matrix)
        |> look_around({i, j + 1}, matrix)
    end
  end
end
