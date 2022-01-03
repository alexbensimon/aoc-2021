defmodule Day17 do
  def answer_part_1_example, do: answer_part_1("inputs/17/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/17/input.txt")

  def answer_part_1(file_path) do
    {_x1, x2, y1, _y2} =
      target =
      file_path
      |> read_file()

    for x <- 0..x2, y <- y1..abs(y1), reduce: 0 do
      highest ->
        case launch_probe({0, 0}, {x, y}, target, 0) do
          {:inside, high} -> max(high, highest)
          _ -> highest
        end
    end
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    regex = ~r"target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)"
    [[_, x1, x2, y1, y2]] = Regex.scan(regex, contents)
    [x1, x2, y1, y2] |> Enum.map(fn string -> String.to_integer(string) end) |> List.to_tuple()
  end

  def launch_probe(position, velocity, target, high) do
    cond do
      inside?(position, target) ->
        {:inside, high}

      missed?(position, target) ->
        :missed

      true ->
        {position = {_i, j}, velocity} = do_step(position, velocity)
        high = max(j, high)
        launch_probe(position, velocity, target, high)
    end
  end

  def do_step({i, j}, {x, y}) do
    i = i + x
    j = j + y

    x =
      cond do
        x > 0 -> x - 1
        x < 0 -> x + 1
        true -> 0
      end

    y = y - 1

    {{i, j}, {x, y}}
  end

  def inside?({i, j}, {x1, x2, y1, y2}) do
    i >= x1 and i <= x2 and j >= y1 and j <= y2
  end

  def missed?({_i, j}, {_x1, _x2, y1, _y2}) do
    j < y1
  end

  def answer_part_2_example, do: answer_part_2("inputs/17/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/17/input.txt")

  def answer_part_2(file_path) do
    {_x1, x2, y1, _y2} =
      target =
      file_path
      |> read_file()

    for x <- 0..x2, y <- y1..abs(y1), reduce: [] do
      values ->
        case launch_probe({0, 0}, {x, y}, target, 0) do
          {:inside, _} -> [{x, y} | values]
          _ -> values
        end
    end
    |> Enum.count()
  end
end
