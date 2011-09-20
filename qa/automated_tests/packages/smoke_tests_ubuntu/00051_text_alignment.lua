
test_description = "Left, right and center align some wrapped text.."
test_group = "smoke"
test_area = "text"
test_api = "alignment"


local textString = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam nibh. Nunc varius facilisis eros. Sed erat. In in velit quis arcu ornare laoreet. Curabitur adipiscing luctus massa. "

function generate_test_image ()
	local g = Group ()

	text_txt = Text {font="DejaVu Sans 30px",
			 text = "Default - "..textString, 
			 position = { 220, 200 },
			 wrap = true,
			 alignment = "LEFT", 
			 width = 800,
			 height = 140
			}
	g:add(text_txt)

	text1_txt = Text {font="DejaVu Sans 30px",
			 text = "Left - "..textString, 
			 position = { 220, 400 },
			 alignment = "LEFT",  
			 wrap = true,
			 width = 800,
			 height = 140
			 }
	g:add(text1_txt)

	text2_txt = Text {font="DejaVu Sans 30px",
			 text = "Center - "..textString, 
			 position = { 220, 600 },
			 alignment = "CENTER", 
			 wrap = true,
			 width = 800,
			 height = 140
			}
	g:add(text2_txt)


	text3_txt = Text {font="DejaVu Sans 30px",
			 text = "Right - "..textString, 
			 position = { 220, 800 },
			 alignment = "RIGHT", 
			 wrap = true,
			 width = 800,
			 height = 140
			}
	g:add(text3_txt)


	return g
end















