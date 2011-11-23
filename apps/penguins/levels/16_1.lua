local g = ... 


local image8 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,200,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {710,536,0},
		size = {200,55},
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


local image10 = Image
	{
		src = "/assets/images/beach-ball.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image10",
		position = {753,481,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image10.extra.focus = {}

function image10:on_key_down(key)
	if image10.focus[key] then
		if type(image10.focus[key]) == "function" then
			image10.focus[key]()
		elseif screen:find_child(image10.focus[key]) then
			if image10.clear_focus then
				image10.clear_focus(key)
			end
			screen:find_child(image10.focus[key]):grab_key_focus()
			if screen:find_child(image10.focus[key]).set_focus then
				screen:find_child(image10.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image10.extra.reactive = true


local clone5 = Clone
	{
		scale = {1,1,0,0},
		source = image8,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {1403,537,0},
		size = {200,55},
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


local clone2 = Clone
	{
		scale = {1,1,0,0},
		source = image10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone2",
		position = {1445,487,0},
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


local image6 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image6",
		position = {1090,454,0},
		size = {128,128},
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
		scale = {0.85,0.85,0,0},
		source = image6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone7",
		position = {1099,376,0},
		size = {128,128},
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


local clone9 = Clone
	{
		scale = {0.7,0.7,0,0},
		source = image6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone9",
		position = {1107,312,0},
		size = {127,128},
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


local image11 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image11",
		position = {1117,268,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

image11.extra.focus = {}

function image11:on_key_down(key)
	if image11.focus[key] then
		if type(image11.focus[key]) == "function" then
			image11.focus[key]()
		elseif screen:find_child(image11.focus[key]) then
			if image11.clear_focus then
				image11.clear_focus(key)
			end
			screen:find_child(image11.focus[key]):grab_key_focus()
			if screen:find_child(image11.focus[key]).set_focus then
				screen:find_child(image11.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image11.extra.reactive = true


local clone12 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone12",
		position = {1861,485,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone12.extra.focus = {}

function clone12:on_key_down(key)
	if clone12.focus[key] then
		if type(clone12.focus[key]) == "function" then
			clone12.focus[key]()
		elseif screen:find_child(clone12.focus[key]) then
			if clone12.clear_focus then
				clone12.clear_focus(key)
			end
			screen:find_child(clone12.focus[key]):grab_key_focus()
			if screen:find_child(clone12.focus[key]).set_focus then
				screen:find_child(clone12.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone12.extra.reactive = true


local clone13 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone13",
		position = {1782,492,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone13.extra.focus = {}

function clone13:on_key_down(key)
	if clone13.focus[key] then
		if type(clone13.focus[key]) == "function" then
			clone13.focus[key]()
		elseif screen:find_child(clone13.focus[key]) then
			if clone13.clear_focus then
				clone13.clear_focus(key)
			end
			screen:find_child(clone13.focus[key]):grab_key_focus()
			if screen:find_child(clone13.focus[key]).set_focus then
				screen:find_child(clone13.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone13.extra.reactive = true


local clone14 = Clone
	{
		scale = {1,1,0,0},
		source = image6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone14",
		position = {1801,392,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone14.extra.focus = {}

function clone14:on_key_down(key)
	if clone14.focus[key] then
		if type(clone14.focus[key]) == "function" then
			clone14.focus[key]()
		elseif screen:find_child(clone14.focus[key]) then
			if clone14.clear_focus then
				clone14.clear_focus(key)
			end
			screen:find_child(clone14.focus[key]):grab_key_focus()
			if screen:find_child(clone14.focus[key]).set_focus then
				screen:find_child(clone14.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone14.extra.reactive = true


local image12 = Image
	{
		src = "/assets/images/icicles.png",
		clip = {0,0,161,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image12",
		position = {728,-4,0},
		size = {161,131},
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


local clone15 = Clone
	{
		scale = {1,1,0,0},
		source = image12,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone15",
		position = {1414,-7,0},
		size = {161,131},
		opacity = 255,
		reactive = true,
	}

clone15.extra.focus = {}

function clone15:on_key_down(key)
	if clone15.focus[key] then
		if type(clone15.focus[key]) == "function" then
			clone15.focus[key]()
		elseif screen:find_child(clone15.focus[key]) then
			if clone15.clear_focus then
				clone15.clear_focus(key)
			end
			screen:find_child(clone15.focus[key]):grab_key_focus()
			if screen:find_child(clone15.focus[key]).set_focus then
				screen:find_child(clone15.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone15.extra.reactive = true


g:add(image8,image10,clone5,clone2,image6,clone7,clone9,image11,clone12,clone13,clone14,image12,clone15)