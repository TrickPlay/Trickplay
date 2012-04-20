--
-- TrickPlay Localization Sample Application
--

-- *********************************************************
-- Constants

-- Names of external files
-- Note: A localized version will exist for each of these files
LOCALIZED_TEXT_AND_COORDS	= "localized:i18n.lua"
LOCALIZED_ANIMATION			= "localized:animation.lua"
MAIN_SCREEN_BACKGROUND		= "localized:Background.png"
BILLBOARD_IMAGE				= "localized:Billboard.png"

BUTTON_TEXT_FONT			= "FreeSans Bold 88px"
BUTTON_TEXT_COLOR_ACTIVE	= "chocolate4"
BUTTON_TEXT_COLOR_INACTIVE	= "#B07F59FF"

-- *********************************************************
-- Global Variables

	gI18n			= nil	-- localized strings and X,Y coordinates for screen layouts
	gAnimation		= nil	-- localized function that animates the billboard
	gBillboard		= nil	-- this is global because it may be animated
	
-- *********************************************************
function
displayMainScreen()

	local mainScreen = nil
	
	-- Load the localized version of the main screen
	mainScreen = Image( { name = "MainScreen",
	                      src  = MAIN_SCREEN_BACKGROUND,
	} )
	if( mainScreen.loaded == false )then
		print( "Could not load the screen's main image:", MAIN_SCREEN_BACKGROUND )
		exit()
		return
	end
	screen:add( mainScreen )

end

-- *********************************************************
function
displayBillboard()

	-- Load the localized version of the billboard
	gBillboard = Image( { name     = "Billboard",
	                      src      = BILLBOARD_IMAGE,
	                      position = { gI18n.BILLBOARD_X, gI18n.BILLBOARD_Y },
	} )
	if( gBillboard.loaded == false )then
		print( "Could not load the image:", BILLBOARD_IMAGE )
		exit()
		return
	end
	screen:add( gBillboard )
	
end

-- *********************************************************
function
displayButtonText()

	local	buttonText = nil

	-- Display the top button's localized text at the correct location for 
	-- this screen layout
	buttonText = Text( { name     = "TopButtonText",
	                     text     = gI18n.BUTTON_TOP_TEXT,
	                     position = { gI18n.BUTTON_TOP_X, gI18n.BUTTON_TOP_Y },
	                     font     = BUTTON_TEXT_FONT,
	                     color    = BUTTON_TEXT_COLOR_ACTIVE,
	} )
	screen:add( buttonText )

	-- Do the same for the middle and bottom buttons
	buttonText = Text( { name     = "MiddleButtonText",
	                     text     = gI18n.BUTTON_MIDDLE_TEXT,
	                     position = { gI18n.BUTTON_MIDDLE_X, gI18n.BUTTON_MIDDLE_Y },
	                     font     = BUTTON_TEXT_FONT,
	                     color    = BUTTON_TEXT_COLOR_INACTIVE,
	} )
	screen:add( buttonText )
	
	buttonText = Text( { name     = "BottomButtonText",
	                     text     = gI18n.BUTTON_BOTTOM_TEXT,
	                     position = { gI18n.BUTTON_BOTTOM_X, gI18n.BUTTON_BOTTOM_Y },
	                     font     = BUTTON_TEXT_FONT,
	                     color    = BUTTON_TEXT_COLOR_INACTIVE,
	} )
	screen:add( buttonText )
	
end

-- *********************************************************
function
processAnimation()

	errorMsg	= nil
	
	-- Load any optional localized animation function to animate the billboard
	-- Note: We don't define any default animation; if a localized animation is
	-- not defined then no animation occurs
	gAnimation, errorMsg = loadfile( LOCALIZED_ANIMATION )
	if( gAnimation == nil )then
		-- No localized animation
		print( "No localized animation function, or Error loading function:", errorMsg )
		return
	end
	
	-- Start the animation, passing in the Billboard object
	gAnimation( gBillboard )

end

-- *********************************************************
-- Program's Main Entry Point

	-- Load the application's localized text strings and X,Y
	-- coordinates for localized screen layouts
	gI18n = dofile( LOCALIZED_TEXT_AND_COORDS )

	-- Load and display the localized version of the main screen
	displayMainScreen()
	
	-- Load and display the localized version of the billboard
	displayBillboard()
	
	-- Place localized text strings on the "buttons"
	displayButtonText()
	
	-- Load and start localized animation
	processAnimation()
	
	-- Show the screen
	screen:show()
	
-- *********************************************************

