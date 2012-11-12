--
-- TrickPlay Physics 2D Application
-- Demo PrismaticJoint connecting Two Dynamic Objects
--
-- *********************************************************
-- Global variables

	gBox01		= nil
	gBox02		= nil
	gGround		= nil
	gSideLeft	= nil
	gSideRight	= nil
	gTop		= nil

-- *****************************************************************************
-- gBox01 stuff

	-- Create a simple rectangle
	gBox01 = Rectangle( { size  = { 100, 100 },
						  color = "SaddleBrown",
	} )
	gBox01.anchor_point = { gBox01.width / 2, gBox01.height / 2 }	-- center of object
	gBox01.position     = { screen.width / 3, screen.height / 2 }	-- located on left side of screen
	screen:add( gBox01 )

	-- Add the box to the physics simulation
	gBox01 = physics:Body( gBox01, { } )

-- *****************************************************************************
-- gBox02 stuff

	-- Create another rectangle on the right side of the screen
	gBox02 = Rectangle( { size  = { 100, 100 },
						  color = "SaddleBrown",
	} )
	gBox02.anchor_point = { gBox02.width / 2, gBox02.height / 2 }
	gBox02.position     = { screen.width - (screen.width / 3), screen.height / 2 }
	screen:add( gBox02 )
	gBox02 = physics:Body( gBox02, { } )

-- *****************************************************************************
-- Joint stuff

	-- Create a PrismaticJoint between gBox01 and gBox02
	gBox01:PrismaticJoint( gBox02,						-- the remaining arguments affect this object
	                       { -1, 0 },					-- horizontal axis pointing to the left
	                       { enable_limit      = false,
	                         upper_translation = 200,
	                         lower_translation = -400,
	                         enable_motor      = true,
                             motor_speed       = 5.0,
                             max_motor_force   = 10.0,
	                       }
	)

-- *****************************************************************************
-- Static-frame stuff

	-- Create a framed sandbox around the jointed objects
	gGround = Rectangle( { size  = { (gBox02.x + (gBox02.width / 2)) - (gBox01.x - (gBox01.width / 2)), 2 },
						   color = "AntiqueWhite",
	} )
	gGround.anchor_point = { gGround.width / 2, gGround.height / 2 }
	gGround.position     = { screen.width / 2, gBox01.y + (gBox01.height / 2) + (gGround.height / 2) }
	screen:add( gGround )
	gSideLeft = Rectangle( { size  = { 2, gBox01.height },
							 color = "AntiqueWhite",
	} )
	gSideLeft.anchor_point = { gSideLeft.width / 2, gSideLeft.height / 2 }
	gSideLeft.position     = { gBox01.x - (gBox01.width / 2) + (gSideLeft.width / 2), gBox01.y }
	screen:add( gSideLeft )
	gSideRight = Rectangle( { size  = { gSideLeft.width, gSideLeft.height },
							  color = "AntiqueWhite",
	} )
	gSideRight.anchor_point = { gSideRight.width / 2, gSideRight.height / 2 }
	gSideRight.position     = { gBox02.x + (gBox02.width / 2) + (gSideRight.width / 2), gBox02.y }
	screen:add( gSideRight )
	gTop = Rectangle( { size  = { gGround.width, gGround.height },
						color = "AntiqueWhite",
	} )
	gTop.anchor_point = { gTop.width / 2, gTop.height / 2 }
	gTop.position     = { gGround.x, gBox01.y - (gBox01.height / 2) - (gTop.height) }
	screen:add( gTop )

	-- Make the sandbox a static, frictionless object in the physics world
	gGround    = physics:Body( gGround,    { type = "static", friction = 0.0 } )
	gSideLeft  = physics:Body( gSideLeft,  { type = "static", friction = 0.0 } )
	gSideRight = physics:Body( gSideRight, { type = "static", friction = 0.0 } )
	gTop       = physics:Body( gTop,       { type = "static", friction = 0.0 } )

-- *****************************************************************************
-- Setup stuff

	-- Show the screen
	screen:show()

	-- Start the physics simulation
	physics:start( )
