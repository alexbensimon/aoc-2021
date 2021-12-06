defmodule Day06 do
  def answer_part_1_example, do: answer_part_1("inputs/06/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/06/input.txt")

  def answer_part_1(file_path) do
    read_file(file_path) |> process_list(0)
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&(&1 |> String.split(",", trim: true)))
    |> Enum.map(&String.to_integer/1)
  end

  def process_list(list, day) when day < 80 do
    new_fishes = list |> Enum.filter(&(&1 === 0)) |> Enum.map(&(&1 = 8))

    existing_fishes =
      list
      |> Enum.map(fn timer ->
        if timer === 0 do
          6
        else
          timer - 1
        end
      end)

    process_list(new_fishes ++ existing_fishes, day + 1)
  end

  def process_list(list, _day), do: list |> Enum.count()

  def answer_part_2_example, do: answer_part_2("inputs/06/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/06/input.txt")

  def answer_part_2(file_path) do
    read_file(file_path) |> list_to_map(%{}) |> process_fishes(0) |> Map.values() |> Enum.sum()
  end

  def list_to_map([head | tail], map) do
    new_map = Map.update(map, head, 1, &(&1 + 1))
    list_to_map(tail, new_map)
  end

  def list_to_map([], map), do: map

  def process_fishes(map, day) when day < 256 do
    map
    |> Map.put(8, map[0] || 0)
    |> Map.put(7, map[8] || 0)
    |> Map.put(6, (map[7] || 0) + (map[0] || 0))
    |> Map.put(5, map[6] || 0)
    |> Map.put(4, map[5] || 0)
    |> Map.put(3, map[4] || 0)
    |> Map.put(2, map[3] || 0)
    |> Map.put(1, map[2] || 0)
    |> Map.put(0, map[1] || 0)
    |> process_fishes(day + 1)
  end

  def process_fishes(map, _day), do: map
end
