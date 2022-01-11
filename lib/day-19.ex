defmodule Day19 do
  def answer_part_1_example, do: answer_part_1("inputs/19/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/19/input.txt")

  def answer_part_1(file_path) do
    {aligned, scanners_to_align} =
      file_path
      |> read_file()
      |> List.pop_at(0)

    {aligned, _} = align_next_match(aligned, [{0, 0, 0}], scanners_to_align)
    aligned |> Enum.count()
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn scanner ->
      scanner
      |> String.split("\n", trim: true)
      |> List.delete_at(0)
      |> Enum.map(fn coords ->
        coords
        |> String.split(",")
        |> Enum.map(fn num -> num |> String.to_integer() end)
        |> List.to_tuple()
      end)
    end)
  end

  def compute_lengths_between_points([], lengths), do: lengths

  def compute_lengths_between_points([{x1, y1, z1} | points], lengths) do
    lengths =
      points
      |> Enum.reduce(lengths, fn {x2, y2, z2}, lengths ->
        length = square(x2 - x1) + square(y2 - y1) + square(z2 - z1)
        [{length, {{x1, y1, z1}, {x2, y2, z2}}} | lengths]
      end)

    compute_lengths_between_points(points, lengths)
  end

  def square(num) do
    num |> Integer.pow(2)
  end

  def align_next_match(aligned, scanners_coords, []), do: {aligned, scanners_coords}

  def align_next_match(aligned, scanners_coords, scanners_to_align) do
    {aligned, scanner_coords, i} =
      scanners_to_align
      |> Enum.with_index()
      |> Enum.reduce_while({aligned, 0}, fn {scanner, i}, acc ->
        common_points =
          common_points(
            compute_lengths_between_points(aligned, []),
            compute_lengths_between_points(scanner, [])
          )

        # 66 distances is 12 points
        if common_points |> length >= 66 do
          {aligned, scanner_coords} = align_scanner(aligned, scanner, common_points)
          {:halt, {aligned, scanner_coords, i}}
        else
          {:cont, acc}
        end
      end)

    align_next_match(
      aligned,
      [scanner_coords | scanners_coords],
      scanners_to_align |> List.delete_at(i)
    )
  end

  def align_scanner(aligned, to_align, common_points) do
    [{_, [{_, points_aligned}, {_, points_to_align}]} | _] = common_points
    {{x1, y1, z1}, {x2, y2, z2}} = points_aligned
    {{x3, y3, z3}, {x4, y4, z4}} = points_to_align

    {rotation, {a, b, c}} =
      0..23
      |> Enum.reduce_while({-1, {0, 0, 0}}, fn rotation, acc ->
        {a1, b1, c1} = points_offset({x1, y1, z1}, rotate_point({x3, y3, z3}, rotation))
        {a2, b2, c2} = points_offset({x2, y2, z2}, rotate_point({x4, y4, z4}, rotation))

        if a1 === a2 and b1 === b2 and c1 === c2 do
          {:halt, {rotation, {a1, b1, c1}}}
        else
          {:cont, acc}
        end
      end)

    if rotation === -1 do
      align_scanner(aligned, to_align, common_points |> List.delete_at(0))
    else
      aligned =
        (aligned ++
           (to_align
            |> Enum.map(fn point ->
              {x, y, z} = point |> rotate_point(rotation)
              {x + a, y + b, z + c}
            end)))
        |> Enum.uniq()

      {aligned, {a, b, c}}
    end
  end

  def common_points(lengths1, lengths2) do
    (lengths1 ++ lengths2)
    |> Enum.group_by(fn {length, _} -> length end)
    |> Enum.filter(fn {_, matches} -> length(matches) === 2 end)
  end

  def points_offset({x1, y1, z1}, {x2, y2, z2}) do
    {x1 - x2, y1 - y2, z1 - z2}
  end

  def rotate_point({x, y, z}, rotation) do
    case rotation do
      0 -> {x, y, z}
      1 -> {-y, x, z}
      2 -> {-x, -y, z}
      3 -> {y, -x, z}
      4 -> {-z, y, x}
      5 -> {-y, -z, x}
      6 -> {z, -y, x}
      7 -> {y, z, x}
      8 -> {-x, y, -z}
      9 -> {-y, -x, -z}
      10 -> {x, -y, -z}
      11 -> {y, x, -z}
      12 -> {z, y, -x}
      13 -> {-y, z, -x}
      14 -> {-z, -y, -x}
      15 -> {y, -z, -x}
      16 -> {x, -z, y}
      17 -> {z, x, y}
      18 -> {-x, z, y}
      19 -> {-z, -x, y}
      20 -> {x, z, -y}
      21 -> {-z, x, -y}
      22 -> {-x, -z, -y}
      23 -> {z, -x, -y}
    end
  end

  def answer_part_2_example, do: answer_part_2("inputs/19/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/19/input.txt")

  def answer_part_2(file_path) do
    {aligned, scanners_to_align} =
      file_path
      |> read_file()
      |> List.pop_at(0)

    {_, scanners_coords} = align_next_match(aligned, [{0, 0, 0}], scanners_to_align)

    scanners_coords |> manhattan_distances([]) |> Enum.max()
  end

  def manhattan_distances([], distances), do: distances

  def manhattan_distances([{x1, y1, z1} | points], distances) do
    distances =
      points
      |> Enum.reduce(distances, fn {x2, y2, z2}, distances ->
        distance = abs(x2 - x1) + abs(y2 - y1) + abs(z2 - z1)
        [distance | distances]
      end)

    manhattan_distances(points, distances)
  end
end
