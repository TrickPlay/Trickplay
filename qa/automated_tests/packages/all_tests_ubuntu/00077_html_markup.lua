
test_description = "use html markup code"
test_group = "smoke"
test_area = "test"
test_api = "use_markup"

function generate_test_image ()
	local g = Group ()

	local myText_markup = Text ()
	myText_markup.font = "DejaVu Sans 38px"
	myText_markup.color = "FFFFFFAA"
	textString = "<span foreground=\"blue\" size=\"x-large\">Trickplay</span> rizzocks the <i>hizzouse</i>!"
	local myText_no_markup = Text ()
myText_markup.text = string.format( "%s" , textString )
	myText_no_markup.position = { 100, 200 }
	myText_markup.use_markup = true
	g:add(myText_markup)

	local myText_no_markup = Text ()
	myText_no_markup.font = "DejaVu Sans 38px"
	myText_no_markup.color = "FFFFFFAA"
	textString = "<span foreground=\"blue\" size=\"x-large\">Trickplay</span> rizzocks the <i>hizzouse</i>!"
	myText_no_markup.text = string.format( "%s" , textString )
	myText_no_markup.use_markup = false
	myText_no_markup.position = { 100, 500 }
	g:add(myText_no_markup)

	return g
end















