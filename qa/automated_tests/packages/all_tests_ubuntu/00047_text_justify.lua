
test_description = "Justified and Unjustified text"
test_group = "smoke"
test_area = "Text"
test_api = "justify"

local textString = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam nibh. Nunc varius facilisis eros. Sed erat. In in velit quis arcu ornare laoreet. Curabitur adipiscing luctus massa. Integer ut purus ac augue commodo commodo. Nunc nec mi eu justo tempor consectetuer. Etiam vitae nisl. In dignissim lacus ut ante. Cras elit lectus, bibendum a, adipiscing vitae, commodo et, dui. Ut tincidunt tortor. Donec nonummy, enim in lacinia pulvinar, velit tellus scelerisque augue, ac posuere libero urna eget neque. Cras ipsum. Vestibulum pretium, lectus nec venenatis volutpat, purus lectus ultrices risus, a condimentum risus mi et quam. Pellentesque auctor fringilla neque. Duis eu massa ut lorem iaculis vestibulum. Maecenas facilisis elit sed justo. Quisque volutpat malesuada velit. "

function generate_test_image ()
	local g = Group ()

	text_txt = Text {font="DejaVu Sans 30px",
			 text = "JUSTIFIED\n"..textString, 
			 position = { 20, 200 },
			 alignment = "LEFT",
			 justify = true, 
			 wrap = true, 
			 width = 800 }
	g:add(text_txt)

	text1_txt = Text {font="DejaVu Sans 30px",
			 text = "UNJUSTIFIED\n"..textString, 
			 position = { screen.w/2, 200 },
			 justify = false, 
			 wrap = true, 
			 width = 800 }
	g:add(text1_txt)

	return g
end















