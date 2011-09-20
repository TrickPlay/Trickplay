
test_description = "Replace text with the * character for password protection."
test_group = "smoke"
test_area = "text"
test_api = "password_char"


local textString = "Lorem ipsum dolor sit amet "
local text_txt = Text ()

function generate_test_image ()
	
	local g = Group ()

	function text_changed (text)
		print ("text changed")
		local text1_txt = Text {
			font="DejaVu Sans 80px",
			color = "002eb8",
			 text = "on_text_changed called", 
			 position = { 200, 450 }
		}
		g:add(text1_txt)
	end

	text_txt = Text {
			 font="DejaVu Sans 80px",
			 text = textString, 
			 position = { 200, 350 },
			 single_line = true,
			 width = screen.w - 200
			}
	text_txt.on_text_changed = text_changed
	text_txt.text = "text changed"
	g:add(text_txt)

	return g
end


























