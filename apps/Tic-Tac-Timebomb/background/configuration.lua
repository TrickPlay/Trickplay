-- make sure you update_config() if you have random numbers in animation

function update_config()

-----------------------------------------------
-- CIRCLE
-----------------------------------------------

-- Sets radius of circle
radius = 20

-----------------------------------------------
-- Grow Animation
-----------------------------------------------

-- Array for randomly scaling up objects


SCALE_RANDOM = {	[1] = 5,
					[2] = 15,
					[3] = 25,
					[4] = 35,
					[5] = 45,
					[6] = 55,
					[7] = 65,
					[8] = 75,
					[9] = 85,
					[10] = 95,
					[11] = 105,
					[12] = 115,
					[13] = 125,
					}

-- Chooses random scale from array SET THE RANGE OF SIZE DIFFERENCE HERE

random_scale = SCALE_RANDOM[math.random(1,6)]



-----------------------------------------------
-- Square/Rectangle
-----------------------------------------------

-- Sets Rectangle width and height
square_width = 15
square_height = 15


-----------------------------------------------
-- Universal
-----------------------------------------------




-----------------
-- Rotation
-----------------

-- Sets the z rotation in animation

shape_z_rotation = 1440


-----------------
--- Scale
-----------------

-- Sets the Starting scale
start_scale = 0

-- End scale ( use random_scale for random scaling)
end_scale = random_scale


-------------------
-- Position
-------------------

-- Start Position of shapes
shape_start_x = math.random(-100,-50)
shape_start_y = math.random(0,1080)

-- End Position of shapes
shape_end_x = math.random(2000,2050) 
shape_end_y = shape_start_y



-------------------
-- Opacity
-------------------

-- Sets initial opacity of shapes
shape_start_opacity = math.random(10,20)

-- Sets the final opacity 
shape_end_opacity = 0

-----------------
-- Shape Quantity
-----------------

-- Sets interval between creation of shapes

timer_interval = 9

-- Dicates number of shapes per cycle. cycle length is timer_interval

number_of_shapes = math.random(4,6)

------------------
-- color/fill/stroke
------------------

-- start Color of Fill/Stroke

shape_color = "ffffff"

-- Use true for fill, false for no fill

fill_bool = true

-- Use true for stroke, false for no stroke

stroke_bool = false


----------------------
-- Animate mode/duration
----------------------

-- Animation Mode
animation_mode = "EASE_OUT_SINE"

--- Animation Duration
animation_duration = 35000

------------------------------------------------------------


end