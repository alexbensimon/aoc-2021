defmodule Day24 do
  def answer_part_1_example, do: answer_part_1("inputs/24/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/24/input-test.txt")

  def answer_part_1(file_path) do
    file_path
    |> read_file()
    |> find_largest_input()
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)

    # contents
    # |> String.split("\n\n", trim: true)
    # |> Enum.map(fn part -> String.split(part, "\n", trim: true) end)
  end

  def find_largest_model_number(instructions_parts) do
    possible_z = %{0 => []}

    instructions_parts
    |> Enum.reduce(possible_z, fn part, acc ->
      for i <- 1..9, {val, inputs} <- acc do
        IO.inspect(acc)
        variables = %{"w" => 0, "x" => 0, "y" => 0, "z" => val}

        z = execute_monad(part, variables, [i])
        {z, inputs ++ [i]}
      end
      |> Enum.group_by(fn {z, _inputs} -> z end)
      |> Enum.map(fn {z, possibilities} ->
        {_z, inputs} =
          possibilities
          |> Enum.max_by(fn {_z, inputs} -> Integer.undigits(inputs) end)

        {z, inputs}
      end)
      |> Map.new()
    end)
    |> IO.inspect()
    |> Map.get(0)
    |> Integer.undigits()

    # 1..99_999_999_999_999
    # |> Enum.reduce_while(22_222_222_222_222, fn _, number ->
    #   IO.inspect(number)

    #   inputs = Integer.digits(number)

    #   if inputs |> Enum.find(fn digit -> digit === 0 end) do
    #     {:cont, number - 1}
    #   else
    #     res = execute_monad(instructions, variables, inputs)
    #     IO.inspect(res, label: "Res")

    #     if res === 0 do
    #       {:halt, number}
    #     else
    #       {:cont, number - 1}
    #     end
    #   end
    # end)
  end

  def find_largest_input(instructions) do
    variables = %{"w" => 0, "x" => 0, "y" => 0, "z" => 0}

    for i <- 1..9, j <- 1..9 do
      res = execute_monad(instructions, variables, [i, j])
      if res === 0, do: IO.inspect({i, j})
      res
    end
  end

  def test_number(instructions, number) do
    variables = %{"w" => 0, "x" => 0, "y" => 0, "z" => 0}
    inputs = Integer.digits(number)
    execute_monad(instructions, variables, inputs)
  end

  def execute_monad([], variables, _input), do: variables["z"]

  def execute_monad([instruction | instructions], variables, inputs) do
    # IO.inspect(inputs, as_lists: true)
    # IO.inspect(variables)
    # IO.inspect(instruction)
    parts = instruction |> String.split()

    {variables, inputs} =
      case parts do
        ["inp", a] ->
          [input | inputs] = inputs
          variables = Map.put(variables, a, input)
          {variables, inputs}

        ["add", a, b] ->
          variables = Map.put(variables, a, variables[a] + interpret_value(b, variables))
          {variables, inputs}

        ["mul", a, b] ->
          variables = Map.put(variables, a, variables[a] * interpret_value(b, variables))
          {variables, inputs}

        ["div", a, b] ->
          variables = Map.put(variables, a, div(variables[a], interpret_value(b, variables)))
          {variables, inputs}

        ["mod", a, b] ->
          variables = Map.put(variables, a, rem(variables[a], interpret_value(b, variables)))
          {variables, inputs}

        ["eql", a, b] ->
          res = if variables[a] === interpret_value(b, variables), do: 1, else: 0
          variables = Map.put(variables, a, res)
          {variables, inputs}
      end

    execute_monad(instructions, variables, inputs)
  end

  def interpret_value(value, variables) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> variables[value]
    end
  end
end

# 99999999999999 -> 3288342921
# 99999999999998 -> 3288342920
# 99999999999997 -> 3288342919
# 99999999999996 -> 3288342918
# 99999999999995 -> 3288342917

# 99999999999994 -> 126474727

# 99999999999993 -> 3288342915
# 99999999999992 -> 3288342914
# 99999999999991 -> 3288342913

# 99999999999989 -> 3288342921

# 1 -> 9
# 2 -> 9
# 3 -> 2
# 4 -> 9
# 5 -> 9
# 6 -> 5
# 7 -> 1
# 8 -> 3
# 9 -> 8
# 10 -> 9
# 11 -> 9
# 12 -> 9
# 13 -> 7
# 14 -> 1

# 99299513899971

# 1 -> 9
# 2 -> 3
# 3 -> 1
# 4 -> 8
# 5 -> 5
# 6 -> 1
# 7 -> 1
# 8 -> 1
# 9 -> 1
# 10 -> 2
# 11 -> 7
# 12 -> 9
# 13 -> 1
# 14 -> 1

# 93185111127911
