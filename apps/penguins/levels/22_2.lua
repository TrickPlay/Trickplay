local g = ... 


local image13 = Image
	{
		src = "/assets/images/snow-ramp.png",
		clip = {0,0,429,130},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image13",
		position = {1491,443,0},
		size = {429,130},
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


local image0 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image0",
		position = {1173,451,0},
		size = {128,128},
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


local image3 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,300,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {729,536,0},
		size = {300,55},
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
		scale = {0.75,0.75,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {-135,0,0},
		anchor_point = {64,64},
		name = "clone4",
		position = {1232,409,0},
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


local image5 = Image
	{
		src = "/assets/images/beach-ball.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image5",
		position = {853,485,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image5.extra.focus = {}

function image5:on_key_down(key)
	if image5.focus[key] then
		if type(image5.focus[key]) == "function" then
			image5.focus[key]()
		elseif screen:find_child(image5.focus[key]) then
			if image5.clear_focus then
				image5.clear_focus(key)
			end
			screen:find_child(image5.focus[key]):grab_key_focus()
			if screen:find_child(image5.focus[key]).set_focus then
				screen:find_child(image5.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image5.extra.reactive = true


local clone6 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {618,351,0},
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
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone7",
		position = {517,400,0},
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
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone8",
		position = {375,351,0},
		size = {127,128},
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
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone9",
		position = {277,393,0},
		size = {128,128},
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


local image12 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image12",
		position = {161,80,0},
		size = {64,64},
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


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {132,-20,0},
		size = {128,128},
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


g:add(image13,image0,image3,clone4,image5,clone6,clone7,clone8,clone9,image12,clone10)