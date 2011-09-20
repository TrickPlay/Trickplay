
test_description = "Display all fonts"
test_group = "smoke"
test_area = "Text"
test_api = "font"


function generate_test_image ()

	local font_list = {
		"Accidental Presidency",
		"Anivers",
		"Aurulent Sans",
		"Banhart",
		"Blackout",
		"Blue Highway",
		"Blue Highway Condensed",
		"Blue Highway D Type",
		"Blue Highway Linocut",
		"Comfortaa",
		"DejaVu Sans",
		"DejaVu Sans Mono",
		"DejaVu Serif",
		"Delicious",
		"Diavlo",
		"Eraser",
		"Fertigo",
		"Fontin",
		"Fontin Sans",
		"GraublauWeb",
		"Highway Gothic Condensed",
		"Highway Gothic Expanded",
		"Highway Gothic Narrow",
		"Highway Gothic Wide",
		"Junction",
		"Kenyan Coffee",
		"League Gothic",
		"Liberation Sans",
		"Mail Ray Stuff",
		"Minya Nouvelle",
		"Museo",
		"Museo Sans",
		"Museo Slab",
		"Orbitron",
		"Pankenham",
		"Raleway",
		"Sniglet",
		"Steelfish",
		"Steelfish Outline",
		"Teen",
		"Teen Light",
		"x360",
		"Sans",
		"Un"
	}

	local g = Group ()
	local row, col
	local COLS = 3
	local ROWS = 24
	local font_count = 1

	for row = 1, ROWS do
		local col = 1
		while col < COLS and font_count <= #font_list do
			local font_name, text_txt
			local font_size = 40
		
			text_txt = Text {font=font_list[font_count].." oblique "..font_size.."px",text=font_list[font_count]}
			text_txt.color = {0, 0, 0}

			if row == 0 then
				text_txt = Text {font=font_list[font_count].." oblique  "..font_size.."px",text=font_list[font_count]}
				text_txt.color = {0, 0, 0}
				font_size = 10
				my_scale = 1.0
			end

			if col == 0 then
				text_txt = Text {font=font_list[font_count].." oblique  "..font_size.."px",text=font_list[font_count]}
				text_txt.color = {0, 0, 0}
				if row == 0 then
					text = nil
				end
				font_size = 10
				my_scale = 1.0
			end
			text_txt.position = { (screen.w/COLS)*col - 500, (screen.h/ROWS)*row + 40}

			g:add(text_txt)

			font_count = font_count + 1
			col = col + 1
		end
	end
	
	return g


end














