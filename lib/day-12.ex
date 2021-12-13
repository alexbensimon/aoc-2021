defmodule Day12 do
  def answer_part_1_example, do: answer_part_1("inputs/12/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/12/input.txt")

  def answer_part_1(file_path) do
    file_path
    |> get_connections_from_file
    |> map_connections
    |> advance(["start"], [])
    |> Enum.count()
  end

  def get_connections_from_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents |> String.split("\n", trim: true)
  end

  def map_connections(connections) do
    connections
    |> Enum.reduce(%{}, fn connection, map ->
      [c1, c2] = connection |> String.split("-")

      map
      |> add_connection([c1, c2])
      |> add_connection([c2, c1])
    end)
  end

  def add_connection(map, [c1, c2]) do
    cond do
      c2 === "start" -> map
      c1 === "end" -> map
      true -> Map.update(map, c1, [c2], fn possibilities -> [c2 | possibilities] end)
    end
  end

  def advance(_map, path, paths) when hd(path) === "end", do: [path | paths]

  def advance(map, path, paths) do
    map[hd(path)]
    |> Enum.reduce(paths, fn cave, acc ->
      if isSmallCave?(cave) do
        Map.new(map, fn {key, possibilities} -> {key, possibilities -- [cave]} end)
      else
        map
      end
      |> advance([cave | path], acc)
    end)
  end

  def isSmallCave?(cave) do
    cave !== String.upcase(cave)
  end

  def answer_part_2_example, do: answer_part_2("inputs/12/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/12/input.txt")

  def answer_part_2(file_path) do
    file_path
    |> get_connections_from_file
    |> map_connections
    |> advance_part_2(["start"], MapSet.new(), false, MapSet.new())
    |> Enum.count()
  end

  def advance_part_2(_map, path, _visited, _twice?, paths) when hd(path) === "end",
    do: MapSet.put(paths, path)

  def advance_part_2(map, path, visited, twice?, paths) do
    map[hd(path)]
    |> Enum.reduce(paths, fn cave, acc ->
      if !isSmallCave?(cave) do
        advance_part_2(map, [cave | path], visited, twice?, acc)
      else
        new_map = Map.new(map, fn {key, possibilities} -> {key, possibilities -- [cave]} end)

        if cave in visited do
          if twice? do
            advance_part_2(new_map, path, MapSet.put(visited, cave), true, acc)
          else
            advance_part_2(new_map, [cave | path], MapSet.put(visited, cave), true, acc)
          end
        else
          set_map =
            if twice? do
              Map.new(map, fn {key, possibilities} -> {key, possibilities -- [cave]} end)
            else
              map
            end

          advance_part_2(set_map, [cave | path], MapSet.put(visited, cave), twice?, acc)
        end
      end
    end)
  end
end
