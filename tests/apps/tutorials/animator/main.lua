--
-- TrickPlay Animator Sample Application
--
-- *********************************************************
-- Constants

-- Names of external files
MAIN_BACKGROUND_IMAGE			= "MainBackground.png"

SPOTLIGHT_DIAMETER				= 500
SPOTLIGHT_COLOR					= "#fff5ee7F"				-- warm white, semi-transparent

-- The characters we want to animate
TP_STR							= { "T", "r", "i", "c", "k", "P", "l", "a", "y" }
TEXT_COLOR_LIGHT				= "red3"
TEXT_COLOR_DARK					= "rgb(46,57,131)"
TEXT_POS_X						= 380						-- final X coordinate of first character
TEXT_POS_Y						= 175						-- final Y coordinate of first character

-- *********************************************************
-- Global variables

	gDisplayArea				= nil		-- Rectangle between title and footer
	gSpotlight1					= nil		-- Image generated from Canvas
	gSpotlight2					= nil		-- Clone generated from gSpotlight1
	gTrickPlayStr				= {}		-- Array of characters
	gLoopingTimeline			= nil		-- Timeline object used to loop animation
	
-- *********************************************************
function
displayMainScreen()

	local mainScreen = nil
	
	-- Load the background screen
	mainScreen = Image( { name = "MainScreen",
	                      src  = MAIN_BACKGROUND_IMAGE,
	} )
	if( mainScreen.loaded == false )then
		print( "Could not load the screen's main image:", MAIN_BACKGROUND_IMAGE )
		exit()
		return
	end
	screen:add( mainScreen )
	
	-- Define a Group object that covers the screen area between the title and footer areas
	-- Note: All objects outside this area will be clipped
	gDisplayArea = Group( { position = { 0, 145 },
	                        clip     = { 0, 0, screen.width, 755 },
	} )
	screen:add( gDisplayArea )

end

-- *********************************************************
function
createTrickPlayString()

	local	TEXT_FONT			= "FreeSans Bold 280px"
	local	SPACING				= (-10)					-- number of pixels between characters
	
	-- Initial positions (off-screen) for each character
	local	POSITIONS			= { { -200,  750 },		-- "T"
	                                {  200, -350 },		-- "r"
	                                {  300,  955 },		-- "i"
	                                { 1600, -350 },		-- "c"
	                                { 2120,  755 },		-- "k"
	                                {  400, -350 },		-- "P"
	                                { 1000,  955 },		-- "l"
	                                { 2120,  400 },		-- "a"
	                                { 2120,    0 },		-- "y"
	                              }
	                              
	local	i					= nil
	local	currHeight			= 0
	local	maxHeight			= 0
	local	currLen				= 0
	
	-- Each element in the gTrickPlayStr table can be referenced by using the
	-- element's character from the string "TrickPlay," as in gTrickPlayStr.T
	-- or gTrickPlayStr.r or gTrickPlayStr[ "T" ] or gTrickPlayStr[ "r" ]
	-- Each element in the gTrickPlayStr table is a record with the following fields:
	--		textObj - a Text object that contains a single character from the string "TrickPlay"
	--		homeX   - the character's offscreen X coordinate
	--      homeY   - the character's offscreen Y coordinate
	--		offsetX - the character's final onscreen X offset from the string's far left
	--		offsetY - the character's final onscreen Y offset from the string's top-most row

	-- For each character, create a record in the gTrickPlayStr table
	for i = 1, #TP_STR do
		gTrickPlayStr[ TP_STR[ i ] ] = { textObj = Text( { text     = TP_STR[ i ],
		                                                   font     = TEXT_FONT,
		                                                   color    = TEXT_COLOR_DARK,
		                                                   position = POSITIONS[ i ],
		                                                 } )
		}

		-- Save X offset of this character from the left-most position
		gTrickPlayStr[ TP_STR[ i ] ].offsetX = currLen
		
		-- Save the character's offscreen starting X,Y coordinates
		gTrickPlayStr[ TP_STR[ i ] ].homeX = POSITIONS[ i ][ 1 ]
		gTrickPlayStr[ TP_STR[ i ] ].homeY = POSITIONS[ i ][ 2 ]
		
		-- Add the width of this character to the current length
		currLen = currLen + gTrickPlayStr[ TP_STR[ i ] ].textObj.width + SPACING
		
		-- Is this character the largest in height so far?
		currHeight = gTrickPlayStr[ TP_STR[ i ] ].textObj.height
		if( currHeight > maxHeight )then
			-- Yes, save this height
			maxHeight = currHeight
		end
		
		-- Add the Text character to the display area
		gDisplayArea:add( gTrickPlayStr[ TP_STR[ i ] ].textObj )
	end

	-- Using maxHeight, determine each character's Y offset so all the characters
	-- line up along the bottom
	for i = 1, #TP_STR do
		gTrickPlayStr[ TP_STR[ i ] ].offsetY = maxHeight - gTrickPlayStr[ TP_STR[ i ] ].textObj.height
	end

end

-- *********************************************************
function
createResources()

	local	SCALE_FACTOR	= (1.5)
	
	local	spotlight		= nil
	
	-- Create semi-transparent circular spotlights
	-- First, create a Canvas object
	spotlight = Canvas( SPOTLIGHT_DIAMETER, SPOTLIGHT_DIAMETER )

	-- Draw a semi-transparent, whitish circle on the Canvas
	spotlight:arc( spotlight.width / 2, spotlight.height / 2, SPOTLIGHT_DIAMETER / 2, 0, 360 )
	spotlight:set_source_color( SPOTLIGHT_COLOR )
	spotlight:fill()

	-- Convert it to an Image object
	gSpotlight1      = spotlight:Image()
	gSpotlight1.name = "Spotlight1"
	
	-- Scale it along the X-axis to make it an oval and add it to the display area
	gSpotlight1.scale = { SCALE_FACTOR, 1.0 }
	gDisplayArea:add( gSpotlight1 )
	
	-- Create the second spotlight by cloning the first
	gSpotlight2       = Clone( { name = "Spotlight2", source = gSpotlight1 } )
	gSpotlight2.scale = { SCALE_FACTOR, 1.0 }
	gDisplayArea:add( gSpotlight2 )
	
	-- Create "TrickPlay" string of individual characters
	createTrickPlayString()

	--[[
	-- Test TrickPlay string positioning by displaying it
	local		i
	for i = 1, #TP_STR do
		gTrickPlayStr[ TP_STR[ i ] ].textObj.position = { TEXT_POS_X + gTrickPlayStr[ TP_STR[ i ] ].offsetX,
		                                                  TEXT_POS_Y + gTrickPlayStr[ TP_STR[ i ] ].offsetY }
	end
	--]]

end

-- *********************************************************
function
charAnimationFinished( charAnimation )

	-- The charAnimation argument is the Timeline object associated with the
	-- Animator defined in the animateCharacters() function.
	
	-- At this point, both the Character and the Spotlight animations have completed.
	-- Now we will start another animation that loops indefinitely and changes
	-- the colors of the characters.
	
	local		i				= 0
	local		props			= {}
	local		colorChars		= nil
	
	-- Create the Animator's table of properties for assignment in the Animator constructor
	for i = 1, #TP_STR do
		-- Create properties table entry and add it to the props table
		table.insert( props, { source = gTrickPlayStr[ TP_STR[ i ] ].textObj,
		                       name   = "color",
		                       keys   = { { 0.0, "LINEAR", TEXT_COLOR_DARK },
		                                  { 0.5, "LINEAR", TEXT_COLOR_LIGHT },
		                                  { 1.0, "LINEAR", TEXT_COLOR_DARK },
		                                }
		} )
	end
	
	-- Create the Animator's associated Timeline object which will be used to loop
	-- the animation infinitely.
	-- Note: This variable must be global because if the animation sequence is run again,
	-- this animation will be stopped.
	gLoopingTimeline = Timeline( { loop = true,
	                               duration = 10000,
	} )
	
	-- Create the Animator
	colorChars = Animator( {
					duration   = 10000,
					timeline   = gLoopingTimeline,		-- Loops the animation infinitely
					properties = props,
	} )
	
	-- Start the animation
	colorChars:start()

end

-- *********************************************************
function
animateCharacters()

	local		i				= 0
	local		props			= {}
	local		animateChars	= nil
	local		doneTimeline	= nil
	
	
	-- Create the Animator's table of properties for assignment in the Animator constructor
	for i = 1, #TP_STR do
		-- Position characters offscreen
		gTrickPlayStr[ TP_STR[ i ] ].textObj.x = gTrickPlayStr[ TP_STR[ i ] ].homeX
		gTrickPlayStr[ TP_STR[ i ] ].textObj.y = gTrickPlayStr[ TP_STR[ i ] ].homeY
		
		-- Create properties table entry and add it to the props table
		table.insert( props, { source = gTrickPlayStr[ TP_STR[ i ] ].textObj,
		                       name   = "position",
		                       keys   = { { 0.0, "LINEAR",        { gTrickPlayStr[ TP_STR[ i ] ].homeX,
		                                                            gTrickPlayStr[ TP_STR[ i ] ].homeY } },
		                                  { 1.0, "EASE_OUT_SINE", { TEXT_POS_X + gTrickPlayStr[ TP_STR[ i ] ].offsetX,
		                                                            TEXT_POS_Y + gTrickPlayStr[ TP_STR[ i ] ].offsetY } },
		                                }
		} )
	end
	
	-- Create the Animator's associated Timeline object which will be used to start another
	-- animation after the character animation is finished.
	doneTimeline = Timeline( { on_completed = charAnimationFinished } )

	-- Create the Animator
	animateChars = Animator( {
					duration   = 2000,
					timeline   = doneTimeline,	-- Receives notification when the animation is finished
					properties = props,
	} )
	
	-- Start animating the characters
	animateChars:start()
	
end

-- *********************************************************
function
animateSpotlights()

	local	SPOT1_X			= (0 - SPOTLIGHT_DIAMETER)
	local	SPOT1_Y			= SPOT1_X
	local	SPOT2_X			= (screen.width + SPOTLIGHT_DIAMETER)
	local	SPOT2_Y			= (0 - SPOTLIGHT_DIAMETER)

	local	animateSpots	= nil
	
	-- Initialize spotlights' starting positions
	gSpotlight1.position = { SPOT1_X, SPOT1_Y }
	gSpotlight2.position = { SPOT2_X, SPOT2_Y }
	
	animateSpots = Animator( { 
					duration = 500,
					properties = {
						{ source = gSpotlight1,
						  name   = "position",
						  keys   = { { 0.0, "LINEAR", { SPOT1_X, SPOT1_Y } },
						  			 { 0.8, "LINEAR", { 270, 105 } },			-- finish before Spot2
						  			 { 1.0, "LINEAR", { 270, 105 } },
						  		   },
						},
						{ source = gSpotlight2,
						  name   = "position",
						  keys   = { { 0.0, "LINEAR", { SPOT2_X, SPOT2_Y } },
						             { 0.2, "LINEAR", { SPOT2_X, SPOT2_Y } },	-- don't start moving until this point
						             { 1.0, "LINEAR", { 890, 105 } },
						           },
						},
					}
	} )
						  
	-- Start animating the spotlights
	animateSpots:start()
end

-- *********************************************************
function
performAnimation()

	-- If replaying the animation, stop the looping animation
	-- This is necessary to block a hanging reference to the Timeline object from 
	-- existing and, thereby, preventing the object from being garbage-collected.
	if( gLoopingTimeline ~= nil )then
		gLoopingTimeline:stop()
	end
	
	-- Animate the characters into position
	-- Note: Runs asynchronously; when this function returns, the animation will
	-- still be running.
	animateCharacters()
		
	-- Animate the spotlights on the characters
	-- Note: This animation runs concurrently with the character animation.
	animateSpotlights()

end

-- *********************************************************
-- Program's main entry point

	-- Show the main background screen
	displayMainScreen()
	
	-- Create the resources that will be animated
	createResources()
	
	-- Show the screen
	screen:show()
	
	-- Perform the animation
	performAnimation()

	-- Direct any keystrokes to the performAnimation() function
	screen.on_key_down = performAnimation

-- *********************************************************

