defmodule Day05 do
  def answer_part_1_example, do: answer_part_1("inputs/05/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/05/input.txt")

  def answer_part_1(file_path) do
    read_lines_from_file(file_path)
    |> filter_straight_lines
    |> Enum.flat_map(fn line -> line |> coords_covered_by_line() end)
    |> coords_covered_to_map(%{})
    |> count_points_covered
  end

  def read_lines_from_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn segment ->
      segment
      |> String.split(" -> ")
      |> Enum.map(fn point ->
        point
        |> String.split(",")
        |> Enum.map(fn digit -> digit |> String.to_integer() end)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end

  def filter_straight_lines(lines) do
    lines |> Enum.filter(fn {{x1, y1}, {x2, y2}} -> x1 === x2 or y1 === y2 end)
  end

  def coords_covered_by_line({{x1, y1}, {x2, y2}}) when x1 === x2 do
    [ya, yb] = Enum.sort([y1, y2])

    for value <- ya..yb do
      {x1, value}
    end
  end

  def coords_covered_by_line({{x1, y1}, {x2, y2}}) when y1 === y2 do
    [xa, xb] = Enum.sort([x1, x2])

    for value <- xa..xb do
      {value, y1}
    end
  end

  def coords_covered_by_line({{x1, y1}, {x2, y2}}) do
    for xi <- x1..x2,
        yi <- y1..y2,
        # To only keep diagonal
        abs(x1 - xi) === abs(y1 - yi) do
      {xi, yi}
    end
  end

  def coords_covered_to_map([coord | next_coords], map) do
    new_map = fill_map(coord, map)

    coords_covered_to_map(next_coords, new_map)
  end

  def coords_covered_to_map([], map), do: map

  def fill_map(coord, map) do
    Map.put(map, coord, (map[coord] || 0) + 1)
  end

  def count_points_covered(map) do
    map |> Map.values() |> Enum.count(fn covered_count -> covered_count > 1 end)
  end

  def answer_part_2_example, do: answer_part_2("inputs/05/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/05/input.txt")

  def answer_part_2(file_path) do
    read_lines_from_file(file_path)
    |> Enum.flat_map(fn line -> line |> coords_covered_by_line() end)
    |> coords_covered_to_map(%{})
    |> count_points_covered
  end
end
