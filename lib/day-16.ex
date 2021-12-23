defmodule Day16 do
  def answer_part_1_example, do: answer_part_1("inputs/16/example-part-1.txt")

  def answer_part_1_input, do: answer_part_1("inputs/16/input.txt")

  def answer_part_1(file_path) do
    {_, res} =
      file_path
      |> read_file()
      |> to_binary()
      |> String.graphemes()
      |> parse_packet(0)

    res
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents |> String.trim()
  end

  def to_binary(hex) do
    hex_to_binary = %{
      "0" => "0000",
      "1" => "0001",
      "2" => "0010",
      "3" => "0011",
      "4" => "0100",
      "5" => "0101",
      "6" => "0110",
      "7" => "0111",
      "8" => "1000",
      "9" => "1001",
      "A" => "1010",
      "B" => "1011",
      "C" => "1100",
      "D" => "1101",
      "E" => "1110",
      "F" => "1111"
    }

    hex
    |> String.graphemes()
    |> Enum.map(fn hex -> hex_to_binary[hex] end)
    |> Enum.join()
  end

  def parse_packet([], version_sum), do: {[], version_sum}

  def parse_packet(packet, version_sum) do
    if not (packet |> Enum.any?(fn bit -> bit === "1" end)) do
      {packet, version_sum}
    else
      {version, packet} = packet |> compute_n_bits(3)
      {type_id, packet} = packet |> compute_n_bits(3)

      if type_id === 4 do
        {_value, packet} = compute_literal_value(packet, "")
        {packet, version_sum + version}
      else
        # Operator packet
        {length_type_id, packet} = packet |> take_n_bits(1)

        if length_type_id === "0" do
          {total_length, packet} = packet |> compute_n_bits(15)
          parse_subpackets_by_length(packet, total_length, version_sum + version)
        else
          {sub_packet_count, packet} = packet |> compute_n_bits(11)
          parse_subpackets_by_count(packet, sub_packet_count, version_sum + version)
        end
      end
    end
  end

  def compute_n_bits(packet, n) do
    {bits, rest} = packet |> Enum.split(n)

    {value, _} = bits |> Enum.join() |> Integer.parse(2)

    {value, rest}
  end

  def compute_literal_value(["1" | packet], value) do
    {bits, packet} = packet |> take_n_bits(4)

    compute_literal_value(packet, value <> bits)
  end

  def compute_literal_value(["0" | packet], value) do
    {bits, packet} = packet |> take_n_bits(4)

    {value, _} = (value <> bits) |> Integer.parse(2)

    {value, packet}
  end

  def take_n_bits(packet, n) do
    {bits, rest} = packet |> Enum.split(n)

    {bits |> Enum.join(), rest}
  end

  def parse_subpackets_by_length(packet, length, version_sum) do
    {subpackets, new_packet} = packet |> Enum.split(length)
    {_, new_version_sum} = subpackets |> parse_until_empty(version_sum)
    parse_packet(new_packet, new_version_sum)
  end

  def parse_until_empty([], version_sum) do
    {[], version_sum}
  end

  def parse_until_empty(packet, version_sum) do
    {packet, new_version_sum} = packet |> parse_packet(version_sum)
    parse_until_empty(packet, new_version_sum)
  end

  def parse_subpackets_by_count(packet, count, version_sum) do
    packet |> parse_count(0, count, version_sum)
  end

  def parse_count(packet, total, total, version_sum) do
    {packet, version_sum}
  end

  def parse_count(packet, count, total, version_sum) do
    {packet, new_version_sum} = packet |> parse_packet(version_sum)
    parse_count(packet, count + 1, total, new_version_sum)
  end

  def answer_part_2_example, do: answer_part_2("inputs/16/example-part-2.txt")

  def answer_part_2_input, do: answer_part_2("inputs/16/input.txt")

  def answer_part_2(file_path) do
    {_, [res]} =
      file_path
      |> read_file()
      |> to_binary()
      |> String.graphemes()
      |> parse_packet_part_2([])

    res
  end

  def parse_packet_part_2([], values), do: {[], values}

  def parse_packet_part_2(packet, values) do
    if not (packet |> Enum.any?(fn bit -> bit === "1" end)) do
      {packet, values}
    else
      {_version, packet} = packet |> compute_n_bits(3)
      {type_id, packet} = packet |> compute_n_bits(3)

      if type_id === 4 do
        # Literal value
        {value, packet} = compute_literal_value(packet, "")
        {packet, [value | values]}
      else
        # Operator packet
        {length_type_id, packet} = packet |> take_n_bits(1)

        {packet, new_values} =
          if length_type_id === "0" do
            {total_length, packet} = packet |> compute_n_bits(15)

            parse_subpackets_by_length_part_2(packet, total_length)
          else
            {sub_packet_count, packet} = packet |> compute_n_bits(11)

            parse_subpackets_by_count_part_2(packet, sub_packet_count)
          end

        {packet, [compute_operation(new_values, type_id) | values]}
      end
    end
  end

  def parse_subpackets_by_length_part_2(packet, length) do
    {subpackets, packet} = packet |> Enum.split(length)
    {_, values} = subpackets |> parse_until_empty_part_2([])
    {packet, values}
  end

  def parse_until_empty_part_2([], values) do
    {[], values}
  end

  def parse_until_empty_part_2(packet, values) do
    {packet, values} = packet |> parse_packet_part_2(values)
    parse_until_empty_part_2(packet, values)
  end

  def parse_subpackets_by_count_part_2(packet, count) do
    packet |> parse_count_part_2(0, count, [])
  end

  def parse_count_part_2(packet, total, total, values) do
    {packet, values}
  end

  def parse_count_part_2(packet, count, total, values) do
    {packet, values} = packet |> parse_packet_part_2(values)
    parse_count_part_2(packet, count + 1, total, values)
  end

  def compute_operation(values, operation) do
    case operation do
      0 ->
        Enum.sum(values)

      1 ->
        Enum.product(values)

      2 ->
        Enum.min(values)

      3 ->
        Enum.max(values)

      5 ->
        [v2, v1] = values

        if v1 > v2 do
          1
        else
          0
        end

      6 ->
        [v2, v1] = values

        if v1 < v2 do
          1
        else
          0
        end

      7 ->
        [v2, v1] = values

        if v1 === v2 do
          1
        else
          0
        end
    end
  end
end
