local g = ... 


local image8 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,600,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {511,536,0},
		size = {600,55},
		opacity = 255,
		reactive = true,
	}

image8.extra.focus = {}

function image8:on_key_down(key)
	if image8.focus[key] then
		if type(image8.focus[key]) == "function" then
			image8.focus[key]()
		elseif screen:find_child(image8.focus[key]) then
			if image8.clear_focus then
				image8.clear_focus(key)
			end
			screen:find_child(image8.focus[key]):grab_key_focus()
			if screen:find_child(image8.focus[key]).set_focus then
				screen:find_child(image8.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image8.extra.reactive = true


local image13 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image13",
		position = {774,226,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

image13.extra.focus = {}

function image13:on_key_down(key)
	if image13.focus[key] then
		if type(image13.focus[key]) == "function" then
			image13.focus[key]()
		elseif screen:find_child(image13.focus[key]) then
			if image13.clear_focus then
				image13.clear_focus(key)
			end
			screen:find_child(image13.focus[key]):grab_key_focus()
			if screen:find_child(image13.focus[key]).set_focus then
				screen:find_child(image13.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image13.extra.reactive = true


local image12 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image12",
		position = {744,125,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image12.extra.focus = {}

function image12:on_key_down(key)
	if image12.focus[key] then
		if type(image12.focus[key]) == "function" then
			image12.focus[key]()
		elseif screen:find_child(image12.focus[key]) then
			if image12.clear_focus then
				image12.clear_focus(key)
			end
			screen:find_child(image12.focus[key]):grab_key_focus()
			if screen:find_child(image12.focus[key]).set_focus then
				screen:find_child(image12.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image12.extra.reactive = true


local clone4 = Clone
	{
		scale = {1,1,0,0},
		source = image12,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone4",
		position = {1440,307,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone4.extra.focus = {}

function clone4:on_key_down(key)
	if clone4.focus[key] then
		if type(clone4.focus[key]) == "function" then
			clone4.focus[key]()
		elseif screen:find_child(clone4.focus[key]) then
			if clone4.clear_focus then
				clone4.clear_focus(key)
			end
			screen:find_child(clone4.focus[key]):grab_key_focus()
			if screen:find_child(clone4.focus[key]).set_focus then
				screen:find_child(clone4.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone4.extra.reactive = true


g:add(image8,image13,image12,clone4)