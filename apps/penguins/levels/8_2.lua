local g = ... 


local image8 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,1500,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {20,536,0},
		size = {1500,55},
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
		position = {567,499,0},
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


local clone2 = Clone
	{
		scale = {1,1,0,0},
		source = image10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone2",
		position = {886,485,0},
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
		position = {1217,495,0},
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
		position = {348,483,0},
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


g:add(image8,image10,clone2,clone3,clone4)