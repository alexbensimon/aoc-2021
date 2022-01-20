defmodule Day22 do
  def answer_part_1_example, do: answer_part_1("inputs/22/example-1.txt")

  def answer_part_1_input, do: answer_part_1("inputs/22/input-1.txt")

  def answer_part_1(file_path) do
    file_path
    |> read_file()
    |> execute_steps([])
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    regex = ~r"(\w+) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)"

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> Regex.scan(regex, line) |> List.flatten() end)
    |> Enum.map(fn [_, mode, x1, x2, y1, y2, z1, z2] ->
      {mode, String.to_integer(x1), String.to_integer(x2), String.to_integer(y1),
       String.to_integer(y2), String.to_integer(z1), String.to_integer(z2)}
    end)
  end

  def execute_steps([], cubes), do: cubes |> Enum.count()

  def execute_steps([step | next_steps], cubes) do
    {mode, x1, x2, y1, y2, z1, z2} = step

    step_cubes = list_cubes({x1, x2, y1, y2, z1, z2})

    cubes =
      case mode do
        "on" ->
          (cubes ++ step_cubes) |> Enum.uniq()

        "off" ->
          cubes -- step_cubes
      end

    execute_steps(next_steps, cubes)
  end

  def list_cubes({x1, x2, y1, y2, z1, z2}) do
    for x <- x1..x2, y <- y1..y2, z <- z1..z2 do
      {x, y, z}
    end
  end

  def answer_part_2_example, do: answer_part_2("inputs/22/example-2.txt")

  def answer_part_2_input, do: answer_part_2("inputs/22/input-2.txt")

  def answer_part_2(file_path) do
    file_path
    |> read_file()
    |> execute_steps_part_2([])
    |> count_cubes(0)
  end

  def execute_steps_part_2([], ranges), do: ranges

  def execute_steps_part_2([step | next_steps], ranges) do
    ranges = merge_ranges(step, ranges)

    execute_steps_part_2(next_steps, ranges)
  end

  def merge_ranges(step, ranges) do
    {mode, _x1, _x2, _y1, _y2, _z1, _z2} = step

    ranges =
      ranges
      |> Enum.reduce(ranges, fn range, acc ->
        int_range = intersection_range(step, range)

        if int_range !== nil do
          acc ++ [int_range]
        else
          acc
        end
      end)

    if mode === "on" do
      ranges ++ [step]
    else
      ranges
    end
  end

  def intersection_range(step, range) do
    {mode, x1, x2, y1, y2, z1, z2} = step
    {mode_i, x1_i, x2_i, y1_i, y2_i, z1_i, z2_i} = range

    if x2 < x1_i or x1 > x2_i or
         y2 < y1_i or y1 > y2_i or
         z2 < z1_i or z1 > z2_i do
      # No overlap
      nil
    else
      # Compensation for overlap
      intersection_mode =
        cond do
          mode === "on" and mode_i === "on" ->
            "off"

          mode === "off" and mode_i === "on" ->
            "off"

          mode === "off" and mode_i === "off" ->
            "on"

          mode === "on" and mode_i === "off" ->
            "on"
        end

      {intersection_mode, max(x1, x1_i), min(x2, x2_i), max(y1, y1_i), min(y2, y2_i),
       max(z1, z1_i), min(z2, z2_i)}
    end
  end

  def count_cubes([], count), do: count

  def count_cubes([range | ranges], count) do
    {mode, x1, x2, y1, y2, z1, z2} = range
    cubes_count = (x2 - x1 + 1) * (y2 - y1 + 1) * (z2 - z1 + 1)

    new_count =
      case mode do
        "on" -> count + cubes_count
        "off" -> count - cubes_count
      end

    count_cubes(ranges, new_count)
  end
end
