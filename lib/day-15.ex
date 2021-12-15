defmodule Day15 do
  def answer_part_1_example, do: answer_part_1("inputs/15/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/15/input.txt")

  def answer_part_1(file_path) do
    grid = file_path |> read_file |> map_grid
    {{last_row, _last_col}, _} = grid |> Enum.max_by(fn {{row, _col}, _} -> row end)

    find_lowest_total_risk({0, 0}, grid, %{{0, 0} => 0}, MapSet.new(), last_row)
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

  def find_lowest_total_risk({last, last} = current_node, _grid, lowest_risk_map, _visited, last),
    do: lowest_risk_map[current_node]

  # Dijkstra's algorithm
  def find_lowest_total_risk({row, col} = current_node, grid, lowest_risk_map, visited, last) do
    new_lowest_risk_map =
      [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
      |> Enum.reduce(lowest_risk_map, fn neighbor, acc ->
        if grid[neighbor] !== nil and neighbor not in visited do
          new_possible_risk = lowest_risk_map[current_node] + grid[neighbor]

          acc
          |> Map.update(
            neighbor,
            new_possible_risk,
            fn value -> min(value, new_possible_risk) end
          )
        else
          acc
        end
      end)
      |> Map.delete(current_node)

    {new_current, _} = new_lowest_risk_map |> Enum.min_by(fn {_node, risk} -> risk end)

    find_lowest_total_risk(
      new_current,
      grid,
      new_lowest_risk_map,
      MapSet.put(visited, current_node),
      last
    )
  end

  def answer_part_2_example, do: answer_part_2("inputs/15/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/15/input.txt")

  def answer_part_2(file_path) do
    grid = file_path |> read_file |> map_grid
    {{last_row, _last_col}, _} = grid |> Enum.max_by(fn {{row, _col}, _} -> row end)

    big_grid = grid |> build_big_grid(last_row + 1)
    {{last_big_row, _last_big_col}, _} = big_grid |> Enum.max_by(fn {{row, _col}, _} -> row end)

    find_lowest_total_risk({0, 0}, big_grid, %{{0, 0} => 0}, MapSet.new(), last_big_row)
  end

  def build_big_grid(grid, grid_size) do
    for {{row, col}, risk} <- grid, i <- 0..4, j <- 0..4, into: %{} do
      new_risk =
        if risk + i + j <= 9 do
          risk + i + j
        else
          rem(risk + i + j, 9)
        end

      {{row + i * grid_size, col + j * grid_size}, new_risk}
    end
  end
end
