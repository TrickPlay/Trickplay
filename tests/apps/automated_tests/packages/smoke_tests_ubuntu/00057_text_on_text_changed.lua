
test_description = "Replace text with the * character for password protection."
test_group = "smoke"
test_area = "text"
test_api = "password_char"


local textString = "Lorem ipsum dolor sit amet "
local text_txt = Text ()

function generate_test_image ()
	
	local g = Group ()

	text_txt.on_text_changed = function (text)
		print ("on_text_changed called")
		local 	text1_txt = Text {
			 font="Sans 80px",
			 text = "On_text_changed called", 
			 position = { 200, 150 },
			 width = screen.w - 200,
			 color = "002EB8"
			}
		g:add(text1_txt)
	end

	text_txt = Text {
			 font="Sans 80px",
			 text = textString, 
			 position = { 200, 350 },
			 single_line = true,
			 width = screen.w - 200
			}
	g:add(text_txt)

	text_txt.text = "changed"

	return g
end















