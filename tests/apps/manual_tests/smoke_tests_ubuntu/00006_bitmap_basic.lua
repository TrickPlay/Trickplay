--[[
Filename: 0005_bitmap_basic.lua
Author: Peter von dem Hagen
Date: February 17, 2011
Test type: Manual GUI Test
Description: Create several rectangles and verify that they display as expected
--]]

-- Test Set up --

test_question = "Does the code image animate and finish looking like the baseline?"

function generate_test_image ()

	local images = { 
		{"png", "58 MB", "large_4000x6000_flower.png", "Large png"},
		{"png", "526 KB", "medium_480x640_layers.png", "Medium png wit layers"},
		{"png", "158 KB", "small_240x320_layers.png", "Small png"},
		{"jpg", "2 MB", "large_6000x4000_HQ_panda.jpg", "Large jpg"},
		{"jpg", "57 KB KB", "medium_640x420_panda.jpg", "Medium jpg"},
		{"jpg", "40 KB", "medium_640x420_MQ_Progressive_panda.jpg", "Medium jpg/Prog"},
		{"jpg", "26 KB", "small_240x160_panda.jpg", "Small jpg"},
		{"tiff", "105 MB", "large_6000x4000_lzw_compression_beach.tif", "Large tiff"},
		{"tiff", "42 MB", "medium_3000x2000_beach_lzw_compression.tif", "Medium tiff/compress"},
		{"tiff", "35 MB", "medium_3000x2000_no_compression_beach.tif", "Medium tiff/no compress"},
		{"tiff", "538 KB", "small_320x240_no_compression_beach.tif", "Small tiff"},
		{"gif", "534 KB", "large_1920x1440_shapes.gif", "Large gif"},
		{"gif", "33 KB", "medium_640x480_compression_shapes.gif", "Medium gif/compress"},
		{"gif", "64 KB", "medium_640x480_shapes.gif", "Medium gif/no compress"},
		{"gif", "6 KB", "small_120x90_shapes.gif", "Small gif"},
	    }

	local g = Group ()

	local row_height = 310
	local row_width = 200
	local column_height = 210
	local column_width = 350

	local max_rows = 3
	local max_columns = 5
	local total_images = #images
	local image_count = total_images
	local column_count = 0
	local row_count = 0
	local image_load_count = 0





	while row_count < max_rows do

		row_count = row_count + 1
		local desc_txt = Text (
				{ 	
					position = { 10, row_height * row_count  },
					font="24px",
					color="000000",
					text= "Description:\nSize\nWidth,Height:",
					alignment = "CENTER"
				}
			)
			g:add(desc_txt)
		while (column_count < max_columns and image_count ~= 0) do
			column_count = column_count + 1
			bmp = Bitmap ("assets/"..images[image_count][3])
			local img = bmp:Image()
			img.position = {column_width * column_count - 200, row_height * row_count - 180 }
			img.size = { 160, 160 }
			g:add(img)
			image_count = image_count - 1
			img = nil
			bmp = nil
		end
	end
	
	return g
end











