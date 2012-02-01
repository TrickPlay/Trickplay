local g = ... 


local image8 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,63,63},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {968,43,0},
		size = {63,63},
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


local image0 = Image
	{
		src = "/assets/images/fish-blue.png",
		clip = {0,0,150,110},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image0",
		position = {619,192,0},
		size = {150,110},
		opacity = 255,
		reactive = true,
	}

image0.extra.focus = {}

function image0:on_key_down(key)
	if image0.focus[key] then
		if type(image0.focus[key]) == "function" then
			image0.focus[key]()
		elseif screen:find_child(image0.focus[key]) then
			if image0.clear_focus then
				image0.clear_focus(key)
			end
			screen:find_child(image0.focus[key]):grab_key_focus()
			if screen:find_child(image0.focus[key]).set_focus then
				screen:find_child(image0.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image0.extra.reactive = true


local image1 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image1",
		position = {928,453,0},
		size = {127.99993896484,128},
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


local clone2 = Clone
	{
		scale = {1,1,0,0},
		source = image1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone2",
		position = {932,360,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone2.extra.focus = {}

function clone2:on_key_down(key)
	if clone2.focus[key] then
		if type(clone2.focus[key]) == "function" then
			clone2.focus[key]()
		elseif screen:find_child(clone2.focus[key]) then
			if clone2.clear_focus then
				clone2.clear_focus(key)
			end
			screen:find_child(clone2.focus[key]):grab_key_focus()
			if screen:find_child(clone2.focus[key]).set_focus then
				screen:find_child(clone2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone2.extra.reactive = true


local clone3 = Clone
	{
		scale = {1,1,0,0},
		source = clone2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone3",
		position = {940,-54,0},
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
		scale = {1,1,0,0},
		source = clone3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone4",
		position = {96,452,0},
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


local image6 = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,0,475,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image6",
		position = {-63,253,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

image6.extra.focus = {}

function image6:on_key_down(key)
	if image6.focus[key] then
		if type(image6.focus[key]) == "function" then
			image6.focus[key]()
		elseif screen:find_child(image6.focus[key]) then
			if image6.clear_focus then
				image6.clear_focus(key)
			end
			screen:find_child(image6.focus[key]):grab_key_focus()
			if screen:find_child(image6.focus[key]).set_focus then
				screen:find_child(image6.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image6.extra.reactive = true


local clone7 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone7",
		position = {1223,193,0},
		size = {150,110},
		opacity = 255,
		reactive = true,
	}

clone7.extra.focus = {}

function clone7:on_key_down(key)
	if clone7.focus[key] then
		if type(clone7.focus[key]) == "function" then
			clone7.focus[key]()
		elseif screen:find_child(clone7.focus[key]) then
			if clone7.clear_focus then
				clone7.clear_focus(key)
			end
			screen:find_child(clone7.focus[key]):grab_key_focus()
			if screen:find_child(clone7.focus[key]).set_focus then
				screen:find_child(clone7.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone7.extra.reactive = true


g:add(image8,image0,image1,clone2,clone3,clone4,image6,clone7)