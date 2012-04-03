--
-- TrickPlay AnimationState Example Program
--

-- *********************************************************
-- Constants

-- Names of external files
MAIN_SCREEN_IMAGE		= "images/Background.png"
SHADOW_LEFT_IMAGE		= "images/shadow-left-tile.png"
SHADOW_MIDDLE_IMAGE		= "images/shadow-center-tile.png"
EL_GRECO_IMAGE			= "images/ElGreco.png"
REMBRANDT_IMAGE			= "images/Rembrandt.png"
VELAZQUEZ_IMAGE			= "images/Velazquez.png"

BOX_WIDTH				= 500
BOX_HEIGHT				= BOX_WIDTH

LEFTBOX_INIT_X			= 200
LEFTBOX_INIT_Y			= 250

MIDDLEBOX_INIT_X		= ((screen.width / 2) - (BOX_WIDTH / 2))
MIDDLEBOX_INIT_Y		= LEFTBOX_INIT_Y

RIGHTBOX_INIT_X			= 1220
RIGHTBOX_INIT_Y			= LEFTBOX_INIT_Y

-- *********************************************************
-- Global Variables

	gLeftBox			= nil
	gLeftShadow			= nil
	
	gMiddleBox			= nil
	gMiddleShadow		= nil
	
	gRightBox			= nil
	gRightShadow		= nil

	gBoxStates			= nil		-- AnimationState object
	
-- *********************************************************
-- Table of handlers for keystroke input

-- Menu keystroke handler
keyInputHandler = {
	LEFT  = function() openBoxLeft()  end,
	RIGHT = function() openBoxRight() end,
}

-- *********************************************************
function
openBoxLeft()

	-- If we're at the Middle box, move to the Left
	if( gBoxStates.state == "Middle" )then
		gBoxStates.state = "Left"

	-- If we're at the Right box, move to the Middle
	elseif( gBoxStates.state == "Right" )then
		gBoxStates.state = "Middle"
	end
	-- Note: If we're at the Left, ignore the keystroke
	
end

-- *********************************************************
function
openBoxRight()

	-- If we're at the Middle box, move to the Right
	if( gBoxStates.state == "Middle" )then
		gBoxStates.state = "Right"
	
	-- If we're at the Left box, move to the Middle
	elseif( gBoxStates.state == "Left" )then
		gBoxStates.state = "Middle"
	end
	-- Note: If we're at the Right, ignore the keystroke
	
end

-- *********************************************************
function
displayMainScreen()

	local	mainScreen = nil
	
	-- Load the main screen image
	mainScreen = Image( { src = MAIN_SCREEN_IMAGE } )
	if( mainScreen.loaded == false )then
		print( "Could not load the screen's main image: ", MAIN_SCREEN_IMAGE )
		exit()
		return
	end
	screen:add( mainScreen )

end

-- *********************************************************
function
initBoxes()

	-- Create the panels by loading images
	gLeftBox = Image( { name     = "Velazquez",
	                    src      = VELAZQUEZ_IMAGE,
	                    position = { LEFTBOX_INIT_X, LEFTBOX_INIT_Y },
	} )
	if( gLeftBox == nil )then
		print( "Could not load Velazquez image:", VELAZQUEZ_IMAGE )
		exit()
		return
	end
	
	-- Move anchor point to the box's vertical center (along the X-axis)
	gLeftBox:move_anchor_point( (BOX_WIDTH / 2), 0 )
	
	-- "Close" this box by rotating it and setting its opacity
	gLeftBox.y_rotation = { 90, 0, 0 }
	gLeftBox.opacity    = 0
	
	-- Display the box onscreen
	screen:add( gLeftBox )
	
	-- Do the same things for the gMiddleBox and gRightBox
	gMiddleBox = Image( { name     = "Rembrandt",
	                      src      = REMBRANDT_IMAGE,
	                      position = { MIDDLEBOX_INIT_X, MIDDLEBOX_INIT_Y },
	} )
	if( gMiddleBox == nil )then
		print( "Could not load Rembrandt image:", REMBRANDT_IMAGE )
		exit()
		return
	end
	gMiddleBox:move_anchor_point( (BOX_WIDTH / 2), 0 )
	-- Leave this box "open," so don't rotate it or change its opacity
	screen:add( gMiddleBox )
	
	gRightBox = Image( { name     = "ElGreco",
	                     src      = EL_GRECO_IMAGE,
	                     position = { RIGHTBOX_INIT_X, RIGHTBOX_INIT_Y },
	} )
	if( gRightBox == nil )then
		print( "Could not load El Greco image:", EL_GRECO_IMAGE )
		exit()
		return
	end
	gRightBox:move_anchor_point( (BOX_WIDTH / 2), 0 )
	gRightBox.y_rotation = { -90, 0, 0 }
	gRightBox.opacity    = 0
	screen:add( gRightBox )  

	-- Load the left shadow image
	gLeftShadow = Image( { name = "LeftShadow",
	                       src  = SHADOW_LEFT_IMAGE,
	} )
	if( gLeftShadow == nil )then
		print( "Could not load shadow image:", SHADOW_LEFT_IMAGE )
		exit()
		return
	end
	gLeftShadow.position = { 0, 775 }
	gLeftShadow:move_anchor_point( gLeftShadow.width / 2, gLeftShadow.height / 2 )
	gLeftShadow.opacity = 0			-- don't show this shadow on start-up
	gLeftShadow.scale   = { 0, 1 } 	-- scale down so when we do show it, we'll scale it back up
	screen:add( gLeftShadow )
	
	-- Load the middle and right shadow image
	gMiddleShadow = Image( { name = "MiddleShadow",
	                         src  = SHADOW_MIDDLE_IMAGE,
	} )
	if( gMiddleShadow == nil )then
		print( "Could not load shadow image:", SHADOW_MIDDLE_IMAGE )
		exit()
		return
	end
	gMiddleShadow.position = { ((screen.width / 2) - (gLeftShadow.base_size[ 1 ] / 2) + 50), 775 }
	gMiddleShadow.opacity  = 255   -- show this shadow on start-up
	gMiddleShadow:move_anchor_point( gMiddleShadow.width / 2, gMiddleShadow.height / 2 )
	screen:add( gMiddleShadow )

	-- For the right shadow, use a clone of the middle shadow	
	gRightShadow = Clone( { name     = "RightShadow",
	                        source   = gMiddleShadow,
	                        position = { 1220, 775 },
	                        opacity  = 0,
	} )
	gRightShadow:move_anchor_point( gRightShadow.width / 2, gRightShadow.height / 2 )
	gRightShadow.scale = { 0, 1 }	-- we'll scale back up when we show it
	screen:add( gRightShadow )
	
end

-- *********************************************************
function
initAnimationStates()

	-- Create the AnimationState transitions
	gBoxStates = AnimationState( {
	                 duration = 750,
	                 transitions = {
	                     { -- Move from Middle to Left
	                       source = "Middle",
	                       target = "Left",
	                       keys   = { { gMiddleBox,    "y_rotation", 90 },
	                                  { gMiddleBox,    "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gMiddleShadow, "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gMiddleShadow, "scale", { 0, 1 } },
	                                  { gLeftBox,      "y_rotation", 0 }, 
	                                  { gLeftBox,      "opacity", "EASE_IN_QUAD", 255 },
	                                  { gLeftShadow,   "opacity", "EASE_IN_QUAD", 255 },
	                                  { gLeftShadow,   "scale", { 1, 1 } },
	                       },
	                     },
	                     { -- Move from Right to Middle
	                       source = "Right",
	                       target = "Middle",
	                       keys   = { { gRightBox,     "y_rotation", -90 },
	                                  { gRightBox,     "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gRightShadow,  "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gRightShadow,  "scale", { 0, 1 } },
	                                  { gMiddleBox,    "y_rotation", 0 },
	                                  { gMiddleBox,    "opacity", "EASE_IN_QUAD", 255 },
	                                  { gMiddleShadow, "opacity", "EASE_IN_QUAD", 255 },
	                                  { gMiddleShadow, "scale", { 1, 1 } },
	                       },
	                     },
	                     { -- Move from Left to Middle
	                       source = "Left",
	                       target = "Middle",
	                       keys   = { { gLeftBox,      "y_rotation", 90 },
	                                  { gLeftBox,      "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gLeftShadow,   "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gLeftShadow,   "scale", { 1, 0 } },
	                                  { gMiddleBox,    "y_rotation", 0 },
	                                  { gMiddleBox,    "opacity", "EASE_IN_QUAD", 255 },
	                                  { gMiddleShadow, "opacity", "EASE_IN_QUAD", 255 },
	                                  { gMiddleShadow, "scale", { 1, 1 } },
	                       },
	                     },
	                     { -- Move from Middle to Right
	                       source = "Middle",
	                       target = "Right",
	                       keys   = { { gMiddleBox,    "y_rotation", 90 },
	                                  { gMiddleBox,    "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gMiddleShadow, "opacity", "EASE_IN_QUINT", 0, 0.0, 0.25 },
	                                  { gMiddleShadow, "scale", { 0, 1 } },
	                                  { gRightBox,     "y_rotation", 0 },
	                                  { gRightBox,     "opacity", "EASE_IN_QUAD", 255 },
	                                  { gRightShadow,  "opacity", "EASE_IN_QUAD", 255 },
	                                  { gRightShadow,  "scale", { 1, 1 } },
	                       },
	                     },
	                 },
	} )

	-- Initialize first state
	gBoxStates.state = "Middle"
	
end

-- *********************************************************
-- Keyhandler
-- Accepts a table of KEY=function()... where KEY is an element from the 
-- TrickPlay SDK's keys global variable and function() is a function that
-- processes the keystroke.
-- Alternatively, the table entry can be KEY="KEY" where "KEY" references
-- an element from the keys global variable; this syntax equates the "KEY"
-- keystroke with KEY.

function
KeyHandler( t )
    return
        function( o , key , ... )
            local k = keys[ key ]:upper()
            while k do
                local f = t[ k ]
                if type( f ) == "function" then
                    return f( o , key , ... )
                end
                k = f
            end
        end
end

-- *********************************************************
-- Program's Main Entry Point

	-- Show the main screen background
	displayMainScreen()
	
	-- Create and display Left, Middle and Right boxes that will be animated
	initBoxes()
	
	-- Create the AnimationState animations
	initAnimationStates()
	
	-- Hook the screen's menu keyboard input to our handlers
	screen.on_key_down = KeyHandler( keyInputHandler )

	-- Show the TrickPlay screen
	screen:show()

-- *********************************************************

