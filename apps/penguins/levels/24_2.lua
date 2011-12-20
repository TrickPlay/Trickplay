local g = ... 


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
		position = {428,457,0},
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


local clone6 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {1126,132,0},
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


local clone22 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone22",
		position = {422,362,0},
		size = {128,127},
		opacity = 255,
		reactive = true,
	}

clone22.extra.focus = {}

function clone22:on_key_down(key)
	if clone22.focus[key] then
		if type(clone22.focus[key]) == "function" then
			clone22.focus[key]()
		elseif screen:find_child(clone22.focus[key]) then
			if clone22.clear_focus then
				clone22.clear_focus(key)
			end
			screen:find_child(clone22.focus[key]):grab_key_focus()
			if screen:find_child(clone22.focus[key]).set_focus then
				screen:find_child(clone22.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone22.extra.reactive = true


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
		position = {770,-16,0},
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


local clone27 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone27",
		position = {437,293,0},
		size = {127.99996948242,128},
		opacity = 255,
		reactive = true,
	}

clone27.extra.focus = {}

function clone27:on_key_down(key)
	if clone27.focus[key] then
		if type(clone27.focus[key]) == "function" then
			clone27.focus[key]()
		elseif screen:find_child(clone27.focus[key]) then
			if clone27.clear_focus then
				clone27.clear_focus(key)
			end
			screen:find_child(clone27.focus[key]):grab_key_focus()
			if screen:find_child(clone27.focus[key]).set_focus then
				screen:find_child(clone27.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone27.extra.reactive = true


local image33 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,400,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image33",
		position = {877,536,0},
		size = {400,55},
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


g:add(image0,clone6,clone22,image24,clone27,image33)
