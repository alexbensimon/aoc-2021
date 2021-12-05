defmodule Day03 do
  def answer_part_1_example, do: answer_part_1("inputs/03/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/03/input.txt")

  def answer_part_1(file_path) do
    acc =
      get_number_list_from_file(file_path)
      |> process_list(%{})

    zero_bit_count_per_position = Map.delete(acc, :size)

    {gamma_rate, _rest} =
      compute_gamma_rate(zero_bit_count_per_position, acc[:size]) |> Integer.parse(2)

    {epsilon_rate, _rest} =
      compute_epsilon_rate(zero_bit_count_per_position, acc[:size]) |> Integer.parse(2)

    gamma_rate * epsilon_rate
  end

  def get_number_list_from_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
  end

  def process_list([head | tail], acc) do
    new_acc = process_line(String.graphemes(head), 0, acc)

    # We need the list size so we should compute it as we go through it
    new_acc_with_size = Map.put(new_acc, :size, (new_acc[:size] || 0) + 1)

    process_list(tail, new_acc_with_size)
  end

  def process_list([], acc), do: acc

  def process_line([head | tail], position, acc) do
    new_acc = head |> String.to_integer() |> process_bit(position, acc)

    process_line(tail, position + 1, new_acc)
  end

  def process_line([], _position, acc), do: acc

  # We want to count the occurences of the zero bit for each position
  def process_bit(bit, position, acc) when bit === 0,
    do: Map.put(acc, position, (acc[position] || 0) + 1)

  # For the exhaustiveness of the map keys
  def process_bit(bit, position, acc) when bit === 1,
    do: Map.put(acc, position, acc[position] || 0)

  def process_bit(_bit, _position, acc), do: acc

  def compute_gamma_rate(zero_bit_count_per_position, size) do
    zero_bit_count_per_position
    |> Map.values()
    |> Enum.map(fn zero_bit_count ->
      # If the zero bit count is greater than half of the list size, zero is the most frequent bit at that position
      if zero_bit_count > size / 2 do
        0
      else
        1
      end
    end)
    |> Enum.join("")
  end

  def compute_epsilon_rate(zero_bit_count_per_position, size) do
    zero_bit_count_per_position
    |> Map.values()
    |> Enum.map(fn zero_bit_count ->
      # Do the opposite to find the least frequent bit
      if zero_bit_count > size / 2 do
        1
      else
        0
      end
    end)
    |> Enum.join("")
  end

  def answer_part_2_example, do: answer_part_2("inputs/03/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/03/input.txt")

  def answer_part_2(file_path) do
    list = get_number_list_from_file(file_path)

    {oxygen_generator_rating, _rest} =
      compute_rating(list, 0, &compute_gamma_rate/2) |> Integer.parse(2)

    {co2_scrubber_rating, _rest} =
      compute_rating(list, 0, &compute_epsilon_rate/2) |> Integer.parse(2)

    oxygen_generator_rating * co2_scrubber_rating
  end

  def compute_rating(list, position, compute_rate_fn) when length(list) > 1 do
    acc =
      list
      |> process_list(%{})

    zero_bit_count_per_position = Map.delete(acc, :size)

    # We can use the rate from part 1 to know the most and least frequent bits at each position
    rate = compute_rate_fn.(zero_bit_count_per_position, acc[:size])

    new_list = filter_at_position(list, rate, position)

    # We need the process the list again after each round of filtering
    compute_rating(new_list, position + 1, compute_rate_fn)
  end

  def compute_rating([last], _position, _compute_rate_fn), do: last

  def filter_at_position(list, rate, position) do
    bit = String.at(rate, position)

    list
    |> Enum.filter(&(String.at(&1, position) == bit))
  end
end
