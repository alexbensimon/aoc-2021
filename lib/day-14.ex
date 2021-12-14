defmodule Day14 do
  def answer_part_1_example, do: answer_part_1("inputs/14/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/14/input.txt")

  def answer_part_1(file_path) do
    [polymer, rules] = file_path |> read_file

    rules = format_rules(rules)

    frequencies =
      1..10
      |> Enum.reduce(polymer, fn _, acc ->
        acc
        |> process_polymer(rules)
      end)
      |> String.graphemes()
      |> Enum.frequencies()

    {_el_max, freq_max} = Enum.max_by(frequencies, fn {_element, frequency} -> frequency end)
    {_el_min, freq_min} = Enum.min_by(frequencies, fn {_element, frequency} -> frequency end)

    freq_max - freq_min
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n\n", trim: true)
  end

  def format_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.reduce(%{}, fn [pair, element], acc ->
      acc |> Map.put(pair, element)
    end)
  end

  def process_polymer(polymer, rules) do
    String.at(polymer, 0) <>
      (polymer
       |> String.graphemes()
       |> Enum.chunk_every(2, 1, :discard)
       |> Enum.map(fn polymer = [_e1, e2] ->
         element = rules[Enum.join(polymer)]
         element <> e2
       end)
       |> Enum.join())
  end

  def answer_part_2_example, do: answer_part_2("inputs/14/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/14/input.txt")

  def answer_part_2(file_path) do
    [polymer, rules] = file_path |> read_file

    rules = format_rules(rules)

    polymer = map_pairs(polymer)

    frequencies =
      1..40
      |> Enum.reduce(polymer, fn _, acc ->
        acc
        |> process_polymer_part_2(rules)
      end)
      |> Enum.reduce(%{}, fn {pair, count}, acc ->
        [e1, e2] = String.graphemes(pair)

        acc
        |> Map.update(e1, count, fn current_count -> current_count + count end)
        |> Map.update(e2, count, fn current_count -> current_count + count end)
      end)
      |> Map.new(fn {e, count} -> {e, ceil(count / 2)} end)

    {_el_max, freq_max} = Enum.max_by(frequencies, fn {_element, frequency} -> frequency end)
    {_el_min, freq_min} = Enum.min_by(frequencies, fn {_element, frequency} -> frequency end)

    freq_max - freq_min
  end

  def map_pairs(polymer) do
    polymer
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&Enum.join/1)
    |> Enum.frequencies()
  end

  def process_polymer_part_2(polymer, rules) do
    polymer
    |> Enum.reduce(%{}, fn {pair, count}, acc ->
      [e1, e2] = String.graphemes(pair)
      new_e = rules[pair]

      acc
      |> Map.update(e1 <> new_e, count, fn current_count -> current_count + count end)
      |> Map.update(new_e <> e2, count, fn current_count -> current_count + count end)
    end)
  end
end
