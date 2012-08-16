	-- Create a static body on which we will attach a distance joint
	gJointBody = Rectangle( {
						size         = { 100, 100 },
						position     = { screen.width / 2, screen.height / 5 },
						color        = "AntiqueWhite",
	} )
	gJointBody.anchor_point = { 50, 50 }
	screen:add( gJointBody )
	gJointBody = physics:Body( gJointBody,
	                           { type = "static",
	} )

	-- Make a rod-shaped rectangle
	gRod = Rectangle( {	size         = { 30, 400 },
						position     = { (screen.width / 2) + 100, (screen.height / 5) + 300 },
						color        = "SlateGray2",
	} )
	gRod.anchor_point = { 15, 200 }
	screen:add( gRod )
	gRod = physics:Body( gRod, { density = 100 } )

	-- Join the rod to the gJointBody
	gJointBody:DistanceJoint( { gJointBody.x, gJointBody.y },	-- middle of gJointBody
	                          gRod,
	                          { gRod.x, gRod.y - 200 },			-- top and center of gRod
	                          { }
	)

	-- Show everything on-screen
	screen:show()

	-- Start the physics simulation
	physics:start()

