
test_description = "Display the possible style options with Korean text."
test_group = "smoke"
test_area = "Text"
test_api = "font"


function generate_test_image ()

	local font_list = {
		"UnBatang",
		"UnBatang Bold",
		"UnDotum",
		"UnDotum Bold",
		"UnGungseo"
}

	local g = Group ()
	local row, col
	local COLS = 2
	local ROWS = 7
	local font_count = 1
	local test_string = "환영받는"

	for row = 1, ROWS do
		local col = 1
		while col < COLS and font_count <= #font_list do
			local font_name, text_txt
			local font_size = 55
		
			text_txt = Text {font=font_list[font_count].." "..font_size.."px",text=font_list[font_count].." \t\t "..test_string}
			text_txt.color = {0, 0, 0}

			if row == 0 then
				text_txt = Text {font=font_list[font_count].."   "..font_size.."px",text=font_list[font_count].." \t\t "..test_string}
				text_txt.color = {0, 0, 0}
				font_size = 10
				my_scale = 1.0
			end

			if col == 0 then
				text_txt = Text {font=font_list[font_count].."  "..font_size.."px",text=font_list[font_count].." \t\t "..test_string}
				text_txt.color = {0, 0, 0}
				if row == 0 then
					text = nil
				end
				font_size = 10
				my_scale = 1.0
			end
			text_txt.position = { 50, (screen.h/ROWS)*row + 60}

			g:add(text_txt)

			font_count = font_count + 1
			col = col + 1
		end
	end
	
	return g


end














