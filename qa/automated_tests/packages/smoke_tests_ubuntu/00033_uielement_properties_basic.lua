
test_description = "Display some basic UI properties"
test_group = "smoke"
test_area = "UI_element"
test_api = "properties_basic"


function generate_test_image ()
 	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	name = "myRec",
			x = screen.w/2 - 300,
			y = screen.h/2 - 300,
			z = screen.z/2,
			color = "CCFFCC",
			w = 600,
			h = 400
		   }
		}
	}
			
	local g2 = Group 
	{
		size = { screen.w , screen.h },
	        children = {
	            Text {
	            	text = "x = "..g:find_child("myRec").x,
			x = screen.w/8,
			y = screen.h/4,
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		    Text {
	            	text = "y = "..g:find_child("myRec").y,
			x = screen.w/8,
			y = screen.h/4 + 40,
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		    Text {
	            	text = "w = "..g:find_child("myRec").w,
			x = screen.w/8,
			y = screen.h/4 + 80,
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		    Text {
	            	text = "h = "..g:find_child("myRec").h,
			x = screen.w/8,
			y = screen.h/4 + 120,
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		    Text {
	            	text = "size = "..g:find_child("myRec").size[1]..", "..g:find_child("myRec").size[2],
			x = screen.w/8,
			y = screen.h/4 + 160,
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		    Text {
	            	text = "position = "..g:find_child("myRec").position[1]..", "..g:find_child("myRec").position[2],
			x = screen.w/8,
			y = screen.h/4 + 200,
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		    Text {
	            	text = "center = "..g:find_child("myRec").center[1]..", "..g:find_child("myRec").center[2],
			x = screen.w/8,
			y = screen.h/4 + 240,
			color = "000000",
			font = "DejaVu Sans 40px"
		   }
	    }
	}
	g:add(g2)

	return g
end















