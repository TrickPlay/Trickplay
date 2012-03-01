local g = ... 


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
		position = {1095,360,0},
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
		position = {1323,273,0},
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
		position = {1686,460,0},
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
		position = {1698,386,0},
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
		position = {1697,307,0},
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


local image7 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,700,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image7",
		position = {596,536,0},
		size = {700,55},
		opacity = 255,
		reactive = true,
	}

image7.extra.focus = {}

function image7:on_key_down(key)
	if image7.focus[key] then
		if type(image7.focus[key]) == "function" then
			image7.focus[key]()
		elseif screen:find_child(image7.focus[key]) then
			if image7.clear_focus then
				image7.clear_focus(key)
			end
			screen:find_child(image7.focus[key]):grab_key_focus()
			if screen:find_child(image7.focus[key]).set_focus then
				screen:find_child(image7.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image7.extra.reactive = true


local image8 = Image
	{
		src = "/assets/images/beach-ball.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {807,485,0},
		size = {128,128},
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


local clone7 = Clone
	{
		scale = {0.8,0.8,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone7",
		position = {1696,230,0},
		size = {128,127},
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


local clone8 = Clone
	{
		scale = {0.8,0.8,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone8",
		position = {1696,153,0},
		size = {128,127},
		opacity = 255,
		reactive = true,
	}

clone8.extra.focus = {}

function clone8:on_key_down(key)
	if clone8.focus[key] then
		if type(clone8.focus[key]) == "function" then
			clone8.focus[key]()
		elseif screen:find_child(clone8.focus[key]) then
			if clone8.clear_focus then
				clone8.clear_focus(key)
			end
			screen:find_child(clone8.focus[key]):grab_key_focus()
			if screen:find_child(clone8.focus[key]).set_focus then
				screen:find_child(clone8.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone8.extra.reactive = true


local clone9 = Clone
	{
		scale = {0.8,0.8,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone9",
		position = {1696,76,0},
		size = {128,127},
		opacity = 255,
		reactive = true,
	}

clone9.extra.focus = {}

function clone9:on_key_down(key)
	if clone9.focus[key] then
		if type(clone9.focus[key]) == "function" then
			clone9.focus[key]()
		elseif screen:find_child(clone9.focus[key]) then
			if clone9.clear_focus then
				clone9.clear_focus(key)
			end
			screen:find_child(clone9.focus[key]):grab_key_focus()
			if screen:find_child(clone9.focus[key]).set_focus then
				screen:find_child(clone9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone9.extra.reactive = true


g:add(image6,image1,image2,clone3,clone4,image7,image8,clone7,clone8,clone9)