
-- Constants
-- Define the percentage of screen real estate used by the various regions
headerPercent = 0.12		-- percentage of screen height the header region uses
footerPercent = headerPercent

-- Using percentages above, calculate various coordinates
headerHeight = (math.floor( screen.height * headerPercent ) + 1)
footerHeight = (math.floor( screen.height * footerPercent ) + 1)
footerY      = (screen.height - footerHeight)
mainHeight   = (screen.height - headerHeight - footerHeight)
mainCenterY  = (headerHeight + (mainHeight / 2))
mainY        = headerHeight

-- Placement of menu
menuTitleX      = 70
menuTitleY      = (headerHeight + 20)
maxMenuItems    = 8  -- Any more than this will be ignored; if necessary, add scrolling capability
menuXorg        = 40
menuYorg        = (menuTitleY + 70)
menuWidth       = 700
menuHeight      = 80
menuBorderWidth = 10

-- Placement of menu selection controls
-- Note: Adjusting the prevMenuX and prevMenuY settings will shift the entire group.
prevMenuX       = 100
prevMenuY       = (footerY + 15)
prevMenuLabelX  = 180
prevMenuLabelY  = (prevMenuY + 32)
prevMenuItemX   = (prevMenuX + 185)
prevMenuItemY   = (prevMenuY - 130)
nextMenuItemX   = prevMenuItemX
nextMenuItemY   = (prevMenuY + 210)
selectMenuItemX = (prevMenuX + 150)
selectMenuItemY = (prevMenuY - 10)

-- Placement of MovieInfo screen contents
-- Note: X and Y coordinates are relative to the movieInfo group's position
posterWidth     = 400
posterHeight    = 600
posterX         = 100
posterY         = 100
movieTitleX     = 600
movieTitleY     = 100
movieDescX      = movieTitleX
movieDescY      = (movieTitleY + 100)
movieDescWidth  = 1200
movieDescHeight = 400

-- Colors used in each region
headerColor             = "rgba(46,57,131,255)"
headerTitleColor        = "rgba(255,165,64,255)"
footerColor             = headerColor
mainColor               = "rgba(7,114,161,255)"
menuItemRegionUnfocused = "rgba(55,219,121,255)"
menuItemRegionFocused   = "rgba(0,119,48,255)"
menuItemLabelUnfocused  = menuItemRegionFocused
menuItemLabelFocused    = menuItemRegionUnfocused
menuTitleColor          = "rgba(255,135,0,255)"
menuBorderColor         = "rgba(0,79,32,255)"
prevMenuLabelColor      = menuTitleColor
movieTitleColor         = menuItemRegionUnfocused 
movieDescColor          = movieTitleColor


-- Fonts used
headerTitleFont   = "DejaVu Sans Bold 60px"
menuTitleFont     = "DejaVu Sans Bold 40px"
menuLabelFont     = "DejaVu Sans Bold 35px"
movieTitleFont    = "DejaVu Sans Bold 40px"
movieDescFont     = "DejaVu Serif Bold 35px"
prevMenuLabelFont = "DejaVu Sans Bold 30px"

-- Global variables that will be initialized later
prevMenuGraphic = nil		-- reference to Image object for previousMenu graphic
bckImage        = nil       -- background image for main screen region

menuTitle    = nil			-- string containing title of current menu
menuItems    = {}			-- table of menuItems in the current menu

currMenu     = nil			-- reference to current Menu record
currMenuItem = nil			-- index of current menuItem in current Menu

currMenuItemGroup = nil		-- group for current menuItem plaque
currMenuItemLabel = nil		-- label of current menuItem

movieInfoScr = nil			-- group containing MovieInfo screen structure
moviePoster  = nil			-- movie poster image
movieTitle   = nil			-- movie title string
movieDesc    = nil			-- movie description string

-- *************************************
-- Tables of handlers for keystroke input

-- Menu screen keystroke handler
keyInputHandlerMenu = {
		UP   = function() moveToPrevMenuItem() end,
		DOWN = function() moveToNextMenuItem() end,
		LEFT = function() moveToPrevMenu()     end,
		OK   = function() selectMenuItem()     end,
}

-- MovieInfo screen keystroke handler
keyInputHandlerMovie = {
		LEFT  = "OK",
		OK    = function() selectControl() end,
}

-- *************************************
function
displayMainScreen()

	--Define a header region, extending the entire screen's actual width
	local headerRect = Rectangle( { name = "headerRegion",
	                                size = { screen.width, headerHeight },
	                                position = { 0, 0 },
	                                color = headerColor,
	} )
	screen:add( headerRect )

	-- Place app's title in header region
	local headerTitle = Text( { text = "TrickPlay Multi-Level Menus Demo",
	                            font = headerTitleFont,
	                            color = headerTitleColor,
	                            position = { 370, 30 },
	} )
	screen:add( headerTitle )
	
	-- Define a footer region
	local footerRect = Rectangle( { name = "footerRegion",
	                                size = { screen.width, footerHeight },
	                                position = { 0, footerY },
	                                color = footerColor,
	} )
	screen:add( footerRect )

	-- Define remainder of screen as background region
	-- Note: This variable must be global because it will be cloned for the MovieInfo screen.
	bckImage = Image( { name = "bckgndTexture",
	                    src  = "images/PaperTinted.png",
	                    position = { 0, mainY },
	                    size = { screen.width, mainHeight },
	                    tile = { true, true },
	} )
	if( bckImage.loaded )then
		screen:add( bckImage )
	end
	
	-- Display the TrickPlay 3D Logo in the main region
	local tpLogo = Image( { name = "TrickPlayLogo",
	                        src = "images/Logo.png",
	                        position = { 850, mainY + 125 },
	                        --opacity = 200,
	} )
	if( tpLogo.loaded )then
		screen:add( tpLogo )
	end
	
	-- Show the selection controls. These are shown only in child menus and in
	-- movieInfo screens, not top-level menu screens.
	-- Note: The prevMenuGraphic and prevMenuLabel must be global; when a menu
	-- selection is made, the graphic and label are appropriately hidden or shown.
	prevMenuGraphic = Image( { src = "images/prevMenu.png",
	                           position = { prevMenuX, prevMenuY },
	} )
	if( prevMenuGraphic.loaded )then
		screen:add( prevMenuGraphic )
	end
	
	prevMenuLabel = Text( { text = "Previous Menu",
	                        position = { prevMenuLabelX, prevMenuLabelY },
	                        font = prevMenuLabelFont,
	                        color = prevMenuLabelColor,
	} )
	screen:add( prevMenuLabel )

end  -- displayMainScreen()

-- *************************************
function
defineMenuLayout()

	-- Build the basic, but empty menu display layout. To display a particular 
	-- menu, simply fill its data into this layout.
	
	-- The global menuTitle will store the menu's title
	menuTitle = Text( { font     = menuTitleFont,
	                    color    = menuTitleColor,
	                    position = { menuTitleX, menuTitleY },
	} )
	screen:add( menuTitle )
	
	-- Build the menu items structure
	-- This structure will be filled dynamically with the current menu's info
	-- stored in the global menuItems[] array of tables.
	
	-- Create a border for the menu region
	local menuBorder = Canvas( menuWidth  + (menuBorderWidth * 2),
	                           (menuHeight * maxMenuItems) + (menuBorderWidth * 2) )
	menuBorder:set_source_color( menuBorderColor )
	menuBorder.line_width = menuBorderWidth * 2
	menuBorder.line_join = "ROUND"
	menuBorder:rectangle( 0, 0, menuBorder.width, menuBorder.height )
	menuBorder:stroke()
	local menuBorderI = menuBorder:Image()  -- convert to Image for display
	menuBorderI.name = "menuBorder"
	menuBorderI.position = { menuXorg - menuBorderWidth, menuYorg - menuBorderWidth }
	screen:add( menuBorderI )
	
	-- Create the menu background texture. Each menuitem will be displayed on this background.
	local menuRegionBckgnd = Image( { name = "menuRegionTexture",
	                                  src  = "images/PaperTintedGreen.png",
	                                  size = {menuWidth, menuHeight * maxMenuItems },
	                                  position = { menuXorg, menuYorg },
	                                  tile = { true, true },
	} )
	if( menuRegionBckgnd.loaded )then
		screen:add( menuRegionBckgnd )
	end
	
	for menuNum = 1, maxMenuItems do
		local menuLabel = Text( { font     = menuLabelFont,
		                          position = { menuXorg + 25,
		                                       menuYorg + (menuHeight * (menuNum - 1)) + 17 },
		                          color    = menuItemLabelUnfocused,
		} )
		
		-- Add label to global menuItems[]
		-- menuItems[ #menuItems + 1 ] = { region = menuRegion, label = menuLabel }
		menuItems[ #menuItems + 1 ] = { label = menuLabel }
		
		-- Add region and label to screen
		-- screen:add( menuRegion )
		screen:add( menuLabel )
	end
	
	-- Build the current menuItem "plaque." This plaque will move from menuItem
	-- to menuItem using simple animation. It will always cover the current
	-- menuItem.
	currMenuItemGroup = Group( { name     = "currMenuItemPlaque",
	                             size     = { menuWidth, menuHeight },
	                             position = { menuXorg, menuYorg },
	} )
	screen:add( currMenuItemGroup )
	                             
	local currMenuItemRegion = Rectangle( { size     = { menuWidth, menuHeight },
	                                        position = { 0, 0 },  -- relative to group
	                                        color    = menuItemRegionFocused,
	} )
	currMenuItemGroup:add( currMenuItemRegion )
	
	currMenuItemLabel = Text( { font     = menuLabelFont,
	                            position = { currMenuItemRegion.position[ 1 ] + 25,
	                                         currMenuItemRegion.position[ 2 ] + 17 },
	                            color    = menuItemLabelFocused,
	} )
	currMenuItemGroup:add( currMenuItemLabel )

end  -- defineMenuLayout()

-- *************************************
function
showMenu( menu, menuItem )

	-- Does this menu have a parent?
	if( menu.parentMenu ~= nil )then
		-- Yes, display the prevMenu graphic
		prevMenuGraphic:show()
		prevMenuLabel:show()
	else
		-- No, this is the primary menu
		prevMenuGraphic:hide()
		prevMenuLabel:hide()
	end

	-- Populate the global menu title
	menuTitle.text = menu.title

	-- Reset the global menuItems[]
	for menuNum, menuItem in ipairs( menuItems ) do
		menuItem.label.text = ""
	end
	
	-- Populate each menuItem with its new label
	for menuNum, menuItem in ipairs( menu.menuItems ) do
		-- Only process maxMenuItems; any items beyond that number are ignored
		if( menuNum > maxMenuItems )then
			do break end
		end
		
		-- Populate global menuItems[] with item's label
		menuItems[ menuNum ].label.text = menuItem.menuText
	end

	-- Set the focus to the specified menuitem
	-- Set plaque's label to current menuItem label
	currMenuItemLabel.text = menuItems[ menuItem ].label.text
	
	-- Position the plaque over the current menuItem
	currMenuItemGroup.position = { menuXorg,
	                               menuYorg + (menuHeight * (menuItem - 1)) }

end  -- showMenu()

-- *************************************
function
updateDisplayFocus( newFocusOffset )

	-- Move the current menuItem plaque to the new current menuItem
	-- Use a simple animation that moves from the current position to the new position
	
	-- Update the global currMenuItem variable
	currMenuItem = currMenuItem + newFocusOffset

	-- Make plaque's label transparent
	currMenuItemLabel.opacity = 0
	
	-- Update the plaque's label
	currMenuItemLabel.text = menuItems[ currMenuItem ].label.text

	-- Calculate the new position
	newPos = { menuXorg, menuYorg + (menuHeight * (currMenuItem - 1)) }
	
	-- Animate the plaque group to the new position, gradually revealing new label
	currMenuItemGroup:animate( { duration = 200,
	                             position = newPos,
	} )
	currMenuItemLabel:animate( { duration = 200,
	                             opacity  = 255,
	} )

end  -- updateDisplayFocus()

-- *************************************
function
moveToPrevMenuItem()

	-- If already at the first menuItem, do nothing
	if( currMenuItem == 1 )then
		return
	end

	-- Update the display focus and adjust the global current menuItem variable
	updateDisplayFocus( -1 )
	
end  -- moveToPrevMenuItem()

-- *************************************
function
moveToNextMenuItem()

	-- If already at the last menuItem, do nothing
	if( currMenuItem == #currMenu.menuItems )then
		return
	end
	
	-- Update the display focus and adjust the global current menuItem variable
	updateDisplayFocus( 1 )
	
end  -- moveToNextMenuItem()

-- *************************************
function
moveToPrevMenu()

	-- If the current menu doesn't have a parent menu, do nothing
	if( currMenu.parentMenu == nil )then
		return
	end
	
	-- Reset current menu and menuItem
	currMenu     = currMenu.parentMenu
	currMenuItem = 1
	
	-- Display new current menu
	showMenu( currMenu, currMenuItem )
	
end  -- moveToPrevMenu()

-- *************************************
function
defineMovieInfoLayout()

	-- Cover and hide the current contents in the screen's main region
	-- Create a group object to hold the movie-info screen's contents. When the
	-- MovieInfo screen is shown, this group can be made visible. When the screen
	-- is exited, this group can be hidden, restoring the previous menu screen.
	-- Note: This group variable is global.
	movieInfoScr = Group( { name = "movieInfoScreen",
	                        size = { screen.width, mainHeight },
	                        position = { 0, mainY },
	                        is_visible = false,
	} )
	screen:add( movieInfoScr )

	-- Clone the background image. This will temporarily cover the menu screen
	-- and be used as a background for the movie information.
	local movieBckImage = Clone( { source = bckImage } )
	movieInfoScr:add( movieBckImage )

	-- Movie poster image
	moviePoster = Image( { name = "moviePoster",
	                       size = { posterWidth, posterHeight },
	                       position = { posterX, posterY },
	} )
	movieInfoScr:add( moviePoster )
	
	-- Movie title string
	movieTitle = Text( { name = "movieTitle",
	                     position = { movieTitleX, movieTitleY },
	                     color = movieTitleColor,
	                     font = movieTitleFont,
	                     text = "",
	} )
	movieInfoScr:add( movieTitle )
	
	-- Movie description string
	movieDesc = Text( { name = "movieDescription",
	                    position = { movieDescX, movieDescY },
	                    color = movieDescColor,
	                    font = movieDescFont,
	                    size = { movieDescWidth, movieDescHeight },  -- setting this enables line wrapping
	                    wrap_mode = "WORD",
	                    text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu mattis sapien. Sed eros mi, convallis et rhoncus non, faucibus sit amet ligula. Aliquam nec mauris non leo vestibulum venenatis eu vitae turpis.\n\nDonec bibendum volutpat orci nec bibendum. Integer dui ante, fermentum non pretium ut, mattis sed nisi. Integer aliquet consequat erat tempus egestas. Nullam adipiscing ligula vitae nibh ullamcorper semper.",
	} )
	movieInfoScr:add( movieDesc )
	
	-- Initially, the movieInfo group and all its children should be hidden
	movieInfoScr:hide_all()

end  -- defineMovieInfoLayout()

-- *************************************
function
scalePoster( poster, maxWidth, maxHeight )

	-- If necessary, scale the poster image (while maintaining its aspect ratio)
	-- so it fits within the specified width/height.
	-- Note: Only scales down, never up.
	
	local scaleWidth  = 1.0
	local scaleHeight = 1.0
	local scaleFactor = 1.0
	
	-- Does the image's width need to be scaled?
	if( poster.base_size[ 1 ] > maxWidth )then
		-- Yes, calculate scaling factor
		scaleWidth = maxWidth / poster.base_size[ 1 ]
	end
	
	-- Does the image's height need to be scaled?
	if( poster.base_size[ 2 ] > maxHeight )then
		-- Yes, calculate scaling factor
		scaleHeight = maxHeight / poster.base_size[ 2 ]
	end
	
	-- Do we need to scale?
	if( (scaleWidth < 1.0) or (scaleHeight < 1.0) ) then
		-- Yes, scale by the smallest scaling factor
		scaleFactor = math.min( scaleWidth, scaleHeight )
		
		-- Resize the image
		poster.size = { poster.base_size[ 1 ] * scaleFactor,
		                poster.base_size[ 2 ] * scaleFactor }
	end
	
end  -- scalePoster()

-- *************************************
function
showMovieInfoScreen( movieInfo )

	-- Clear any previous movie info content
	movieTitle.text = ""
	
	-- Under normal conditions, the movieDesc string would also be cleared, but
	-- for this demo app, the string remains constant, so there is no need to update it here.
	-- movieDesc.text = ""
	
	-- Load movie's poster image
	moviePoster.src = movieInfo.image
	if( moviePoster.loaded )then
		scalePoster( moviePoster, posterWidth, posterHeight )
	end
	
	-- Set movie's title
	movieTitle.text = movieInfo.title
	
	-- Show the movieInfo screen/group
	movieInfoScr:show_all()
	
	-- Direct user input to the movieInfo handlers
	screen.on_key_down = KeyHandler( keyInputHandlerMovie )

end  -- showMovieInfoScreen()

-- *************************************
function
selectMenuItem()

	-- Is selection another menu?
	if( currMenu.menuItems[ currMenuItem ].childMenu ~= nil )then
		-- Yes, move to that menu
		currMenu     = currMenu.menuItems[ currMenuItem ].childMenu
		currMenuItem = 1
		
		-- Display new current menu
		showMenu( currMenu, currMenuItem )
	else
		-- Selection is a movie; display its information
		showMovieInfoScreen( currMenu.menuItems[ currMenuItem ].info )
	end

end  -- selectMenuItem()

-- *************************************
function
selectControl()

	-- For now, assume the selected control was "Return to Menu"

	-- Hide the MovieInfo screen and restore the previous menu
	movieInfoScr:hide_all()
	
	-- Direct user input back to the menu handler
	screen.on_key_down = KeyHandler( keyInputHandlerMenu )
	
end  -- selectControl()

-- *************************************
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

-- **************************************

-- Initialize screen (color regions, title, selection controls, etc.)
displayMainScreen()

-- Load the program's menus
appMenus = dofile( "menus.lua" )

-- Build the menu and movieInfo display layouts
defineMenuLayout()
defineMovieInfoLayout()

-- Initialize current menu
currMenu     = appMenus.primaryMenu
currMenuItem = 1

-- Display the menu
showMenu( currMenu, currMenuItem )

-- Hook the screen's menu keyboard input to our handler
screen.on_key_down = KeyHandler( keyInputHandlerMenu )

-- Show the screen
screen:show()

