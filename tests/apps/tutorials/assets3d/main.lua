--
--	Using 3D Assets in a TrickPlay 2D Application
--

-- *********************************************************
-- Constants

-- Names of external files
MAIN_SCREEN_IMAGE		= "images/Background3D.png"

-- 3D Coin animation cels
COIN_CEL_FILENAMES		= { "images/frame01.png",
							"images/frame02.png",
							"images/frame03.png",
							"images/frame04.png",
							"images/frame05.png",
							"images/frame06.png",
							"images/frame07.png",
							"images/frame08.png",
							"images/frame09.png",
							"images/frame10.png",
							"images/frame11.png",
							"images/frame12.png",
							"images/frame13.png",
							"images/frame14.png",
							"images/frame15.png",
							"images/frame16.png",
							"images/frame17.png",
							"images/frame18.png",
							"images/frame19.png",
							"images/frame20.png",
							"images/frame21.png",
							"images/frame22.png",
							"images/frame23.png",
							"images/frame24.png",
}
NUM_COIN_CELS			= 24
COIN_ANIMATION_FPS		= (1000 / 24)		-- 24 fps

COIN_INIT_X				= (screen.width / 2)
COIN_INIT_Y				= ((screen.height / 2) + 215)

-- *************************************
-- Note: The positions stored in the following tables are offsets from the coin's 
-- "at rest" position stored in the global variables gCoinRestingX and gCoinRestingY

-- Table of cel position offsets for animating the coin left
ANIMATE_COIN_LEFT_POS	= { {    0,    0 },	-- Cel #1
							{   -5,  -10 },
							{  -20,  -37 },
							{  -30,  -82 },
							{  -50, -142 },	-- Cel #5
							{  -79, -207 },
							{  -95, -277 },
							{ -111, -337 },
							{ -127, -392 },
							{ -143, -430 },	-- Cel #10
							{ -159, -455 },
							{ -175, -455 },
							{ -189, -455 },
							{ -203, -445 },
							{ -217, -423 },	-- Cel #15
							{ -231, -395 },
							{ -245, -360 },
							{ -260, -318 },
							{ -275, -270 },
							{ -290, -220 },	-- Cel #20
							{ -305, -170 },
							{ -320, -108 },
							{ -335,  -45 },
							{ -350,    0 },	-- Cel #24
}

-- Table of cel position offsets for animating the coin right
ANIMATE_COIN_RIGHT_POS	= { {   0,    0 },	-- Cel #1
							{   5,  -10 },
							{  20,  -37 },
							{  30,  -82 },
							{  50, -142 },	-- Cel #5
							{  79, -207 },
							{  95, -277 },
							{ 111, -337 },
							{ 127, -392 },
							{ 143, -430 },	-- Cel #10
							{ 159, -455 },
							{ 175, -455 },
							{ 189, -455 },
							{ 203, -445 },
							{ 217, -423 },	-- Cel #15
							{ 231, -395 },
							{ 245, -360 },
							{ 260, -318 },
							{ 275, -270 },
							{ 290, -220 },	-- Cel #20
							{ 305, -170 },
							{ 320, -108 },
							{ 335,  -45 },
							{ 350,    0 },	-- Cel #24
}

-- Table of cel position offsets for animating the coin straight up
ANIMATE_COIN_UP_POS		= { { 0,    0 },	-- Cel #1
							{ 0,  -10 },
							{ 0,  -37 },
							{ 0,  -82 },
							{ 0, -142 },	-- Cel #5
							{ 0, -207 },
							{ 0, -277 },
							{ 0, -337 },
							{ 0, -392 },
							{ 0, -430 },	-- Cel #10
							{ 0, -455 },
							{ 0, -455 },
							{ 0, -455 },
							{ 0, -445 },
							{ 0, -423 },	-- Cel #15
							{ 0, -395 },
							{ 0, -360 },
							{ 0, -318 },
							{ 0, -270 },
							{ 0, -220 },	-- Cel #20
							{ 0, -170 },
							{ 0, -108 },
							{ 0,  -45 },
							{ 0,    0 },	-- Cel #24
}

-- *************************************
-- Global Variables

	gCoin				= 1					-- Image object containing current coin image
	gCoinCels			= {}				-- Table of coin cel Image objects
	gCoinPos			= nil				-- Table of animation cel offset positions
	gAnimationTimer		= nil				-- Animation timer
	gCoinRestingX		= COIN_INIT_X		-- Coin's X position when "at rest"
	gCoinRestingY		= COIN_INIT_Y		-- Coin's Y position when "at rest"

-- *********************************************************
-- Table of handlers for keystroke input

-- Menu keystroke handler
keyInputHandler = {
	LEFT  = function() animateCoinLeft()  end,
	RIGHT = function() animateCoinRight() end,
	UP    = function() animateCoinUp()    end,
}

-- *********************************************************
function
nextCoinFrame( timer )

	-- Advance to the next frame
	gCoin = gCoin + 1
	
	-- Position the frame's image
	gCoinCels[ gCoin ].x = gCoinRestingX + gCoinPos[ gCoin ][ 1 ]
	gCoinCels[ gCoin ].y = gCoinRestingY + gCoinPos[ gCoin ][ 2 ]
	
	-- Make the image visible
	gCoinCels[ gCoin ].opacity = 255
	
	-- Make the previous image invisible
	gCoinCels[ gCoin - 1 ].opacity = 0
	
	-- Was this the last frame in the animation?
	if( gCoin == NUM_COIN_CELS )then
		-- Yes, terminate animation
		timer:stop()
		
		-- Save current X coordinate as new at-rest location
		gCoinRestingX = gCoinCels[ gCoin ].x
		
		-- Did coin reach right or left edge of the screen?
		if( (gCoinRestingX > (screen.width - (gCoinCels[ NUM_COIN_CELS ].width / 2)))	-- right edge test
		    or
		    (gCoinRestingX < (gCoinCels[ NUM_COIN_CELS ].width / 2)) )then				-- left edge test
				-- Yes, move back to the middle of the screen
				gCoinRestingX = COIN_INIT_X
		end
		
		-- Move position of first cel to updated position
		gCoinCels[ 1 ].x = gCoinRestingX
		
		-- Re-init cel index
		gCoin = 1
		
		-- The first and last cels in our cycle are identical. Replace the last
		-- with the first on the screen so the next cycle starts with Cel #1.
		gCoinCels[ 1 ].opacity = 255
		gCoinCels[ NUM_COIN_CELS ].opacity = 0
	end

end

-- *********************************************************
function
animateCoinLeft()

	-- Assign Left-animation positions to global variable
	gCoinPos = ANIMATE_COIN_LEFT_POS
	
	-- Start the animation
	-- Note: gCoin == 1 at this point, indexing the animation's first cel image
	-- and position
	gAnimationTimer:start()

end

-- *********************************************************
function
animateCoinRight()

	-- Assign Right-animation positions to global variable
	gCoinPos = ANIMATE_COIN_RIGHT_POS
	
	-- Start the animation
	-- Note: gCoin == 1 at this point, indexing the animation's first cel image
	-- and position
	gAnimationTimer:start()

end

-- *********************************************************
function
animateCoinUp()

	-- Assign Up-animation positions to global variable
	gCoinPos = ANIMATE_COIN_UP_POS
	
	-- Start the animation
	-- Note: gCoin == 1 at this point, indexing the animation's first cel image
	-- and position
	gAnimationTimer:start()

end

-- *********************************************************
function
showTwoCels( animationCelPos )

	-- Utility function that displays semi-transparently two cels in the
	-- animation.
	-- This function is useful when positioning each cel in the animation's
	-- sequence during development.
	-- This function is not called during the normal running of the finished
	-- program.
	
	-- The animationCelPos argument is a table containing the offsets (from 
	-- gCoinRestingX/Y) of each cel's position
	
	local	i = 5
	local	j = 6

	-- Position this cel and show it semi-transparently
	gCoinCels[ i ].x = gCoinRestingX + animationCelPos[ i ][ 1 ]
	gCoinCels[ i ].y = gCoinRestingY + animationCelPos[ i ][ 2 ]
	gCoinCels[ i ].opacity = 255

	gCoinCels[ j ].x = gCoinRestingX + animationCelPos[ j ][ 1 ]
	gCoinCels[ j ].y = gCoinRestingY + animationCelPos[ j ][ 2 ]
	gCoinCels[ j ].opacity = 128

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
loadCoinAnimationCels()

	local	i = 0
	
	for i = 1, NUM_COIN_CELS do
		gCoinCels[ i ] = Image( { src = COIN_CEL_FILENAMES[ i ] } )
		if( gCoinCels[ i ].loaded == false )then
			print( "Could not load the coin animation's cel: ", COIN_CEL_FILENAMES[ i ] )
			exit()
			return
		end
		
		-- Make image invisible until it is needed
		gCoinCels[ i ].opacity = 0
		
		-- Place the image's origin in its center
		gCoinCels[ i ].anchor_point = { gCoinCels[ i ].width / 2, gCoinCels[ i ].height / 2 }
		
		-- Add image to screen
		screen:add( gCoinCels[ i ] )
	end

end

-- *********************************************************
function
initCoinDisplay()

	-- Position the first coin onscreen and show it
	gCoinCels[ 1 ].position = { COIN_INIT_X, COIN_INIT_Y }
	gCoinCels[ 1 ].opacity = 255
	
	-- We'll also define the animation's Timer now, too, but don't start it
	gAnimationTimer = Timer( COIN_ANIMATION_FPS )
	
	-- Define the handler to show the animation's next frame
	gAnimationTimer.on_timer = nextCoinFrame

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

	-- Show the main screen
	displayMainScreen()
	
	-- Load all the animation's coin cels
	loadCoinAnimationCels()
	
	-- Show initial coin
	initCoinDisplay()
	
	-- Hook the screen's menu keyboard input to our handlers
	screen.on_key_down = KeyHandler( keyInputHandler )

	-- Show the TrickPlay screen
	screen:show()
	
	-- Development utility function: Determine animation's cel positions
	--showTwoCels( ANIMATE_COIN_RIGHT_POS )
	
	-- Perform program intro
	animateCoinUp()

-- *********************************************************

