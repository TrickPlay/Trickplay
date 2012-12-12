
test_description = "Wrap_mode wraps CHAR, WORD and WORD_CHAR"
test_group = "smoke"
test_area = "test"
test_api = "use_markup"

function generate_test_image ()

	local g = Group ()

	local textString = "That samiam that samiam. I do not like that samiam. do you like green eggs and ham?That samiam that samiam. I do not like that samiam. do you like green eggs and ham? That samiam that samiam. I do not like that samiam. do you like green eggs and ham? That samiam that samiam. I do not like that samiam. do you like green eggs and ham? That samiam that samiam. I do not like that samiam. do you like green eggs and ham? That samiam that samiam. I do not like that samiam. do you like green eggs and ham?"


	--wrap - false
	text_txt = Text {font="DejaVu Sans 30px",
			 text = textString, 
			 position = { 100, 50 },
			 width = screen.w - 210,
			 height = 300,
			 wrap = false
			}
	g:add(text_txt)

	-- wrap = true, word_wrap = CHAR
	text1_txt = Text {font="DejaVu Sans 30px",
			 text = textString, 
			 position = { 100, 300 },
			 width = screen.w - 210,
			 height = 300,
			 wrap = true,
			 wrap_mode = "CHAR"
			 }

	g:add(text1_txt)

	-- wrap = true, word_wrap = WORD
	text2_txt = Text {font="DejaVu Sans 30px",
			 text = textString, 
			 position = { 100, 550 },
			 width = screen.w - 210,
			 height = 400,
			 wrap = true,
			 wrap_mode = "WORD"
			 }
	g:add(text2_txt)

	-- wrap = true, word_wrap = WORD_CHAR
	text3_txt = Text {font="DejaVu Sans 30px",
			 text = textString, 
			 position = { 100, 800 },
			 width = screen.w - 210,
			 height = 400,
			 wrap = true,
			 wrap_mode = "WORD_CHAR"
			 }
	g:add(text3_txt)

	return g
end















