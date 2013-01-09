
test_description = "Modify the color and size of the text"
test_group = "smoke"
test_area = "Text"
test_api = "color"


function generate_test_image ()
	local g = Group ()
	local row, col
	local COLS = 17
	local ROWS = 15

	for row = 1, ROWS do
		for col = 1, COLS do
			local font_name, text_txt
			local font_size = row + 20
			local my_scale = 0.3 + (1.5 * col / COLS)

			text_txt = Text {font="DejaVu Sans "..font_size.."px",text="TP"}
			text_txt.color = {col * 35, 255 - col * 35, 255 - col * 35}

			if row == 0 then
				text_txt = Text {font="DejaVu Sans "..font_size.."px",text="TP"}
				text_txt.color = {col * 35, 255 - col * 35, 255 - col * 35}
				font_size = 10
				my_scale = 1.0
			end

			if col == 0 then
				text_txt = Text {font="DejaVu Sans "..font_size.."px",text="TP"}
				text_txt.color = {col * 35, 255 - col * 35, 255 - col * 3500}
				if row == 0 then
					text = nil
				end
				font_size = 10
				my_scale = 1.0
			end

			text_txt.position = { (1.0 * screen.w/COLS)*col, (1.0 * screen.h/ROWS)*row +20}
			text_txt.scale = { my_scale, my_scale }
			text_txt.wrap = false
			g:add(text_txt)
		end
	end

	return g
end















