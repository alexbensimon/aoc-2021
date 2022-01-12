defmodule Day20 do
  def answer_part_1_example, do: answer_part_1("inputs/20/example.txt")

  def answer_part_1_input, do: answer_part_1("inputs/20/input.txt")

  def answer_part_1(file_path) do
    {image, algo} =
      file_path
      |> read_file()

    image
    |> extend_image(".")
    |> enhance_image(algo, ".")
    # The infinite was changed into the first pixel in algo
    |> extend_image(String.at(algo, 0))
    |> enhance_image(algo, String.at(algo, 0))
    |> Enum.count(fn {_, pixel} -> pixel === "#" end)
  end

  def read_file(file_path) do
    {:ok, contents} = File.read(file_path)

    [algo, image] =
      contents
      |> String.split("\n\n", trim: true)

    image =
      for {line, row} <-
            image
            |> String.split("\n", trim: true)
            |> Enum.with_index(),
          {pixel, col} <- line |> String.graphemes() |> Enum.with_index(),
          into: %{} do
        {{row, col}, pixel}
      end

    {image, algo}
  end

  # Extends image of 2 pixels in every direction
  def extend_image(image, padding_pixel) do
    extension = 2
    max = image_max_index(image)
    full = max + extension * 2

    image =
      for {{row, col}, pixel} <- image, into: %{} do
        {{row + extension, col + extension}, pixel}
      end

    # Top
    image =
      for row <- 0..(extension - 1), col <- 0..full, reduce: image do
        acc -> Map.put(acc, {row, col}, padding_pixel)
      end

    # Left
    image =
      for row <- 0..full, col <- 0..(extension - 1), reduce: image do
        acc -> Map.put(acc, {row, col}, padding_pixel)
      end

    # Right
    image =
      for row <- 0..full, col <- (max + extension + 1)..full, reduce: image do
        acc -> Map.put(acc, {row, col}, padding_pixel)
      end

    # Bottom
    for row <- (max + extension + 1)..full, col <- 0..full, reduce: image do
      acc -> Map.put(acc, {row, col}, padding_pixel)
    end
  end

  def image_max_index(image) do
    {max, _} = image |> Map.keys() |> Enum.max_by(fn {row, _} -> row end)
    max
  end

  def enhance_image(image, algo, unknown_pixel) do
    max = image_max_index(image)

    # For each pixel
    for row <- 0..max, col <- 0..max, into: %{} do
      # Get the 9 pixels around
      around =
        for i <- (row - 1)..(row + 1), j <- (col - 1)..(col + 1), into: [] do
          case image |> Map.get({i, j}) do
            nil -> unknown_pixel
            pixel -> pixel
          end
        end

      {index, _} =
        around
        |> Enum.map(fn pixel ->
          case pixel do
            "." -> 0
            "#" -> 1
          end
        end)
        |> Enum.join()
        |> Integer.parse(2)

      new_pixel = String.at(algo, index)

      {{row, col}, new_pixel}
    end
  end

  def print_image(image) do
    max = image_max_index(image)

    for row <- 0..max do
      for col <- 0..max, into: "" do
        Map.get(image, {row, col})
      end
      |> IO.inspect()
    end

    image
  end

  def answer_part_2_example, do: answer_part_2("inputs/20/example.txt")

  def answer_part_2_input, do: answer_part_2("inputs/20/input.txt")

  def answer_part_2(file_path) do
    {image, algo} =
      file_path
      |> read_file()

    1..50
    |> Enum.reduce(image, fn i, acc ->
      unknown_pixel =
        cond do
          i === 1 ->
            "."

          rem(i, 2) === 0 ->
            String.at(algo, 0)

          true ->
            # If the first index of the algo is empty, the expansion will always be empty
            if String.at(algo, 0) === "." do
              "."
              # Otherwise, it will alternate between empty and full
            else
              String.at(algo, -1)
            end
        end

      acc
      |> extend_image(unknown_pixel)
      |> enhance_image(algo, unknown_pixel)
    end)
    |> Enum.count(fn {_, pixel} -> pixel === "#" end)
  end
end
