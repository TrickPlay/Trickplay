local g = ... 


local image9 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image9",
		position = {1037,144,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

image9.extra.focus = {}

function image9:on_key_down(key)
	if image9.focus[key] then
		if type(image9.focus[key]) == "function" then
			image9.focus[key]()
		elseif screen:find_child(image9.focus[key]) then
			if image9.clear_focus then
				image9.clear_focus(key)
			end
			screen:find_child(image9.focus[key]):grab_key_focus()
			if screen:find_child(image9.focus[key]).set_focus then
				screen:find_child(image9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image9.extra.reactive = true


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {1369,144,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

clone10.extra.focus = {}

function clone10:on_key_down(key)
	if clone10.focus[key] then
		if type(clone10.focus[key]) == "function" then
			clone10.focus[key]()
		elseif screen:find_child(clone10.focus[key]) then
			if clone10.clear_focus then
				clone10.clear_focus(key)
			end
			screen:find_child(clone10.focus[key]):grab_key_focus()
			if screen:find_child(clone10.focus[key]).set_focus then
				screen:find_child(clone10.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone10.extra.reactive = true


local image8 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,550,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {958,536,0},
		size = {550,55},
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


local image2 = Image
	{
		src = "/assets/images/seal-down.png",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {0,0,0},
		anchor_point = {55,0},
		name = "image2",
		position = {1247,440,0},
		size = {131,151},
		opacity = 255,
		reactive = false,
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

image2.extra.reactive = false


local image3 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {1526,123,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image3.extra.focus = {}

function image3:on_key_down(key)
	if image3.focus[key] then
		if type(image3.focus[key]) == "function" then
			image3.focus[key]()
		elseif screen:find_child(image3.focus[key]) then
			if image3.clear_focus then
				image3.clear_focus(key)
			end
			screen:find_child(image3.focus[key]):grab_key_focus()
			if screen:find_child(image3.focus[key]).set_focus then
				screen:find_child(image3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image3.extra.reactive = true


local clone4 = Clone
	{
		scale = {1,1,0,0},
		source = image3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone4",
		position = {1432,81,0},
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
		source = clone4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {1337,50,0},
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
		scale = {1,1,0,0},
		source = image3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {1000,49,0},
		size = {128,128},
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


local clone7 = Clone
	{
		scale = {1,1,0,0},
		source = clone6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone7",
		position = {907,81,0},
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


local clone8 = Clone
	{
		scale = {1,1,0,0},
		source = clone7,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone8",
		position = {812,108,0},
		size = {128,128},
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


g:add(image9,clone10,image8,image2,image3,clone4,clone5,clone6,clone7,clone8)