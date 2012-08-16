
test_description = "use html markup code"
test_group = "smoke"
test_area = "test"
test_api = "use_markup"

function generate_test_image ()
	local g = Group ()

	local myText_markup = Text ()
	myText_markup.font = "DejaVu Sans 38px"
	myText_markup.color = "000000"
	textString = "Default\n<span foreground=\"blue\" size=\"x-large\">Trickplay</span> rizzocks the <i>hizzouse</i>!"
	myText_markup.markup = string.format( "%s" , textString )
	myText_markup.position = { 100, 200 }
	g:add(myText_markup)

	local myText_no_markup = Text ()
	myText_no_markup.font = "DejaVu Sans 38px"
	myText_no_markup.color = "000000"
	textString = "use_markup = false\n<span foreground=\"blue\" size=\"x-large\">Trickplay</span> rizzocks the <i>hizzouse</i>!"
	myText_no_markup.markup = string.format( "%s" , textString )
	myText_no_markup.use_markup = false
	myText_no_markup.position = { 100, 500 }
	g:add(myText_no_markup)

	local myText1_markup = Text ()
	myText1_markup.font = "DejaVu Sans 38px"
	myText1_markup.color = "000000"
	textString = "use_markup = true\n<span foreground=\"blue\" size=\"x-large\">Trickplay</span> rizzocks the <i>hizzouse</i>!"
	myText1_markup.markup = string.format( "%s" , textString )
	myText1_markup.position = { 100, 700 }
	g:add(myText1_markup)

	return g
end















