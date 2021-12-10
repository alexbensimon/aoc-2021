defmodule Day10 do
  def answer_part_1_example, do: answer_part_1("inputs/10/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/10/input.txt")

  def answer_part_1(file_path) do
    file_path
    |> read_file
    |> Enum.map(&find_illegal_character/1)
    |> Enum.filter(&(&1 !== ""))
    |> compute_score
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
  end

  def find_illegal_character(line) do
    char_map = %{
      "(" => ")",
      "[" => "]",
      "{" => "}",
      "<" => ">"
    }

    line |> String.graphemes() |> process_chars([], char_map)
  end

  def process_chars([char | tail], stack, char_map) do
    openings = char_map |> Map.keys()

    # if it's an opening character, we add it to the stack
    if openings |> Enum.member?(char) do
      process_chars(tail, [char | stack], char_map)
    else
      # if it's the correct closing character, we remove the valid chunk from the stack
      if char === char_map[Enum.at(stack, 0)] do
        {_, new_stack} = stack |> List.pop_at(0)
        process_chars(tail, new_stack, char_map)
      else
        # else, we have our illegal character
        char
      end
    end
  end

  def process_chars([], _stack, _char_map), do: ""

  def compute_score(illegal_characters) do
    char_to_score = %{
      ")" => 3,
      "]" => 57,
      "}" => 1197,
      ">" => 25137
    }

    illegal_characters |> Enum.map(&char_to_score[&1]) |> Enum.sum()
  end

  def answer_part_2_example, do: answer_part_2("inputs/10/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/10/input.txt")

  def answer_part_2(file_path) do
    file_path
    |> read_file
    |> Enum.map(&find_line_score/1)
    |> Enum.map(&compute_stack_score/1)
    |> Enum.filter(&(&1 !== 0))
    |> median_score
  end

  def find_line_score(line) do
    char_map = %{
      "(" => ")",
      "[" => "]",
      "{" => "}",
      "<" => ">"
    }

    line
    |> String.graphemes()
    |> process_chars_part_2([], char_map)
  end

  def process_chars_part_2([char | tail], stack, char_map) do
    openings = char_map |> Map.keys()

    # if it's an opening character, we add it to the stack
    if openings |> Enum.member?(char) do
      process_chars_part_2(tail, [char | stack], char_map)
    else
      # if it's the correct closing character, we remove the valid chunk from the stack
      if char === char_map[Enum.at(stack, 0)] do
        {_, new_stack} = stack |> List.pop_at(0)
        process_chars_part_2(tail, new_stack, char_map)
      else
        # else, this is a corrupted line
        []
      end
    end
  end

  def process_chars_part_2([], stack, _char_map), do: stack

  def compute_stack_score(stack) do
    char_score = %{
      "(" => 1,
      "[" => 2,
      "{" => 3,
      "<" => 4
    }

    stack |> Enum.reduce(0, fn char, total -> total * 5 + char_score[char] end)
  end

  def median_score(scores) do
    scores |> Enum.sort() |> Enum.at(ceil(length(scores) / 2 - 1))
  end
end
