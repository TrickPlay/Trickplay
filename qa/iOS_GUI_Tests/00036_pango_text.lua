
test_description = "Display a variety of Pango text options"
test_steps = "View the device"
test_verify = " Compare the device to the screenshot."
test_group = "acceptance"
test_area = "Text"
test_api = "Pango"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}
	
	local t1 = factory:Text{x = 10, y = 10, w = 500, h = 200, markup = "<span font=\"Verdana 20px\" foreground=\"blue\" strikethrough=\"true\">Blue text with yellow <sub>strike-through</sub>!"}

	local t2 = factory:Text{x = 10, y = 50, w = 500, h = 200, markup = "<span font=\"Verdana 20px\" foreground=\"white\" rise=\"200\"> white text with rise = 200"}

	local t3 = factory:Text{x = 10, y = 90, w = 500, h = 200, markup = "<span font=\"Verdana 20px\" foreground=\"blue\" >Blue text with no rise"}

	local t4 = factory:Text{x = 10, y = 130, w = 500, h = 200, markup = "<span font=\"Verdana 20px\" foreground=\"white\">white text with <sub>this part subscripted</sub>!"}

	local t5 = factory:Text{x = 10, y = 170, w = 500, h = 200, markup = "<span font=\"Verdana 20px\" foreground=\"white\">white text with <sup>this part superscripted</sup>!"}

	local t6 = factory:Text{x = 10, y = 210, w = 500, h = 200, markup = "<span font=\"Verdana 20px\" foreground=\"green\" letter_spacing=\"2000\">green text with wide letter spacing!"}


	g:add(t1, t2, t3, t4, t5, t6)

	return g
end

	
