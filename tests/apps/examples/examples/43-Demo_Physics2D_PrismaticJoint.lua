-- *********************************************************
-- Global variables

	gBox01		= nil
	gBox02		= nil

-- *********************************************************
function
pushBoxDown()

	-- Apply a linear impulse to pull the box down
	gBox01:apply_linear_impulse( { 0, 5 }, { gBox01.x, gBox01.y } )

end

-- *********************************************************
-- gBox02 stuff

	-- Create a large rectangle
	gBox02 = Rectangle( { size     = { 100, 100 },
						  position = { (screen.width / 2) - 25, (screen.height / 4) + 100, 0 },
						  color    = { 224, 255, 255, 127 },
	} )
	gBox02.anchor_point = { 50, 50 }
	screen:add( gBox02 )

	-- Add the rectangle to the physics world and make it static, i.e., non-moving
	gBox02 = physics:Body( gBox02, { type = "static" } )

-- gBox01 stuff

	-- Create a smaller rectangle to the right of gBox02
	gBox01 = Rectangle( { size     = { 50, 50 },
						  position = { gBox02.x + 100, gBox02.y + 50 },
						  color    = "SaddleBrown",
	} )
	gBox01.anchor_point = { 25, 25 }	-- center of object
	screen:add( gBox01 )

	-- Add the box to the physics world, making it dynamic/movable (which is the default)
	gBox01 = physics:Body( gBox01, { } )

-- Joint stuff

	-- Create a PrismaticJoint between gBox01 and gBox02
	-- The smaller box can move straight up and down along the joint's axis
	-- Movement is limited along the axis by the upper and lower translation settings
	-- A motor pushes the box up to its upper limit
	-- Pressing any key will pull the box down
	gBox02:PrismaticJoint( gBox01,
			               { 0, -1 },						-- axis going straight up
			               { enable_limit      = true,
			                 upper_translation = 200,		-- 200 vector units up
			                 lower_translation = -400,		-- 400 vector units down
			                 enable_motor      = true,
		                     motor_speed       = 5.0,
		                     max_motor_force   = 10.0,
			               }
	)

	-- Show the screen
	screen:show()

	-- Start the physics simulation
	physics:start( )

	-- Any keypress will push the box down
	screen:add_onkeydown_listener( pushBoxDown )

