defmodule Day21 do
  def answer_part_1_example, do: answer_part_1("inputs/21/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/21/input.txt")

  def answer_part_1(file_path) do
    {game, rolled} =
      file_path
      |> read_file()
      |> play(1, 0, 0)

    {_, {_, losing_score}} = game |> Enum.min_by(fn {_, {_, score}} -> score end)

    losing_score * rolled
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    regex = ~r"Player (\d+) starting position: (\d+)"

    # We want a map with player => {position, score}
    contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> Regex.scan(regex, line) |> List.flatten() end)
    |> Enum.reduce(%{}, fn [_, player, position], acc ->
      acc |> Map.put(player |> String.to_integer(), {position |> String.to_integer(), 0})
    end)
  end

  def play(game, next_player, die, rolled) do
    if game |> Enum.find(fn {_, {_, score}} -> score >= 1000 end) do
      {game, rolled}
    else
      next_turn(game, next_player, die, rolled)
    end
  end

  def next_turn(game, next_player, die, rolled) do
    {position, score} = game |> Map.get(next_player)

    {value, die, rolled} = roll_die(die, rolled)

    position = move(value, position)

    game = game |> Map.put(next_player, {position, score + position})

    next_player =
      if next_player === 1 do
        2
      else
        1
      end

    play(game, next_player, die, rolled)
  end

  def roll_die(die, rolled) do
    1..3
    |> Enum.reduce({0, die, rolled}, fn _, {value, die, rolled} ->
      die =
        if die === 100 do
          1
        else
          die + 1
        end

      {value + die, die, rolled + 1}
    end)
  end

  def move(value, position) do
    res = rem(value + position, 10)

    if res === 0 do
      10
    else
      res
    end
  end

  def answer_part_2_example, do: answer_part_2("inputs/21/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/21/input.txt")

  def answer_part_2(file_path) do
    games =
      file_path
      |> read_file_part_2()
      |> play_part_2()

    for {{_, score_1, _, score_2, _}, universe_count} <- games, reduce: [0, 0] do
      [p1_wins, p2_wins] ->
        if score_1 > score_2 do
          [p1_wins + universe_count, p2_wins]
        else
          [p1_wins, p2_wins + universe_count]
        end
    end
    |> Enum.max()
  end

  def read_file_part_2(file_path) do
    {:ok, contents} = File.read(file_path)

    regex = ~r"Player (\d+) starting position: (\d+)"

    # We want a map with {position_1, score_1, position_2, score_2, next_player} => universe count
    [[_, "1", position_1], [_, "2", position_2]] =
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> Regex.scan(regex, line) |> List.flatten() end)

    %{{String.to_integer(position_1), 0, String.to_integer(position_2), 0, 1} => 1}
  end

  def play_part_2(games) do
    not_ended_game =
      games
      |> Enum.find(&both_scores_under_21/1)

    # We continue while we still have some game not finished
    if not_ended_game do
      next_turn_part_2(games)
    else
      games
    end
  end

  def next_turn_part_2(games) do
    possible_rolls =
      for a <- 1..3, b <- 1..3, c <- 1..3 do
        a + b + c
      end
      |> Enum.frequencies()

    not_ended_games =
      games
      |> Enum.filter(&both_scores_under_21/1)

    ended_games =
      games
      |> Enum.reject(&both_scores_under_21/1)
      |> Map.new()

    for {game, previous_universe_count} <- not_ended_games,
        reduce: ended_games do
      acc ->
        {position_1, score_1, position_2, score_2, next_player} = game

        for {roll, frequency} <- possible_rolls, reduce: acc do
          acc ->
            {position, score} = player(game)
            position = move(roll, position)
            score = score + position

            key =
              if next_player === 1 do
                {position, score, position_2, score_2, 2}
              else
                {position_1, score_1, position, score, 1}
              end

            # Each universe that rolls this result produces a new universe
            new_universe_count = frequency * previous_universe_count

            Map.update(
              acc,
              key,
              new_universe_count,
              fn universe_count -> universe_count + new_universe_count end
            )
        end
    end
    |> play_part_2()
  end

  def both_scores_under_21({{_, score_1, _, score_2, _}, _}), do: score_1 < 21 && score_2 < 21

  def player({position_1, score_1, position_2, score_2, next_player}) do
    if next_player === 1 do
      {position_1, score_1}
    else
      {position_2, score_2}
    end
  end
end
