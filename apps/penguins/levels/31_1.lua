local g = ... 


local image1 = Image
	{
		src = "/assets/images/armor-2.png",
		clip = {0,0,66,98},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image1",
		position = {757,477,0},
		size = {66,98},
		opacity = 255,
		reactive = true,
	}

image1.extra.focus = {}

function image1:on_key_down(key)
	if image1.focus[key] then
		if type(image1.focus[key]) == "function" then
			image1.focus[key]()
		elseif screen:find_child(image1.focus[key]) then
			if image1.clear_focus then
				image1.clear_focus(key)
			end
			screen:find_child(image1.focus[key]):grab_key_focus()
			if screen:find_child(image1.focus[key]).set_focus then
				screen:find_child(image1.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image1.extra.reactive = true


local image2 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image2",
		position = {1366,453,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image2.extra.focus = {}

function image2:on_key_down(key)
	if image2.focus[key] then
		if type(image2.focus[key]) == "function" then
			image2.focus[key]()
		elseif screen:find_child(image2.focus[key]) then
			if image2.clear_focus then
				image2.clear_focus(key)
			end
			screen:find_child(image2.focus[key]):grab_key_focus()
			if screen:find_child(image2.focus[key]).set_focus then
				screen:find_child(image2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image2.extra.reactive = true


local clone3 = Clone
	{
		scale = {0.8,0.8,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone3",
		position = {1390,378,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone3.extra.focus = {}

function clone3:on_key_down(key)
	if clone3.focus[key] then
		if type(clone3.focus[key]) == "function" then
			clone3.focus[key]()
		elseif screen:find_child(clone3.focus[key]) then
			if clone3.clear_focus then
				clone3.clear_focus(key)
			end
			screen:find_child(clone3.focus[key]):grab_key_focus()
			if screen:find_child(clone3.focus[key]).set_focus then
				screen:find_child(clone3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone3.extra.reactive = true


local clone4 = Clone
	{
		scale = {0.8,0.8,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone4",
		position = {1374,300,0},
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


local clone5 = Clone
	{
		scale = {1,1,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {1363,205,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone5.extra.focus = {}

function clone5:on_key_down(key)
	if clone5.focus[key] then
		if type(clone5.focus[key]) == "function" then
			clone5.focus[key]()
		elseif screen:find_child(clone5.focus[key]) then
			if clone5.clear_focus then
				clone5.clear_focus(key)
			end
			screen:find_child(clone5.focus[key]):grab_key_focus()
			if screen:find_child(clone5.focus[key]).set_focus then
				screen:find_child(clone5.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone5.extra.reactive = true


local clone6 = Clone
	{
		scale = {0.8,0.8,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {1376,131,0},
		size = {128,127},
		opacity = 255,
		reactive = true,
	}

clone6.extra.focus = {}

function clone6:on_key_down(key)
	if clone6.focus[key] then
		if type(clone6.focus[key]) == "function" then
			clone6.focus[key]()
		elseif screen:find_child(clone6.focus[key]) then
			if clone6.clear_focus then
				clone6.clear_focus(key)
			end
			screen:find_child(clone6.focus[key]):grab_key_focus()
			if screen:find_child(clone6.focus[key]).set_focus then
				screen:find_child(clone6.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone6.extra.reactive = true


g:add(image1,image2,clone3,clone4,clone5,clone6)