defmodule Day13 do
  def answer_part_1_example, do: answer_part_1("inputs/13/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/13/input.txt")

  def answer_part_1(file_path) do
    [coords, instructions] =
      file_path
      |> read_file

    instructions = list_instructions(instructions)

    list_coords(coords)
    |> process_instruction(Enum.at(instructions, 0))
    |> Enum.uniq()
    |> Enum.count()
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
  end

  def list_coords(coords) do
    coords
    |> Enum.map(fn text ->
      String.split(text, ",") |> Enum.map(fn value -> String.to_integer(value) end)
    end)
    |> Enum.map(&List.to_tuple/1)
  end

  def list_instructions(instructions) do
    instructions
    |> Enum.map(fn instruction -> String.split(instruction, "fold along ", trim: true) end)
    |> List.flatten()
    |> Enum.map(fn text -> String.split(text, "=") end)
    |> Enum.map(fn instruction -> List.to_tuple(instruction) end)
    |> Enum.map(fn {axis, value} -> {axis, String.to_integer(value)} end)
  end

  def process_instruction(coords, {"x", value}) do
    coords
    |> Enum.map(fn {x, y} ->
      if x > value do
        {2 * value - x, y}
      else
        {x, y}
      end
    end)
  end

  def process_instruction(coords, {"y", value}) do
    coords
    |> Enum.map(fn {x, y} ->
      if y > value do
        {x, 2 * value - y}
      else
        {x, y}
      end
    end)
  end

  def answer_part_2_example, do: answer_part_2("inputs/13/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/13/input.txt")

  def answer_part_2(file_path) do
    [coords, instructions] =
      file_path
      |> read_file

    coords = list_coords(coords)

    dots =
      list_instructions(instructions)
      |> Enum.reduce(coords, fn instruction, coords ->
        process_instruction(coords, instruction)
      end)
      |> MapSet.new()

    0..8
    |> Enum.each(fn y ->
      0..50
      |> Enum.reduce("", fn x, acc ->
        if {x, y} in dots do
          acc <> "#"
        else
          acc <> "."
        end
      end)
      |> IO.inspect()
    end)
  end
end
