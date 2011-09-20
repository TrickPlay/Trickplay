
test_description = "Set max_length to 0 and various higher values plus a text wrap example."
test_group = "smoke"
test_area = "text"
test_api = "max_length"


local textString = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam nibh. Nunc varius facilisis eros. Sed erat. In in velit quis arcu ornare laoreet. Curabitur adipiscing luctus massa. Integer ut purus ac augue commodo commodo. Nunc nec mi eu justo tempor consectetuer. Etiam vitae nisl. In dignissim lacus ut ante. Cras elit lectus, bibendum a, adipiscing vitae, commodo et, dui. Ut tincidunt tortor. Donec nonummy, enim in lacinia pulvinar, velit tellus scelerisque augue, ac posuere libero urna eget neque. Cras ipsum. Vestibulum pretium, lectus nec venenatis volutpat, purus lectus ultrices risus, a condimentum risus mi et quam. Pellentesque auctor fringilla neque. Duis eu massa ut lorem iaculis vestibulum. Maecenas facilisis elit sed justo. Quisque volutpat malesuada velit. "

function generate_test_image ()
	local g = Group ()

	text_txt = Text {font="DejaVu Sans 30px",
			 text = "max_length = 0 - "..textString, 
			 position = { 10, 200 },
			 max_length = 0,
			 width = screen.w - 200,
			 height = 45
			}
	g:add(text_txt)

	text1_txt = Text {font="DejaVu Sans 30px",
			 text = "max_length = 25 - "..textString, 
			 position = { 10, 550 },
			 max_length = 25,
			 width = screen.w - 200,
			 height = 45
			 }
	g:add(text1_txt)

	text2_txt = Text {font="DejaVu Sans 30px",
			 text = "max_length = 50 - "..textString, 
			 position = { 10, 650 },
			 max_length = 50, 
			 width = screen.w - 200,
			 height = 45
			}
	g:add(text2_txt)


	text3_txt = Text {font="DejaVu Sans 30px",
			 text = "max_length = 150; wrap = true - "..textString, 
			 position = { 10, 800 },
			 max_length = 150,
			 wrap = true,
			 width = screen.w - 200,
			 height = 90
			}
	g:add(text3_txt)


	return g
end















