
test_description = "Display the possible style options with the DejaVu font"
test_group = "smoke"
test_area = "Text"
test_api = "font"


function generate_test_image ()

	local font_list = {
		"TakaoExGothic",
		"TakaoGothic",
		"TakaoPGothic",
		"TakaoMincho",
		"TakaoPMincho",
		"TakaoExMincho"
}

	local g = Group ()
	local row, col
	local COLS = 2
	local ROWS = 8
	local font_count = 1
	local test_string = "花は桜、人は武士。ソープあいうえおかきくけこ"

	for row = 1, ROWS do
		local col = 1
		while col < COLS and font_count <= #font_list do
			local font_name, text_txt
			local font_size = 60
		
			text_txt = Text {font=font_list[font_count].." "..font_size.."px",text=test_string.."\t"..font_list[font_count]}
			text_txt.color = {0, 0, 0}

			if row == 0 then
				text_txt = Text {font=font_list[font_count].."   "..font_size.."px",text=test_string.."\t"..font_list[font_count]}
				text_txt.color = {0, 0, 0}
				font_size = 10
				my_scale = 1.0
			end

			if col == 0 then
				text_txt = Text {font=font_list[font_count].."  "..font_size.."px",text=test_string.."\t"..font_list[font_count]}
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














