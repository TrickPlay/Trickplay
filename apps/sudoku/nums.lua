local big_font_s   = "DejaVu Bold 82px"
local big_font     = "DejaVu Bold 80px"
local shadow_color = "000000"
local given_color  = "FFFFFF"
local user_color   = "fefa00"
local wrong_color  = "FF0000"
local pencil_font  = "Eraser 57px"

given_nums     = {}
pen_nums       = {}
wr_pen_nums    = {}
pencil_nums    = {}
wr_pencil_nums = {}
for i=1,9 do
	given_nums[i] = Group{
		name=i
	}
	given_nums[i]:add(
		Text{
				text  = i,
				font  = big_font_s,
				color = shadow_color,
		},Text{
				text  = i,
				font  = big_font,
				color = given_color,
				position = {1,1}
	})	
	screen:add(given_nums[i])
	pen_nums[i] = Group{
		name=i
	}
	pen_nums[i]:add(
			Text{
				text  = i,
				font  = big_font_s,
				color = shadow_color,
		},Text{
				text  = i,
				font  = big_font,
				color = user_color,
				position = {1,1}
	})
	screen:add(pen_nums[i])
	wr_pen_nums[i] = Group{
		name=i
	}
	wr_pen_nums[i]:add(
			Text{
				text  = i,
				font  = big_font_s,
				color = shadow_color,
		},Text{
				text  = i,
				font  = big_font,
				color = wrong_color,
				position = {1,1}
	})
	screen:add(wr_pen_nums[i])
	pencil_nums[i] = Text{
				text  = i,
				font  = pencil_font,
				color = user_color,
				position = {1,1}
	}
	screen:add(pencil_nums[i])
	wr_pencil_nums[i] = Text{
				text  = i,
				font  = pencil_font,
				color = wrong_color,
				position = {1,1}
	}
	screen:add(wr_pencil_nums[i])

end

