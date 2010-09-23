------------------------------------------------------------
-- USE CONFIGURATION.LUA
------------------------------------------------------------


dofile("background/configuration.lua")
update_config()
dofile("background/shape.lua")

math.randomseed(os.time())

local background = Image{
				src = "background/background.png",
				opacity = 255,
				y = 0,
				x = 0,
				z = -3,
				}
screen:add(background)

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

local function make_shapes()
--make_squares()
make_circles()
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
					 z = -2,
				}
	screen:add(growclone)
	
	
	growclone.opacity = shape_start_opacity
	growclone.position = { math.random(200,1720),  math.random(150, 930) }
	growclone.scale = {start_scale,start_scale}
	growclone.anchor_point={radius*2,radius*2}
	print("Animating:",growclone,"from",shape)
	
	growclone:animate({ 
	
		duration = animation_duration, 
		scale = {random_scale,random_scale}, 
		opacity = shape_end_opacity, 
		mode = animation_mode, 
		on_completed = function(_,a) print("unparent:",a,a.name) a:unparent()  end,
	})

end


local function make_roll_clones()

	update_config()
	rollclone = Clone
			   {
					 source = shape,
					 name = "imaclone2",
					 z = -2,
				}
	
	screen:add(rollclone)
	
	rollclone.opacity = shape_start_opacity
	rollclone.position = {shape_start_x,shape_start_y}
	rollclone.scale = {start_scale,start_scale}
	rollclone.anchor_point = {square_width/2,square_height/2}
	print("Animating: rollclone, from: ",shape)
    	
	rollclone:animate({ 
	duration = 4000, 
	scale = {start_scale, start_scale}, 
	opacity = shape_end_opacity, 
	mode = animation_mode, 
	position = { shape_end_x,shape_end_y },  
	on_completed = function(_,a) print("unparent:",a,a.name) a:unparent()  end,
	z_rotation = shape_z_rotation,
	})

end

local function make_roll_clones_big()

	update_config()
	rollclone = Clone
			   {
					 source = shape,
					 name = "imaclone2",
					 z = -2,
				}
	
	screen:add(rollclone)
	
	rollclone.opacity = shape_start_opacity
	rollclone.position = {shape_start_x,shape_start_y}
	rollclone.scale = {5,5}
	rollclone.anchor_point = {square_width/2,square_height/2}
	print("Animating: rollclone, from: ",shape)
    	
	rollclone:animate({ 
	duration = 20000, 
    scale = {5, 5}, 
	opacity = shape_start_opacity, 
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
	for i = 1,number_of_shapes do
		print("Cloning..")
--		make_roll_clones()
--		make_roll_clones_big()
		make_grow_clones()
		print("Cloned!")
	end
end

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


timer=Timer()
timer.interval = timer_interval

function timer.on_timer(timer)
    random_shapes()
    print("Timer Fired")
end

make_shapes()
random_shapes()
timer:start()
screen:show()