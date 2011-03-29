
test_description = "Replace text with the * character for password protection."
test_group = "smoke"
test_area = "text"
test_api = "password_char"


local textString = "Lorem ipsum dolor sit amet "

function generate_test_image ()
	local g = Group ()

	text_txt = Text {font="Sans 80px",
			 text = textString, 
			 position = { 100, 150 },
			 single_line = true,
			 width = screen.w - 200,
			 height = 85,
			 wrap = true,
			 password_char = 42
			}
	g:add(text_txt)


	return g
end















