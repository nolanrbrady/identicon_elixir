defmodule IdenticonElixir do
	def main (index) do
		index
		|> hash_input #pipe to hash_input
		|> pick_color #pipe to pick_color
		|> build_grid #pipe to build grip
		|> filter_odd_squares #pipe to filter out odd squares
		|> build_pixel_map #build out the map
		|> draw_image #draw the image
		|> save_image
	end

	def save_image(image) do
		File.write("test.png", image)
	end

	def draw_image(%IdenticonElixir.Image{color: color, pixel_map: pixel_map}) do
		image = :egd.create(250, 250)
		fill = :egd.color(color)

		Enum.each pixel_map, fn({start, stop}) ->
			:egd.filledRectangle(image, start, stop, fill)
		end
		:egd.render(image)
	end

	def build_pixel_map(%IdenticonElixir.Image{grid: grid} = image) do
			pixel_map = Enum.map grid, fn({_code, index}) ->
				horizontal = rem(index, 5) * 50
				vertical = div(index, 5) * 50

				top_left = {horizontal, vertical}
				bottom_right = {horizontal + 50, vertical + 50}

				{top_left, bottom_right}
			end
				%IdenticonElixir.Image{image | pixel_map: pixel_map}
	end

	def filter_odd_squares(%IdenticonElixir.Image{grid: grid} = image) do
			Enum.filter grid, fn({code, _index}) ->
				rem(code, 2) == 0 #checks to see if the remainder is 0 if not it is removed.
			end
			%IdenticonElixir.Image{image | grid: grid}
	end

	#grabs first 3 values of hex
	def pick_color(image) do
		#grabs the first three hex values from hex (_tail ignores the rest of the list)
		%IdenticonElixir.Image{hex: [r, g, b | _tail]} = image
		#storing the hex values from hex and placing them into the color struct
		%IdenticonElixir.Image{image | color: {r, g, b}}
	end

	#Building out the 5x5 grid for Identicon
	def build_grid(%IdenticonElixir.Image{hex: hex} = image) do
		grid =
			hex
			|> Enum.chunk(3) #loops through and breaks hex list into triples
			|> Enum.map(&mirror_row/1) #calling mirror_row
			|> List.flatten
			|> Enum.with_index #adds tuples with index to list

		%IdenticonElixir.Image{image | grid: grid}
	end

	#mirrors the rows to make the grid
	def mirror_row(row) do
		[first, second | _tail] = row # grab the first and second value of rows
		row ++ [second, first] #take the list row and add on the second and first value
		end

	#hash string function
  def hash_input (input) do
  	hex = :crypto.hash(:md5, input)
		|> :binary.bin_to_list

			%IdenticonElixir.Image{hex: hex}
  end
end
