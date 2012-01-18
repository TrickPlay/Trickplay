------------------------------------------------------------
-- USE CONFIGURATION.LUA
------------------------------------------------------------
dofile("background/configuration.lua")
update_config()
dofile("background/shape.lua")


math.randomseed(os.time())

local background = Image{
				src = "background/background.jpg",
				opacity = 255,
				y = 0,
				x = 0,
				z = -2,
				}
screen:add(background)

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

local function make_shapes()
--make_squares()
make_circles()
--make_triangles()
end

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


function make_squares()
	print("Generating Squares...")
	square_generator()	
	screen:add(shape)
	shape.opacity = 0
	print("Done!")
end

function make_triangles()
	print("Generating Squares...")
	triangle_generator()	
	screen:add(shape)
	shape.opacity = 0
	print("Done!")
end

function make_circles()
	print("Generating Circles...")
	circle_generator()	
	screen:add(shape)
	shape.opacity = 0
	print("Done!")
end

local function make_grow_clones()
	update_config()
	growclone = Clone
			   {                    
					 source = shape,   
					 name = "imaclone",
					 z = -5,
				}
	screen:add(growclone)
	
	
	growclone.opacity = shape_start_opacity
	growclone.position = { math.random(200,1720),  math.random(150, 930) }
	growclone.scale = {start_scale,start_scale}
	growclone.anchor_point={shape.w/2, shape.h/2}
	
	growclone:animate({ 
	
		duration = animation_duration, 
		scale = {random_scale,random_scale}, 
		opacity = shape_end_opacity, 
		mode = animation_mode, 
		on_completed = function(_,a) a:unparent()  end,
	})

end


local function make_roll_clones()
	update_config()

	rollclone = Clone
			   {
					 source = shape,
					 name = "imaclone2",
					 z = -5,
				}
	
	screen:add(rollclone)
	
	rollclone.opacity = shape_start_opacity
	rollclone.position = {shape_start_x,shape_start_y}
	rollclone.scale = {start_scale,start_scale}
	rollclone.anchor_point = {shape.w/2, shape.h/2}
	
    	
	rollclone:animate({ 
	duration = animation_duration, 
	scale = {end_scale, end_scale}, 
	opacity = shape_end_opacity, 
	mode = animation_mode, 
	position = { shape_end_x,shape_end_y },  
	on_completed = function(_,a) a:unparent()  end,
	z_rotation = shape_z_rotation,
	})

end

local function make_small_roll_clones()
	update_config()
	square_width = 10
    square_height = 10
	rollclone = Clone
			   {
					 source = shape,
					 name = "imaclone2",
				}
	
	screen:add(rollclone)
	
	rollclone.opacity = shape_start_opacity
	rollclone.position = {shape_start_x,shape_start_y}
	rollclone.scale = {start_scale,start_scale}
	rollclone.anchor_point = {shape.w/2, shape.h/2}
    	
	rollclone:animate({ 
	duration = animation_duration, 
	scale = {end_scale, end_scale}, 
	opacity = shape_end_opacity, 
	mode = animation_mode, 
	position = { shape_end_x,shape_end_y },  
	on_completed = function(_,a) print("unparent:",a,a.name) a:unparent()  end,
	z_rotation = shape_z_rotation,
	})

end

  
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


function random_shapes()
    update_config()
    -- Start Position of shapes
    for i = 1,number_of_shapes do
--		make_roll_clones()
		make_grow_clones()
	end
end

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


timer=Timer()
timer.interval = timer_interval

function timer.on_timer(timer)
    random_shapes()
end

make_shapes()
random_shapes()
timer:start()
screen:show()