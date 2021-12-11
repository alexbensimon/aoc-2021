defmodule Day11 do
  def answer_part_1_example, do: answer_part_1("inputs/11/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/11/input.txt")

  def answer_part_1(file_path) do
    file_path |> read_file |> map_grid |> next_step(0, 0)
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
  end

  def map_grid(grid) do
    grid
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_index}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {digit, col_index}, map ->
        map
        |> Map.put({row_index, col_index}, digit |> String.to_integer())
      end)
    end)
  end

  def next_step(map, step, flash_count) when step < 100 do
    new_map =
      map
      # Increase each energy by 1
      |> Enum.map(fn {coords, energy} -> {coords, energy + 1} end)
      |> Enum.into(%{})
      |> process_map()

    new_flashes = new_map |> Map.values() |> Enum.count(&(&1 === 11))

    new_map
    |> Enum.map(fn {coords, energy} ->
      # Reinit energy
      if energy === 11 do
        {coords, 0}
      else
        {coords, energy}
      end
    end)
    |> Enum.into(%{})
    |> next_step(step + 1, flash_count + new_flashes)
  end

  def next_step(_map, _step, flash_count), do: flash_count

  def process_map(map) do
    new_map =
      map
      |> Enum.reduce(map, fn {coords, energy}, map ->
        if energy === 10 do
          map
          |> Map.update!(coords, fn 10 -> 11 end)
          |> increase_adjacents(coords)
        else
          map
        end
      end)

    if new_map |> Map.values() |> Enum.any?(fn energy -> energy === 10 end) do
      process_map(new_map)
    else
      new_map
    end
  end

  def increase_adjacents(map, {row, col}) do
    map
    |> increase_coords({row, col - 1})
    |> increase_coords({row, col + 1})
    |> increase_coords({row - 1, col})
    |> increase_coords({row - 1, col - 1})
    |> increase_coords({row - 1, col + 1})
    |> increase_coords({row + 1, col})
    |> increase_coords({row + 1, col - 1})
    |> increase_coords({row + 1, col + 1})
  end

  def increase_coords(map, coords) do
    case map |> Map.fetch(coords) do
      {:ok, _value} ->
        map
        |> Map.update!(coords, fn energy ->
          if energy < 10 do
            energy + 1
          else
            energy
          end
        end)

      :error ->
        map
    end
  end

  def answer_part_2_example, do: answer_part_2("inputs/11/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/11/input.txt")

  def answer_part_2(file_path) do
    file_path |> read_file |> map_grid |> find_synchronizing_step(1)
  end

  def find_synchronizing_step(map, step) do
    new_map =
      map
      # Increase each energy by 1
      |> Enum.map(fn {coords, energy} -> {coords, energy + 1} end)
      |> Enum.into(%{})
      |> process_map()

    if new_map |> Map.values() |> Enum.all?(fn energy -> energy === 11 end) do
      step
    else
      new_map
      |> Enum.map(fn {coords, energy} ->
        # Reinit energy
        if energy === 11 do
          {coords, 0}
        else
          {coords, energy}
        end
      end)
      |> Enum.into(%{})
      |> find_synchronizing_step(step + 1)
    end
  end
end
