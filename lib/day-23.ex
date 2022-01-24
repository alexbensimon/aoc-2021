defmodule Day23 do
  def answer_part_1_example, do: answer_part_1(starting_state_example())

  def answer_part_1_input, do: answer_part_1(starting_state_input())

  def answer_part_1(starting_state) do
    find_least_energy_required(starting_state, %{starting_state => 0}, MapSet.new())
  end

  # Dijkstra's algorithm
  def find_least_energy_required(current_state, lowest_energy_map, visited) do
    if current_state === destination_state() do
      lowest_energy_map[current_state]
    else
      new_lowest_energy_map =
        find_next_possible_states(current_state)
        |> Enum.reduce(lowest_energy_map, fn {next_state, cost}, acc ->
          if next_state in visited do
            acc
          else
            new_possible_cost = lowest_energy_map[current_state] + cost

            acc
            |> Map.update(
              next_state,
              new_possible_cost,
              fn value -> min(value, new_possible_cost) end
            )
          end
        end)
        |> Map.delete(current_state)

      {new_current, _} = new_lowest_energy_map |> Enum.min_by(fn {_state, cost} -> cost end)

      find_least_energy_required(
        new_current,
        new_lowest_energy_map,
        MapSet.put(visited, current_state)
      )
    end
  end

  def find_next_possible_states(state) do
    state
    |> Enum.reduce([], fn {position, value}, acc ->
      cond do
        value === "." ->
          acc

        true ->
          can_move =
            case position do
              # In the hallway
              {0, _} ->
                # Can only move to go to destination
                true

              # First level
              {1, j} ->
                # Can only move if not current destination and free spot outside
                not (letter_destination_j(value) === j and
                       letter_destination_j(state[{2, j}]) === j) and
                  (state[{0, j - 1}] === "." or state[{0, j + 1}] === ".")

              # Second level
              {2, j} ->
                # Can only move if not current destination and first level is empty and free spot outside
                letter_destination_j(value) !== j and state[{1, j}] === "." and
                  (state[{0, j - 1}] === "." or state[{0, j + 1}] === ".")
            end

          if can_move do
            acc ++ possible_moves_cost(state, position, value)
          else
            acc
          end
      end
    end)
  end

  def possible_moves_cost(state, position = {i, j}, value) do
    state
    |> Map.keys()
    |> Enum.reduce([], fn {a, b} = spot, acc ->
      # can position go to spot ?
      # get state with new position and energy to get there

      if state[spot] !== "." or spot in impossible_spots() or
           (a === 1 and state[{2, b}] === ".") or
           (a === 1 and letter_destination_j(state[{2, b}]) !== b) do
        acc
      else
        block =
          b..j |> Enum.find(fn val -> val !== b and val !== j and state[{0, val}] !== "." end)

        # is the path free?

        if block do
          acc
        else
          can_move =
            if a === 0 do
              # in the hallway
              i !== 0
            else
              # in a room
              letter_destination_j(value) === b
            end

          if can_move do
            new_state = state |> Map.put(spot, value) |> Map.put(position, ".")
            step_count = abs(j - b) + a + i
            energy_needed = compute_energy_needed(step_count, value)

            [{new_state, energy_needed} | acc]
          else
            acc
          end
        end
      end
    end)
  end

  def compute_energy_needed(step_count, letter) do
    case letter do
      "A" -> step_count * 1
      "B" -> step_count * 10
      "C" -> step_count * 100
      "D" -> step_count * 1000
    end
  end

  def impossible_spots() do
    [{0, 2}, {0, 4}, {0, 6}, {0, 8}]
  end

  def letter_destination_j(letter) do
    case letter do
      "A" -> 2
      "B" -> 4
      "C" -> 6
      "D" -> 8
    end
  end

  def starting_state_example() do
    %{
      {0, 0} => ".",
      {0, 1} => ".",
      {0, 2} => ".",
      {0, 3} => ".",
      {0, 4} => ".",
      {0, 5} => ".",
      {0, 6} => ".",
      {0, 7} => ".",
      {0, 8} => ".",
      {0, 9} => ".",
      {0, 10} => ".",
      {1, 2} => "B",
      {2, 2} => "A",
      {1, 4} => "C",
      {2, 4} => "D",
      {1, 6} => "B",
      {2, 6} => "C",
      {1, 8} => "D",
      {2, 8} => "A"
    }
  end

  def starting_state_input() do
    %{
      {0, 0} => ".",
      {0, 1} => ".",
      {0, 2} => ".",
      {0, 3} => ".",
      {0, 4} => ".",
      {0, 5} => ".",
      {0, 6} => ".",
      {0, 7} => ".",
      {0, 8} => ".",
      {0, 9} => ".",
      {0, 10} => ".",
      {1, 2} => "D",
      {2, 2} => "B",
      {1, 4} => "D",
      {2, 4} => "A",
      {1, 6} => "C",
      {2, 6} => "A",
      {1, 8} => "B",
      {2, 8} => "C"
    }
  end

  def destination_state() do
    %{
      {0, 0} => ".",
      {0, 1} => ".",
      {0, 2} => ".",
      {0, 3} => ".",
      {0, 4} => ".",
      {0, 5} => ".",
      {0, 6} => ".",
      {0, 7} => ".",
      {0, 8} => ".",
      {0, 9} => ".",
      {0, 10} => ".",
      {1, 2} => "A",
      {2, 2} => "A",
      {1, 4} => "B",
      {2, 4} => "B",
      {1, 6} => "C",
      {2, 6} => "C",
      {1, 8} => "D",
      {2, 8} => "D"
    }
  end

  def answer_part_2_example, do: answer_part_2(starting_state_example_part_2())

  def answer_part_2_input, do: answer_part_2(starting_state_input_part_2())

  def answer_part_2(starting_state) do
    find_least_energy_required_part_2(starting_state, %{starting_state => 0}, MapSet.new())
  end

  def find_least_energy_required_part_2(current_state, lowest_energy_map, visited) do
    if current_state === destination_state_part_2() do
      lowest_energy_map[current_state]
    else
      new_lowest_energy_map =
        find_next_possible_states_part_2(current_state)
        |> Enum.reduce(lowest_energy_map, fn {next_state, cost}, acc ->
          if next_state in visited do
            acc
          else
            new_possible_cost = lowest_energy_map[current_state] + cost

            acc
            |> Map.update(
              next_state,
              new_possible_cost,
              fn value -> min(value, new_possible_cost) end
            )
          end
        end)
        |> Map.delete(current_state)

      {new_current, _} = new_lowest_energy_map |> Enum.min_by(fn {_state, cost} -> cost end)

      find_least_energy_required_part_2(
        new_current,
        new_lowest_energy_map,
        MapSet.put(visited, current_state)
      )
    end
  end

  def find_next_possible_states_part_2(state) do
    state
    |> Enum.reduce([], fn {position, value}, acc ->
      cond do
        value === "." ->
          acc

        true ->
          can_move =
            case position do
              # In the hallway
              {0, _} ->
                # Can only move to go to destination
                true

              # First level
              {1, j} ->
                # Can only move if not current destination and free spot outside
                not (letter_destination_j(value) === j and
                       letter_destination_j(state[{2, j}]) === j and
                       letter_destination_j(state[{3, j}]) === j and
                       letter_destination_j(state[{4, j}]) === j) and
                  (state[{0, j - 1}] === "." or state[{0, j + 1}] === ".")

              # Second level
              {2, j} ->
                # Can only move if not current destination and first level is empty and free spot outside
                state[{1, j}] === "." and
                  not (letter_destination_j(value) === j and
                         letter_destination_j(state[{3, j}]) === j and
                         letter_destination_j(state[{4, j}]) === j) and
                  (state[{0, j - 1}] === "." or state[{0, j + 1}] === ".")

              # Third level
              {3, j} ->
                # Can only move if not current destination and first level is empty and free spot outside
                state[{1, j}] === "." and
                  state[{2, j}] === "." and
                  not (letter_destination_j(value) === j and
                         letter_destination_j(state[{4, j}]) === j) and
                  (state[{0, j - 1}] === "." or state[{0, j + 1}] === ".")

              # Fourth level
              {4, j} ->
                # Can only move if not current destination and first level is empty and free spot outside
                state[{1, j}] === "." and
                  state[{2, j}] === "." and
                  state[{3, j}] === "." and
                  letter_destination_j(value) !== j and
                  (state[{0, j - 1}] === "." or state[{0, j + 1}] === ".")
            end

          if can_move do
            acc ++ possible_moves_cost_part_2(state, position, value)
          else
            acc
          end
      end
    end)
  end

  def possible_moves_cost_part_2(state, position = {i, j}, value) do
    state
    |> Map.keys()
    |> Enum.reduce([], fn {a, b} = spot, acc ->
      # can position go to spot ?
      # get state with new position and energy to get there

      if state[spot] !== "." or spot in impossible_spots() or
           (a === 1 and state[{2, b}] === ".") or
           (a === 1 and
              (letter_destination_j(state[{2, b}]) !== b or
                 letter_destination_j(state[{3, b}]) !== b or
                 letter_destination_j(state[{4, b}]) !== b)) or
           (a === 2 and state[{3, b}] === ".") or
           (a === 2 and
              (letter_destination_j(state[{3, b}]) !== b or
                 letter_destination_j(state[{4, b}]) !== b)) or
           (a === 3 and state[{4, b}] === ".") or
           (a === 3 and letter_destination_j(state[{4, b}]) !== b) do
        acc
      else
        block =
          b..j |> Enum.find(fn val -> val !== b and val !== j and state[{0, val}] !== "." end)

        # is the path free?

        if block do
          acc
        else
          can_move =
            if a === 0 do
              # in the hallway
              i !== 0
            else
              # in a room
              letter_destination_j(value) === b
            end

          if can_move do
            new_state = state |> Map.put(spot, value) |> Map.put(position, ".")
            step_count = abs(j - b) + a + i
            energy_needed = compute_energy_needed(step_count, value)

            [{new_state, energy_needed} | acc]
          else
            acc
          end
        end
      end
    end)
  end

  def starting_state_example_part_2() do
    %{
      {0, 0} => ".",
      {0, 1} => ".",
      {0, 2} => ".",
      {0, 3} => ".",
      {0, 4} => ".",
      {0, 5} => ".",
      {0, 6} => ".",
      {0, 7} => ".",
      {0, 8} => ".",
      {0, 9} => ".",
      {0, 10} => ".",
      {1, 2} => "B",
      {2, 2} => "D",
      {3, 2} => "D",
      {4, 2} => "A",
      {1, 4} => "C",
      {2, 4} => "C",
      {3, 4} => "B",
      {4, 4} => "D",
      {1, 6} => "B",
      {2, 6} => "B",
      {3, 6} => "A",
      {4, 6} => "C",
      {1, 8} => "D",
      {2, 8} => "A",
      {3, 8} => "C",
      {4, 8} => "A"
    }
  end

  def starting_state_input_part_2() do
    %{
      {0, 0} => ".",
      {0, 1} => ".",
      {0, 2} => ".",
      {0, 3} => ".",
      {0, 4} => ".",
      {0, 5} => ".",
      {0, 6} => ".",
      {0, 7} => ".",
      {0, 8} => ".",
      {0, 9} => ".",
      {0, 10} => ".",
      {1, 2} => "D",
      {2, 2} => "D",
      {3, 2} => "D",
      {4, 2} => "B",
      {1, 4} => "D",
      {2, 4} => "C",
      {3, 4} => "B",
      {4, 4} => "A",
      {1, 6} => "C",
      {2, 6} => "B",
      {3, 6} => "A",
      {4, 6} => "A",
      {1, 8} => "B",
      {2, 8} => "A",
      {3, 8} => "C",
      {4, 8} => "C"
    }
  end

  def destination_state_part_2() do
    %{
      {0, 0} => ".",
      {0, 1} => ".",
      {0, 2} => ".",
      {0, 3} => ".",
      {0, 4} => ".",
      {0, 5} => ".",
      {0, 6} => ".",
      {0, 7} => ".",
      {0, 8} => ".",
      {0, 9} => ".",
      {0, 10} => ".",
      {1, 2} => "A",
      {2, 2} => "A",
      {3, 2} => "A",
      {4, 2} => "A",
      {1, 4} => "B",
      {2, 4} => "B",
      {3, 4} => "B",
      {4, 4} => "B",
      {1, 6} => "C",
      {2, 6} => "C",
      {3, 6} => "C",
      {4, 6} => "C",
      {1, 8} => "D",
      {2, 8} => "D",
      {3, 8} => "D",
      {4, 8} => "D"
    }
  end
end
