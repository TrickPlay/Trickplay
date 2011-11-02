-- Test Set up --
local test_description = "Verify that string and image change when localization variables are changed."
local test_group = "acceptance"
local test_area = "localization"
local test_api = "jp"

test_question = "Switch system language to Japanese. Then restart app and verify that there's a picture of Mount Fuji and the text says 富士山."

function generate_test_image ()

	strings = dofile( "localized:strings.lua" )

 	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	    		Rectangle {
			    	color = "000000",
			    	size = { screen.w, screen.h }
			    },
			Text {
				text = strings.country_icon,
				font = "Deja Vu 60px",
				position = { 250, 600 },
				color = "FFFFFF"
			},
			 Image {
				src = "localized:country_icon.jpg",
				position = { 200, 200 }
				}
		}
	}
	
	return g

end







