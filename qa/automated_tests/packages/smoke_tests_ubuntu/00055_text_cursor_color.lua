
test_description = "Change the cursor color to blue."
test_group = "smoke"
test_area = "text"
test_api = "cursor_color"


local textString = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. "

function generate_test_image ()
	local g = Group ()

	text_txt = Text {font="DejaVu Sans 80px",
			 text = textString, 
			 position = { 100, 150 },
			 single_line = true,
			 width = screen.w - 200,
			 height = 85,
			 wrap = true,
			 editable = true,
			 cursor_visible = true,
			 cursor_color = "00FF00",
			 cursor_size = 10
			}
	g:add(text_txt)


	return g
end















