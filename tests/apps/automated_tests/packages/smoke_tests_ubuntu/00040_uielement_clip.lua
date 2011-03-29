
test_description = "Clip the globe so that only a square section of it displays"
test_group = "smoke"
test_area = "UI_element"
test_api = "clip"


function generate_test_image ()
	local g = Group ()
	local img = Image ()
	
	img.src = "packages/"..test_folder.."/assets/globe.png"
	img.anchor_point = { img.w/2, img.h/2 }
	img.position = { screen.w/2, screen.h/2 }
	g:add (img)
	img.clip = { img.w/6, img.h/6, img.w - img.w/2, img.h - img.h/2 }
	
	local result
	if img.has_clip == true then
		result = "true"
	else
		result = "false"
	end
	
	local has_clip_txt = Text()
	has_clip_txt.font="sans 30px"
	has_clip_txt.position={screen.w/2 - 150, screen.h/2 + 60}
	has_clip_txt.text = "has_clip ="..result
	has_clip_txt.color = "000000"
	g:add(has_clip_txt)
	
	return g
end















