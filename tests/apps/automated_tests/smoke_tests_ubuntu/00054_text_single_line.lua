
test_description = "The single_line property set to true should cutoff the text at the width "
test_group = "smoke"
test_area = "text"
test_api = "single_line"


local textString = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam nibh. Nunc varius facilisis eros. Sed erat. In in velit quis arcu ornare laoreet. Curabitur adipiscing luctus massa. Integer ut purus ac augue commodo commodo. Nunc nec mi eu justo tempor consectetuer. Etiam vitae nisl. In dignissim lacus ut ante. Cras elit lectus, bibendum a, adipiscing vitae, commodo et, dui. Ut tincidunt tortor. Donec nonummy, enim in lacinia pulvinar, velit tellus scelerisque augue, ac posuere libero urna eget neque. Cras ipsum. Vestibulum pretium, lectus nec venenatis volutpat, purus lectus ultrices risus, a condimentum risus mi et quam. Pellentesque auctor fringilla neque. Duis eu massa ut lorem iaculis vestibulum. Maecenas facilisis elit sed justo. Quisque volutpat malesuada velit. "

function generate_test_image ()
	local g = Group ()

	text_txt = Text {font="Sans 40px",
			 text = "single_line = true - "..textString, 
			 position = { 10, 150 },
			 single_line = true,
			 width = screen.w - 200,
			 height = 45,
			 wrap = true
			}
	g:add(text_txt)

	text1_txt = Text {font="Sans 40px",
			 text = "single_line = false - "..textString, 
			 position = { 10, 450 },
			 single_line = false,
			 width = screen.w - 200,
			 height = 45,
			 wrap = true
			 }
	g:add(text1_txt)


	return g
end















