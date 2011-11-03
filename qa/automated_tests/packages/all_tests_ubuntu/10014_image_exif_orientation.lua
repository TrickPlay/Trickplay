
test_description = "View 2 pictures taken in portrait orientation. Verify the one with the exif orientation tag = rotate CW 90 is rotated correctly."
test_group = "acceptance"
test_area = "image"
test_api = "exif orientation"


function generate_test_image ()

	image1_loaded = false
	image2_loaded = false
 	
	local image1 = Image ()
	image1.async = true

	image1.on_loaded = function ( loaded_image, failed )
	   if failed == false then
	   	image1_loaded = true
	  	--print ("image1 loaded")
	  end
	end

	image1.src = "packages/assets/exif_pic_none.jpg"
	image1.position = { screen.w/2, 150}


	local image2 = Image ()
	image2.async = true

	image2.on_loaded = function ( loaded_image, failed )
	   if failed == false then
	   	image2_loaded = true
	  	--print ("image2 loaded")
	  end
	end

	image2.src = "packages/assets/exif_rotate_90_cw.jpg"
	image2.position = { 150, 150}


	local g = Group ()

--[[
	 {
	        size = { screen.w , screen.h },
	        children = {
	 --          Image {
	--		src = "packages/assets/exif_pic_none.jpg",
	--		position = { screen.w/2, 150},
		   },
		   Text {
		--	text = "no exif orientation tag",
			position = { screen.w/2, 150},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   Image {
			src = "packages/assets/exif_rotate_90_cw.jpg",
			position = { 150, 150},
		   },
		   Text {
		--	text = "exif orientation tag = Rotate 90 CW",
			position = { 150, 150 },
			color = "000000",
			font = "DejaVu Sans 40px"
		   }
		}
	}
--]]
	--g:add(image1, image2)
	return g
end















