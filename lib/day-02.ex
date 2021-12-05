defmodule Day02 do
  def answer_part_1_example, do: answer_part_1("inputs/02/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/02/input.txt")

  def answer_part_1(file_path) do
    position = get_commands_from_file(file_path) |> process_commands(%{horizontal: 0, depth: 0})

    position.horizontal * position.depth
  end

  def get_commands_from_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
  end

  def process_commands([next_command | remaining_commands], position) do
    new_position = String.split(next_command, " ") |> execute_command(position)

    process_commands(remaining_commands, new_position)
  end

  def process_commands([], position), do: position

  def execute_command(["forward", units], position),
    do: %{
      position
      | horizontal: position.horizontal + String.to_integer(units)
    }

  def execute_command(["down", units], position),
    do: %{
      position
      | depth: position.depth + String.to_integer(units)
    }

  def execute_command(["up", units], position),
    do: %{
      position
      | depth: position.depth - String.to_integer(units)
    }

  def answer_part_2_example, do: answer_part_2("inputs/02/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/02/input.txt")

  def answer_part_2(file_path) do
    position =
      get_commands_from_file(file_path)
      |> process_commands_part_2(%{horizontal: 0, depth: 0, aim: 0})

    position.horizontal * position.depth
  end

  def process_commands_part_2([next_command | remaining_commands], position) do
    new_position = String.split(next_command, " ") |> execute_command_part_2(position)

    process_commands_part_2(remaining_commands, new_position)
  end

  def process_commands_part_2([], position), do: position

  def execute_command_part_2(["down", units], position),
    do: %{
      position
      | aim: position.aim + String.to_integer(units)
    }

  def execute_command_part_2(["up", units], position),
    do: %{
      position
      | aim: position.aim - String.to_integer(units)
    }

  def execute_command_part_2(["forward", units], position),
    do: %{
      position
      | horizontal: position.horizontal + String.to_integer(units),
        depth: position.depth + position.aim * String.to_integer(units)
    }
end
