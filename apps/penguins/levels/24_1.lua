local g = ... 


local image24 = Image
	{
		src = "/assets/images/icicles.png",
		clip = {0,0,161,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image24",
		position = {680,-12,0},
		size = {161,131},
		opacity = 255,
		reactive = true,
	}

image24.extra.focus = {}

function image24:on_key_down(key)
	if image24.focus[key] then
		if type(image24.focus[key]) == "function" then
			image24.focus[key]()
		elseif screen:find_child(image24.focus[key]) then
			if image24.clear_focus then
				image24.clear_focus(key)
			end
			screen:find_child(image24.focus[key]):grab_key_focus()
			if screen:find_child(image24.focus[key]).set_focus then
				screen:find_child(image24.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image24.extra.reactive = true


local image33 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,500,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image33",
		position = {819,536,0},
		size = {500.00006103516,55},
		opacity = 255,
		reactive = true,
	}

image33.extra.focus = {}

function image33:on_key_down(key)
	if image33.focus[key] then
		if type(image33.focus[key]) == "function" then
			image33.focus[key]()
		elseif screen:find_child(image33.focus[key]) then
			if image33.clear_focus then
				image33.clear_focus(key)
			end
			screen:find_child(image33.focus[key]):grab_key_focus()
			if screen:find_child(image33.focus[key]).set_focus then
				screen:find_child(image33.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image33.extra.reactive = true


local clone34 = Clone
	{
		scale = {1,1,0,0},
		source = image24,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone34",
		position = {1289,-19,0},
		size = {161,131},
		opacity = 255,
		reactive = true,
	}

clone34.extra.focus = {}

function clone34:on_key_down(key)
	if clone34.focus[key] then
		if type(clone34.focus[key]) == "function" then
			clone34.focus[key]()
		elseif screen:find_child(clone34.focus[key]) then
			if clone34.clear_focus then
				clone34.clear_focus(key)
			end
			screen:find_child(clone34.focus[key]):grab_key_focus()
			if screen:find_child(clone34.focus[key]).set_focus then
				screen:find_child(clone34.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone34.extra.reactive = true


local image35 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image35",
		position = {1716,448,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image35.extra.focus = {}

function image35:on_key_down(key)
	if image35.focus[key] then
		if type(image35.focus[key]) == "function" then
			image35.focus[key]()
		elseif screen:find_child(image35.focus[key]) then
			if image35.clear_focus then
				image35.clear_focus(key)
			end
			screen:find_child(image35.focus[key]):grab_key_focus()
			if screen:find_child(image35.focus[key]).set_focus then
				screen:find_child(image35.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image35.extra.reactive = true


g:add(image24,image33,clone34,image35)