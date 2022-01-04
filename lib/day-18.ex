defmodule Day18 do
  def answer_part_1_example, do: answer_part_1("inputs/18/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/18/input.txt")

  def answer_part_1(file_path) do
    [line | lines] =
      file_path
      |> read_file()
      |> Enum.map(fn line -> String.graphemes(line) |> parse_line(0, []) end)

    add(line, lines)
    |> compute_magnitude()
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents |> String.split("\n", trim: true)
  end

  def parse_line([], _depth, res), do: res

  def parse_line([char | chars], depth, res) do
    case char do
      "[" -> parse_line(chars, depth + 1, res)
      "]" -> parse_line(chars, depth - 1, res)
      "," -> parse_line(chars, depth, res)
      num -> parse_line(chars, depth, res ++ [{String.to_integer(num), depth}])
    end
  end

  def add(prev, []), do: prev

  def add(prev, [next | lines]) do
    ((prev |> increase_depth) ++ (next |> increase_depth))
    |> reduce()
    |> add(lines)
  end

  def increase_depth(line) do
    line |> Enum.map(fn {num, depth} -> {num, depth + 1} end)
  end

  def reduce(line) do
    line |> explode()
  end

  def explode(line) do
    to_explode = line |> Enum.with_index() |> Enum.find(fn {{_num, depth}, _i} -> depth > 4 end)

    if to_explode do
      {{num1, depth}, i} = to_explode
      {num2, _} = line |> Enum.at(i + 1)

      line
      |> apply_explode(num1, i - 1)
      |> apply_explode(num2, i + 2)
      |> List.replace_at(i, {0, depth - 1})
      |> List.delete_at(i + 1)
      |> explode
    else
      line |> split()
    end
  end

  def apply_explode(line, to_add, i) do
    if i >= 0 and line |> Enum.at(i) do
      line |> List.update_at(i, fn {num, depth} -> {num + to_add, depth} end)
    else
      line
    end
  end

  def split(line) do
    to_split = line |> Enum.with_index() |> Enum.find(fn {{num, _depth}, _i} -> num >= 10 end)

    if to_split do
      {{num, depth}, i} = to_split

      left = floor(num / 2)
      right = ceil(num / 2)

      line
      |> List.replace_at(i, {left, depth + 1})
      |> List.insert_at(i + 1, {right, depth + 1})
      |> explode
    else
      line
    end
  end

  def compute_magnitude([{magnitude, 0}]), do: magnitude

  def compute_magnitude(line) do
    [{{num_left, depth}, i_left}, {{num_right, depth}, i_right}] = line |> find_deepest_pair

    magnitude = 3 * num_left + 2 * num_right

    line
    |> List.replace_at(i_left, {magnitude, depth - 1})
    |> List.delete_at(i_right)
    |> compute_magnitude()
  end

  def find_deepest_pair(line) do
    line
    |> Enum.with_index()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(
      fn pair = [{{_num_left, depth_left}, _i_left}, {{_num_right, depth_right}, _i_right}],
         deepest = [{{_num, depth}, _i}, _] ->
        if depth_left === depth_right and depth_left > depth do
          pair
        else
          deepest
        end
      end
    )
  end

  def answer_part_2_example, do: answer_part_2("inputs/18/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/18/input.txt")

  def answer_part_2(file_path) do
    lines =
      file_path
      |> read_file()
      |> Enum.map(fn line -> String.graphemes(line) |> parse_line(0, []) end)

    for line1 <- lines, line2 <- lines, reduce: 0 do
      largest_magnitude ->
        if line1 !== line2 do
          mag1 = add(line1, [line2]) |> compute_magnitude()
          mag2 = add(line2, [line1]) |> compute_magnitude()

          Enum.max([mag1, mag2, largest_magnitude])
        else
          largest_magnitude
        end
    end
  end
end
