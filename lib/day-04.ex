defmodule Day04 do
  def answer_part_1_example, do: answer_part_1("inputs/04/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/04/input.txt")

  def answer_part_1(file_path) do
    {numbers_to_draw, boards} = read_file(file_path) |> parse_file_contents()

    {last_number, winning_board} = draw_numbers(numbers_to_draw, boards)

    sum_unmarked_numbers(winning_board) * last_number
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    contents
    |> String.split("\n\n", trim: true)
  end

  def parse_file_contents(contents) do
    [first_line | rest] = contents

    numbers_to_draw = first_line |> String.split(",")

    boards =
      rest
      |> Enum.map(
        # Split each board
        &(String.split(&1, "\n", trim: true)
          # Split each board_line into list of numbers
          |> Enum.map(fn board_line -> String.split(board_line, " ", trim: true) end))
      )

    {numbers_to_draw, boards}
  end

  def draw_numbers([number | rest_to_draw], boards) do
    case check_number_on_boards(number, boards, []) do
      {:victory, winning_board} -> {String.to_integer(number), winning_board}
      marked_boards -> draw_numbers(rest_to_draw, marked_boards)
    end
  end

  def check_number_on_boards(number, [board | next_boards], marked_boards) do
    new_board = check_number_on_board(number, board)

    if verify_board_victory(new_board) do
      {:victory, new_board}
    else
      check_number_on_boards(number, next_boards, [new_board | marked_boards])
    end
  end

  def check_number_on_boards(_number, [], marked_boards), do: marked_boards

  def check_number_on_board(number, board) do
    board
    |> Enum.map(fn board_line ->
      board_line
      |> Enum.map(fn board_number ->
        if board_number == number do
          # We convert the string to integer to mark them
          String.to_integer(board_number)
        else
          board_number
        end
      end)
    end)
  end

  def verify_board_victory(board) do
    # verify rows
    if verify_rows_victory(board) do
      true
    else
      # transpose
      # verify columns
      verify_rows_victory(board |> transpose)
    end
  end

  def verify_rows_victory(rows) do
    size = length(rows)
    # If the integer count on a line is equal to the size, this is a winning board
    rows
    |> Enum.reduce(false, fn row, acc -> row |> Enum.count(&is_integer/1) === size || acc end)
  end

  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def sum_unmarked_numbers(board) do
    board
    |> Enum.reduce(0, fn row, total_sum ->
      total_sum +
        Enum.reduce(row, 0, fn number, row_sum ->
          # The unmarked numbers are the strings
          if !is_integer(number) do
            row_sum + String.to_integer(number)
          else
            row_sum
          end
        end)
    end)
  end

  def answer_part_2_example, do: answer_part_2("inputs/04/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/04/input.txt")

  def answer_part_2(file_path) do
    {numbers_to_draw, boards} = read_file(file_path) |> parse_file_contents()

    {last_number, last_winning_board} = draw_numbers_part_2(numbers_to_draw, boards)

    sum_unmarked_numbers(last_winning_board) * last_number
  end

  def draw_numbers_part_2([number | rest_to_draw], boards) do
    case check_number_on_boards_part_2(number, boards, []) do
      {:victory, winning_board} -> {String.to_integer(number), winning_board}
      marked_boards -> draw_numbers_part_2(rest_to_draw, marked_boards)
    end
  end

  def check_number_on_boards_part_2(
        number,
        [board | next_boards] = remaining_boards,
        marked_boards
      ) do
    new_board = check_number_on_board(number, board)

    if verify_board_victory(new_board) do
      if length(remaining_boards) === 1 and length(marked_boards) === 0 do
        {:victory, new_board}
      else
        # if the board wins, we don't want it in the marked_boards anymore unless it's the last one
        check_number_on_boards_part_2(number, next_boards, marked_boards)
      end
    else
      check_number_on_boards_part_2(number, next_boards, [new_board | marked_boards])
    end
  end

  def check_number_on_boards_part_2(_number, [], marked_boards),
    do: marked_boards
end
