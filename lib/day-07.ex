defmodule Day07 do
  def answer_part_1_example, do: answer_part_1("inputs/07/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/07/input.txt")

  def answer_part_1(file_path) do
    positions = read_file(file_path)
    optimal_position = find_optimal_position(positions)
    compute_fuel(positions, optimal_position)
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&(&1 |> String.split(",", trim: true)))
    |> Enum.map(&String.to_integer/1)
  end

  def find_optimal_position(positions) do
    # Optimal position is at the center when we sort the positions
    positions |> Enum.sort() |> Enum.at(div(Enum.count(positions), 2))
  end

  def compute_fuel(positions, optimal_position) do
    positions |> Enum.reduce(0, fn position, acc -> abs(position - optimal_position) + acc end)
  end

  def answer_part_2_example, do: answer_part_2("inputs/07/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/07/input.txt")

  def answer_part_2(file_path) do
    positions = read_file(file_path) |> Enum.sort()

    {floor, ceil} = positions |> find_optimal_positions()

    # The answer is an int so we have to try both roundings to find the smallest value
    floor_fuel = compute_fuel_part_2(positions, floor)
    ceil_fuel = compute_fuel_part_2(positions, ceil)

    min(floor_fuel, ceil_fuel)
  end

  def find_optimal_positions(positions) do
    optimal = Enum.sum(positions) / length(positions)

    {floor(optimal), ceil(optimal)}
  end

  def compute_fuel_part_2(positions, optimal_position) do
    positions
    |> Enum.reduce(0, fn position, acc ->
      compute_fuel_for_position(position, optimal_position) + acc
    end)
  end

  def compute_fuel_for_position(position, optimal_position) do
    step_count = abs(position - optimal_position)
    Enum.reduce(0..step_count, 0, fn step, acc -> acc + step end)
  end
end
