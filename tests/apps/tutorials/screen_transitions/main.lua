
-- How to perform various screen transitions in a TrickPlay application

-- *********************************************************
-- Constants

-- Define the percentage of screen real estate used by the various regions
HEADER_PERCENT     = 0.12  -- percentage of screen height the header region uses
FOOTER_PERCENT     = HEADER_PERCENT
MENU_PERCENT       = 0.20  -- percentage of screen width for menu region

-- Using percentages above, calculate region sizes
MENU_WIDTH         = (math.ceil( screen.width * MENU_PERCENT ))
MENU_HEIGHT        = screen.height
HEADER_WIDTH       = (screen.width - MENU_WIDTH)
HEADER_HEIGHT      = (math.ceil( screen.height * HEADER_PERCENT ))
FOOTER_WIDTH       = HEADER_WIDTH
FOOTER_HEIGHT      = (math.ceil( screen.height * FOOTER_PERCENT ))
MAIN_WIDTH         = (screen.width  - MENU_WIDTH)
MAIN_HEIGHT        = (screen.height - HEADER_HEIGHT - FOOTER_HEIGHT)
SCREEN_WIDTH       = (screen.width - MENU_WIDTH)
SCREEN_HEIGHT      = screen.height

-- Determine region locations. These coordinates are in relation to the screen
-- global variable.
MENU_X             = 0
MENU_Y             = 0
SCREEN_X           = MENU_WIDTH
SCREEN_Y           = 0

-- These coordinates are in relation to the screen's Group object. The Group
-- may be placed anywhere on the screen, but the object's in the Group are
-- positioned from the 0,0 location in the Group.
HEADER_X           = 0
HEADER_Y           = 0
MAIN_X             = 0
MAIN_Y             = HEADER_HEIGHT
FOOTER_X           = 0
FOOTER_Y           = (screen.height - FOOTER_HEIGHT)

-- Menuitem size and location
MENU_TITLE_X       = (MENU_X + 10)
MENU_TITLE_Y       = (MENU_Y + 50)
MENUITEM_X         = (MENU_TITLE_X + 20)
MENUITEM_Y         = (MENU_TITLE_Y + 20)
MENUITEM_WIDTH     = (MENU_WIDTH - MENUITEM_X)
MENUITEM_HEIGHT    = 75
SEPARATOR_WIDTH    = 5
SEPARATOR_HEIGHT   = MENU_HEIGHT
SEPARATOR_X        = (MENU_WIDTH - SEPARATOR_WIDTH)
SEPARATOR_Y        = MENU_Y

-- Colors used in each region
MENU_COLOR         = "#4671D5FF"
HEADER_COLOR       = "rgba(46,57,131,255)"
HEADER_TITLE_COLOR = "rgba(255,165,64,255)"
FOOTER_COLOR       = HEADER_COLOR
FOOTER_TITLE_COLOR = HEADER_TITLE_COLOR
MENU_TITLE_COLOR   = "rgba(27,46,90,255)"
MENUITEM_COLOR     = MENU_TITLE_COLOR
SEPARATOR_COLOR    = MENU_TITLE_COLOR

-- Fonts used
HEADER_TITLE_FONT  = "FreeSans Bold 75px"
FOOTER_TITLE_FONT  = "FreeSans 50px"
MENU_TITLE_FONT    = "FreeSans Bold 40px"
MENUITEM_FONT      = "FreeSans Bold 30px"

-- Images and videos used
BKGND_IMAGE        = "images/PaperTinted.png"
BKGND2_IMAGE       = "images/PaperTintedOrange.png"
LOGO3D_IMAGE       = "images/Logo3D.jpg"
LOGO_IMAGE         = "images/Logo.png"

-- Louver/Blinds constants
NUM_LOUVERS        = 10
LOUVER_WIDTH       = math.ceil( SCREEN_WIDTH / NUM_LOUVERS )
LOUVER_HEIGHT      = SCREEN_HEIGHT

-- Menu of screen transitions
TransitionMenu     = { "1. Instant Switch",
                       "2. Fade Out",
                       "3. Fade In",
                       "4. Fade In and Out",
                       "5. Edge Wipe",
                       "6. Slide",
                       "7. Double Slide",
                       "8. Zoom Out",
                       "9. Zoom In",
                       "0. Louvered Blinds",
}

-- Global variables are good for your health
CurrentScreen      = nil
ScreenOne          = nil
ScreenTwo          = nil

-- The Louver-Blinds transition is more complicated and requires a few globals
Louvers            = nil
LouverCount        = 0
InLouverTransition = false

-- *********************************************************
-- Table of handlers for keystroke input/screen transition implementations

-- Menu keystroke handler
keyInputHandlerMenu = {
	["1"] = function() transitionInstant    ( otherScreen( CurrentScreen ) ) end,
	["2"] = function() transitionFadeOut    ( CurrentScreen, 
	                                          otherScreen( CurrentScreen ) ) end,
	["3"] = function() transitionFadeIn     ( otherScreen( CurrentScreen ) ) end,
	["4"] = function() transitionFadeInOut  ( CurrentScreen,
	                                          otherScreen( CurrentScreen ) ) end,
	["5"] = function() transitionEdgeWipe   ( CurrentScreen,
	                                          otherScreen( CurrentScreen ) ) end,
	["6"] = function() transitionSlide      ( CurrentScreen,
	                                          otherScreen( CurrentScreen ) ) end,
	["7"] = function() transitionSlideDouble( CurrentScreen,
	                                          otherScreen( CurrentScreen ) ) end,
	["8"] = function() transitionZoomOut    ( CurrentScreen,
	                                          otherScreen( CurrentScreen ) ) end,
	["9"] = function() transitionZoomIn     ( otherScreen( CurrentScreen ) ) end,
	["0"] = function() transitionLouvBlinds ( CurrentScreen,
	                                          otherScreen( CurrentScreen ) ) end,
}

-- *********************************************************
function
constructMenu()

	-- Define menu region
	local menuRect = Rectangle( { name = "menuRegion",
	                              size = { MENU_WIDTH, MENU_HEIGHT },
	                              position = { MENU_X, MENU_Y },
	                              color = MENU_COLOR,
	} )
	screen:add( menuRect )
	
	-- Define vertical separator between menu region and rest of screen
	local separator = Rectangle( { name = "menuSeparator",
	                               size = { SEPARATOR_WIDTH, SEPARATOR_HEIGHT },
	                               position = { SEPARATOR_X, SEPARATOR_Y },
	                               color = SEPARATOR_COLOR,
	} )
	screen:add( separator )
	
	-- Define menu header
	local menuTitle = Text( { text = "Screen Transitions",
	                          font = MENU_TITLE_FONT,
	                          color = MENU_TITLE_COLOR,
	                          position = { MENU_TITLE_X, MENU_TITLE_Y },
	} )
	screen:add( menuTitle )
	
	-- Define menu of screen transitions
	local menuNum
	for menuNum = 1, #TransitionMenu do
		local menuLabel = Text( { text = TransitionMenu[ menuNum ],
		                          font = MENUITEM_FONT,
		                          position = { MENUITEM_X,
		                                       MENUITEM_Y + (MENUITEM_HEIGHT * menuNum) },
		                          color = MENUITEM_COLOR,
		} )
		screen:add( menuLabel )
	end

end -- constructMenu()

-- *********************************************************
function
constructScreenOne()

	-- Define Screen One's group. All objects on this screen are in this group.
	-- This group is a global variable so it can be manipulated later
	ScreenOne = Group( { name = "ScreenOne",
	                     position = { SCREEN_X, SCREEN_Y },
	} )
	
	--Define a header region
	local headerRect = Rectangle( { name = "headerRegion",
	                                size = { HEADER_WIDTH, HEADER_HEIGHT },
	                                position = { HEADER_X, HEADER_Y },
	                                color = HEADER_COLOR,
	} )
	ScreenOne:add( headerRect )

	-- Place app's title in header region
	local headerTitle = Text( { text = "TrickPlay Screen Transition Demo",
	                            font = HEADER_TITLE_FONT,
	                            color = HEADER_TITLE_COLOR,
	                            position = { HEADER_X + 165, 15 },
	} )
	ScreenOne:add( headerTitle )
	
	-- Define a footer region
	local footerRect = Rectangle( { name = "footerRegion",
	                                size = { FOOTER_WIDTH, FOOTER_HEIGHT },
	                                position = { FOOTER_X, FOOTER_Y },
	                                color = FOOTER_COLOR,
	} )
	ScreenOne:add( footerRect )
	
	-- Place user instructions in footer region
	local footerTitle = Text( { text = "Press number to perform transition",
	                            font = FOOTER_TITLE_FONT,
	                            color = FOOTER_TITLE_COLOR,
	                            position = { FOOTER_X + 380, FOOTER_Y + 30 },
	} )
	ScreenOne:add( footerTitle )

	-- Define remainder of screen as background region
	-- This must be a global variable because it will be hidden before
	-- displaying the video.
	BckImage = Image( { name = "bckgndTexture",
	                    src  = BKGND_IMAGE,
	                    position = { MAIN_X, MAIN_Y },
	                    size = { MAIN_WIDTH, MAIN_HEIGHT },
	                    tile = { true, true },
	} )
	if( BckImage.loaded )then
		ScreenOne:add( BckImage )
	end
	
	-- Display the TrickPlay 3D Logo in the main region
	-- This must be a global variable because it will be hidden before
	-- displaying the video.
	TpLogo = Image( { name = "TrickPlayLogo",
	                  src = LOGO3D_IMAGE,
	} )
	if( TpLogo.loaded )then
		-- Position image in the center of the main region
		TpLogo.position = { ((MAIN_WIDTH  - TpLogo.base_size[ 1 ]) / 2) + MAIN_X,
		                    ((MAIN_HEIGHT - TpLogo.base_size[ 2 ]) / 2) + MAIN_Y }
		ScreenOne:add( TpLogo )
	end
	
	-- Add the group to the screen
	screen:add( ScreenOne )

end -- constructScreenOne()

-- *********************************************************
function
constructScreenTwo()

	-- Define Screen Two's group. All objects on this screen are in this group.
	-- This group is a global variable so it can be manipulated later
	ScreenTwo = Group( { name = "ScreenTwo",
	                     position = { SCREEN_X, SCREEN_Y },
	} )
	
	--Define a header region
	local headerRect = Rectangle( { name = "headerRegion",
	                                size = { HEADER_WIDTH, HEADER_HEIGHT },
	                                position = { HEADER_X, HEADER_Y },
	                                color = HEADER_TITLE_COLOR,
	} )
	ScreenTwo:add( headerRect )

	-- Place app's title in header region
	local headerTitle = Text( { text = "TrickPlay Screen Transition Demo",
	                            font = HEADER_TITLE_FONT,
	                            color = HEADER_COLOR,
	                            position = { HEADER_X + 165, 15 },
	} )
	ScreenTwo:add( headerTitle )
	
	-- Define a footer region
	local footerRect = Rectangle( { name = "footerRegion",
	                                size = { FOOTER_WIDTH, FOOTER_HEIGHT },
	                                position = { FOOTER_X, FOOTER_Y },
	                                color = FOOTER_TITLE_COLOR,
	} )
	ScreenTwo:add( footerRect )
	
	-- Place user instructions in footer region
	local footerTitle = Text( { text = "Press number to perform transition",
	                            font = FOOTER_TITLE_FONT,
	                            color = FOOTER_COLOR,
	                            position = { FOOTER_X + 380, FOOTER_Y + 30 },
	} )
	ScreenTwo:add( footerTitle )

	-- Define remainder of screen as background region
	-- This must be a global variable because it will be hidden before
	-- displaying the video.
	BckImage = Image( { name = "bckgndTexture",
	                    src  = BKGND2_IMAGE,
	                    position = { MAIN_X, MAIN_Y },
	                    size = { MAIN_WIDTH, MAIN_HEIGHT },
	                    tile = { true, true },
	} )
	if( BckImage.loaded )then
		ScreenTwo:add( BckImage )
	end
	
	-- Display the TrickPlay 3D Logo in the main region
	-- This must be a global variable because it will be hidden before
	-- displaying the video.
	TpLogo = Image( { name = "TrickPlayLogo",
	                  src = LOGO_IMAGE,
	} )
	if( TpLogo.loaded )then
		-- Position image in the center of the main region
		TpLogo.position = { ((MAIN_WIDTH  - TpLogo.base_size[ 1 ]) / 2) + MAIN_X,
		                    ((MAIN_HEIGHT - TpLogo.base_size[ 2 ]) / 2) + MAIN_Y }
		ScreenTwo:add( TpLogo )
	end
	
	-- Add the group to the screen
	screen:add( ScreenTwo )

end -- constructScreenTwo()

-- *********************************************************
function
displayScreen( NewScreen )

	-- Argument: NewScreen - Group object of screen to display
	
	-- Force NewScreen to the front
	NewScreen:raise_to_top()

end -- displayScreen()

-- *********************************************************
function
otherScreen( oldScreen )

	-- Change CurrentScreen to other screen. Returns updated CurrentScreen.
	if( CurrentScreen == ScreenOne )then
		CurrentScreen = ScreenTwo
	else
		CurrentScreen = ScreenOne
	end
	
	-- Return new CurrentScreen
	return CurrentScreen
	
end -- otherScreen()

-- *********************************************************
function
transitionInstant( NewScreen )

	-- Argument: NewScreen - Group object of screen to transition to	

	-- Transition to NewScreen instantly, with no special effects
	-- All we need to do is force the screen's Group object to the top of
	-- its container, which is the global screen variable.
	NewScreen:raise_to_top()
	
end -- transitionInstant()

-- *********************************************************
function
transitionFadeOutCleanup()

	-- This function is invoked at the completion of the FadeOutOld screen
	-- transition.
	
	-- Force CurrentScreen to the front
	CurrentScreen:raise_to_top()
	
	-- Reset old screen's opacity
	if( CurrentScreen == ScreenOne )then
		ScreenTwo.opacity = 255
	else
		ScreenOne.opacity = 255
	end
	
end -- transitionFadeOutCleanup()

-- *********************************************************
function
transitionFadeOut( OldScreen, NewScreen )

	-- Arguments: OldScreen - Group object of screen to transition from
	--            NewScreen - Group object of screen to transition to
	
	-- Fade out OldScreen, revealing NewScreen
	-- Use a simple UIElement:animate() function with an on_completed() event
	-- handler to clean up, afterwards.
	OldScreen:animate( { duration = 500,    -- transition time duration
	                     opacity = 0,        -- fade to fully transparent
	                     on_completed = transitionFadeOutCleanup,
	} )
	
end -- transitionFadeOut()
	                   
-- *********************************************************
function
transitionFadeIn( NewScreen )

	-- Argument: NewScreen - Group object of screen to transition to
	
	-- Make NewScreen fully transparent/invisible
	NewScreen.opacity = 0
	
	-- Raise NewScreen to the front of the screen
	NewScreen:raise_to_top()
	
	-- Animate opacity back up to fully opaque
	-- Note: No clean-up is necessary after this operation.
	NewScreen:animate( { duration = 500,   -- transition time duration
	                     opacity = 255,     -- fade in to fully opaque
	} )
	
end -- transitionFadeIn()

-- *********************************************************
function
transitionFadeInOut( OldScreen, NewScreen )

	-- Arguments: OldScreen - Group object of screen to transition from
	--            NewScreen - Group object of screen to transition to
	
	-- Fade out OldScreen, fade in NewScreen
	transitionFadeOut( OldScreen, NewScreen )	
	transitionFadeIn( NewScreen )
	
end -- transitionFadeInOut()

-- *********************************************************
function
transitionEdgeWipeCleanup()

	-- Cleanup after completing Edge Wipe transition
	local oldScreen = ScreenOne
	if( CurrentScreen == ScreenOne )then
		oldScreen = ScreenTwo
	end
	
	-- Move OldScreen behind new current screen
	oldScreen:lower_to_bottom()
	
	-- Clear clipping rectangle
	oldScreen.clip = nil

end -- transitionEdgeWipeCleanup()

-- *********************************************************
function
transitionEdgeWipe( OldScreen, NewScreen )

	-- Arguments: OldScreen - Group object of screen to transition from
	--            NewScreen - Group object of screen to transition to (not used)
	
	-- Set clipping rectangle over entire OldScreen group
	OldScreen.clip = { 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT }
	
	-- Animate clipping rectangle to reveal NewScreen behind
	-- Note: Must clean up after this operation
	OldScreen:animate( { duration = 500,   -- transition time duration
	                     clip = { SCREEN_WIDTH, 0, 0, SCREEN_HEIGHT },
	                     on_completed = transitionEdgeWipeCleanup,
	} )

end -- transitionEdgeWipe()

-- *********************************************************
function
transitionSlideCleanup()

	-- Cleanup after completing Slide transition
	local oldScreen = ScreenOne
	if( CurrentScreen == ScreenOne )then
		oldScreen = ScreenTwo
	end
	
	-- Move OldSCreen behind new current screen
	oldScreen:lower_to_bottom()

	-- Restore OldScreen's original, pre-animation X position
	oldScreen.x = SCREEN_X
	
end -- transitionSlideCleanup()

-- *********************************************************
function
transitionSlide( OldScreen, NewScreen )

	-- Arguments: OldScreen - Group object of screen to transition from
	--            NewScreen - Group object of screen to transition to (not used)
	
	-- Animate OldScreen to move right, off-screen, revealing NewScreen behind
	-- Note: Must clean up after this operation
	OldScreen:animate( { duration = 500,   -- transition time duration
	                     x = SCREEN_WIDTH + SCREEN_X,
	                     on_completed = transitionSlideCleanup,
	} )

end -- transitionSlide()

-- *********************************************************
function
transitionSlideDouble( OldScreen, NewScreen )

	-- Arguments: OldScreen - Group object of screen to transition from
	--            NewScreen - Group object of screen to transition to
	
	-- Move NewScreen so its right edge is on the display area's left edge, i.e., off-screen
	NewScreen.x = SCREEN_X - SCREEN_WIDTH
	
	-- Animate NewScreen to move right, from off-screen to center-screen
	-- Note: No cleanup is needed after this operation
	NewScreen:animate( { duration = 500,   -- transition time duration
	                     x = SCREEN_X,
	} )
	
	-- Perform Slide screen transition on OldScreen
	transitionSlide( OldScreen, NewScreen )

end -- transitionSlideDouble()

-- *********************************************************
function
transitionZoomOutCleanup()

	-- Cleanup after completing Zoom-Out transition
	local oldScreen = ScreenOne
	if( CurrentScreen == ScreenOne )then
		oldScreen = ScreenTwo
	end
	
	-- Move OldScreen behind new current screen
	oldScreen:lower_to_bottom()
	
	-- Restore OldScreen's original scale
	oldScreen.scale = 1
	
	-- Restore original anchor point
	oldScreen:move_anchor_point( 0, 0 )

end -- transitionZoomOutCleanup()

-- *********************************************************
function
transitionZoomOut( OldScreen, NewScreen )

	-- Arguments: OldScreen - Group object of screen to transition from
	--            NewScreen - Group object of screen to transition to (not used)
	
	-- Set OldScreen's anchor point to the center
	OldScreen:move_anchor_point( SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 )

	-- Animate OldScreen so it scales down to nothing
	-- Note: Must clean up after this operation
	OldScreen:animate( { duration = 500,   -- transition time duration
	                     scale = { 0, 0 },
	                     on_completed = transitionZoomOutCleanup,
	} )

end -- transitionZoomOut()

-- *********************************************************
function
transitionZoomInCleanup()

	-- Cleanup after performing Zoom-In transition
	-- Restore current screen's anchor point
	CurrentScreen:move_anchor_point( 0, 0 )
	
end -- transitionZoomInCleanup()

-- *********************************************************
function
transitionZoomIn( NewScreen )

	-- Arguments: NewScreen - Group object of screen to transition to
	
	-- Set NewScreen's anchor point to the center
	NewScreen:move_anchor_point( SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 )
	
	-- Scale NewScreen down to nothing, so it is invisible
	NewScreen.scale = 0
	
	-- Move NewScreen to the front of the screen
	NewScreen:raise_to_top()
	
	-- Animate NewScreen so it scales up to normal size
	-- Note: Must clean up after this operation
	NewScreen:animate( { duration = 500,   -- transition time duration
	                     scale = { 1, 1 },
	                     on_completed = transitionZoomInCleanup,
	} )

end -- transitionZoomIn()

-- *********************************************************
function
transitionLouvBlindsCleanup()

	-- Cleanup after performing Louver-Blinds transition
	
	-- Increase number of blinds that have completed drawing
	LouverCount = LouverCount + 1
	
	-- Are there still louvers that are opening?
	if( LouverCount < NUM_LOUVERS ) then
		-- Yes, don't clean up until the animation is completely finished
		return
	end
	
	-- Remove Louvers from the screen
	screen:remove( Louvers )
	
	-- Clear Louvers and make all the louvers available for garbage collection
	Louvers:clear()
	Louvers = nil
	
	-- Enable subsequent Louver-Blinds transitions
	InLouverTransition = false

end -- transitionLouvBlindsCleanup()

-- *********************************************************
function
transitionLouvBlindsPhase2()

	-- Blinds are being drawn, covering the entire screen
	
	-- Increase number of blinds that have completed drawing
	LouverCount = LouverCount + 1
	
	--Are there still louvers that are closing?
	if( LouverCount < NUM_LOUVERS )then
		-- Yes, don't start phase 2 of animation until phase 1 is completely finished
		return
	end
	
	-- All blinds are drawn; reset counter
	LouverCount = 0
	
	-- Move the CurrentScreen to the front, but behind the blinds
	CurrentScreen:lower( Louvers )
	
	-- Now open the blinds, revealing the new CurrentScreen
	-- Note: Must cleanup after this operation
	local louvers = Louvers.children
	for i, louver in ipairs( louvers ) do
		-- Animate this louver's clipping region to uncover the screen below
		louver:animate( { duration = 250,   -- transition time duration
		                  clip = { 0, 0, 0, LOUVER_HEIGHT },
		                  on_completed = transitionLouvBlindsCleanup,
		} )
	end

end -- transitionLouvBlindsPhase2()

-- *********************************************************
function
transitionLouvBlinds( OldScreen, NewScreen )

	-- Arguments: OldScreen - Group object of screen to transition from
	--            NewScreen - Group object of screen to transition to
	
	-- While performing Louver-Blinds transition, don't allow another Louver-
	-- Blinds transition to start until this one completely finishes. This is
	-- necessary to guarantee that final cleanup occurs.
	if( InLouverTransition == true )then return end
	InLouverTransition = true
	
	-- Create Group of clipped/invisible Rectangles/louvers and place onscreen
	
	-- The louvers are a Group that covers the entire screen area
	-- This must be global so it can be destroyed after the screen transition
	Louvers = Group( { name = "Louvers",
	                   position = { SCREEN_X, SCREEN_Y },
	} )
	
	-- Create the louvers. Clip them so they are invisible.
	for i = 1, NUM_LOUVERS do
		local louver = Rectangle( { size = { LOUVER_WIDTH, LOUVER_HEIGHT },
		                            position = { LOUVER_WIDTH * (i - 1), 0 },
		                            color = "black",
		                            clip = { -1, 0, 0, LOUVER_HEIGHT },
		} )
	    Louvers:add( louver )
	end
	
	-- Place the louvers on the screen, in front of the current screen
	screen:add( Louvers )

	-- Perform first phase of animation, closing the louvers
	-- Initialize global louver counter
	LouverCount = 0
	
	-- The screen of louvers is placed in a local variable for performance reasons
	-- Note: The second phase of animation is performed upon completion of phase 1
	local louvers = Louvers.children
	for i, louver in ipairs( louvers ) do
		-- Animate this louver's clipping region to expose the rectangle and
		-- cover the underlying screen
		louver:animate( { duration = 250,   -- transition time duration
		                  clip = { -1, 0, LOUVER_WIDTH, LOUVER_HEIGHT },
		                  on_completed = transitionLouvBlindsPhase2,
		} )
	end

end -- transitionLouvBlinds()

-- *********************************************************
-- Keyhandler
-- Accepts a table of KEY=function()... where KEY is an element from the keys
-- global variable and function() is a function that processes the keystroke.
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
-- Program Entry Point

-- Initialization
constructMenu()
constructScreenOne()
constructScreenTwo()

-- Set beginning screen
CurrentScreen = ScreenOne
displayScreen( CurrentScreen )

-- Hook the screen's menu keyboard input to our handlers
screen.on_key_down = KeyHandler( keyInputHandlerMenu )

-- Show the TrickPlay screen
screen:show()

