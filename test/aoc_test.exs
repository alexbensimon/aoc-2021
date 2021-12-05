defmodule Day01Tests do
  use ExUnit.Case

  test "Day01 part 1 example" do
    assert Day01.answer_part_1_example() == 7
  end

  test "Day01 part 1 input" do
    assert Day01.answer_part_1_input() == 1167
  end

  test "Day01 part 2 example" do
    assert Day01.answer_part_2_example() == 5
  end

  test "Day01 part 2 input" do
    assert Day01.answer_part_2_input() == 1130
  end
end

defmodule Day02Tests do
  use ExUnit.Case

  test "Day02 part 1 example" do
    assert Day02.answer_part_1_example() == 150
  end

  test "Day02 part 1 input" do
    assert Day02.answer_part_1_input() == 1_728_414
  end

  test "Day02 part 2 example" do
    assert Day02.answer_part_2_example() == 900
  end

  test "Day02 part 2 input" do
    assert Day02.answer_part_2_input() == 1_765_720_035
  end
end

defmodule Day03Tests do
  use ExUnit.Case

  test "Day03 part 1 example" do
    assert Day03.answer_part_1_example() == 198
  end

  test "Day03 part 1 input" do
    assert Day03.answer_part_1_input() == 4_006_064
  end

  test "Day03 part 2 example" do
    assert Day03.answer_part_2_example() == 230
  end

  test "Day03 part 2 input" do
    assert Day03.answer_part_2_input() == 5_941_884
  end
end

defmodule Day04Tests do
  use ExUnit.Case

  test "Day04 part 1 example" do
    assert Day04.answer_part_1_example() == 4512
  end

  test "Day04 part 1 input" do
    assert Day04.answer_part_1_input() == 8136
  end

  test "Day04 part 2 example" do
    assert Day04.answer_part_2_example() == 1924
  end

  test "Day04 part 2 input" do
    assert Day04.answer_part_2_input() == 12738
  end
end
