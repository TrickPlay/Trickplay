
test_description = "Raise and lower a rectangle using the sibling parameter."
test_group = "acceptance"
test_area = "container"
test_api = "add/remove"


function generate_test_image ()

	local test_image = Group ()

	local rect1 = Rectangle {
				color = "yellow",
			    	size = { 200, 300 },
				position = { 100, 100 }
	}

	local rect2 = Rectangle {
				color = "blue",
			    	size = { 200, 300 },
				position = { 125, 125 }
	}

	local rect3 = Rectangle {
				color = "green",
			    	size = { 200, 300 },
				position = { 150, 150 }
	}

	local rect4 = Rectangle {
				color = "red",
			    	size = { 200, 300 },
				position = { 175, 175 }
	}

	local rect5 = Rectangle {
				color = "yellow",
			    	size = { 200, 300 },
				position = { 400, 100 }
	}

	local rect6 = Rectangle {
				color = "blue",
			    	size = { 200, 300 },
				position = { 425, 125 }
	}

	local rect7 = Rectangle {
				color = "green",
			    	size = { 200, 300 },
				position = { 450, 150 }
	}

	local rect8 = Rectangle {
				color = "red",
			    	size = { 200, 300 },
				position = { 475, 175 }
	}

	test_image:add(rect1, rect2, rect3, rect4, rect5, rect6, rect7, rect8)
	test_image:raise_child(rect1,rect4)
	test_image:lower_child(rect5,rect8)

	
	return test_image
end











