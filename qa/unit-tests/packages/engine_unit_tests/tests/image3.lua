--[[
Filename: Image3.lua
Author: Peter von dem Hagen
Date: October 13, 2011
Description: Load and image with tags and verify they can be returned.
--]]

-- Test Set up --
local tag_img_tags = {}
tag_image_loaded = false

local tag_img = Image{
		read_tags = true, 
		src="packages/engine_unit_tests/tests/assets/connor_kai_fb_1.JPG",
		async = true,
		position = {20, 750}, 
		size = {150, 300}
}
test_group:add(tag_img)

-- Test callback for a failed load
function tag_img_on_loaded(image,failed)
	tag_img_loaded = true
	tag_img_tags = tag_img.tags
end

tag_img.on_loaded = tag_img_on_loaded


-- Tests --
function test_Image_exif_orientation_tag()
	assert_equal( tag_img_tags["IMAGE/Orientation"] , 6, "tag_img_tags[IMAGE/Orientation] returned: "..tag_img_tags["IMAGE/Orientation"].." Expected: 6 ")
end




-- Test Tear down --














