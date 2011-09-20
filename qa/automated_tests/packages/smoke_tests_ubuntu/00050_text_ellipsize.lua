
test_description = "Use ellipsize on a variety of code."
test_group = "smoke"
test_area = "text"
test_api = "ellipsize"


local textString = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam nibh. Nunc varius facilisis eros. Sed erat. In in velit quis arcu ornare laoreet. Curabitur adipiscing luctus massa. Integer ut purus ac augue commodo commodo. Nunc nec mi eu justo tempor consectetuer. Etiam vitae nisl. "

function generate_test_image ()
	local g = Group ()

	text_txt = Text {font="DejaVu Sans 40px",
			 text = "START - "..textString, 
			 position = { 20, 200 },
			 alignment = "LEFT",
			 ellipsize = "START", 
			 width = 400,
			 height = 45,
			 clip = { 0, 0, 350, 45 }
			}
	g:add(text_txt)

	text1_txt = Text {font="DejaVu Sans 40px",
			 text = "MIDDLE - "..textString, 
			 position = { 20, 400 },
			 ellipsize = "MIDDLE",  
			 width = 400,
			 height = 45,
			 clip = { 0, 0, 350, 45 }
			 }
	g:add(text1_txt)

	text2_txt = Text {font="DejaVu Sans 40px",
			 text = "END - "..textString, 
			 position = { 20, 600 },
			 ellipsize = "END", 
			 width = 400,
			 height = 45,
			 clip = { 50, 0, 350, 45 }
			}
	g:add(text2_txt)


	text3_txt = Text {font="DejaVu Sans 40px",
			 text = "NONE - "..textString, 
			 position = { 20, 800 },
			 ellipsize = "NONE", 
			 width = 400,
			 height = 45,
			 clip = { 0, 0, 350, 45 }
			}
	g:add(text3_txt)


	return g
end















