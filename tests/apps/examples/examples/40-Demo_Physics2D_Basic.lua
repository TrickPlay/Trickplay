-- Basic 2D Physics Application

-- Create a simple rectangle and add it to the screen
local gBox01 = Rectangle( { 
					size     = { 100, 100 },
					position = { (screen.width / 2) - 50, (screen.height / 4) - 50 },
					color    = "SaddleBrown",
} )
screen:add( gBox01 )

-- Make the rectangle a dynamic object, i.e., affected by physics; use default Body settings
gBox01 = physics:Body( gBox01, { } )

-- Create a ground so the rectangle doesn't fall off the screen
local gGround = Rectangle( {
					size     = { screen.width / 2, 2 },
					position = { screen.width / 4, screen.height - (screen.height / 4) },
					color    = "AntiqueWhite",
} )
screen:add( gGround )

-- Make the ground an immobile static object in the physics world
gGround = physics:Body( gGround, { type = "static" } )

-- Show the screen
screen:show()

-- Start the physics simulation
physics:start()

