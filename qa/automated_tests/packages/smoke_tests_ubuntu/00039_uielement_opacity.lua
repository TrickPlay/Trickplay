
test_description = "Show various levels of opacity and color"
test_group = "smoke"
test_area = "UI_element"
test_api = "opacity"


function generate_test_image ()
	local g = Group ()
	local x_rows = screen.w/12
	local y_cols = screen.h/8
	
	for j = 1, 7 do
		for i = 1, 10 do
			local myRec = Rectangle()
			myRec.size = { x_rows - 5, y_cols - 10 }
			myRec.position = {x_rows * i, j * y_cols}
			myRec.color = {j * 35, 255 - j * 35, 255 - j * 35, i*25}
			g:add(myRec)
		end
	end

	return g
end















