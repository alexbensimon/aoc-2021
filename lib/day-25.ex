defmodule Day25 do
  def answer_part_1_example, do: answer_part_1("inputs/25/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/25/input.txt")

  def answer_part_1(file_path) do
    file_path
    |> read_file()
    |> execute_step(1)
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    for {line, row} <-
          contents
          |> String.split("\n", trim: true)
          |> Enum.with_index(),
        {char, col} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{row, col}, char}
    end
  end

  def execute_step(map, step) do
    # print_map(map)
    # IO.puts("")

    # move east
    {map, move?} =
      for {{row, col} = position, char} <- map, reduce: {map, false} do
        {acc, move?} ->
          case char do
            ">" ->
              destination = if map[{row, col + 1}], do: {row, col + 1}, else: {row, 0}

              case map[destination] do
                "." -> {acc |> Map.put(destination, ">") |> Map.put(position, "."), true}
                _ -> {acc, move?}
              end

            _ ->
              {acc, move?}
          end
      end

    # move south
    {map, move?} =
      for {{row, col} = position, char} <- map, reduce: {map, move?} do
        {acc, move?} ->
          case char do
            "v" ->
              destination = if map[{row + 1, col}], do: {row + 1, col}, else: {0, col}

              case map[destination] do
                "." -> {acc |> Map.put(destination, "v") |> Map.put(position, "."), true}
                _ -> {acc, move?}
              end

            _ ->
              {acc, move?}
          end
      end

    # if move go to next step
    if move?, do: execute_step(map, step + 1), else: step
  end

  def print_map(map) do
    for row <- 0..8 do
      for col <- 0..9, into: "" do
        Map.get(map, {row, col})
      end
      |> IO.inspect()
    end
  end
end
