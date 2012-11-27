	-- Create a static body on which we will attach a revolute joint
	gJointBody = Rectangle( {
						size         = { 100, 100 },
						position     = { screen.width / 2, screen.height / 2 },
						anchor_point = { 50, 50 },		-- middle of rectangle
						color        = "AntiqueWhite",
	} )
	screen:add( gJointBody )
	gJointBody = physics:Body( gJointBody,
	                           { type = "static",
	} )

	-- Make a propeller-shaped rectangle
	gPropeller = Rectangle( {
						size         = { 700, 30 },
						position     = { screen.width / 2, screen.height / 2 },
						anchor_point = { 350, 15 },		-- middle of rectangle
						color        = "SlateGray2",
	} )
	screen:add( gPropeller )
	gPropeller = physics:Body( gPropeller, { } )

	-- Join the propeller to the gJointBody
	gJointBody:RevoluteJoint( gPropeller,
	                          { gJointBody.x, gJointBody.y  },
	                          { enable_motor = true,
	                            motor_speed = 300,		-- clockwise
	                            max_motor_torque = 100,	-- steady rate
	                          } )
	-- Show the screen
	screen:show()

	-- Start the physics simulation
	physics:start()

